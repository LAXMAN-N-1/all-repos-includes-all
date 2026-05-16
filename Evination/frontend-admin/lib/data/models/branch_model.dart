import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'branch_model.g.dart';

@JsonSerializable()
class Branch {
  final int id;
  @JsonKey(name: 'organization_id')
  final int organizationId;
  final String name;
  final String code;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  @JsonKey(name: 'is_head_office', defaultValue: 0)
  final int isHeadOffice;
  
  @JsonKey(name: 'manager_id')
  final int? managerId;
  final User? manager;
  
  @JsonKey(defaultValue: false)
  final bool inactive;

  Branch({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.code,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.isHeadOffice = 0,
    this.managerId,
    this.manager,
    this.inactive = false,
    this.employeesCount = 0,
  });

  bool get isHeadquarters => isHeadOffice == 1;
  bool get isActive => !inactive;
  
  @JsonKey(name: 'employees_count', defaultValue: 0)
  final int employeesCount;

  factory Branch.fromJson(Map<String, dynamic> json) => _$BranchFromJson(json);

  Map<String, dynamic> toJson() => _$BranchToJson(this);
}
