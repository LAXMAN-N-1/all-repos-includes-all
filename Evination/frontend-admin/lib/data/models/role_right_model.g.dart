// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'role_right_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoleRight _$RoleRightFromJson(Map<String, dynamic> json) => RoleRight(
  id: (json['id'] as num?)?.toInt(),
  menuId: (json['menu_id'] as num).toInt(),
  canView: json['can_view'] as bool,
  canCreate: json['can_create'] as bool,
  canEdit: json['can_edit'] as bool,
  canDelete: json['can_delete'] as bool,
  menu: json['menu'] == null
      ? null
      : Menu.fromJson(json['menu'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RoleRightToJson(RoleRight instance) => <String, dynamic>{
  'id': instance.id,
  'menu_id': instance.menuId,
  'can_view': instance.canView,
  'can_create': instance.canCreate,
  'can_edit': instance.canEdit,
  'can_delete': instance.canDelete,
  'menu': instance.menu,
};

RoleRightBulkItem _$RoleRightBulkItemFromJson(Map<String, dynamic> json) =>
    RoleRightBulkItem(
      menuId: (json['menu_id'] as num).toInt(),
      canView: json['can_view'] as bool? ?? false,
      canCreate: json['can_create'] as bool? ?? false,
      canEdit: json['can_edit'] as bool? ?? false,
      canDelete: json['can_delete'] as bool? ?? false,
    );

Map<String, dynamic> _$RoleRightBulkItemToJson(RoleRightBulkItem instance) =>
    <String, dynamic>{
      'menu_id': instance.menuId,
      'can_view': instance.canView,
      'can_create': instance.canCreate,
      'can_edit': instance.canEdit,
      'can_delete': instance.canDelete,
    };
