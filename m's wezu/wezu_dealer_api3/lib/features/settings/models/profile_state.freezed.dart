// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileDto {
  @JsonKey(name: 'business_name')
  String? get businessName;
  @JsonKey(name: 'gst_number')
  String? get gstNumber;
  @JsonKey(name: 'pan_number')
  String? get panNumber;
  @JsonKey(name: 'year_established')
  String? get yearEstablished;
  @JsonKey(name: 'website_url')
  String? get websiteUrl;
  @JsonKey(name: 'business_description')
  String? get businessDescription;
  @JsonKey(name: 'contact_person')
  String? get contactPerson;
  @JsonKey(name: 'contact_email')
  String? get contactEmail;
  @JsonKey(name: 'contact_phone')
  String? get contactPhone;
  @JsonKey(name: 'alternate_phone')
  String? get alternatePhone;
  @JsonKey(name: 'whatsapp_number')
  String? get whatsappNumber;
  @JsonKey(name: 'support_email')
  String? get supportEmail;
  @JsonKey(name: 'support_phone')
  String? get supportPhone;
  String? get email; // Primary account email from User table
  @JsonKey(name: 'address_line1')
  String? get addressLine1;
  String? get city;
  String? get state;
  String? get pincode;
  @JsonKey(name: 'bank_details')
  Map<String, dynamic>? get bankDetails;
  @JsonKey(name: 'profile_picture')
  String? get profilePicture;

  /// Create a copy of ProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileDtoCopyWith<ProfileDto> get copyWith =>
      _$ProfileDtoCopyWithImpl<ProfileDto>(this as ProfileDto, _$identity);

  /// Serializes this ProfileDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileDto &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.gstNumber, gstNumber) ||
                other.gstNumber == gstNumber) &&
            (identical(other.panNumber, panNumber) ||
                other.panNumber == panNumber) &&
            (identical(other.yearEstablished, yearEstablished) ||
                other.yearEstablished == yearEstablished) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.businessDescription, businessDescription) ||
                other.businessDescription == businessDescription) &&
            (identical(other.contactPerson, contactPerson) ||
                other.contactPerson == contactPerson) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.alternatePhone, alternatePhone) ||
                other.alternatePhone == alternatePhone) &&
            (identical(other.whatsappNumber, whatsappNumber) ||
                other.whatsappNumber == whatsappNumber) &&
            (identical(other.supportEmail, supportEmail) ||
                other.supportEmail == supportEmail) &&
            (identical(other.supportPhone, supportPhone) ||
                other.supportPhone == supportPhone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.addressLine1, addressLine1) ||
                other.addressLine1 == addressLine1) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pincode, pincode) || other.pincode == pincode) &&
            const DeepCollectionEquality()
                .equals(other.bankDetails, bankDetails) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        businessName,
        gstNumber,
        panNumber,
        yearEstablished,
        websiteUrl,
        businessDescription,
        contactPerson,
        contactEmail,
        contactPhone,
        alternatePhone,
        whatsappNumber,
        supportEmail,
        supportPhone,
        email,
        addressLine1,
        city,
        state,
        pincode,
        const DeepCollectionEquality().hash(bankDetails),
        profilePicture
      ]);

  @override
  String toString() {
    return 'ProfileDto(businessName: $businessName, gstNumber: $gstNumber, panNumber: $panNumber, yearEstablished: $yearEstablished, websiteUrl: $websiteUrl, businessDescription: $businessDescription, contactPerson: $contactPerson, contactEmail: $contactEmail, contactPhone: $contactPhone, alternatePhone: $alternatePhone, whatsappNumber: $whatsappNumber, supportEmail: $supportEmail, supportPhone: $supportPhone, email: $email, addressLine1: $addressLine1, city: $city, state: $state, pincode: $pincode, bankDetails: $bankDetails, profilePicture: $profilePicture)';
  }
}

/// @nodoc
abstract mixin class $ProfileDtoCopyWith<$Res> {
  factory $ProfileDtoCopyWith(
          ProfileDto value, $Res Function(ProfileDto) _then) =
      _$ProfileDtoCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'business_name') String? businessName,
      @JsonKey(name: 'gst_number') String? gstNumber,
      @JsonKey(name: 'pan_number') String? panNumber,
      @JsonKey(name: 'year_established') String? yearEstablished,
      @JsonKey(name: 'website_url') String? websiteUrl,
      @JsonKey(name: 'business_description') String? businessDescription,
      @JsonKey(name: 'contact_person') String? contactPerson,
      @JsonKey(name: 'contact_email') String? contactEmail,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'alternate_phone') String? alternatePhone,
      @JsonKey(name: 'whatsapp_number') String? whatsappNumber,
      @JsonKey(name: 'support_email') String? supportEmail,
      @JsonKey(name: 'support_phone') String? supportPhone,
      String? email,
      @JsonKey(name: 'address_line1') String? addressLine1,
      String? city,
      String? state,
      String? pincode,
      @JsonKey(name: 'bank_details') Map<String, dynamic>? bankDetails,
      @JsonKey(name: 'profile_picture') String? profilePicture});
}

/// @nodoc
class _$ProfileDtoCopyWithImpl<$Res> implements $ProfileDtoCopyWith<$Res> {
  _$ProfileDtoCopyWithImpl(this._self, this._then);

  final ProfileDto _self;
  final $Res Function(ProfileDto) _then;

  /// Create a copy of ProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? businessName = freezed,
    Object? gstNumber = freezed,
    Object? panNumber = freezed,
    Object? yearEstablished = freezed,
    Object? websiteUrl = freezed,
    Object? businessDescription = freezed,
    Object? contactPerson = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
    Object? alternatePhone = freezed,
    Object? whatsappNumber = freezed,
    Object? supportEmail = freezed,
    Object? supportPhone = freezed,
    Object? email = freezed,
    Object? addressLine1 = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pincode = freezed,
    Object? bankDetails = freezed,
    Object? profilePicture = freezed,
  }) {
    return _then(_self.copyWith(
      businessName: freezed == businessName
          ? _self.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      gstNumber: freezed == gstNumber
          ? _self.gstNumber
          : gstNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      panNumber: freezed == panNumber
          ? _self.panNumber
          : panNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      yearEstablished: freezed == yearEstablished
          ? _self.yearEstablished
          : yearEstablished // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _self.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      businessDescription: freezed == businessDescription
          ? _self.businessDescription
          : businessDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPerson: freezed == contactPerson
          ? _self.contactPerson
          : contactPerson // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _self.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _self.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      alternatePhone: freezed == alternatePhone
          ? _self.alternatePhone
          : alternatePhone // ignore: cast_nullable_to_non_nullable
              as String?,
      whatsappNumber: freezed == whatsappNumber
          ? _self.whatsappNumber
          : whatsappNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      supportEmail: freezed == supportEmail
          ? _self.supportEmail
          : supportEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      supportPhone: freezed == supportPhone
          ? _self.supportPhone
          : supportPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLine1: freezed == addressLine1
          ? _self.addressLine1
          : addressLine1 // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      pincode: freezed == pincode
          ? _self.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String?,
      bankDetails: freezed == bankDetails
          ? _self.bankDetails
          : bankDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      profilePicture: freezed == profilePicture
          ? _self.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProfileDto].
extension ProfileDtoPatterns on ProfileDto {
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
    TResult Function(_ProfileDto value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileDto() when $default != null:
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
    TResult Function(_ProfileDto value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileDto():
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
    TResult? Function(_ProfileDto value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileDto() when $default != null:
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
            @JsonKey(name: 'business_name') String? businessName,
            @JsonKey(name: 'gst_number') String? gstNumber,
            @JsonKey(name: 'pan_number') String? panNumber,
            @JsonKey(name: 'year_established') String? yearEstablished,
            @JsonKey(name: 'website_url') String? websiteUrl,
            @JsonKey(name: 'business_description') String? businessDescription,
            @JsonKey(name: 'contact_person') String? contactPerson,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'alternate_phone') String? alternatePhone,
            @JsonKey(name: 'whatsapp_number') String? whatsappNumber,
            @JsonKey(name: 'support_email') String? supportEmail,
            @JsonKey(name: 'support_phone') String? supportPhone,
            String? email,
            @JsonKey(name: 'address_line1') String? addressLine1,
            String? city,
            String? state,
            String? pincode,
            @JsonKey(name: 'bank_details') Map<String, dynamic>? bankDetails,
            @JsonKey(name: 'profile_picture') String? profilePicture)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileDto() when $default != null:
        return $default(
            _that.businessName,
            _that.gstNumber,
            _that.panNumber,
            _that.yearEstablished,
            _that.websiteUrl,
            _that.businessDescription,
            _that.contactPerson,
            _that.contactEmail,
            _that.contactPhone,
            _that.alternatePhone,
            _that.whatsappNumber,
            _that.supportEmail,
            _that.supportPhone,
            _that.email,
            _that.addressLine1,
            _that.city,
            _that.state,
            _that.pincode,
            _that.bankDetails,
            _that.profilePicture);
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
            @JsonKey(name: 'business_name') String? businessName,
            @JsonKey(name: 'gst_number') String? gstNumber,
            @JsonKey(name: 'pan_number') String? panNumber,
            @JsonKey(name: 'year_established') String? yearEstablished,
            @JsonKey(name: 'website_url') String? websiteUrl,
            @JsonKey(name: 'business_description') String? businessDescription,
            @JsonKey(name: 'contact_person') String? contactPerson,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'alternate_phone') String? alternatePhone,
            @JsonKey(name: 'whatsapp_number') String? whatsappNumber,
            @JsonKey(name: 'support_email') String? supportEmail,
            @JsonKey(name: 'support_phone') String? supportPhone,
            String? email,
            @JsonKey(name: 'address_line1') String? addressLine1,
            String? city,
            String? state,
            String? pincode,
            @JsonKey(name: 'bank_details') Map<String, dynamic>? bankDetails,
            @JsonKey(name: 'profile_picture') String? profilePicture)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileDto():
        return $default(
            _that.businessName,
            _that.gstNumber,
            _that.panNumber,
            _that.yearEstablished,
            _that.websiteUrl,
            _that.businessDescription,
            _that.contactPerson,
            _that.contactEmail,
            _that.contactPhone,
            _that.alternatePhone,
            _that.whatsappNumber,
            _that.supportEmail,
            _that.supportPhone,
            _that.email,
            _that.addressLine1,
            _that.city,
            _that.state,
            _that.pincode,
            _that.bankDetails,
            _that.profilePicture);
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
            @JsonKey(name: 'business_name') String? businessName,
            @JsonKey(name: 'gst_number') String? gstNumber,
            @JsonKey(name: 'pan_number') String? panNumber,
            @JsonKey(name: 'year_established') String? yearEstablished,
            @JsonKey(name: 'website_url') String? websiteUrl,
            @JsonKey(name: 'business_description') String? businessDescription,
            @JsonKey(name: 'contact_person') String? contactPerson,
            @JsonKey(name: 'contact_email') String? contactEmail,
            @JsonKey(name: 'contact_phone') String? contactPhone,
            @JsonKey(name: 'alternate_phone') String? alternatePhone,
            @JsonKey(name: 'whatsapp_number') String? whatsappNumber,
            @JsonKey(name: 'support_email') String? supportEmail,
            @JsonKey(name: 'support_phone') String? supportPhone,
            String? email,
            @JsonKey(name: 'address_line1') String? addressLine1,
            String? city,
            String? state,
            String? pincode,
            @JsonKey(name: 'bank_details') Map<String, dynamic>? bankDetails,
            @JsonKey(name: 'profile_picture') String? profilePicture)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileDto() when $default != null:
        return $default(
            _that.businessName,
            _that.gstNumber,
            _that.panNumber,
            _that.yearEstablished,
            _that.websiteUrl,
            _that.businessDescription,
            _that.contactPerson,
            _that.contactEmail,
            _that.contactPhone,
            _that.alternatePhone,
            _that.whatsappNumber,
            _that.supportEmail,
            _that.supportPhone,
            _that.email,
            _that.addressLine1,
            _that.city,
            _that.state,
            _that.pincode,
            _that.bankDetails,
            _that.profilePicture);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProfileDto implements ProfileDto {
  const _ProfileDto(
      {@JsonKey(name: 'business_name') this.businessName,
      @JsonKey(name: 'gst_number') this.gstNumber,
      @JsonKey(name: 'pan_number') this.panNumber,
      @JsonKey(name: 'year_established') this.yearEstablished,
      @JsonKey(name: 'website_url') this.websiteUrl,
      @JsonKey(name: 'business_description') this.businessDescription,
      @JsonKey(name: 'contact_person') this.contactPerson,
      @JsonKey(name: 'contact_email') this.contactEmail,
      @JsonKey(name: 'contact_phone') this.contactPhone,
      @JsonKey(name: 'alternate_phone') this.alternatePhone,
      @JsonKey(name: 'whatsapp_number') this.whatsappNumber,
      @JsonKey(name: 'support_email') this.supportEmail,
      @JsonKey(name: 'support_phone') this.supportPhone,
      this.email,
      @JsonKey(name: 'address_line1') this.addressLine1,
      this.city,
      this.state,
      this.pincode,
      @JsonKey(name: 'bank_details') final Map<String, dynamic>? bankDetails,
      @JsonKey(name: 'profile_picture') this.profilePicture})
      : _bankDetails = bankDetails;
  factory _ProfileDto.fromJson(Map<String, dynamic> json) =>
      _$ProfileDtoFromJson(json);

  @override
  @JsonKey(name: 'business_name')
  final String? businessName;
  @override
  @JsonKey(name: 'gst_number')
  final String? gstNumber;
  @override
  @JsonKey(name: 'pan_number')
  final String? panNumber;
  @override
  @JsonKey(name: 'year_established')
  final String? yearEstablished;
  @override
  @JsonKey(name: 'website_url')
  final String? websiteUrl;
  @override
  @JsonKey(name: 'business_description')
  final String? businessDescription;
  @override
  @JsonKey(name: 'contact_person')
  final String? contactPerson;
  @override
  @JsonKey(name: 'contact_email')
  final String? contactEmail;
  @override
  @JsonKey(name: 'contact_phone')
  final String? contactPhone;
  @override
  @JsonKey(name: 'alternate_phone')
  final String? alternatePhone;
  @override
  @JsonKey(name: 'whatsapp_number')
  final String? whatsappNumber;
  @override
  @JsonKey(name: 'support_email')
  final String? supportEmail;
  @override
  @JsonKey(name: 'support_phone')
  final String? supportPhone;
  @override
  final String? email;
// Primary account email from User table
  @override
  @JsonKey(name: 'address_line1')
  final String? addressLine1;
  @override
  final String? city;
  @override
  final String? state;
  @override
  final String? pincode;
  final Map<String, dynamic>? _bankDetails;
  @override
  @JsonKey(name: 'bank_details')
  Map<String, dynamic>? get bankDetails {
    final value = _bankDetails;
    if (value == null) return null;
    if (_bankDetails is EqualUnmodifiableMapView) return _bankDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey(name: 'profile_picture')
  final String? profilePicture;

  /// Create a copy of ProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileDtoCopyWith<_ProfileDto> get copyWith =>
      __$ProfileDtoCopyWithImpl<_ProfileDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProfileDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileDto &&
            (identical(other.businessName, businessName) ||
                other.businessName == businessName) &&
            (identical(other.gstNumber, gstNumber) ||
                other.gstNumber == gstNumber) &&
            (identical(other.panNumber, panNumber) ||
                other.panNumber == panNumber) &&
            (identical(other.yearEstablished, yearEstablished) ||
                other.yearEstablished == yearEstablished) &&
            (identical(other.websiteUrl, websiteUrl) ||
                other.websiteUrl == websiteUrl) &&
            (identical(other.businessDescription, businessDescription) ||
                other.businessDescription == businessDescription) &&
            (identical(other.contactPerson, contactPerson) ||
                other.contactPerson == contactPerson) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.alternatePhone, alternatePhone) ||
                other.alternatePhone == alternatePhone) &&
            (identical(other.whatsappNumber, whatsappNumber) ||
                other.whatsappNumber == whatsappNumber) &&
            (identical(other.supportEmail, supportEmail) ||
                other.supportEmail == supportEmail) &&
            (identical(other.supportPhone, supportPhone) ||
                other.supportPhone == supportPhone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.addressLine1, addressLine1) ||
                other.addressLine1 == addressLine1) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.pincode, pincode) || other.pincode == pincode) &&
            const DeepCollectionEquality()
                .equals(other._bankDetails, _bankDetails) &&
            (identical(other.profilePicture, profilePicture) ||
                other.profilePicture == profilePicture));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        businessName,
        gstNumber,
        panNumber,
        yearEstablished,
        websiteUrl,
        businessDescription,
        contactPerson,
        contactEmail,
        contactPhone,
        alternatePhone,
        whatsappNumber,
        supportEmail,
        supportPhone,
        email,
        addressLine1,
        city,
        state,
        pincode,
        const DeepCollectionEquality().hash(_bankDetails),
        profilePicture
      ]);

  @override
  String toString() {
    return 'ProfileDto(businessName: $businessName, gstNumber: $gstNumber, panNumber: $panNumber, yearEstablished: $yearEstablished, websiteUrl: $websiteUrl, businessDescription: $businessDescription, contactPerson: $contactPerson, contactEmail: $contactEmail, contactPhone: $contactPhone, alternatePhone: $alternatePhone, whatsappNumber: $whatsappNumber, supportEmail: $supportEmail, supportPhone: $supportPhone, email: $email, addressLine1: $addressLine1, city: $city, state: $state, pincode: $pincode, bankDetails: $bankDetails, profilePicture: $profilePicture)';
  }
}

/// @nodoc
abstract mixin class _$ProfileDtoCopyWith<$Res>
    implements $ProfileDtoCopyWith<$Res> {
  factory _$ProfileDtoCopyWith(
          _ProfileDto value, $Res Function(_ProfileDto) _then) =
      __$ProfileDtoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'business_name') String? businessName,
      @JsonKey(name: 'gst_number') String? gstNumber,
      @JsonKey(name: 'pan_number') String? panNumber,
      @JsonKey(name: 'year_established') String? yearEstablished,
      @JsonKey(name: 'website_url') String? websiteUrl,
      @JsonKey(name: 'business_description') String? businessDescription,
      @JsonKey(name: 'contact_person') String? contactPerson,
      @JsonKey(name: 'contact_email') String? contactEmail,
      @JsonKey(name: 'contact_phone') String? contactPhone,
      @JsonKey(name: 'alternate_phone') String? alternatePhone,
      @JsonKey(name: 'whatsapp_number') String? whatsappNumber,
      @JsonKey(name: 'support_email') String? supportEmail,
      @JsonKey(name: 'support_phone') String? supportPhone,
      String? email,
      @JsonKey(name: 'address_line1') String? addressLine1,
      String? city,
      String? state,
      String? pincode,
      @JsonKey(name: 'bank_details') Map<String, dynamic>? bankDetails,
      @JsonKey(name: 'profile_picture') String? profilePicture});
}

/// @nodoc
class __$ProfileDtoCopyWithImpl<$Res> implements _$ProfileDtoCopyWith<$Res> {
  __$ProfileDtoCopyWithImpl(this._self, this._then);

  final _ProfileDto _self;
  final $Res Function(_ProfileDto) _then;

  /// Create a copy of ProfileDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? businessName = freezed,
    Object? gstNumber = freezed,
    Object? panNumber = freezed,
    Object? yearEstablished = freezed,
    Object? websiteUrl = freezed,
    Object? businessDescription = freezed,
    Object? contactPerson = freezed,
    Object? contactEmail = freezed,
    Object? contactPhone = freezed,
    Object? alternatePhone = freezed,
    Object? whatsappNumber = freezed,
    Object? supportEmail = freezed,
    Object? supportPhone = freezed,
    Object? email = freezed,
    Object? addressLine1 = freezed,
    Object? city = freezed,
    Object? state = freezed,
    Object? pincode = freezed,
    Object? bankDetails = freezed,
    Object? profilePicture = freezed,
  }) {
    return _then(_ProfileDto(
      businessName: freezed == businessName
          ? _self.businessName
          : businessName // ignore: cast_nullable_to_non_nullable
              as String?,
      gstNumber: freezed == gstNumber
          ? _self.gstNumber
          : gstNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      panNumber: freezed == panNumber
          ? _self.panNumber
          : panNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      yearEstablished: freezed == yearEstablished
          ? _self.yearEstablished
          : yearEstablished // ignore: cast_nullable_to_non_nullable
              as String?,
      websiteUrl: freezed == websiteUrl
          ? _self.websiteUrl
          : websiteUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      businessDescription: freezed == businessDescription
          ? _self.businessDescription
          : businessDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPerson: freezed == contactPerson
          ? _self.contactPerson
          : contactPerson // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _self.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _self.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      alternatePhone: freezed == alternatePhone
          ? _self.alternatePhone
          : alternatePhone // ignore: cast_nullable_to_non_nullable
              as String?,
      whatsappNumber: freezed == whatsappNumber
          ? _self.whatsappNumber
          : whatsappNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      supportEmail: freezed == supportEmail
          ? _self.supportEmail
          : supportEmail // ignore: cast_nullable_to_non_nullable
              as String?,
      supportPhone: freezed == supportPhone
          ? _self.supportPhone
          : supportPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      addressLine1: freezed == addressLine1
          ? _self.addressLine1
          : addressLine1 // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _self.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      pincode: freezed == pincode
          ? _self.pincode
          : pincode // ignore: cast_nullable_to_non_nullable
              as String?,
      bankDetails: freezed == bankDetails
          ? _self._bankDetails
          : bankDetails // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      profilePicture: freezed == profilePicture
          ? _self.profilePicture
          : profilePicture // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$ProfileState {
  bool get isLoading;
  bool get isUpdating;
  String? get error;
  ProfileDto? get profile;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      _$ProfileStateCopyWithImpl<ProfileState>(
          this as ProfileState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.profile, profile) || other.profile == profile));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isUpdating, error, profile);

  @override
  String toString() {
    return 'ProfileState(isLoading: $isLoading, isUpdating: $isUpdating, error: $error, profile: $profile)';
  }
}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) _then) =
      _$ProfileStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLoading, bool isUpdating, String? error, ProfileDto? profile});

  $ProfileDtoCopyWith<$Res>? get profile;
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res> implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
    Object? profile = freezed,
  }) {
    return _then(_self.copyWith(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      profile: freezed == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as ProfileDto?,
    ));
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileDtoCopyWith<$Res>? get profile {
    if (_self.profile == null) {
      return null;
    }

    return $ProfileDtoCopyWith<$Res>(_self.profile!, (value) {
      return _then(_self.copyWith(profile: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ProfileState].
extension ProfileStatePatterns on ProfileState {
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
    TResult Function(_ProfileState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
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
    TResult Function(_ProfileState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState():
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
    TResult? Function(_ProfileState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
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
    TResult Function(bool isLoading, bool isUpdating, String? error,
            ProfileDto? profile)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
        return $default(
            _that.isLoading, _that.isUpdating, _that.error, _that.profile);
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
            bool isLoading, bool isUpdating, String? error, ProfileDto? profile)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState():
        return $default(
            _that.isLoading, _that.isUpdating, _that.error, _that.profile);
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
    TResult? Function(bool isLoading, bool isUpdating, String? error,
            ProfileDto? profile)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileState() when $default != null:
        return $default(
            _that.isLoading, _that.isUpdating, _that.error, _that.profile);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ProfileState implements ProfileState {
  const _ProfileState(
      {this.isLoading = true,
      this.isUpdating = false,
      this.error,
      this.profile});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isUpdating;
  @override
  final String? error;
  @override
  final ProfileDto? profile;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileStateCopyWith<_ProfileState> get copyWith =>
      __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isUpdating, isUpdating) ||
                other.isUpdating == isUpdating) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.profile, profile) || other.profile == profile));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isUpdating, error, profile);

  @override
  String toString() {
    return 'ProfileState(isLoading: $isLoading, isUpdating: $isUpdating, error: $error, profile: $profile)';
  }
}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(
          _ProfileState value, $Res Function(_ProfileState) _then) =
      __$ProfileStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool isLoading, bool isUpdating, String? error, ProfileDto? profile});

  @override
  $ProfileDtoCopyWith<$Res>? get profile;
}

/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLoading = null,
    Object? isUpdating = null,
    Object? error = freezed,
    Object? profile = freezed,
  }) {
    return _then(_ProfileState(
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isUpdating: null == isUpdating
          ? _self.isUpdating
          : isUpdating // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      profile: freezed == profile
          ? _self.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as ProfileDto?,
    ));
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileDtoCopyWith<$Res>? get profile {
    if (_self.profile == null) {
      return null;
    }

    return $ProfileDtoCopyWith<$Res>(_self.profile!, (value) {
      return _then(_self.copyWith(profile: value));
    });
  }
}

// dart format on
