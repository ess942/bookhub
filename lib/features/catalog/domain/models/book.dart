import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';
part 'book.g.dart';

@freezed
abstract class Book with _$Book {
  const factory Book({
    @Default('') String id,
    required String title,
    required String titleLower,
    required String author,
    required String authorLower,
    @Default('') String description,
    @Default('') String coverUrl,
    required double price,
    required String categoryId,
    @Default(0) double rating,
    @Default(0) int stock,
    @Default(false) bool isFeatured,
    DateTime? createdAt,
  }) = _Book;

  factory Book.fromJson(Map<String, dynamic> json) => _$BookFromJson(json);
}
