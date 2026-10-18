import 'dart:typed_data';

/// CRC-32 (IEEE 802.3, the zlib polynomial) as used by BC-UR.
abstract final class Crc32 {
  static final Uint32List _table = _buildTable();

  static Uint32List _buildTable() {
    final table = Uint32List(256);
    for (var n = 0; n < 256; n++) {
      var c = n;
      for (var k = 0; k < 8; k++) {
        c = (c & 1) != 0 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
      }
      table[n] = c;
    }
    return table;
  }

  static int of(List<int> bytes) {
    var crc = 0xffffffff;
    for (final byte in bytes) {
      crc = _table[(crc ^ byte) & 0xff] ^ (crc >>> 8);
    }
    return (crc ^ 0xffffffff) & 0xffffffff;
  }
}

class BytewordsException implements Exception {
  const BytewordsException(this.message);

  final String message;

  @override
  String toString() => 'BytewordsException: $message';
}

/// BC-UR Bytewords, "minimal" style (first and last letter of each word),
/// with the CRC-32 checksum appended. This is the body of a `ur:` string.
abstract final class Bytewords {
  static const _words =
      'ableacidalsoapexaquaarchatomauntawayaxisbackbaldbarnbeltbetabias'
      'bluebodybragbrewbulbbuzzcalmcashcatschefcityclawcodecolacookcost'
      'cruxcurlcuspcyandarkdatadaysdelidicedietdoordowndrawdropdrumdull'
      'dutyeacheasyechoedgeepicevenexamexiteyesfactfairfernfigsfilmfish'
      'fizzflapflewfluxfoxyfreefrogfuelfundgalagamegeargemsgiftgirlglow'
      'goodgraygrimgurugushgyrohalfhanghardhawkheathelphighhillholyhope'
      'hornhutsicedideaidleinchinkyintoirisironitemjadejazzjoinjoltjowl'
      'judojugsjumpjunkjurykeepkenokeptkeyskickkilnkingkitekiwiknoblamb'
      'lavalazyleaflegsliarlimplionlistlogoloudloveluaulucklungmainmany'
      'mathmazememomenumeowmildmintmissmonknailnavyneednewsnextnoonnote'
      'numbobeyoboeomitonyxopenovalowlspaidpartpeckplaypluspoempoolpose'
      'puffpumapurrquadquizraceramprealredorichroadrockroofrubyruinruns'
      'rustsafesagascarsetssilkskewslotsoapsolosongstubsurfswantacotask'
      'taxitenttiedtimetinytoiltombtoystriptunatwinuglyundouniturgeuser'
      'vastveryvetovialvibeviewvisavoidvowswallwandwarmwaspwavewaxywebs'
      'whatwhenwhizwolfworkyankyawnyellyogayurtzapszerozestzinczonezoom';

  static final List<String> _minimal = List.generate(
    256,
    (i) => '${_words[i * 4]}${_words[i * 4 + 3]}',
    growable: false,
  );

  static final Map<String, int> _minimalIndex = {
    for (var i = 0; i < 256; i++) _minimal[i]: i,
  };

  static String encodeMinimal(List<int> data) {
    final checksum = Crc32.of(data);
    final buffer = StringBuffer();
    for (final byte in data) {
      buffer.write(_minimal[byte]);
    }
    for (var shift = 24; shift >= 0; shift -= 8) {
      buffer.write(_minimal[(checksum >> shift) & 0xff]);
    }
    return buffer.toString();
  }

  static Uint8List decodeMinimal(String text) {
    final lower = text.toLowerCase();
    if (lower.length.isOdd || lower.length < 10) {
      throw const BytewordsException('Invalid bytewords length.');
    }
    final bytes = Uint8List(lower.length ~/ 2);
    for (var i = 0; i < bytes.length; i++) {
      final value = _minimalIndex[lower.substring(i * 2, i * 2 + 2)];
      if (value == null) {
        throw const BytewordsException('Invalid byteword.');
      }
      bytes[i] = value;
    }
    final body = Uint8List.sublistView(bytes, 0, bytes.length - 4);
    final tail = bytes.sublist(bytes.length - 4);
    final expected = Crc32.of(body);
    final actual = (tail[0] << 24) | (tail[1] << 16) | (tail[2] << 8) | tail[3];
    if (expected != actual) {
      throw const BytewordsException('Bytewords checksum mismatch.');
    }
    return Uint8List.fromList(body);
  }
}
