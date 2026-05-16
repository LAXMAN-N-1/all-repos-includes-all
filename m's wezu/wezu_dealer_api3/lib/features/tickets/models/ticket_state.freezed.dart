// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketMessage {
  int get id;
  String get senderName;
  String get senderAvatar;
  String get text;
  DateTime get timestamp;
  String get type;

  /// Create a copy of TicketMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TicketMessageCopyWith<TicketMessage> get copyWith =>
      _$TicketMessageCopyWithImpl<TicketMessage>(
          this as TicketMessage, _$identity);

  /// Serializes this TicketMessage to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TicketMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderAvatar, senderAvatar) ||
                other.senderAvatar == senderAvatar) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, senderName, senderAvatar, text, timestamp, type);

  @override
  String toString() {
    return 'TicketMessage(id: $id, senderName: $senderName, senderAvatar: $senderAvatar, text: $text, timestamp: $timestamp, type: $type)';
  }
}

/// @nodoc
abstract mixin class $TicketMessageCopyWith<$Res> {
  factory $TicketMessageCopyWith(
          TicketMessage value, $Res Function(TicketMessage) _then) =
      _$TicketMessageCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String senderName,
      String senderAvatar,
      String text,
      DateTime timestamp,
      String type});
}

/// @nodoc
class _$TicketMessageCopyWithImpl<$Res>
    implements $TicketMessageCopyWith<$Res> {
  _$TicketMessageCopyWithImpl(this._self, this._then);

  final TicketMessage _self;
  final $Res Function(TicketMessage) _then;

  /// Create a copy of TicketMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderName = null,
    Object? senderAvatar = null,
    Object? text = null,
    Object? timestamp = null,
    Object? type = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      senderName: null == senderName
          ? _self.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      senderAvatar: null == senderAvatar
          ? _self.senderAvatar
          : senderAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [TicketMessage].
extension TicketMessagePatterns on TicketMessage {
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
    TResult Function(_TicketMessage value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketMessage() when $default != null:
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
    TResult Function(_TicketMessage value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketMessage():
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
    TResult? Function(_TicketMessage value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketMessage() when $default != null:
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
    TResult Function(int id, String senderName, String senderAvatar,
            String text, DateTime timestamp, String type)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketMessage() when $default != null:
        return $default(_that.id, _that.senderName, _that.senderAvatar,
            _that.text, _that.timestamp, _that.type);
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
    TResult Function(int id, String senderName, String senderAvatar,
            String text, DateTime timestamp, String type)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketMessage():
        return $default(_that.id, _that.senderName, _that.senderAvatar,
            _that.text, _that.timestamp, _that.type);
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
    TResult? Function(int id, String senderName, String senderAvatar,
            String text, DateTime timestamp, String type)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketMessage() when $default != null:
        return $default(_that.id, _that.senderName, _that.senderAvatar,
            _that.text, _that.timestamp, _that.type);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TicketMessage implements TicketMessage {
  const _TicketMessage(
      {required this.id,
      required this.senderName,
      required this.senderAvatar,
      required this.text,
      required this.timestamp,
      required this.type});
  factory _TicketMessage.fromJson(Map<String, dynamic> json) =>
      _$TicketMessageFromJson(json);

  @override
  final int id;
  @override
  final String senderName;
  @override
  final String senderAvatar;
  @override
  final String text;
  @override
  final DateTime timestamp;
  @override
  final String type;

  /// Create a copy of TicketMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TicketMessageCopyWith<_TicketMessage> get copyWith =>
      __$TicketMessageCopyWithImpl<_TicketMessage>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TicketMessageToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TicketMessage &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderAvatar, senderAvatar) ||
                other.senderAvatar == senderAvatar) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, senderName, senderAvatar, text, timestamp, type);

  @override
  String toString() {
    return 'TicketMessage(id: $id, senderName: $senderName, senderAvatar: $senderAvatar, text: $text, timestamp: $timestamp, type: $type)';
  }
}

/// @nodoc
abstract mixin class _$TicketMessageCopyWith<$Res>
    implements $TicketMessageCopyWith<$Res> {
  factory _$TicketMessageCopyWith(
          _TicketMessage value, $Res Function(_TicketMessage) _then) =
      __$TicketMessageCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String senderName,
      String senderAvatar,
      String text,
      DateTime timestamp,
      String type});
}

/// @nodoc
class __$TicketMessageCopyWithImpl<$Res>
    implements _$TicketMessageCopyWith<$Res> {
  __$TicketMessageCopyWithImpl(this._self, this._then);

  final _TicketMessage _self;
  final $Res Function(_TicketMessage) _then;

  /// Create a copy of TicketMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? senderName = null,
    Object? senderAvatar = null,
    Object? text = null,
    Object? timestamp = null,
    Object? type = null,
  }) {
    return _then(_TicketMessage(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      senderName: null == senderName
          ? _self.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String,
      senderAvatar: null == senderAvatar
          ? _self.senderAvatar
          : senderAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$StatusChangeEvent {
  DateTime get timestamp;
  String get description;
  String get dotColor;

  /// Create a copy of StatusChangeEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StatusChangeEventCopyWith<StatusChangeEvent> get copyWith =>
      _$StatusChangeEventCopyWithImpl<StatusChangeEvent>(
          this as StatusChangeEvent, _$identity);

  /// Serializes this StatusChangeEvent to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StatusChangeEvent &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.dotColor, dotColor) ||
                other.dotColor == dotColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, timestamp, description, dotColor);

  @override
  String toString() {
    return 'StatusChangeEvent(timestamp: $timestamp, description: $description, dotColor: $dotColor)';
  }
}

/// @nodoc
abstract mixin class $StatusChangeEventCopyWith<$Res> {
  factory $StatusChangeEventCopyWith(
          StatusChangeEvent value, $Res Function(StatusChangeEvent) _then) =
      _$StatusChangeEventCopyWithImpl;
  @useResult
  $Res call({DateTime timestamp, String description, String dotColor});
}

/// @nodoc
class _$StatusChangeEventCopyWithImpl<$Res>
    implements $StatusChangeEventCopyWith<$Res> {
  _$StatusChangeEventCopyWithImpl(this._self, this._then);

  final StatusChangeEvent _self;
  final $Res Function(StatusChangeEvent) _then;

  /// Create a copy of StatusChangeEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? timestamp = null,
    Object? description = null,
    Object? dotColor = null,
  }) {
    return _then(_self.copyWith(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      dotColor: null == dotColor
          ? _self.dotColor
          : dotColor // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [StatusChangeEvent].
extension StatusChangeEventPatterns on StatusChangeEvent {
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
    TResult Function(_StatusChangeEvent value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StatusChangeEvent() when $default != null:
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
    TResult Function(_StatusChangeEvent value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusChangeEvent():
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
    TResult? Function(_StatusChangeEvent value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusChangeEvent() when $default != null:
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
    TResult Function(DateTime timestamp, String description, String dotColor)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StatusChangeEvent() when $default != null:
        return $default(_that.timestamp, _that.description, _that.dotColor);
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
    TResult Function(DateTime timestamp, String description, String dotColor)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusChangeEvent():
        return $default(_that.timestamp, _that.description, _that.dotColor);
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
    TResult? Function(DateTime timestamp, String description, String dotColor)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusChangeEvent() when $default != null:
        return $default(_that.timestamp, _that.description, _that.dotColor);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StatusChangeEvent implements StatusChangeEvent {
  const _StatusChangeEvent(
      {required this.timestamp,
      required this.description,
      required this.dotColor});
  factory _StatusChangeEvent.fromJson(Map<String, dynamic> json) =>
      _$StatusChangeEventFromJson(json);

  @override
  final DateTime timestamp;
  @override
  final String description;
  @override
  final String dotColor;

  /// Create a copy of StatusChangeEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StatusChangeEventCopyWith<_StatusChangeEvent> get copyWith =>
      __$StatusChangeEventCopyWithImpl<_StatusChangeEvent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StatusChangeEventToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StatusChangeEvent &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.dotColor, dotColor) ||
                other.dotColor == dotColor));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, timestamp, description, dotColor);

  @override
  String toString() {
    return 'StatusChangeEvent(timestamp: $timestamp, description: $description, dotColor: $dotColor)';
  }
}

/// @nodoc
abstract mixin class _$StatusChangeEventCopyWith<$Res>
    implements $StatusChangeEventCopyWith<$Res> {
  factory _$StatusChangeEventCopyWith(
          _StatusChangeEvent value, $Res Function(_StatusChangeEvent) _then) =
      __$StatusChangeEventCopyWithImpl;
  @override
  @useResult
  $Res call({DateTime timestamp, String description, String dotColor});
}

/// @nodoc
class __$StatusChangeEventCopyWithImpl<$Res>
    implements _$StatusChangeEventCopyWith<$Res> {
  __$StatusChangeEventCopyWithImpl(this._self, this._then);

  final _StatusChangeEvent _self;
  final $Res Function(_StatusChangeEvent) _then;

  /// Create a copy of StatusChangeEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? timestamp = null,
    Object? description = null,
    Object? dotColor = null,
  }) {
    return _then(_StatusChangeEvent(
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      dotColor: null == dotColor
          ? _self.dotColor
          : dotColor // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$TicketDto {
  int get id;
  String get subject;
  String get description;
  String get customerName;
  String get customerPhone;
  String get customerAvatar;
  String get priority; // 'Low', 'Medium', 'High', 'Critical'
  String get status; // 'Open', 'In Progress', 'Resolved', 'Closed', 'Escalated'
  String get category;
  String get createdAt;
  String? get updatedAt;
  String? get assignedToName;
  String? get assignedToAvatar;
  DateTime? get slaDeadline;
  String? get stationName;
  String? get batteryId;
  String? get transactionId;
  List<String> get tags;
  String get sourceChannel;
  List<TicketMessage> get messages;
  List<StatusChangeEvent> get statusHistory;
  bool get isCritical;
  bool get isResolved;

  /// Create a copy of TicketDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TicketDtoCopyWith<TicketDto> get copyWith =>
      _$TicketDtoCopyWithImpl<TicketDto>(this as TicketDto, _$identity);

  /// Serializes this TicketDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TicketDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.customerAvatar, customerAvatar) ||
                other.customerAvatar == customerAvatar) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.assignedToName, assignedToName) ||
                other.assignedToName == assignedToName) &&
            (identical(other.assignedToAvatar, assignedToAvatar) ||
                other.assignedToAvatar == assignedToAvatar) &&
            (identical(other.slaDeadline, slaDeadline) ||
                other.slaDeadline == slaDeadline) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.batteryId, batteryId) ||
                other.batteryId == batteryId) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.sourceChannel, sourceChannel) ||
                other.sourceChannel == sourceChannel) &&
            const DeepCollectionEquality().equals(other.messages, messages) &&
            const DeepCollectionEquality()
                .equals(other.statusHistory, statusHistory) &&
            (identical(other.isCritical, isCritical) ||
                other.isCritical == isCritical) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        subject,
        description,
        customerName,
        customerPhone,
        customerAvatar,
        priority,
        status,
        category,
        createdAt,
        updatedAt,
        assignedToName,
        assignedToAvatar,
        slaDeadline,
        stationName,
        batteryId,
        transactionId,
        const DeepCollectionEquality().hash(tags),
        sourceChannel,
        const DeepCollectionEquality().hash(messages),
        const DeepCollectionEquality().hash(statusHistory),
        isCritical,
        isResolved
      ]);

  @override
  String toString() {
    return 'TicketDto(id: $id, subject: $subject, description: $description, customerName: $customerName, customerPhone: $customerPhone, customerAvatar: $customerAvatar, priority: $priority, status: $status, category: $category, createdAt: $createdAt, updatedAt: $updatedAt, assignedToName: $assignedToName, assignedToAvatar: $assignedToAvatar, slaDeadline: $slaDeadline, stationName: $stationName, batteryId: $batteryId, transactionId: $transactionId, tags: $tags, sourceChannel: $sourceChannel, messages: $messages, statusHistory: $statusHistory, isCritical: $isCritical, isResolved: $isResolved)';
  }
}

/// @nodoc
abstract mixin class $TicketDtoCopyWith<$Res> {
  factory $TicketDtoCopyWith(TicketDto value, $Res Function(TicketDto) _then) =
      _$TicketDtoCopyWithImpl;
  @useResult
  $Res call(
      {int id,
      String subject,
      String description,
      String customerName,
      String customerPhone,
      String customerAvatar,
      String priority,
      String status,
      String category,
      String createdAt,
      String? updatedAt,
      String? assignedToName,
      String? assignedToAvatar,
      DateTime? slaDeadline,
      String? stationName,
      String? batteryId,
      String? transactionId,
      List<String> tags,
      String sourceChannel,
      List<TicketMessage> messages,
      List<StatusChangeEvent> statusHistory,
      bool isCritical,
      bool isResolved});
}

/// @nodoc
class _$TicketDtoCopyWithImpl<$Res> implements $TicketDtoCopyWith<$Res> {
  _$TicketDtoCopyWithImpl(this._self, this._then);

  final TicketDto _self;
  final $Res Function(TicketDto) _then;

  /// Create a copy of TicketDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? description = null,
    Object? customerName = null,
    Object? customerPhone = null,
    Object? customerAvatar = null,
    Object? priority = null,
    Object? status = null,
    Object? category = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? assignedToName = freezed,
    Object? assignedToAvatar = freezed,
    Object? slaDeadline = freezed,
    Object? stationName = freezed,
    Object? batteryId = freezed,
    Object? transactionId = freezed,
    Object? tags = null,
    Object? sourceChannel = null,
    Object? messages = null,
    Object? statusHistory = null,
    Object? isCritical = null,
    Object? isResolved = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: null == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      customerAvatar: null == customerAvatar
          ? _self.customerAvatar
          : customerAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedToName: freezed == assignedToName
          ? _self.assignedToName
          : assignedToName // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedToAvatar: freezed == assignedToAvatar
          ? _self.assignedToAvatar
          : assignedToAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      slaDeadline: freezed == slaDeadline
          ? _self.slaDeadline
          : slaDeadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      stationName: freezed == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryId: freezed == batteryId
          ? _self.batteryId
          : batteryId // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _self.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sourceChannel: null == sourceChannel
          ? _self.sourceChannel
          : sourceChannel // ignore: cast_nullable_to_non_nullable
              as String,
      messages: null == messages
          ? _self.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<TicketMessage>,
      statusHistory: null == statusHistory
          ? _self.statusHistory
          : statusHistory // ignore: cast_nullable_to_non_nullable
              as List<StatusChangeEvent>,
      isCritical: null == isCritical
          ? _self.isCritical
          : isCritical // ignore: cast_nullable_to_non_nullable
              as bool,
      isResolved: null == isResolved
          ? _self.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [TicketDto].
extension TicketDtoPatterns on TicketDto {
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
    TResult Function(_TicketDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketDto() when $default != null:
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
    TResult Function(_TicketDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketDto():
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
    TResult? Function(_TicketDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketDto() when $default != null:
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
            String subject,
            String description,
            String customerName,
            String customerPhone,
            String customerAvatar,
            String priority,
            String status,
            String category,
            String createdAt,
            String? updatedAt,
            String? assignedToName,
            String? assignedToAvatar,
            DateTime? slaDeadline,
            String? stationName,
            String? batteryId,
            String? transactionId,
            List<String> tags,
            String sourceChannel,
            List<TicketMessage> messages,
            List<StatusChangeEvent> statusHistory,
            bool isCritical,
            bool isResolved)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketDto() when $default != null:
        return $default(
            _that.id,
            _that.subject,
            _that.description,
            _that.customerName,
            _that.customerPhone,
            _that.customerAvatar,
            _that.priority,
            _that.status,
            _that.category,
            _that.createdAt,
            _that.updatedAt,
            _that.assignedToName,
            _that.assignedToAvatar,
            _that.slaDeadline,
            _that.stationName,
            _that.batteryId,
            _that.transactionId,
            _that.tags,
            _that.sourceChannel,
            _that.messages,
            _that.statusHistory,
            _that.isCritical,
            _that.isResolved);
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
            String subject,
            String description,
            String customerName,
            String customerPhone,
            String customerAvatar,
            String priority,
            String status,
            String category,
            String createdAt,
            String? updatedAt,
            String? assignedToName,
            String? assignedToAvatar,
            DateTime? slaDeadline,
            String? stationName,
            String? batteryId,
            String? transactionId,
            List<String> tags,
            String sourceChannel,
            List<TicketMessage> messages,
            List<StatusChangeEvent> statusHistory,
            bool isCritical,
            bool isResolved)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketDto():
        return $default(
            _that.id,
            _that.subject,
            _that.description,
            _that.customerName,
            _that.customerPhone,
            _that.customerAvatar,
            _that.priority,
            _that.status,
            _that.category,
            _that.createdAt,
            _that.updatedAt,
            _that.assignedToName,
            _that.assignedToAvatar,
            _that.slaDeadline,
            _that.stationName,
            _that.batteryId,
            _that.transactionId,
            _that.tags,
            _that.sourceChannel,
            _that.messages,
            _that.statusHistory,
            _that.isCritical,
            _that.isResolved);
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
            String subject,
            String description,
            String customerName,
            String customerPhone,
            String customerAvatar,
            String priority,
            String status,
            String category,
            String createdAt,
            String? updatedAt,
            String? assignedToName,
            String? assignedToAvatar,
            DateTime? slaDeadline,
            String? stationName,
            String? batteryId,
            String? transactionId,
            List<String> tags,
            String sourceChannel,
            List<TicketMessage> messages,
            List<StatusChangeEvent> statusHistory,
            bool isCritical,
            bool isResolved)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketDto() when $default != null:
        return $default(
            _that.id,
            _that.subject,
            _that.description,
            _that.customerName,
            _that.customerPhone,
            _that.customerAvatar,
            _that.priority,
            _that.status,
            _that.category,
            _that.createdAt,
            _that.updatedAt,
            _that.assignedToName,
            _that.assignedToAvatar,
            _that.slaDeadline,
            _that.stationName,
            _that.batteryId,
            _that.transactionId,
            _that.tags,
            _that.sourceChannel,
            _that.messages,
            _that.statusHistory,
            _that.isCritical,
            _that.isResolved);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TicketDto implements TicketDto {
  const _TicketDto(
      {required this.id,
      required this.subject,
      required this.description,
      required this.customerName,
      required this.customerPhone,
      required this.customerAvatar,
      required this.priority,
      required this.status,
      required this.category,
      required this.createdAt,
      this.updatedAt,
      this.assignedToName,
      this.assignedToAvatar,
      this.slaDeadline,
      this.stationName,
      this.batteryId,
      this.transactionId,
      final List<String> tags = const [],
      this.sourceChannel = 'Mobile App',
      final List<TicketMessage> messages = const [],
      final List<StatusChangeEvent> statusHistory = const [],
      this.isCritical = false,
      this.isResolved = false})
      : _tags = tags,
        _messages = messages,
        _statusHistory = statusHistory;
  factory _TicketDto.fromJson(Map<String, dynamic> json) =>
      _$TicketDtoFromJson(json);

  @override
  final int id;
  @override
  final String subject;
  @override
  final String description;
  @override
  final String customerName;
  @override
  final String customerPhone;
  @override
  final String customerAvatar;
  @override
  final String priority;
// 'Low', 'Medium', 'High', 'Critical'
  @override
  final String status;
// 'Open', 'In Progress', 'Resolved', 'Closed', 'Escalated'
  @override
  final String category;
  @override
  final String createdAt;
  @override
  final String? updatedAt;
  @override
  final String? assignedToName;
  @override
  final String? assignedToAvatar;
  @override
  final DateTime? slaDeadline;
  @override
  final String? stationName;
  @override
  final String? batteryId;
  @override
  final String? transactionId;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String sourceChannel;
  final List<TicketMessage> _messages;
  @override
  @JsonKey()
  List<TicketMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  final List<StatusChangeEvent> _statusHistory;
  @override
  @JsonKey()
  List<StatusChangeEvent> get statusHistory {
    if (_statusHistory is EqualUnmodifiableListView) return _statusHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_statusHistory);
  }

  @override
  @JsonKey()
  final bool isCritical;
  @override
  @JsonKey()
  final bool isResolved;

  /// Create a copy of TicketDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TicketDtoCopyWith<_TicketDto> get copyWith =>
      __$TicketDtoCopyWithImpl<_TicketDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TicketDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TicketDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.subject, subject) || other.subject == subject) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.customerName, customerName) ||
                other.customerName == customerName) &&
            (identical(other.customerPhone, customerPhone) ||
                other.customerPhone == customerPhone) &&
            (identical(other.customerAvatar, customerAvatar) ||
                other.customerAvatar == customerAvatar) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.assignedToName, assignedToName) ||
                other.assignedToName == assignedToName) &&
            (identical(other.assignedToAvatar, assignedToAvatar) ||
                other.assignedToAvatar == assignedToAvatar) &&
            (identical(other.slaDeadline, slaDeadline) ||
                other.slaDeadline == slaDeadline) &&
            (identical(other.stationName, stationName) ||
                other.stationName == stationName) &&
            (identical(other.batteryId, batteryId) ||
                other.batteryId == batteryId) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.sourceChannel, sourceChannel) ||
                other.sourceChannel == sourceChannel) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            const DeepCollectionEquality()
                .equals(other._statusHistory, _statusHistory) &&
            (identical(other.isCritical, isCritical) ||
                other.isCritical == isCritical) &&
            (identical(other.isResolved, isResolved) ||
                other.isResolved == isResolved));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        subject,
        description,
        customerName,
        customerPhone,
        customerAvatar,
        priority,
        status,
        category,
        createdAt,
        updatedAt,
        assignedToName,
        assignedToAvatar,
        slaDeadline,
        stationName,
        batteryId,
        transactionId,
        const DeepCollectionEquality().hash(_tags),
        sourceChannel,
        const DeepCollectionEquality().hash(_messages),
        const DeepCollectionEquality().hash(_statusHistory),
        isCritical,
        isResolved
      ]);

  @override
  String toString() {
    return 'TicketDto(id: $id, subject: $subject, description: $description, customerName: $customerName, customerPhone: $customerPhone, customerAvatar: $customerAvatar, priority: $priority, status: $status, category: $category, createdAt: $createdAt, updatedAt: $updatedAt, assignedToName: $assignedToName, assignedToAvatar: $assignedToAvatar, slaDeadline: $slaDeadline, stationName: $stationName, batteryId: $batteryId, transactionId: $transactionId, tags: $tags, sourceChannel: $sourceChannel, messages: $messages, statusHistory: $statusHistory, isCritical: $isCritical, isResolved: $isResolved)';
  }
}

/// @nodoc
abstract mixin class _$TicketDtoCopyWith<$Res>
    implements $TicketDtoCopyWith<$Res> {
  factory _$TicketDtoCopyWith(
          _TicketDto value, $Res Function(_TicketDto) _then) =
      __$TicketDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int id,
      String subject,
      String description,
      String customerName,
      String customerPhone,
      String customerAvatar,
      String priority,
      String status,
      String category,
      String createdAt,
      String? updatedAt,
      String? assignedToName,
      String? assignedToAvatar,
      DateTime? slaDeadline,
      String? stationName,
      String? batteryId,
      String? transactionId,
      List<String> tags,
      String sourceChannel,
      List<TicketMessage> messages,
      List<StatusChangeEvent> statusHistory,
      bool isCritical,
      bool isResolved});
}

/// @nodoc
class __$TicketDtoCopyWithImpl<$Res> implements _$TicketDtoCopyWith<$Res> {
  __$TicketDtoCopyWithImpl(this._self, this._then);

  final _TicketDto _self;
  final $Res Function(_TicketDto) _then;

  /// Create a copy of TicketDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? subject = null,
    Object? description = null,
    Object? customerName = null,
    Object? customerPhone = null,
    Object? customerAvatar = null,
    Object? priority = null,
    Object? status = null,
    Object? category = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? assignedToName = freezed,
    Object? assignedToAvatar = freezed,
    Object? slaDeadline = freezed,
    Object? stationName = freezed,
    Object? batteryId = freezed,
    Object? transactionId = freezed,
    Object? tags = null,
    Object? sourceChannel = null,
    Object? messages = null,
    Object? statusHistory = null,
    Object? isCritical = null,
    Object? isResolved = null,
  }) {
    return _then(_TicketDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      subject: null == subject
          ? _self.subject
          : subject // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      customerName: null == customerName
          ? _self.customerName
          : customerName // ignore: cast_nullable_to_non_nullable
              as String,
      customerPhone: null == customerPhone
          ? _self.customerPhone
          : customerPhone // ignore: cast_nullable_to_non_nullable
              as String,
      customerAvatar: null == customerAvatar
          ? _self.customerAvatar
          : customerAvatar // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _self.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedToName: freezed == assignedToName
          ? _self.assignedToName
          : assignedToName // ignore: cast_nullable_to_non_nullable
              as String?,
      assignedToAvatar: freezed == assignedToAvatar
          ? _self.assignedToAvatar
          : assignedToAvatar // ignore: cast_nullable_to_non_nullable
              as String?,
      slaDeadline: freezed == slaDeadline
          ? _self.slaDeadline
          : slaDeadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      stationName: freezed == stationName
          ? _self.stationName
          : stationName // ignore: cast_nullable_to_non_nullable
              as String?,
      batteryId: freezed == batteryId
          ? _self.batteryId
          : batteryId // ignore: cast_nullable_to_non_nullable
              as String?,
      transactionId: freezed == transactionId
          ? _self.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sourceChannel: null == sourceChannel
          ? _self.sourceChannel
          : sourceChannel // ignore: cast_nullable_to_non_nullable
              as String,
      messages: null == messages
          ? _self._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as List<TicketMessage>,
      statusHistory: null == statusHistory
          ? _self._statusHistory
          : statusHistory // ignore: cast_nullable_to_non_nullable
              as List<StatusChangeEvent>,
      isCritical: null == isCritical
          ? _self.isCritical
          : isCritical // ignore: cast_nullable_to_non_nullable
              as bool,
      isResolved: null == isResolved
          ? _self.isResolved
          : isResolved // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$TicketMetric {
  String get label;
  String get value;
  String? get trend;
  String get color;

  /// Create a copy of TicketMetric
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TicketMetricCopyWith<TicketMetric> get copyWith =>
      _$TicketMetricCopyWithImpl<TicketMetric>(
          this as TicketMetric, _$identity);

  /// Serializes this TicketMetric to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TicketMetric &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value, trend, color);

  @override
  String toString() {
    return 'TicketMetric(label: $label, value: $value, trend: $trend, color: $color)';
  }
}

/// @nodoc
abstract mixin class $TicketMetricCopyWith<$Res> {
  factory $TicketMetricCopyWith(
          TicketMetric value, $Res Function(TicketMetric) _then) =
      _$TicketMetricCopyWithImpl;
  @useResult
  $Res call({String label, String value, String? trend, String color});
}

/// @nodoc
class _$TicketMetricCopyWithImpl<$Res> implements $TicketMetricCopyWith<$Res> {
  _$TicketMetricCopyWithImpl(this._self, this._then);

  final TicketMetric _self;
  final $Res Function(TicketMetric) _then;

  /// Create a copy of TicketMetric
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? trend = freezed,
    Object? color = null,
  }) {
    return _then(_self.copyWith(
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      trend: freezed == trend
          ? _self.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as String?,
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [TicketMetric].
extension TicketMetricPatterns on TicketMetric {
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
    TResult Function(_TicketMetric value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketMetric() when $default != null:
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
    TResult Function(_TicketMetric value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketMetric():
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
    TResult? Function(_TicketMetric value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketMetric() when $default != null:
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
    TResult Function(String label, String value, String? trend, String color)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketMetric() when $default != null:
        return $default(_that.label, _that.value, _that.trend, _that.color);
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
    TResult Function(String label, String value, String? trend, String color)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketMetric():
        return $default(_that.label, _that.value, _that.trend, _that.color);
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
    TResult? Function(String label, String value, String? trend, String color)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketMetric() when $default != null:
        return $default(_that.label, _that.value, _that.trend, _that.color);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TicketMetric implements TicketMetric {
  const _TicketMetric(
      {required this.label,
      required this.value,
      this.trend,
      required this.color});
  factory _TicketMetric.fromJson(Map<String, dynamic> json) =>
      _$TicketMetricFromJson(json);

  @override
  final String label;
  @override
  final String value;
  @override
  final String? trend;
  @override
  final String color;

  /// Create a copy of TicketMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TicketMetricCopyWith<_TicketMetric> get copyWith =>
      __$TicketMetricCopyWithImpl<_TicketMetric>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TicketMetricToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TicketMetric &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.trend, trend) || other.trend == trend) &&
            (identical(other.color, color) || other.color == color));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, label, value, trend, color);

  @override
  String toString() {
    return 'TicketMetric(label: $label, value: $value, trend: $trend, color: $color)';
  }
}

/// @nodoc
abstract mixin class _$TicketMetricCopyWith<$Res>
    implements $TicketMetricCopyWith<$Res> {
  factory _$TicketMetricCopyWith(
          _TicketMetric value, $Res Function(_TicketMetric) _then) =
      __$TicketMetricCopyWithImpl;
  @override
  @useResult
  $Res call({String label, String value, String? trend, String color});
}

/// @nodoc
class __$TicketMetricCopyWithImpl<$Res>
    implements _$TicketMetricCopyWith<$Res> {
  __$TicketMetricCopyWithImpl(this._self, this._then);

  final _TicketMetric _self;
  final $Res Function(_TicketMetric) _then;

  /// Create a copy of TicketMetric
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? label = null,
    Object? value = null,
    Object? trend = freezed,
    Object? color = null,
  }) {
    return _then(_TicketMetric(
      label: null == label
          ? _self.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _self.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      trend: freezed == trend
          ? _self.trend
          : trend // ignore: cast_nullable_to_non_nullable
              as String?,
      color: null == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$TicketState {
  bool get isLoading;
  String? get error;
  List<TicketDto> get tickets;
  List<TicketMetric> get metrics;
  int? get selectedTicketId;
  bool get isFilterPanelOpen;
  bool get isMetricsView;

  /// Create a copy of TicketState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TicketStateCopyWith<TicketState> get copyWith =>
      _$TicketStateCopyWithImpl<TicketState>(this as TicketState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TicketState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other.tickets, tickets) &&
            const DeepCollectionEquality().equals(other.metrics, metrics) &&
            (identical(other.selectedTicketId, selectedTicketId) ||
                other.selectedTicketId == selectedTicketId) &&
            (identical(other.isFilterPanelOpen, isFilterPanelOpen) ||
                other.isFilterPanelOpen == isFilterPanelOpen) &&
            (identical(other.isMetricsView, isMetricsView) ||
                other.isMetricsView == isMetricsView));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      const DeepCollectionEquality().hash(tickets),
      const DeepCollectionEquality().hash(metrics),
      selectedTicketId,
      isFilterPanelOpen,
      isMetricsView);

  @override
  String toString() {
    return 'TicketState(isLoading: $isLoading, error: $error, tickets: $tickets, metrics: $metrics, selectedTicketId: $selectedTicketId, isFilterPanelOpen: $isFilterPanelOpen, isMetricsView: $isMetricsView)';
  }
}

/// @nodoc
abstract mixin class $TicketStateCopyWith<$Res> {
  factory $TicketStateCopyWith(
          TicketState value, $Res Function(TicketState) _then) =
      _$TicketStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      List<TicketDto> tickets,
      List<TicketMetric> metrics,
      int? selectedTicketId,
      bool isFilterPanelOpen,
      bool isMetricsView});
}

/// @nodoc
class _$TicketStateCopyWithImpl<$Res> implements $TicketStateCopyWith<$Res> {
  _$TicketStateCopyWithImpl(this._self, this._then);

  final TicketState _self;
  final $Res Function(TicketState) _then;

  /// Create a copy of TicketState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? tickets = null,
    Object? metrics = null,
    Object? selectedTicketId = freezed,
    Object? isFilterPanelOpen = null,
    Object? isMetricsView = null,
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
      tickets: null == tickets
          ? _self.tickets
          : tickets // ignore: cast_nullable_to_non_nullable
              as List<TicketDto>,
      metrics: null == metrics
          ? _self.metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as List<TicketMetric>,
      selectedTicketId: freezed == selectedTicketId
          ? _self.selectedTicketId
          : selectedTicketId // ignore: cast_nullable_to_non_nullable
              as int?,
      isFilterPanelOpen: null == isFilterPanelOpen
          ? _self.isFilterPanelOpen
          : isFilterPanelOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      isMetricsView: null == isMetricsView
          ? _self.isMetricsView
          : isMetricsView // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [TicketState].
extension TicketStatePatterns on TicketState {
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
    TResult Function(_TicketState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketState() when $default != null:
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
    TResult Function(_TicketState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketState():
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
    TResult? Function(_TicketState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketState() when $default != null:
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
            bool isLoading,
            String? error,
            List<TicketDto> tickets,
            List<TicketMetric> metrics,
            int? selectedTicketId,
            bool isFilterPanelOpen,
            bool isMetricsView)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TicketState() when $default != null:
        return $default(
            _that.isLoading,
            _that.error,
            _that.tickets,
            _that.metrics,
            _that.selectedTicketId,
            _that.isFilterPanelOpen,
            _that.isMetricsView);
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
            bool isLoading,
            String? error,
            List<TicketDto> tickets,
            List<TicketMetric> metrics,
            int? selectedTicketId,
            bool isFilterPanelOpen,
            bool isMetricsView)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketState():
        return $default(
            _that.isLoading,
            _that.error,
            _that.tickets,
            _that.metrics,
            _that.selectedTicketId,
            _that.isFilterPanelOpen,
            _that.isMetricsView);
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
            bool isLoading,
            String? error,
            List<TicketDto> tickets,
            List<TicketMetric> metrics,
            int? selectedTicketId,
            bool isFilterPanelOpen,
            bool isMetricsView)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TicketState() when $default != null:
        return $default(
            _that.isLoading,
            _that.error,
            _that.tickets,
            _that.metrics,
            _that.selectedTicketId,
            _that.isFilterPanelOpen,
            _that.isMetricsView);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _TicketState implements TicketState {
  const _TicketState(
      {this.isLoading = true,
      this.error,
      final List<TicketDto> tickets = const [],
      final List<TicketMetric> metrics = const [],
      this.selectedTicketId,
      this.isFilterPanelOpen = false,
      this.isMetricsView = false})
      : _tickets = tickets,
        _metrics = metrics;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;
  final List<TicketDto> _tickets;
  @override
  @JsonKey()
  List<TicketDto> get tickets {
    if (_tickets is EqualUnmodifiableListView) return _tickets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tickets);
  }

  final List<TicketMetric> _metrics;
  @override
  @JsonKey()
  List<TicketMetric> get metrics {
    if (_metrics is EqualUnmodifiableListView) return _metrics;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_metrics);
  }

  @override
  final int? selectedTicketId;
  @override
  @JsonKey()
  final bool isFilterPanelOpen;
  @override
  @JsonKey()
  final bool isMetricsView;

  /// Create a copy of TicketState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TicketStateCopyWith<_TicketState> get copyWith =>
      __$TicketStateCopyWithImpl<_TicketState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TicketState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._tickets, _tickets) &&
            const DeepCollectionEquality().equals(other._metrics, _metrics) &&
            (identical(other.selectedTicketId, selectedTicketId) ||
                other.selectedTicketId == selectedTicketId) &&
            (identical(other.isFilterPanelOpen, isFilterPanelOpen) ||
                other.isFilterPanelOpen == isFilterPanelOpen) &&
            (identical(other.isMetricsView, isMetricsView) ||
                other.isMetricsView == isMetricsView));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      error,
      const DeepCollectionEquality().hash(_tickets),
      const DeepCollectionEquality().hash(_metrics),
      selectedTicketId,
      isFilterPanelOpen,
      isMetricsView);

  @override
  String toString() {
    return 'TicketState(isLoading: $isLoading, error: $error, tickets: $tickets, metrics: $metrics, selectedTicketId: $selectedTicketId, isFilterPanelOpen: $isFilterPanelOpen, isMetricsView: $isMetricsView)';
  }
}

/// @nodoc
abstract mixin class _$TicketStateCopyWith<$Res>
    implements $TicketStateCopyWith<$Res> {
  factory _$TicketStateCopyWith(
          _TicketState value, $Res Function(_TicketState) _then) =
      __$TicketStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      List<TicketDto> tickets,
      List<TicketMetric> metrics,
      int? selectedTicketId,
      bool isFilterPanelOpen,
      bool isMetricsView});
}

/// @nodoc
class __$TicketStateCopyWithImpl<$Res> implements _$TicketStateCopyWith<$Res> {
  __$TicketStateCopyWithImpl(this._self, this._then);

  final _TicketState _self;
  final $Res Function(_TicketState) _then;

  /// Create a copy of TicketState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? tickets = null,
    Object? metrics = null,
    Object? selectedTicketId = freezed,
    Object? isFilterPanelOpen = null,
    Object? isMetricsView = null,
  }) {
    return _then(_TicketState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      tickets: null == tickets
          ? _self._tickets
          : tickets // ignore: cast_nullable_to_non_nullable
              as List<TicketDto>,
      metrics: null == metrics
          ? _self._metrics
          : metrics // ignore: cast_nullable_to_non_nullable
              as List<TicketMetric>,
      selectedTicketId: freezed == selectedTicketId
          ? _self.selectedTicketId
          : selectedTicketId // ignore: cast_nullable_to_non_nullable
              as int?,
      isFilterPanelOpen: null == isFilterPanelOpen
          ? _self.isFilterPanelOpen
          : isFilterPanelOpen // ignore: cast_nullable_to_non_nullable
              as bool,
      isMetricsView: null == isMetricsView
          ? _self.isMetricsView
          : isMetricsView // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
