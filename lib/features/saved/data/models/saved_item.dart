import 'package:freezed_annotation/freezed_annotation.dart';

part 'saved_item.freezed.dart';
part 'saved_item.g.dart';

@freezed
class SavedItem with _$SavedItem {
  const factory SavedItem({
    required String productId,
    required String name,
    required double price,
    required String imageUrl,
    @Default(1) int quantity,
  }) = _SavedItem;

  factory SavedItem.fromJson(Map<String, dynamic> json) =>
      _$SavedItemFromJson(json);
}
