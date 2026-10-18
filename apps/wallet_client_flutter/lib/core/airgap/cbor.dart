import 'dart:convert';
import 'dart:typed_data';

/// A tagged CBOR value (major type 6).
class CborTag {
  const CborTag(this.tag, this.value);

  final int tag;
  final Object? value;

  @override
  bool operator ==(Object other) =>
      other is CborTag && other.tag == tag && cborEquals(other.value, value);

  @override
  int get hashCode => Object.hash(tag, value);
}

class CborException implements Exception {
  const CborException(this.message);

  final String message;

  @override
  String toString() => 'CborException: $message';
}

/// Minimal deterministic CBOR for the air-gap QR protocol.
///
/// Supported values: non-negative and negative `int`, `Uint8List` (byte
/// string), `String`, `List`, `Map` (int or String keys), `bool`, `null`
/// and [CborTag]. Floats, indefinite lengths, non-shortest heads and
/// duplicate map keys are rejected on decode: the signer only accepts what
/// the protocol defines.
abstract final class Cbor {
  static Uint8List encode(Object? value) {
    final builder = BytesBuilder(copy: false);
    _encode(builder, value);
    return builder.toBytes();
  }

  static Object? decode(
    List<int> bytes, {
    int maxDepth = 16,
    int maxItems = 4096,
  }) {
    final reader = _CborReader(
      Uint8List.fromList(bytes),
      maxDepth: maxDepth,
      maxItems: maxItems,
    );
    final value = reader.read(0);
    if (!reader.isDone) {
      throw const CborException('Trailing bytes after CBOR value.');
    }
    return value;
  }

  static void _encode(BytesBuilder out, Object? value) {
    if (value == null) {
      out.addByte(0xf6);
    } else if (value is bool) {
      out.addByte(value ? 0xf5 : 0xf4);
    } else if (value is int) {
      if (value >= 0) {
        _head(out, 0, value);
      } else {
        _head(out, 1, -1 - value);
      }
    } else if (value is Uint8List) {
      _head(out, 2, value.length);
      out.add(value);
    } else if (value is String) {
      final encoded = utf8.encode(value);
      _head(out, 3, encoded.length);
      out.add(encoded);
    } else if (value is List) {
      _head(out, 4, value.length);
      for (final item in value) {
        _encode(out, item);
      }
    } else if (value is Map) {
      // Canonical order: shorter encoded keys first, then bytewise.
      final entries =
          value.entries
              .map((entry) => (key: encode(entry.key), value: entry.value))
              .toList()
            ..sort((a, b) => _compareKeys(a.key, b.key));
      _head(out, 5, entries.length);
      for (final entry in entries) {
        out.add(entry.key);
        _encode(out, entry.value);
      }
    } else if (value is CborTag) {
      _head(out, 6, value.tag);
      _encode(out, value.value);
    } else {
      throw CborException('Unsupported CBOR value: ${value.runtimeType}');
    }
  }

  static int _compareKeys(Uint8List a, Uint8List b) {
    if (a.length != b.length) {
      return a.length - b.length;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return a[i] - b[i];
      }
    }
    return 0;
  }

  static void _head(BytesBuilder out, int major, int value) {
    final type = major << 5;
    if (value < 24) {
      out.addByte(type | value);
    } else if (value <= 0xff) {
      out
        ..addByte(type | 24)
        ..addByte(value);
    } else if (value <= 0xffff) {
      out
        ..addByte(type | 25)
        ..add([(value >> 8) & 0xff, value & 0xff]);
    } else if (value <= 0xffffffff) {
      out
        ..addByte(type | 26)
        ..add([
          (value >> 24) & 0xff,
          (value >> 16) & 0xff,
          (value >> 8) & 0xff,
          value & 0xff,
        ]);
    } else {
      out.addByte(type | 27);
      for (var shift = 56; shift >= 0; shift -= 8) {
        out.addByte((value >> shift) & 0xff);
      }
    }
  }
}

class _CborReader {
  _CborReader(this._bytes, {required this.maxDepth, required this.maxItems});

  final Uint8List _bytes;
  final int maxDepth;
  final int maxItems;
  int _offset = 0;
  int _items = 0;

  bool get isDone => _offset == _bytes.length;

  int _byte() {
    if (_offset >= _bytes.length) {
      throw const CborException('Unexpected end of CBOR data.');
    }
    return _bytes[_offset++];
  }

  int _argument(int info) {
    if (info < 24) {
      return info;
    }
    final length = switch (info) {
      24 => 1,
      25 => 2,
      26 => 4,
      27 => 8,
      _ => throw const CborException('Indefinite or reserved CBOR length.'),
    };
    var value = 0;
    for (var i = 0; i < length; i++) {
      value = (value << 8) | _byte();
    }
    if (value < 0) {
      throw const CborException('CBOR integer out of range.');
    }
    // Deterministic CBOR: the shortest head only, so one value has exactly
    // one encoding.
    final minimum = switch (length) {
      1 => 24,
      2 => 0x100,
      4 => 0x10000,
      _ => 0x100000000,
    };
    if (value < minimum) {
      throw const CborException('Non-shortest CBOR encoding.');
    }
    return value;
  }

  Uint8List _take(int length) {
    if (length > _bytes.length - _offset) {
      throw const CborException('CBOR length exceeds the data.');
    }
    final slice = Uint8List.sublistView(_bytes, _offset, _offset + length);
    _offset += length;
    return Uint8List.fromList(slice);
  }

  void _count(int n) {
    _items += n;
    if (_items > maxItems) {
      throw const CborException('Too many CBOR items.');
    }
  }

  Object? read(int depth) {
    if (depth > maxDepth) {
      throw const CborException('CBOR nesting too deep.');
    }
    _count(1);
    final initial = _byte();
    final major = initial >> 5;
    final info = initial & 0x1f;
    switch (major) {
      case 0:
        return _argument(info);
      case 1:
        return -1 - _argument(info);
      case 2:
        return _take(_argument(info));
      case 3:
        try {
          return utf8.decode(_take(_argument(info)));
        } on FormatException {
          throw const CborException('Invalid UTF-8 in CBOR text.');
        }
      case 4:
        final length = _argument(info);
        _count(length);
        return [for (var i = 0; i < length; i++) read(depth + 1)];
      case 5:
        final length = _argument(info);
        _count(length * 2);
        final map = <Object?, Object?>{};
        for (var i = 0; i < length; i++) {
          final key = read(depth + 1);
          if (key is! int && key is! String) {
            throw const CborException('Unsupported CBOR map key.');
          }
          // Decoders that keep the first or the last duplicate would read
          // different requests from the same bytes.
          if (map.containsKey(key)) {
            throw const CborException('Duplicate CBOR map key.');
          }
          map[key] = read(depth + 1);
        }
        return map;
      case 6:
        final tag = _argument(info);
        return CborTag(tag, read(depth + 1));
      default:
        return switch (info) {
          20 => false,
          21 => true,
          22 => null,
          _ => throw const CborException('Unsupported CBOR simple value.'),
        };
    }
  }
}

bool cborEquals(Object? a, Object? b) {
  if (a is Uint8List && b is Uint8List) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!cborEquals(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) {
      return false;
    }
    for (final key in a.keys) {
      if (!b.containsKey(key) || !cborEquals(a[key], b[key])) {
        return false;
      }
    }
    return true;
  }
  return a == b;
}
