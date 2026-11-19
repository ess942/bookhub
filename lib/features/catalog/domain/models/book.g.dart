// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Book _$BookFromJson(Map<String, dynamic> json) => _Book(
  id: json['id'] as String? ?? '',
  title: json['title'] as String,
  titleLower: json['titleLower'] as String,
  author: json['author'] as String,
  authorLower: json['authorLower'] as String,
  description: json['description'] as String? ?? '',
  coverUrl: json['coverUrl'] as String? ?? '',
  price: (json['price'] as num).toDouble(),
  categoryId: json['categoryId'] as String,
  rating: (json['rating'] as num?)?.toDouble() ?? 0,
  stock: (json['stock'] as num?)?.toInt() ?? 0,
  isFeatured: json['isFeatured'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$BookToJson(_Book instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'titleLower': instance.titleLower,
  'author': instance.author,
  'authorLower': instance.authorLower,
  'description': instance.description,
  'coverUrl': instance.coverUrl,
  'price': instance.price,
  'categoryId': instance.categoryId,
  'rating': instance.rating,
  'stock': instance.stock,
  'isFeatured': instance.isFeatured,
  'createdAt': instance.createdAt?.toIso8601String(),
};
