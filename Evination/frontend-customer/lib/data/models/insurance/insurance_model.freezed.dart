// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insurance_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InsuranceModel _$InsuranceModelFromJson(Map<String, dynamic> json) {
  return _InsuranceModel.fromJson(json);
}

/// @nodoc
mixin _$InsuranceModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get coverageAmount => throw _privateConstructorUsedError;
  double get premiumAmount => throw _privateConstructorUsedError;
  String get providerName => throw _privateConstructorUsedError;
  List<String> get features => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this InsuranceModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InsuranceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InsuranceModelCopyWith<InsuranceModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsuranceModelCopyWith<$Res> {
  factory $InsuranceModelCopyWith(
          InsuranceModel value, $Res Function(InsuranceModel) then) =
      _$InsuranceModelCopyWithImpl<$Res, InsuranceModel>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double coverageAmount,
      double premiumAmount,
      String providerName,
      List<String> features,
      String status});
}

/// @nodoc
class _$InsuranceModelCopyWithImpl<$Res, $Val extends InsuranceModel>
    implements $InsuranceModelCopyWith<$Res> {
  _$InsuranceModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InsuranceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? coverageAmount = null,
    Object? premiumAmount = null,
    Object? providerName = null,
    Object? features = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverageAmount: null == coverageAmount
          ? _value.coverageAmount
          : coverageAmount // ignore: cast_nullable_to_non_nullable
              as double,
      premiumAmount: null == premiumAmount
          ? _value.premiumAmount
          : premiumAmount // ignore: cast_nullable_to_non_nullable
              as double,
      providerName: null == providerName
          ? _value.providerName
          : providerName // ignore: cast_nullable_to_non_nullable
              as String,
      features: null == features
          ? _value.features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InsuranceModelImplCopyWith<$Res>
    implements $InsuranceModelCopyWith<$Res> {
  factory _$$InsuranceModelImplCopyWith(_$InsuranceModelImpl value,
          $Res Function(_$InsuranceModelImpl) then) =
      __$$InsuranceModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      double coverageAmount,
      double premiumAmount,
      String providerName,
      List<String> features,
      String status});
}

/// @nodoc
class __$$InsuranceModelImplCopyWithImpl<$Res>
    extends _$InsuranceModelCopyWithImpl<$Res, _$InsuranceModelImpl>
    implements _$$InsuranceModelImplCopyWith<$Res> {
  __$$InsuranceModelImplCopyWithImpl(
      _$InsuranceModelImpl _value, $Res Function(_$InsuranceModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of InsuranceModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? coverageAmount = null,
    Object? premiumAmount = null,
    Object? providerName = null,
    Object? features = null,
    Object? status = null,
  }) {
    return _then(_$InsuranceModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      coverageAmount: null == coverageAmount
          ? _value.coverageAmount
          : coverageAmount // ignore: cast_nullable_to_non_nullable
              as double,
      premiumAmount: null == premiumAmount
          ? _value.premiumAmount
          : premiumAmount // ignore: cast_nullable_to_non_nullable
              as double,
      providerName: null == providerName
          ? _value.providerName
          : providerName // ignore: cast_nullable_to_non_nullable
              as String,
      features: null == features
          ? _value._features
          : features // ignore: cast_nullable_to_non_nullable
              as List<String>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InsuranceModelImpl implements _InsuranceModel {
  const _$InsuranceModelImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.coverageAmount,
      required this.premiumAmount,
      required this.providerName,
      final List<String> features = const [],
      this.status = 'Active'})
      : _features = features;

  factory _$InsuranceModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsuranceModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final double coverageAmount;
  @override
  final double premiumAmount;
  @override
  final String providerName;
  final List<String> _features;
  @override
  @JsonKey()
  List<String> get features {
    if (_features is EqualUnmodifiableListView) return _features;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_features);
  }

  @override
  @JsonKey()
  final String status;

  @override
  String toString() {
    return 'InsuranceModel(id: $id, title: $title, description: $description, coverageAmount: $coverageAmount, premiumAmount: $premiumAmount, providerName: $providerName, features: $features, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsuranceModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.coverageAmount, coverageAmount) ||
                other.coverageAmount == coverageAmount) &&
            (identical(other.premiumAmount, premiumAmount) ||
                other.premiumAmount == premiumAmount) &&
            (identical(other.providerName, providerName) ||
                other.providerName == providerName) &&
            const DeepCollectionEquality().equals(other._features, _features) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      coverageAmount,
      premiumAmount,
      providerName,
      const DeepCollectionEquality().hash(_features),
      status);

  /// Create a copy of InsuranceModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InsuranceModelImplCopyWith<_$InsuranceModelImpl> get copyWith =>
      __$$InsuranceModelImplCopyWithImpl<_$InsuranceModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InsuranceModelImplToJson(
      this,
    );
  }
}

abstract class _InsuranceModel implements InsuranceModel {
  const factory _InsuranceModel(
      {required final String id,
      required final String title,
      required final String description,
      required final double coverageAmount,
      required final double premiumAmount,
      required final String providerName,
      final List<String> features,
      final String status}) = _$InsuranceModelImpl;

  factory _InsuranceModel.fromJson(Map<String, dynamic> json) =
      _$InsuranceModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  double get coverageAmount;
  @override
  double get premiumAmount;
  @override
  String get providerName;
  @override
  List<String> get features;
  @override
  String get status;

  /// Create a copy of InsuranceModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InsuranceModelImplCopyWith<_$InsuranceModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
