// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TokenInfo {

 String get mintAddress; String get symbol; String get name; int get decimals; bool get isNative; bool get isVisible; TokenProgramKind get tokenProgramType;
/// Create a copy of TokenInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenInfoCopyWith<TokenInfo> get copyWith => _$TokenInfoCopyWithImpl<TokenInfo>(this as TokenInfo, _$identity);

  /// Serializes this TokenInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenInfo&&(identical(other.mintAddress, mintAddress) || other.mintAddress == mintAddress)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.name, name) || other.name == name)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.isNative, isNative) || other.isNative == isNative)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.tokenProgramType, tokenProgramType) || other.tokenProgramType == tokenProgramType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mintAddress,symbol,name,decimals,isNative,isVisible,tokenProgramType);

@override
String toString() {
  return 'TokenInfo(mintAddress: $mintAddress, symbol: $symbol, name: $name, decimals: $decimals, isNative: $isNative, isVisible: $isVisible, tokenProgramType: $tokenProgramType)';
}


}

/// @nodoc
abstract mixin class $TokenInfoCopyWith<$Res>  {
  factory $TokenInfoCopyWith(TokenInfo value, $Res Function(TokenInfo) _then) = _$TokenInfoCopyWithImpl;
@useResult
$Res call({
 String mintAddress, String symbol, String name, int decimals, bool isNative, bool isVisible, TokenProgramKind tokenProgramType
});




}
/// @nodoc
class _$TokenInfoCopyWithImpl<$Res>
    implements $TokenInfoCopyWith<$Res> {
  _$TokenInfoCopyWithImpl(this._self, this._then);

  final TokenInfo _self;
  final $Res Function(TokenInfo) _then;

/// Create a copy of TokenInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mintAddress = null,Object? symbol = null,Object? name = null,Object? decimals = null,Object? isNative = null,Object? isVisible = null,Object? tokenProgramType = null,}) {
  return _then(_self.copyWith(
mintAddress: null == mintAddress ? _self.mintAddress : mintAddress // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,isNative: null == isNative ? _self.isNative : isNative // ignore: cast_nullable_to_non_nullable
as bool,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,tokenProgramType: null == tokenProgramType ? _self.tokenProgramType : tokenProgramType // ignore: cast_nullable_to_non_nullable
as TokenProgramKind,
  ));
}

}


/// Adds pattern-matching-related methods to [TokenInfo].
extension TokenInfoPatterns on TokenInfo {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TokenInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TokenInfo() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TokenInfo value)  $default,){
final _that = this;
switch (_that) {
case _TokenInfo():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TokenInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TokenInfo() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mintAddress,  String symbol,  String name,  int decimals,  bool isNative,  bool isVisible,  TokenProgramKind tokenProgramType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TokenInfo() when $default != null:
return $default(_that.mintAddress,_that.symbol,_that.name,_that.decimals,_that.isNative,_that.isVisible,_that.tokenProgramType);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mintAddress,  String symbol,  String name,  int decimals,  bool isNative,  bool isVisible,  TokenProgramKind tokenProgramType)  $default,) {final _that = this;
switch (_that) {
case _TokenInfo():
return $default(_that.mintAddress,_that.symbol,_that.name,_that.decimals,_that.isNative,_that.isVisible,_that.tokenProgramType);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mintAddress,  String symbol,  String name,  int decimals,  bool isNative,  bool isVisible,  TokenProgramKind tokenProgramType)?  $default,) {final _that = this;
switch (_that) {
case _TokenInfo() when $default != null:
return $default(_that.mintAddress,_that.symbol,_that.name,_that.decimals,_that.isNative,_that.isVisible,_that.tokenProgramType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TokenInfo implements TokenInfo {
  const _TokenInfo({required this.mintAddress, required this.symbol, required this.name, required this.decimals, required this.isNative, required this.isVisible, this.tokenProgramType = TokenProgramKind.tokenProgram});
  factory _TokenInfo.fromJson(Map<String, dynamic> json) => _$TokenInfoFromJson(json);

@override final  String mintAddress;
@override final  String symbol;
@override final  String name;
@override final  int decimals;
@override final  bool isNative;
@override final  bool isVisible;
@override@JsonKey() final  TokenProgramKind tokenProgramType;

/// Create a copy of TokenInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TokenInfoCopyWith<_TokenInfo> get copyWith => __$TokenInfoCopyWithImpl<_TokenInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TokenInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TokenInfo&&(identical(other.mintAddress, mintAddress) || other.mintAddress == mintAddress)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.name, name) || other.name == name)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.isNative, isNative) || other.isNative == isNative)&&(identical(other.isVisible, isVisible) || other.isVisible == isVisible)&&(identical(other.tokenProgramType, tokenProgramType) || other.tokenProgramType == tokenProgramType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mintAddress,symbol,name,decimals,isNative,isVisible,tokenProgramType);

@override
String toString() {
  return 'TokenInfo(mintAddress: $mintAddress, symbol: $symbol, name: $name, decimals: $decimals, isNative: $isNative, isVisible: $isVisible, tokenProgramType: $tokenProgramType)';
}


}

/// @nodoc
abstract mixin class _$TokenInfoCopyWith<$Res> implements $TokenInfoCopyWith<$Res> {
  factory _$TokenInfoCopyWith(_TokenInfo value, $Res Function(_TokenInfo) _then) = __$TokenInfoCopyWithImpl;
@override @useResult
$Res call({
 String mintAddress, String symbol, String name, int decimals, bool isNative, bool isVisible, TokenProgramKind tokenProgramType
});




}
/// @nodoc
class __$TokenInfoCopyWithImpl<$Res>
    implements _$TokenInfoCopyWith<$Res> {
  __$TokenInfoCopyWithImpl(this._self, this._then);

  final _TokenInfo _self;
  final $Res Function(_TokenInfo) _then;

/// Create a copy of TokenInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mintAddress = null,Object? symbol = null,Object? name = null,Object? decimals = null,Object? isNative = null,Object? isVisible = null,Object? tokenProgramType = null,}) {
  return _then(_TokenInfo(
mintAddress: null == mintAddress ? _self.mintAddress : mintAddress // ignore: cast_nullable_to_non_nullable
as String,symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,decimals: null == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as int,isNative: null == isNative ? _self.isNative : isNative // ignore: cast_nullable_to_non_nullable
as bool,isVisible: null == isVisible ? _self.isVisible : isVisible // ignore: cast_nullable_to_non_nullable
as bool,tokenProgramType: null == tokenProgramType ? _self.tokenProgramType : tokenProgramType // ignore: cast_nullable_to_non_nullable
as TokenProgramKind,
  ));
}


}

// dart format on
