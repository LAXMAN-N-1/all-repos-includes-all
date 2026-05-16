// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'role_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Role {

 int get id; String get name; String get code; String? get description; List<RoleRight> get rights;
/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoleCopyWith<Role> get copyWith => _$RoleCopyWithImpl<Role>(this as Role, _$identity);

  /// Serializes this Role to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Role&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.rights, rights));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,description,const DeepCollectionEquality().hash(rights));

@override
String toString() {
  return 'Role(id: $id, name: $name, code: $code, description: $description, rights: $rights)';
}


}

/// @nodoc
abstract mixin class $RoleCopyWith<$Res>  {
  factory $RoleCopyWith(Role value, $Res Function(Role) _then) = _$RoleCopyWithImpl;
@useResult
$Res call({
 int id, String name, String code, String? description, List<RoleRight> rights
});




}
/// @nodoc
class _$RoleCopyWithImpl<$Res>
    implements $RoleCopyWith<$Res> {
  _$RoleCopyWithImpl(this._self, this._then);

  final Role _self;
  final $Res Function(Role) _then;

/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = null,Object? description = freezed,Object? rights = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rights: null == rights ? _self.rights : rights // ignore: cast_nullable_to_non_nullable
as List<RoleRight>,
  ));
}

}


/// Adds pattern-matching-related methods to [Role].
extension RolePatterns on Role {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Role value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Role() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Role value)  $default,){
final _that = this;
switch (_that) {
case _Role():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Role value)?  $default,){
final _that = this;
switch (_that) {
case _Role() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String code,  String? description,  List<RoleRight> rights)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Role() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.description,_that.rights);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String code,  String? description,  List<RoleRight> rights)  $default,) {final _that = this;
switch (_that) {
case _Role():
return $default(_that.id,_that.name,_that.code,_that.description,_that.rights);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String code,  String? description,  List<RoleRight> rights)?  $default,) {final _that = this;
switch (_that) {
case _Role() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.description,_that.rights);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Role implements Role {
  const _Role({required this.id, required this.name, required this.code, this.description, final  List<RoleRight> rights = const []}): _rights = rights;
  factory _Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

@override final  int id;
@override final  String name;
@override final  String code;
@override final  String? description;
 final  List<RoleRight> _rights;
@override@JsonKey() List<RoleRight> get rights {
  if (_rights is EqualUnmodifiableListView) return _rights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rights);
}


/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoleCopyWith<_Role> get copyWith => __$RoleCopyWithImpl<_Role>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoleToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Role&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._rights, _rights));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,code,description,const DeepCollectionEquality().hash(_rights));

@override
String toString() {
  return 'Role(id: $id, name: $name, code: $code, description: $description, rights: $rights)';
}


}

/// @nodoc
abstract mixin class _$RoleCopyWith<$Res> implements $RoleCopyWith<$Res> {
  factory _$RoleCopyWith(_Role value, $Res Function(_Role) _then) = __$RoleCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String code, String? description, List<RoleRight> rights
});




}
/// @nodoc
class __$RoleCopyWithImpl<$Res>
    implements _$RoleCopyWith<$Res> {
  __$RoleCopyWithImpl(this._self, this._then);

  final _Role _self;
  final $Res Function(_Role) _then;

/// Create a copy of Role
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = null,Object? description = freezed,Object? rights = null,}) {
  return _then(_Role(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rights: null == rights ? _self._rights : rights // ignore: cast_nullable_to_non_nullable
as List<RoleRight>,
  ));
}


}


/// @nodoc
mixin _$CreateRoleRequest {

 String get name; String get code; String? get description; List<RoleRight> get rights;
/// Create a copy of CreateRoleRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateRoleRequestCopyWith<CreateRoleRequest> get copyWith => _$CreateRoleRequestCopyWithImpl<CreateRoleRequest>(this as CreateRoleRequest, _$identity);

  /// Serializes this CreateRoleRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateRoleRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.rights, rights));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,code,description,const DeepCollectionEquality().hash(rights));

@override
String toString() {
  return 'CreateRoleRequest(name: $name, code: $code, description: $description, rights: $rights)';
}


}

/// @nodoc
abstract mixin class $CreateRoleRequestCopyWith<$Res>  {
  factory $CreateRoleRequestCopyWith(CreateRoleRequest value, $Res Function(CreateRoleRequest) _then) = _$CreateRoleRequestCopyWithImpl;
@useResult
$Res call({
 String name, String code, String? description, List<RoleRight> rights
});




}
/// @nodoc
class _$CreateRoleRequestCopyWithImpl<$Res>
    implements $CreateRoleRequestCopyWith<$Res> {
  _$CreateRoleRequestCopyWithImpl(this._self, this._then);

  final CreateRoleRequest _self;
  final $Res Function(CreateRoleRequest) _then;

/// Create a copy of CreateRoleRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? code = null,Object? description = freezed,Object? rights = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rights: null == rights ? _self.rights : rights // ignore: cast_nullable_to_non_nullable
as List<RoleRight>,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateRoleRequest].
extension CreateRoleRequestPatterns on CreateRoleRequest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateRoleRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateRoleRequest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateRoleRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateRoleRequest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateRoleRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateRoleRequest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String code,  String? description,  List<RoleRight> rights)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateRoleRequest() when $default != null:
return $default(_that.name,_that.code,_that.description,_that.rights);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String code,  String? description,  List<RoleRight> rights)  $default,) {final _that = this;
switch (_that) {
case _CreateRoleRequest():
return $default(_that.name,_that.code,_that.description,_that.rights);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String code,  String? description,  List<RoleRight> rights)?  $default,) {final _that = this;
switch (_that) {
case _CreateRoleRequest() when $default != null:
return $default(_that.name,_that.code,_that.description,_that.rights);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateRoleRequest implements CreateRoleRequest {
  const _CreateRoleRequest({required this.name, required this.code, this.description, final  List<RoleRight> rights = const []}): _rights = rights;
  factory _CreateRoleRequest.fromJson(Map<String, dynamic> json) => _$CreateRoleRequestFromJson(json);

@override final  String name;
@override final  String code;
@override final  String? description;
 final  List<RoleRight> _rights;
@override@JsonKey() List<RoleRight> get rights {
  if (_rights is EqualUnmodifiableListView) return _rights;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rights);
}


/// Create a copy of CreateRoleRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateRoleRequestCopyWith<_CreateRoleRequest> get copyWith => __$CreateRoleRequestCopyWithImpl<_CreateRoleRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateRoleRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateRoleRequest&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._rights, _rights));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,code,description,const DeepCollectionEquality().hash(_rights));

@override
String toString() {
  return 'CreateRoleRequest(name: $name, code: $code, description: $description, rights: $rights)';
}


}

/// @nodoc
abstract mixin class _$CreateRoleRequestCopyWith<$Res> implements $CreateRoleRequestCopyWith<$Res> {
  factory _$CreateRoleRequestCopyWith(_CreateRoleRequest value, $Res Function(_CreateRoleRequest) _then) = __$CreateRoleRequestCopyWithImpl;
@override @useResult
$Res call({
 String name, String code, String? description, List<RoleRight> rights
});




}
/// @nodoc
class __$CreateRoleRequestCopyWithImpl<$Res>
    implements _$CreateRoleRequestCopyWith<$Res> {
  __$CreateRoleRequestCopyWithImpl(this._self, this._then);

  final _CreateRoleRequest _self;
  final $Res Function(_CreateRoleRequest) _then;

/// Create a copy of CreateRoleRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? code = null,Object? description = freezed,Object? rights = null,}) {
  return _then(_CreateRoleRequest(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,rights: null == rights ? _self._rights : rights // ignore: cast_nullable_to_non_nullable
as List<RoleRight>,
  ));
}


}

// dart format on
