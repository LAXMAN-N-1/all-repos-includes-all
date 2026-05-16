// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentDto {
  int get id;
  @JsonKey(name: 'document_type')
  String get documentType;
  String get status;
  String? get category;
  @JsonKey(name: 'file_url')
  String get fileUrl;
  int get version;
  @JsonKey(name: 'valid_until')
  String? get validUntil;

  /// Create a copy of DocumentDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DocumentDtoCopyWith<DocumentDto> get copyWith =>
      _$DocumentDtoCopyWithImpl<DocumentDto>(this as DocumentDto, _$identity);

  /// Serializes this DocumentDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DocumentDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.documentType, documentType) ||
                other.documentType == documentType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, documentType, status,
      category, fileUrl, version, validUntil);

  @override
  String toString() {
    return 'DocumentDto(id: $id, documentType: $documentType, status: $status, category: $category, fileUrl: $fileUrl, version: $version, validUntil: $validUntil)';
  }
}

/// @nodoc
abstract mixin class $DocumentDtoCopyWith<$Res> {
  factory $DocumentDtoCopyWith(
          DocumentDto value, $Res Function(DocumentDto) _then) =
      _$DocumentDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'document_type') String documentType,
      String status,
      String? category,
      @JsonKey(name: 'file_url') String fileUrl,
      int version,
      @JsonKey(name: 'valid_until') String? validUntil});
}

/// @nodoc
class _$DocumentDtoCopyWithImpl<$Res> implements $DocumentDtoCopyWith<$Res> {
  _$DocumentDtoCopyWithImpl(this._self, this._then);

  final DocumentDto _self;
  final $Res Function(DocumentDto) _then;

  /// Create a copy of DocumentDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? documentType = null,
    Object? status = null,
    Object? category = freezed,
    Object? fileUrl = null,
    Object? version = null,
    Object? validUntil = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      documentType: null == documentType
          ? _self.documentType
          : documentType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: null == fileUrl
          ? _self.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      validUntil: freezed == validUntil
          ? _self.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DocumentDto].
extension DocumentDtoPatterns on DocumentDto {
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
    TResult Function(_DocumentDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DocumentDto() when $default != null:
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
    TResult Function(_DocumentDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DocumentDto():
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
    TResult? Function(_DocumentDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DocumentDto() when $default != null:
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
            int id,
            @JsonKey(name: 'document_type') String documentType,
            String status,
            String? category,
            @JsonKey(name: 'file_url') String fileUrl,
            int version,
            @JsonKey(name: 'valid_until') String? validUntil)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DocumentDto() when $default != null:
        return $default(_that.id, _that.documentType, _that.status,
            _that.category, _that.fileUrl, _that.version, _that.validUntil);
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
    TResult Function(
            int id,
            @JsonKey(name: 'document_type') String documentType,
            String status,
            String? category,
            @JsonKey(name: 'file_url') String fileUrl,
            int version,
            @JsonKey(name: 'valid_until') String? validUntil)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DocumentDto():
        return $default(_that.id, _that.documentType, _that.status,
            _that.category, _that.fileUrl, _that.version, _that.validUntil);
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
            int id,
            @JsonKey(name: 'document_type') String documentType,
            String status,
            String? category,
            @JsonKey(name: 'file_url') String fileUrl,
            int version,
            @JsonKey(name: 'valid_until') String? validUntil)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DocumentDto() when $default != null:
        return $default(_that.id, _that.documentType, _that.status,
            _that.category, _that.fileUrl, _that.version, _that.validUntil);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _DocumentDto implements DocumentDto {
  const _DocumentDto(
      {required this.id,
      @JsonKey(name: 'document_type') required this.documentType,
      required this.status,
      this.category,
      @JsonKey(name: 'file_url') required this.fileUrl,
      this.version = 1,
      @JsonKey(name: 'valid_until') this.validUntil});
  factory _DocumentDto.fromJson(Map<String, dynamic> json) =>
      _$DocumentDtoFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'document_type')
  final String documentType;
  @override
  final String status;
  @override
  final String? category;
  @override
  @JsonKey(name: 'file_url')
  final String fileUrl;
  @override
  @JsonKey()
  final int version;
  @override
  @JsonKey(name: 'valid_until')
  final String? validUntil;

  /// Create a copy of DocumentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DocumentDtoCopyWith<_DocumentDto> get copyWith =>
      __$DocumentDtoCopyWithImpl<_DocumentDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$DocumentDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DocumentDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.documentType, documentType) ||
                other.documentType == documentType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.version, version) || other.version == version) &&
            (identical(other.validUntil, validUntil) ||
                other.validUntil == validUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, documentType, status,
      category, fileUrl, version, validUntil);

  @override
  String toString() {
    return 'DocumentDto(id: $id, documentType: $documentType, status: $status, category: $category, fileUrl: $fileUrl, version: $version, validUntil: $validUntil)';
  }
}

/// @nodoc
abstract mixin class _$DocumentDtoCopyWith<$Res>
    implements $DocumentDtoCopyWith<$Res> {
  factory _$DocumentDtoCopyWith(
          _DocumentDto value, $Res Function(_DocumentDto) _then) =
      __$DocumentDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      @JsonKey(name: 'document_type') String documentType,
      String status,
      String? category,
      @JsonKey(name: 'file_url') String fileUrl,
      int version,
      @JsonKey(name: 'valid_until') String? validUntil});
}

/// @nodoc
class __$DocumentDtoCopyWithImpl<$Res> implements _$DocumentDtoCopyWith<$Res> {
  __$DocumentDtoCopyWithImpl(this._self, this._then);

  final _DocumentDto _self;
  final $Res Function(_DocumentDto) _then;

  /// Create a copy of DocumentDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? documentType = null,
    Object? status = null,
    Object? category = freezed,
    Object? fileUrl = null,
    Object? version = null,
    Object? validUntil = freezed,
  }) {
    return _then(_DocumentDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      documentType: null == documentType
          ? _self.documentType
          : documentType // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: null == fileUrl
          ? _self.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String,
      version: null == version
          ? _self.version
          : version // ignore: cast_nullable_to_non_nullable
              as int,
      validUntil: freezed == validUntil
          ? _self.validUntil
          : validUntil // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$DocumentState {
  bool get isLoading;
  String? get error;
  List<DocumentDto> get documents;

  /// Create a copy of DocumentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DocumentStateCopyWith<DocumentState> get copyWith =>
      _$DocumentStateCopyWithImpl<DocumentState>(
          this as DocumentState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DocumentState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other.documents, documents));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(documents));

  @override
  String toString() {
    return 'DocumentState(isLoading: $isLoading, error: $error, documents: $documents)';
  }
}

/// @nodoc
abstract mixin class $DocumentStateCopyWith<$Res> {
  factory $DocumentStateCopyWith(
          DocumentState value, $Res Function(DocumentState) _then) =
      _$DocumentStateCopyWithImpl;
  @useResult
  $Res call({bool isLoading, String? error, List<DocumentDto> documents});
}

/// @nodoc
class _$DocumentStateCopyWithImpl<$Res>
    implements $DocumentStateCopyWith<$Res> {
  _$DocumentStateCopyWithImpl(this._self, this._then);

  final DocumentState _self;
  final $Res Function(DocumentState) _then;

  /// Create a copy of DocumentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? documents = null,
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
      documents: null == documents
          ? _self.documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<DocumentDto>,
    ));
  }
}

/// Adds pattern-matching-related methods to [DocumentState].
extension DocumentStatePatterns on DocumentState {
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
    TResult Function(_DocumentState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DocumentState() when $default != null:
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
    TResult Function(_DocumentState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DocumentState():
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
    TResult? Function(_DocumentState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DocumentState() when $default != null:
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
            bool isLoading, String? error, List<DocumentDto> documents)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DocumentState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.documents);
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
    TResult Function(bool isLoading, String? error, List<DocumentDto> documents)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DocumentState():
        return $default(_that.isLoading, _that.error, _that.documents);
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
            bool isLoading, String? error, List<DocumentDto> documents)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DocumentState() when $default != null:
        return $default(_that.isLoading, _that.error, _that.documents);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DocumentState implements DocumentState {
  const _DocumentState(
      {this.isLoading = true,
      this.error,
      final List<DocumentDto> documents = const []})
      : _documents = documents;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<DocumentDto> _documents;
  @override
  @JsonKey()
  List<DocumentDto> get documents {
    if (_documents is EqualUnmodifiableListView) return _documents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_documents);
  }

  /// Create a copy of DocumentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DocumentStateCopyWith<_DocumentState> get copyWith =>
      __$DocumentStateCopyWithImpl<_DocumentState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DocumentState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._documents, _documents));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(_documents));

  @override
  String toString() {
    return 'DocumentState(isLoading: $isLoading, error: $error, documents: $documents)';
  }
}

/// @nodoc
abstract mixin class _$DocumentStateCopyWith<$Res>
    implements $DocumentStateCopyWith<$Res> {
  factory _$DocumentStateCopyWith(
          _DocumentState value, $Res Function(_DocumentState) _then) =
      __$DocumentStateCopyWithImpl;
  @override
  @useResult
  $Res call({bool isLoading, String? error, List<DocumentDto> documents});
}

/// @nodoc
class __$DocumentStateCopyWithImpl<$Res>
    implements _$DocumentStateCopyWith<$Res> {
  __$DocumentStateCopyWithImpl(this._self, this._then);

  final _DocumentState _self;
  final $Res Function(_DocumentState) _then;

  /// Create a copy of DocumentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? documents = null,
  }) {
    return _then(_DocumentState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      documents: null == documents
          ? _self._documents
          : documents // ignore: cast_nullable_to_non_nullable
              as List<DocumentDto>,
    ));
  }
}

// dart format on
