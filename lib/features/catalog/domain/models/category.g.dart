// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String? ?? '',
  name: json['name'] as String,
  imageUrl: json['imageUrl'] as String? ?? '',
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'imageUrl': instance.imageUrl,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
};
