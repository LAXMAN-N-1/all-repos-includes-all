// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'campaign_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CampaignDto {
  int get id;
  String get title;
  String get desc;
  String get status;
  String get dates;
  String get redemptions;
  String get revenue;

  /// Create a copy of CampaignDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CampaignDtoCopyWith<CampaignDto> get copyWith =>
      _$CampaignDtoCopyWithImpl<CampaignDto>(this as CampaignDto, _$identity);

  /// Serializes this CampaignDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CampaignDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.dates, dates) || other.dates == dates) &&
            (identical(other.redemptions, redemptions) ||
                other.redemptions == redemptions) &&
            (identical(other.revenue, revenue) || other.revenue == revenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, desc, status, dates, redemptions, revenue);

  @override
  String toString() {
    return 'CampaignDto(id: $id, title: $title, desc: $desc, status: $status, dates: $dates, redemptions: $redemptions, revenue: $revenue)';
  }
}

/// @nodoc
abstract mixin class $CampaignDtoCopyWith<$Res> {
  factory $CampaignDtoCopyWith(
          CampaignDto value, $Res Function(CampaignDto) _then) =
      _$CampaignDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String title,
      String desc,
      String status,
      String dates,
      String redemptions,
      String revenue});
}

/// @nodoc
class _$CampaignDtoCopyWithImpl<$Res> implements $CampaignDtoCopyWith<$Res> {
  _$CampaignDtoCopyWithImpl(this._self, this._then);

  final CampaignDto _self;
  final $Res Function(CampaignDto) _then;

  /// Create a copy of CampaignDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? desc = null,
    Object? status = null,
    Object? dates = null,
    Object? redemptions = null,
    Object? revenue = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _self.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      dates: null == dates
          ? _self.dates
          : dates // ignore: cast_nullable_to_non_nullable
              as String,
      redemptions: null == redemptions
          ? _self.redemptions
          : redemptions // ignore: cast_nullable_to_non_nullable
              as String,
      revenue: null == revenue
          ? _self.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [CampaignDto].
extension CampaignDtoPatterns on CampaignDto {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CampaignDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CampaignDto() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_CampaignDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CampaignDto():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CampaignDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CampaignDto() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int id, String title, String desc, String status,
            String dates, String redemptions, String revenue)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CampaignDto() when $default != null:
        return $default(_that.id, _that.title, _that.desc, _that.status,
            _that.dates, _that.redemptions, _that.revenue);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int id, String title, String desc, String status,
            String dates, String redemptions, String revenue)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CampaignDto():
        return $default(_that.id, _that.title, _that.desc, _that.status,
            _that.dates, _that.redemptions, _that.revenue);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int id, String title, String desc, String status,
            String dates, String redemptions, String revenue)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CampaignDto() when $default != null:
        return $default(_that.id, _that.title, _that.desc, _that.status,
            _that.dates, _that.redemptions, _that.revenue);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CampaignDto implements CampaignDto {
  const _CampaignDto(
      {required this.id,
      required this.title,
      required this.desc,
      required this.status,
      required this.dates,
      required this.redemptions,
      required this.revenue});
  factory _CampaignDto.fromJson(Map<String, dynamic> json) =>
      _$CampaignDtoFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  final String desc;
  @override
  final String status;
  @override
  final String dates;
  @override
  final String redemptions;
  @override
  final String revenue;

  /// Create a copy of CampaignDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CampaignDtoCopyWith<_CampaignDto> get copyWith =>
      __$CampaignDtoCopyWithImpl<_CampaignDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CampaignDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CampaignDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.desc, desc) || other.desc == desc) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.dates, dates) || other.dates == dates) &&
            (identical(other.redemptions, redemptions) ||
                other.redemptions == redemptions) &&
            (identical(other.revenue, revenue) || other.revenue == revenue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, desc, status, dates, redemptions, revenue);

  @override
  String toString() {
    return 'CampaignDto(id: $id, title: $title, desc: $desc, status: $status, dates: $dates, redemptions: $redemptions, revenue: $revenue)';
  }
}

/// @nodoc
abstract mixin class _$CampaignDtoCopyWith<$Res>
    implements $CampaignDtoCopyWith<$Res> {
  factory _$CampaignDtoCopyWith(
          _CampaignDto value, $Res Function(_CampaignDto) _then) =
      __$CampaignDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String desc,
      String status,
      String dates,
      String redemptions,
      String revenue});
}

/// @nodoc
class __$CampaignDtoCopyWithImpl<$Res> implements _$CampaignDtoCopyWith<$Res> {
  __$CampaignDtoCopyWithImpl(this._self, this._then);

  final _CampaignDto _self;
  final $Res Function(_CampaignDto) _then;

  /// Create a copy of CampaignDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? desc = null,
    Object? status = null,
    Object? dates = null,
    Object? redemptions = null,
    Object? revenue = null,
  }) {
    return _then(_CampaignDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      desc: null == desc
          ? _self.desc
          : desc // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      dates: null == dates
          ? _self.dates
          : dates // ignore: cast_nullable_to_non_nullable
              as String,
      redemptions: null == redemptions
          ? _self.redemptions
          : redemptions // ignore: cast_nullable_to_non_nullable
              as String,
      revenue: null == revenue
          ? _self.revenue
          : revenue // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$CampaignState {
  bool get isLoading;
  String? get error;
  List<CampaignDto> get campaigns;

  /// Create a copy of CampaignState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CampaignStateCopyWith<CampaignState> get copyWith =>
      _$CampaignStateCopyWithImpl<CampaignState>(
          this as CampaignState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CampaignState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other.campaigns, campaigns));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(campaigns));

  @override
  String toString() {
    return 'CampaignState(isLoading: $isLoading, error: $error, campaigns: $campaigns)';
  }
}

/// @nodoc
abstract mixin class $CampaignStateCopyWith<$Res> {
  factory $CampaignStateCopyWith(
          CampaignState value, $Res Function(CampaignState) _then) =
      _$CampaignStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, String? error, List<CampaignDto> campaigns});
}

/// @nodoc
class _$CampaignStateCopyWithImpl<$Res>
    implements $CampaignStateCopyWith<$Res> {
  _$CampaignStateCopyWithImpl(this._self, this._then);

  final CampaignState _self;
  final $Res Function(CampaignState) _then;

  /// Create a copy of CampaignState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? campaigns = null,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      campaigns: null == campaigns
          ? _self.campaigns
          : campaigns // ignore: cast_nullable_to_non_nullable
              as List<CampaignDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [CampaignState].
extension CampaignStatePatterns on CampaignState {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CampaignState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CampaignState() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_CampaignState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CampaignState():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CampaignState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CampaignState() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            bool isLoading, String? error, List<CampaignDto> campaigns)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CampaignState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.campaigns);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(bool isLoading, String? error, List<CampaignDto> campaigns)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CampaignState():
        return $default(_that.isLoading, _that.error, _that.campaigns);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            bool isLoading, String? error, List<CampaignDto> campaigns)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CampaignState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.campaigns);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CampaignState implements CampaignState {
  const _CampaignState(
      {this.isLoading = true,
      this.error,
      final List<CampaignDto> campaigns = const []})
      : _campaigns = campaigns;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<CampaignDto> _campaigns;
  @override
  @JsonKey()
  List<CampaignDto> get campaigns {
    if (_campaigns is EqualUnmodifiableListView) return _campaigns;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_campaigns);
  }

  /// Create a copy of CampaignState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CampaignStateCopyWith<_CampaignState> get copyWith =>
      __$CampaignStateCopyWithImpl<_CampaignState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CampaignState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._campaigns, _campaigns));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(_campaigns));

  @override
  String toString() {
    return 'CampaignState(isLoading: $isLoading, error: $error, campaigns: $campaigns)';
  }
}

/// @nodoc
abstract mixin class _$CampaignStateCopyWith<$Res>
    implements $CampaignStateCopyWith<$Res> {
  factory _$CampaignStateCopyWith(
          _CampaignState value, $Res Function(_CampaignState) _then) =
      __$CampaignStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, String? error, List<CampaignDto> campaigns});
}

/// @nodoc
class __$CampaignStateCopyWithImpl<$Res>
    implements _$CampaignStateCopyWith<$Res> {
  __$CampaignStateCopyWithImpl(this._self, this._then);

  final _CampaignState _self;
  final $Res Function(_CampaignState) _then;

  /// Create a copy of CampaignState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? campaigns = null,
  }) {
    return _then(_CampaignState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      campaigns: null == campaigns
          ? _self._campaigns
          : campaigns // ignore: cast_nullable_to_non_nullable
              as List<CampaignDto>,
    ));
  }
}

// dart format on
