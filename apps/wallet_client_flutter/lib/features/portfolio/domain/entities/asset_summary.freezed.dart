// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asset_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AssetSummary {

 String get symbol; String get name; String get balance; String get priceUsd; String get valueUsd;
/// Create a copy of AssetSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AssetSummaryCopyWith<AssetSummary> get copyWith => _$AssetSummaryCopyWithImpl<AssetSummary>(this as AssetSummary, _$identity);

  /// Serializes this AssetSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AssetSummary&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.priceUsd, priceUsd) || other.priceUsd == priceUsd)&&(identical(other.valueUsd, valueUsd) || other.valueUsd == valueUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,name,balance,priceUsd,valueUsd);

@override
String toString() {
  return 'AssetSummary(symbol: $symbol, name: $name, balance: $balance, priceUsd: $priceUsd, valueUsd: $valueUsd)';
}


}

/// @nodoc
abstract mixin class $AssetSummaryCopyWith<$Res>  {
  factory $AssetSummaryCopyWith(AssetSummary value, $Res Function(AssetSummary) _then) = _$AssetSummaryCopyWithImpl;
@useResult
$Res call({
 String symbol, String name, String balance, String priceUsd, String valueUsd
});




}
/// @nodoc
class _$AssetSummaryCopyWithImpl<$Res>
    implements $AssetSummaryCopyWith<$Res> {
  _$AssetSummaryCopyWithImpl(this._self, this._then);

  final AssetSummary _self;
  final $Res Function(AssetSummary) _then;

/// Create a copy of AssetSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? name = null,Object? balance = null,Object? priceUsd = null,Object? valueUsd = null,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,priceUsd: null == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as String,valueUsd: null == valueUsd ? _self.valueUsd : valueUsd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AssetSummary].
extension AssetSummaryPatterns on AssetSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AssetSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AssetSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AssetSummary value)  $default,){
final _that = this;
switch (_that) {
case _AssetSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AssetSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AssetSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  String name,  String balance,  String priceUsd,  String valueUsd)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AssetSummary() when $default != null:
return $default(_that.symbol,_that.name,_that.balance,_that.priceUsd,_that.valueUsd);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  String name,  String balance,  String priceUsd,  String valueUsd)  $default,) {final _that = this;
switch (_that) {
case _AssetSummary():
return $default(_that.symbol,_that.name,_that.balance,_that.priceUsd,_that.valueUsd);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  String name,  String balance,  String priceUsd,  String valueUsd)?  $default,) {final _that = this;
switch (_that) {
case _AssetSummary() when $default != null:
return $default(_that.symbol,_that.name,_that.balance,_that.priceUsd,_that.valueUsd);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AssetSummary implements AssetSummary {
  const _AssetSummary({required this.symbol, required this.name, required this.balance, required this.priceUsd, required this.valueUsd});
  factory _AssetSummary.fromJson(Map<String, dynamic> json) => _$AssetSummaryFromJson(json);

@override final  String symbol;
@override final  String name;
@override final  String balance;
@override final  String priceUsd;
@override final  String valueUsd;

/// Create a copy of AssetSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AssetSummaryCopyWith<_AssetSummary> get copyWith => __$AssetSummaryCopyWithImpl<_AssetSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AssetSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AssetSummary&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.name, name) || other.name == name)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.priceUsd, priceUsd) || other.priceUsd == priceUsd)&&(identical(other.valueUsd, valueUsd) || other.valueUsd == valueUsd));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,name,balance,priceUsd,valueUsd);

@override
String toString() {
  return 'AssetSummary(symbol: $symbol, name: $name, balance: $balance, priceUsd: $priceUsd, valueUsd: $valueUsd)';
}


}

/// @nodoc
abstract mixin class _$AssetSummaryCopyWith<$Res> implements $AssetSummaryCopyWith<$Res> {
  factory _$AssetSummaryCopyWith(_AssetSummary value, $Res Function(_AssetSummary) _then) = __$AssetSummaryCopyWithImpl;
@override @useResult
$Res call({
 String symbol, String name, String balance, String priceUsd, String valueUsd
});




}
/// @nodoc
class __$AssetSummaryCopyWithImpl<$Res>
    implements _$AssetSummaryCopyWith<$Res> {
  __$AssetSummaryCopyWithImpl(this._self, this._then);

  final _AssetSummary _self;
  final $Res Function(_AssetSummary) _then;

/// Create a copy of AssetSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? name = null,Object? balance = null,Object? priceUsd = null,Object? valueUsd = null,}) {
  return _then(_AssetSummary(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as String,priceUsd: null == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as String,valueUsd: null == valueUsd ? _self.valueUsd : valueUsd // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
