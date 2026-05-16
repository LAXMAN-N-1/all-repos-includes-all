import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_category_model.freezed.dart';
part 'event_category_model.g.dart';

@freezed
class EventCategoryModel with _$EventCategoryModel {
  const factory EventCategoryModel({
    required int id,
    required String name,
    required String slug,
    String? description,
    String? imageUrl,
    String? iconName,
  }) = _EventCategoryModel;

  factory EventCategoryModel.fromJson(Map<String, dynamic> json) => _$EventCategoryModelFromJson(json);
}

extension EventCategoryModelX on EventCategoryModel {
  String get effectiveImageUrl {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl!;
    
    // Deterministic placeholders based on name
    final lowerName = name.toLowerCase();
    if (lowerName.contains('wedding')) return 'https://images.unsplash.com/photo-1519741497674-611481863552?w=800'; // Wedding
    if (lowerName.contains('birthday')) return 'https://images.unsplash.com/photo-1464349153735-7db50ed83c84?w=800'; // Birthday cake
    if (lowerName.contains('corporate')) return 'https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800'; // Meeting
    if (lowerName.contains('party')) return 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800'; // Party crowd
    if (lowerName.contains('music') || lowerName.contains('concert')) return 'https://images.unsplash.com/photo-1459749411177-287ce93ab434?w=800'; // Concert
    if (lowerName.contains('food') || lowerName.contains('catering')) return 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800'; // Catering

    // Default elegant abstract background
    return 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800';
  }
}
