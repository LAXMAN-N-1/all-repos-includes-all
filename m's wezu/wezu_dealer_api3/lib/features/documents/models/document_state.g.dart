// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentDto _$DocumentDtoFromJson(Map<String, dynamic> json) => _DocumentDto(
      id: (json['id'] as num).toInt(),
      documentType: json['document_type'] as String,
      status: json['status'] as String,
      category: json['category'] as String?,
      fileUrl: json['file_url'] as String,
      version: (json['version'] as num?)?.toInt() ?? 1,
      validUntil: json['valid_until'] as String?,
    );

Map<String, dynamic> _$DocumentDtoToJson(_DocumentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'document_type': instance.documentType,
      'status': instance.status,
      'category': instance.category,
      'file_url': instance.fileUrl,
      'version': instance.version,
      'valid_until': instance.validUntil,
    };
