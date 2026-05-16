import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_state.freezed.dart';
part 'document_state.g.dart';

@freezed
abstract class DocumentDto with _$DocumentDto {
  const factory DocumentDto({
    required int id,
    @JsonKey(name: 'document_type') required String documentType,
    required String status,
    String? category,
    @JsonKey(name: 'file_url') required String fileUrl,
    @Default(1) int version,
    @JsonKey(name: 'valid_until') String? validUntil,
  }) = _DocumentDto;

  factory DocumentDto.fromJson(Map<String, dynamic> json) =>
      _$DocumentDtoFromJson(json);
}

@freezed
abstract class DocumentState with _$DocumentState {
  const factory DocumentState({
    @Default(true) bool isLoading,
    String? error,
    @Default([]) List<DocumentDto> documents,
  }) = _DocumentState;
}
