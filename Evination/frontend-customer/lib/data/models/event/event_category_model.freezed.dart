// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_category_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

EventCategoryModel _$EventCategoryModelFromJson(Map<String, dynamic> json) {
  return _EventCategoryModel.fromJson(json);
}

/// @nodoc
mixin _$EventCategoryModel {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get iconName => throw _privateConstructorUsedError;

  /// Serializes this EventCategoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCategoryModelCopyWith<EventCategoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCategoryModelCopyWith<$Res> {
  factory $EventCategoryModelCopyWith(
          EventCategoryModel value, $Res Function(EventCategoryModel) then) =
      _$EventCategoryModelCopyWithImpl<$Res, EventCategoryModel>;
  @useResult
  $Res call(
      {int id,
      String name,
      String slug,
      String? description,
      String? imageUrl,
      String? iconName});
}

/// @nodoc
class _$EventCategoryModelCopyWithImpl<$Res, $Val extends EventCategoryModel>
    implements $EventCategoryModelCopyWith<$Res> {
  _$EventCategoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? iconName = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      iconName: freezed == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventCategoryModelImplCopyWith<$Res>
    implements $EventCategoryModelCopyWith<$Res> {
  factory _$$EventCategoryModelImplCopyWith(_$EventCategoryModelImpl value,
          $Res Function(_$EventCategoryModelImpl) then) =
      __$$EventCategoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String name,
      String slug,
      String? description,
      String? imageUrl,
      String? iconName});
}

/// @nodoc
class __$$EventCategoryModelImplCopyWithImpl<$Res>
    extends _$EventCategoryModelCopyWithImpl<$Res, _$EventCategoryModelImpl>
    implements _$$EventCategoryModelImplCopyWith<$Res> {
  __$$EventCategoryModelImplCopyWithImpl(_$EventCategoryModelImpl _value,
      $Res Function(_$EventCategoryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? slug = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? iconName = freezed,
  }) {
    return _then(_$EventCategoryModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      iconName: freezed == iconName
          ? _value.iconName
          : iconName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventCategoryModelImpl implements _EventCategoryModel {
  const _$EventCategoryModelImpl(
      {required this.id,
      required this.name,
      required this.slug,
      this.description,
      this.imageUrl,
      this.iconName});

  factory _$EventCategoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventCategoryModelImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String slug;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final String? iconName;

  @override
  String toString() {
    return 'EventCategoryModel(id: $id, name: $name, slug: $slug, description: $description, imageUrl: $imageUrl, iconName: $iconName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventCategoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, slug, description, imageUrl, iconName);

  /// Create a copy of EventCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventCategoryModelImplCopyWith<_$EventCategoryModelImpl> get copyWith =>
      __$$EventCategoryModelImplCopyWithImpl<_$EventCategoryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventCategoryModelImplToJson(
      this,
    );
  }
}

abstract class _EventCategoryModel implements EventCategoryModel {
  const factory _EventCategoryModel(
      {required final int id,
      required final String name,
      required final String slug,
      final String? description,
      final String? imageUrl,
      final String? iconName}) = _$EventCategoryModelImpl;

  factory _EventCategoryModel.fromJson(Map<String, dynamic> json) =
      _$EventCategoryModelImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get slug;
  @override
  String? get description;
  @override
  String? get imageUrl;
  @override
  String? get iconName;

  /// Create a copy of EventCategoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventCategoryModelImplCopyWith<_$EventCategoryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
