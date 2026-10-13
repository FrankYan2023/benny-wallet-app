// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'price_quote.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PriceQuote {

 String get symbol; String get priceUsd; String? get change24hPct; DateTime get updatedAt;
/// Create a copy of PriceQuote
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PriceQuoteCopyWith<PriceQuote> get copyWith => _$PriceQuoteCopyWithImpl<PriceQuote>(this as PriceQuote, _$identity);

  /// Serializes this PriceQuote to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PriceQuote&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.priceUsd, priceUsd) || other.priceUsd == priceUsd)&&(identical(other.change24hPct, change24hPct) || other.change24hPct == change24hPct)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,priceUsd,change24hPct,updatedAt);

@override
String toString() {
  return 'PriceQuote(symbol: $symbol, priceUsd: $priceUsd, change24hPct: $change24hPct, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PriceQuoteCopyWith<$Res>  {
  factory $PriceQuoteCopyWith(PriceQuote value, $Res Function(PriceQuote) _then) = _$PriceQuoteCopyWithImpl;
@useResult
$Res call({
 String symbol, String priceUsd, String? change24hPct, DateTime updatedAt
});




}
/// @nodoc
class _$PriceQuoteCopyWithImpl<$Res>
    implements $PriceQuoteCopyWith<$Res> {
  _$PriceQuoteCopyWithImpl(this._self, this._then);

  final PriceQuote _self;
  final $Res Function(PriceQuote) _then;

/// Create a copy of PriceQuote
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? priceUsd = null,Object? change24hPct = freezed,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,priceUsd: null == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as String,change24hPct: freezed == change24hPct ? _self.change24hPct : change24hPct // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [PriceQuote].
extension PriceQuotePatterns on PriceQuote {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PriceQuote value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PriceQuote() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PriceQuote value)  $default,){
final _that = this;
switch (_that) {
case _PriceQuote():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PriceQuote value)?  $default,){
final _that = this;
switch (_that) {
case _PriceQuote() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  String priceUsd,  String? change24hPct,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PriceQuote() when $default != null:
return $default(_that.symbol,_that.priceUsd,_that.change24hPct,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  String priceUsd,  String? change24hPct,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PriceQuote():
return $default(_that.symbol,_that.priceUsd,_that.change24hPct,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  String priceUsd,  String? change24hPct,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PriceQuote() when $default != null:
return $default(_that.symbol,_that.priceUsd,_that.change24hPct,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PriceQuote implements PriceQuote {
  const _PriceQuote({required this.symbol, required this.priceUsd, this.change24hPct, required this.updatedAt});
  factory _PriceQuote.fromJson(Map<String, dynamic> json) => _$PriceQuoteFromJson(json);

@override final  String symbol;
@override final  String priceUsd;
@override final  String? change24hPct;
@override final  DateTime updatedAt;

/// Create a copy of PriceQuote
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PriceQuoteCopyWith<_PriceQuote> get copyWith => __$PriceQuoteCopyWithImpl<_PriceQuote>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PriceQuoteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PriceQuote&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.priceUsd, priceUsd) || other.priceUsd == priceUsd)&&(identical(other.change24hPct, change24hPct) || other.change24hPct == change24hPct)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,symbol,priceUsd,change24hPct,updatedAt);

@override
String toString() {
  return 'PriceQuote(symbol: $symbol, priceUsd: $priceUsd, change24hPct: $change24hPct, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PriceQuoteCopyWith<$Res> implements $PriceQuoteCopyWith<$Res> {
  factory _$PriceQuoteCopyWith(_PriceQuote value, $Res Function(_PriceQuote) _then) = __$PriceQuoteCopyWithImpl;
@override @useResult
$Res call({
 String symbol, String priceUsd, String? change24hPct, DateTime updatedAt
});




}
/// @nodoc
class __$PriceQuoteCopyWithImpl<$Res>
    implements _$PriceQuoteCopyWith<$Res> {
  __$PriceQuoteCopyWithImpl(this._self, this._then);

  final _PriceQuote _self;
  final $Res Function(_PriceQuote) _then;

/// Create a copy of PriceQuote
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? priceUsd = null,Object? change24hPct = freezed,Object? updatedAt = null,}) {
  return _then(_PriceQuote(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,priceUsd: null == priceUsd ? _self.priceUsd : priceUsd // ignore: cast_nullable_to_non_nullable
as String,change24hPct: freezed == change24hPct ? _self.change24hPct : change24hPct // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
