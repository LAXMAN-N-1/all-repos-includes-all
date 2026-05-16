import 'package:json_annotation/json_annotation.dart';
import 'menu_model.dart';

part 'role_right_model.g.dart';

@JsonSerializable()
class RoleRight {
  final int? id;
  @JsonKey(name: 'menu_id')
  final int menuId;
  @JsonKey(name: 'can_view')
  final bool canView;
  @JsonKey(name: 'can_create')
  final bool canCreate;
  @JsonKey(name: 'can_edit')
  final bool canEdit;
  @JsonKey(name: 'can_delete')
  final bool canDelete;
  final Menu? menu;

  RoleRight({
    this.id,
    required this.menuId,
    required this.canView,
    required this.canCreate,
    required this.canEdit,
    required this.canDelete,
    this.menu,
  });

  factory RoleRight.fromJson(Map<String, dynamic> json) => _$RoleRightFromJson(json);
  Map<String, dynamic> toJson() => _$RoleRightToJson(this);
}

@JsonSerializable()
class RoleRightBulkItem {
  @JsonKey(name: 'menu_id')
  final int menuId;
  @JsonKey(name: 'can_view')
  final bool canView;
  @JsonKey(name: 'can_create')
  final bool canCreate;
  @JsonKey(name: 'can_edit')
  final bool canEdit;
  @JsonKey(name: 'can_delete')
  final bool canDelete;

  RoleRightBulkItem({
    required this.menuId,
    this.canView = false,
    this.canCreate = false,
    this.canEdit = false,
    this.canDelete = false,
  });
  
  // Factory and toJson for BulkItem
  factory RoleRightBulkItem.fromJson(Map<String, dynamic> json) => _$RoleRightBulkItemFromJson(json);
  Map<String, dynamic> toJson() => _$RoleRightBulkItemToJson(this);
}
