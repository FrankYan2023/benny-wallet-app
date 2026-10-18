import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cryptography/dart.dart';
import 'package:meta/meta.dart' show visibleForTesting;

import 'bytewords.dart';
import 'cbor.dart';

class UrException implements Exception {
  const UrException(this.message);

  final String message;

  @override
  String toString() => 'UrException: $message';
}

/// A Uniform Resource (BCR-2020-005): a registry type plus a CBOR payload.
class Ur {
  const Ur(this.type, this.cbor);

  final String type;
  final Uint8List cbor;

  static final _typePattern = RegExp(r'^[a-z0-9-]+$');

  static bool isValidType(String type) => _typePattern.hasMatch(type);

  /// Single-part `ur:type/bytewords` string.
  String toSinglePart() => 'ur:$type/${Bytewords.encodeMinimal(cbor)}';

  static Ur parseSinglePart(String text) {
    final lower = text.trim().toLowerCase();
    if (!lower.startsWith('ur:')) {
      throw const UrException('Not a UR.');
    }
    final parts = lower.substring(3).split('/');
    if (parts.length != 2 || !isValidType(parts[0])) {
      throw const UrException('Not a single-part UR.');
    }
    return Ur(parts[0], Bytewords.decodeMinimal(parts[1]));
  }
}

/// Xoshiro256** seeded from SHA-256, exactly as the BC-UR reference
/// implementation, so fragments interoperate with other UR decoders.
class _Xoshiro256 {
  _Xoshiro256(List<int> seed) {
    final digest = const DartSha256().hashSync(seed).bytes;
    for (var i = 0; i < 4; i++) {
      var v = BigInt.zero;
      for (var j = 0; j < 8; j++) {
        v = (v << 8) | BigInt.from(digest[i * 8 + j]);
      }
      _s[i] = v;
    }
  }

  static final _mask = (BigInt.one << 64) - BigInt.one;
  static final _two64 = BigInt.one << 64;
  final List<BigInt> _s = List.filled(4, BigInt.zero);

  static BigInt _rotl(BigInt x, int k) => ((x << k) | (x >> (64 - k))) & _mask;

  BigInt next() {
    final s = _s;
    final result =
        (_rotl((s[1] * BigInt.from(5)) & _mask, 7) * BigInt.from(9)) & _mask;
    final t = (s[1] << 17) & _mask;
    s[2] ^= s[0];
    s[3] ^= s[1];
    s[1] ^= s[2];
    s[0] ^= s[3];
    s[2] ^= t;
    s[3] = _rotl(s[3], 45);
    return result;
  }

  double nextDouble() => next() / _two64;

  int nextInt(int low, int high) =>
      (nextDouble() * (high - low + 1)).floor() + low;
}

class _RandomSampler {
  _RandomSampler(List<double> weights) {
    final n = weights.length;
    final sum = weights.fold<double>(0, (a, b) => a + b);
    final p = [for (final w in weights) w * n / sum];
    final small = <int>[];
    final large = <int>[];
    for (var i = n - 1; i >= 0; i--) {
      if (p[i] < 1) {
        small.add(i);
      } else {
        large.add(i);
      }
    }
    _probs = List.filled(n, 0);
    _aliases = List.filled(n, 0);
    while (small.isNotEmpty && large.isNotEmpty) {
      final a = small.removeLast();
      final g = large.removeLast();
      _probs[a] = p[a];
      _aliases[a] = g;
      p[g] += p[a] - 1;
      if (p[g] < 1) {
        small.add(g);
      } else {
        large.add(g);
      }
    }
    while (large.isNotEmpty) {
      _probs[large.removeLast()] = 1;
    }
    while (small.isNotEmpty) {
      _probs[small.removeLast()] = 1;
    }
  }

  late final List<double> _probs;
  late final List<int> _aliases;

  int next(_Xoshiro256 rng) {
    final r1 = rng.nextDouble();
    final r2 = rng.nextDouble();
    final i = (_probs.length * r1).floor();
    return r2 < _probs[i] ? i : _aliases[i];
  }
}

Set<int> _chooseFragments(int seqNum, int seqLen, int checksum) {
  if (seqNum <= seqLen) {
    return {seqNum - 1};
  }
  final seed = Uint8List(8)
    ..buffer.asByteData().setUint32(0, seqNum)
    ..buffer.asByteData().setUint32(4, checksum);
  final rng = _Xoshiro256(seed);
  final sampler = _RandomSampler([for (var i = 1; i <= seqLen; i++) 1 / i]);
  final degree = sampler.next(rng) + 1;
  final remaining = [for (var i = 0; i < seqLen; i++) i];
  final shuffled = <int>[];
  while (remaining.isNotEmpty) {
    shuffled.add(remaining.removeAt(rng.nextInt(0, remaining.length - 1)));
  }
  return shuffled.take(degree).toSet();
}

/// Splits a UR into an endless stream of `ur:type/n-m/...` parts: the
/// first `m` are the plain fragments, after that fountain-mixed parts so a
/// scanner that missed frames still completes.
class UrEncoder {
  UrEncoder(this.ur, {int maxFragmentLength = 200, int minFragmentLength = 10})
    : _message = ur.cbor,
      _checksum = Crc32.of(ur.cbor) {
    final length = _message.length;
    final maxCount = math.max(1, length ~/ minFragmentLength);
    var fragmentLength = length;
    for (var count = 1; count <= maxCount; count++) {
      fragmentLength = (length / count).ceil();
      if (fragmentLength <= maxFragmentLength) {
        break;
      }
    }
    _fragmentLength = math.max(1, fragmentLength);
    final count = (length / _fragmentLength).ceil();
    final padded = Uint8List(count * _fragmentLength)..setAll(0, _message);
    _fragments = [
      for (var i = 0; i < count; i++)
        Uint8List.sublistView(
          padded,
          i * _fragmentLength,
          (i + 1) * _fragmentLength,
        ),
    ];
  }

  final Ur ur;
  final Uint8List _message;
  final int _checksum;
  late final int _fragmentLength;
  late final List<Uint8List> _fragments;
  int _seqNum = 0;

  bool get isSinglePart => _fragments.length == 1;

  int get fragmentCount => _fragments.length;

  String nextPart() {
    if (isSinglePart) {
      return ur.toSinglePart();
    }
    _seqNum++;
    final indexes = _chooseFragments(_seqNum, _fragments.length, _checksum);
    final mixed = Uint8List(_fragmentLength);
    for (final index in indexes) {
      final fragment = _fragments[index];
      for (var i = 0; i < mixed.length; i++) {
        mixed[i] ^= fragment[i];
      }
    }
    final part = Cbor.encode([
      _seqNum,
      _fragments.length,
      _message.length,
      _checksum,
      mixed,
    ]);
    return 'ur:${ur.type}/$_seqNum-${_fragments.length}/'
        '${Bytewords.encodeMinimal(part)}';
  }
}

/// Collects scanned parts (single or multi) until the UR is complete.
///
/// Every frame is attacker-controlled: part headers are checked against
/// each other and against hard caps before any work that scales with
/// them, so one QR code cannot make the decoder allocate, spin or wait
/// forever.
class UrDecoder {
  UrDecoder({this.maxMessageLength = 64 * 1024, this.maxFragmentCount = 1024});

  /// A sign request is at most 4 KiB of data plus hints and lookup
  /// tables; 64 KiB leaves ample margin.
  final int maxMessageLength;

  /// Fountain frames cost O(seqLen) to place, so the count is capped.
  /// Our encoder needs ~330 fragments for [maxMessageLength] at 200 bytes.
  final int maxFragmentCount;

  static const _maxUint32 = 0xffffffff;
  static final _seqPattern = RegExp(r'^([1-9][0-9]{0,9})-([1-9][0-9]{0,9})$');

  String? _type;
  int? _seqLen;
  int? _messageLength;
  int? _checksum;
  int? _fragmentLength;
  final Map<int, Uint8List> _simple = {};
  final List<(Set<int>, Uint8List)> _mixed = [];
  final Set<int> _seen = {};
  Ur? _result;

  Ur? get result => _result;

  bool get isComplete => _result != null;

  String? get type => _type;

  /// 0..1, for a progress bar.
  double get progress {
    if (_result != null) {
      return 1;
    }
    final total = _seqLen;
    if (total == null || total == 0) {
      return 0;
    }
    return _simple.length / total;
  }

  /// Returns true when the part was accepted (new and consistent).
  bool receive(String text) {
    if (_result != null) {
      return false;
    }
    final lower = text.trim().toLowerCase();
    if (!lower.startsWith('ur:')) {
      throw const UrException('Not a UR.');
    }
    final segments = lower.substring(3).split('/');
    if (segments.length == 2) {
      final ur = Ur.parseSinglePart(lower);
      _checkType(ur.type);
      _result = ur;
      return true;
    }
    if (segments.length != 3 || !Ur.isValidType(segments[0])) {
      throw const UrException('Malformed UR part.');
    }
    final header = _seqPattern.firstMatch(segments[1]);
    if (header == null) {
      throw const UrException('Malformed UR part header.');
    }
    _checkType(segments[0]);
    final decoded = Cbor.decode(Bytewords.decodeMinimal(segments[2]));
    if (decoded is! List ||
        decoded.length != 5 ||
        decoded[0] is! int ||
        decoded[1] is! int ||
        decoded[2] is! int ||
        decoded[3] is! int ||
        decoded[4] is! Uint8List) {
      throw const UrException('Malformed UR part body.');
    }
    final seqNum = decoded[0] as int;
    final seqLen = decoded[1] as int;
    final messageLength = decoded[2] as int;
    final checksum = decoded[3] as int;
    final data = decoded[4] as Uint8List;
    if (seqNum < 1 ||
        seqNum > _maxUint32 ||
        seqLen < 1 ||
        seqLen > maxFragmentCount ||
        messageLength < 1 ||
        messageLength > maxMessageLength ||
        checksum < 0 ||
        checksum > _maxUint32 ||
        data.isEmpty ||
        data.length > messageLength ||
        seqLen != (messageLength + data.length - 1) ~/ data.length) {
      throw const UrException('UR part out of range.');
    }
    if (int.parse(header.group(1)!) != seqNum ||
        int.parse(header.group(2)!) != seqLen) {
      throw const UrException('UR part header does not match its body.');
    }
    if (_seqLen == null) {
      _seqLen = seqLen;
      _messageLength = messageLength;
      _checksum = checksum;
      _fragmentLength = data.length;
    } else if (_seqLen != seqLen ||
        _messageLength != messageLength ||
        _checksum != checksum ||
        _fragmentLength != data.length) {
      throw const UrException('UR part belongs to another message.');
    }
    if (!_seen.add(seqNum)) {
      return false;
    }
    final indexes = _chooseFragments(seqNum, seqLen, checksum);
    _addPart(indexes, Uint8List.fromList(data));
    _tryFinish();
    return true;
  }

  void _checkType(String type) {
    if (_type != null && _type != type) {
      throw const UrException('UR type changed while scanning.');
    }
    _type = type;
  }

  void _addPart(Set<int> indexes, Uint8List data) {
    final queue = <(Set<int>, Uint8List)>[(indexes, data)];
    while (queue.isNotEmpty) {
      var (parts, bytes) = queue.removeLast();
      // Reduce by every fragment we already know.
      for (final index in parts.toList()) {
        final known = _simple[index];
        if (known != null && parts.length > 1) {
          bytes = _xor(bytes, known);
          parts = parts.difference({index});
        }
      }
      if (parts.length == 1) {
        final index = parts.single;
        if (_simple.containsKey(index)) {
          continue;
        }
        _simple[index] = bytes;
        // A new simple fragment may reduce the waiting mixed parts.
        final waiting = List.of(_mixed);
        _mixed.clear();
        for (final entry in waiting) {
          if (entry.$1.contains(index)) {
            queue.add((entry.$1.difference({index}), _xor(entry.$2, bytes)));
          } else {
            _mixed.add(entry);
          }
        }
      } else if (parts.isNotEmpty) {
        _mixed.add((parts, bytes));
        // Bounded memory: drop the oldest when far more mixed parts wait
        // than a real scan ever needs.
        if (_mixed.length > _seqLen! * 4 + 16) {
          _mixed.removeAt(0);
        }
      }
    }
  }

  void _tryFinish() {
    final seqLen = _seqLen!;
    if (_simple.length != seqLen) {
      return;
    }
    final builder = BytesBuilder(copy: false);
    for (var i = 0; i < seqLen; i++) {
      builder.add(_simple[i]!);
    }
    final message = Uint8List.sublistView(
      builder.toBytes(),
      0,
      _messageLength!,
    );
    if (Crc32.of(message) != _checksum) {
      throw const UrException('UR checksum mismatch.');
    }
    _result = Ur(_type!, Uint8List.fromList(message));
  }

  static Uint8List _xor(Uint8List a, Uint8List b) {
    final out = Uint8List(a.length);
    for (var i = 0; i < a.length; i++) {
      out[i] = a[i] ^ b[i];
    }
    return out;
  }
}

/// Exposed for the reference-vector tests only.
@visibleForTesting
List<int> debugXoshiroSequence(List<int> seed, int count, int modulo) {
  final rng = _Xoshiro256(seed);
  return [
    for (var i = 0; i < count; i++) (rng.next() % BigInt.from(modulo)).toInt(),
  ];
}

@visibleForTesting
Set<int> debugChooseFragments(int seqNum, int seqLen, int checksum) =>
    _chooseFragments(seqNum, seqLen, checksum);
