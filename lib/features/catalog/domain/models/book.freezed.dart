// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Book {

 String get id; String get title; String get titleLower; String get author; String get authorLower; String get description; String get coverUrl; double get price; String get categoryId; double get rating; int get stock; bool get isFeatured; DateTime? get createdAt;
/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookCopyWith<Book> get copyWith => _$BookCopyWithImpl<Book>(this as Book, _$identity);

  /// Serializes this Book to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Book&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.titleLower, titleLower) || other.titleLower == titleLower)&&(identical(other.author, author) || other.author == author)&&(identical(other.authorLower, authorLower) || other.authorLower == authorLower)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.price, price) || other.price == price)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,titleLower,author,authorLower,description,coverUrl,price,categoryId,rating,stock,isFeatured,createdAt);

@override
String toString() {
  return 'Book(id: $id, title: $title, titleLower: $titleLower, author: $author, authorLower: $authorLower, description: $description, coverUrl: $coverUrl, price: $price, categoryId: $categoryId, rating: $rating, stock: $stock, isFeatured: $isFeatured, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $BookCopyWith<$Res>  {
  factory $BookCopyWith(Book value, $Res Function(Book) _then) = _$BookCopyWithImpl;
@useResult
$Res call({
 String id, String title, String titleLower, String author, String authorLower, String description, String coverUrl, double price, String categoryId, double rating, int stock, bool isFeatured, DateTime? createdAt
});




}
/// @nodoc
class _$BookCopyWithImpl<$Res>
    implements $BookCopyWith<$Res> {
  _$BookCopyWithImpl(this._self, this._then);

  final Book _self;
  final $Res Function(Book) _then;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? titleLower = null,Object? author = null,Object? authorLower = null,Object? description = null,Object? coverUrl = null,Object? price = null,Object? categoryId = null,Object? rating = null,Object? stock = null,Object? isFeatured = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,titleLower: null == titleLower ? _self.titleLower : titleLower // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,authorLower: null == authorLower ? _self.authorLower : authorLower // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Book].
extension BookPatterns on Book {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Book value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Book() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Book value)  $default,){
final _that = this;
switch (_that) {
case _Book():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Book value)?  $default,){
final _that = this;
switch (_that) {
case _Book() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String titleLower,  String author,  String authorLower,  String description,  String coverUrl,  double price,  String categoryId,  double rating,  int stock,  bool isFeatured,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.titleLower,_that.author,_that.authorLower,_that.description,_that.coverUrl,_that.price,_that.categoryId,_that.rating,_that.stock,_that.isFeatured,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String titleLower,  String author,  String authorLower,  String description,  String coverUrl,  double price,  String categoryId,  double rating,  int stock,  bool isFeatured,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _Book():
return $default(_that.id,_that.title,_that.titleLower,_that.author,_that.authorLower,_that.description,_that.coverUrl,_that.price,_that.categoryId,_that.rating,_that.stock,_that.isFeatured,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String titleLower,  String author,  String authorLower,  String description,  String coverUrl,  double price,  String categoryId,  double rating,  int stock,  bool isFeatured,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Book() when $default != null:
return $default(_that.id,_that.title,_that.titleLower,_that.author,_that.authorLower,_that.description,_that.coverUrl,_that.price,_that.categoryId,_that.rating,_that.stock,_that.isFeatured,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Book implements Book {
  const _Book({this.id = '', required this.title, required this.titleLower, required this.author, required this.authorLower, this.description = '', this.coverUrl = '', required this.price, required this.categoryId, this.rating = 0, this.stock = 0, this.isFeatured = false, this.createdAt});
  factory _Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);

@override@JsonKey() final  String id;
@override final  String title;
@override final  String titleLower;
@override final  String author;
@override final  String authorLower;
@override@JsonKey() final  String description;
@override@JsonKey() final  String coverUrl;
@override final  double price;
@override final  String categoryId;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int stock;
@override@JsonKey() final  bool isFeatured;
@override final  DateTime? createdAt;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookCopyWith<_Book> get copyWith => __$BookCopyWithImpl<_Book>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Book&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.titleLower, titleLower) || other.titleLower == titleLower)&&(identical(other.author, author) || other.author == author)&&(identical(other.authorLower, authorLower) || other.authorLower == authorLower)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.price, price) || other.price == price)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,titleLower,author,authorLower,description,coverUrl,price,categoryId,rating,stock,isFeatured,createdAt);

@override
String toString() {
  return 'Book(id: $id, title: $title, titleLower: $titleLower, author: $author, authorLower: $authorLower, description: $description, coverUrl: $coverUrl, price: $price, categoryId: $categoryId, rating: $rating, stock: $stock, isFeatured: $isFeatured, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$BookCopyWith<$Res> implements $BookCopyWith<$Res> {
  factory _$BookCopyWith(_Book value, $Res Function(_Book) _then) = __$BookCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String titleLower, String author, String authorLower, String description, String coverUrl, double price, String categoryId, double rating, int stock, bool isFeatured, DateTime? createdAt
});




}
/// @nodoc
class __$BookCopyWithImpl<$Res>
    implements _$BookCopyWith<$Res> {
  __$BookCopyWithImpl(this._self, this._then);

  final _Book _self;
  final $Res Function(_Book) _then;

/// Create a copy of Book
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? titleLower = null,Object? author = null,Object? authorLower = null,Object? description = null,Object? coverUrl = null,Object? price = null,Object? categoryId = null,Object? rating = null,Object? stock = null,Object? isFeatured = null,Object? createdAt = freezed,}) {
  return _then(_Book(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,titleLower: null == titleLower ? _self.titleLower : titleLower // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as String,authorLower: null == authorLower ? _self.authorLower : authorLower // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,coverUrl: null == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as double,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
