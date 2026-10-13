import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_info.freezed.dart';
part 'token_info.g.dart';

enum TokenProgramKind { tokenProgram, token2022Program }

@freezed
abstract class TokenInfo with _$TokenInfo {
  const factory TokenInfo({
    required String mintAddress,
    required String symbol,
    required String name,
    required int decimals,
    required bool isNative,
    required bool isVisible,
    @Default(TokenProgramKind.tokenProgram) TokenProgramKind tokenProgramType,
  }) = _TokenInfo;

  factory TokenInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenInfoFromJson(json);
}
