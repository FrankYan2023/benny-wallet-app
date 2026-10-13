// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TokenInfo _$TokenInfoFromJson(Map<String, dynamic> json) => _TokenInfo(
  mintAddress: json['mintAddress'] as String,
  symbol: json['symbol'] as String,
  name: json['name'] as String,
  decimals: (json['decimals'] as num).toInt(),
  isNative: json['isNative'] as bool,
  isVisible: json['isVisible'] as bool,
  tokenProgramType:
      $enumDecodeNullable(
        _$TokenProgramKindEnumMap,
        json['tokenProgramType'],
      ) ??
      TokenProgramKind.tokenProgram,
);

Map<String, dynamic> _$TokenInfoToJson(_TokenInfo instance) =>
    <String, dynamic>{
      'mintAddress': instance.mintAddress,
      'symbol': instance.symbol,
      'name': instance.name,
      'decimals': instance.decimals,
      'isNative': instance.isNative,
      'isVisible': instance.isVisible,
      'tokenProgramType': _$TokenProgramKindEnumMap[instance.tokenProgramType]!,
    };

const _$TokenProgramKindEnumMap = {
  TokenProgramKind.tokenProgram: 'tokenProgram',
  TokenProgramKind.token2022Program: 'token2022Program',
};
