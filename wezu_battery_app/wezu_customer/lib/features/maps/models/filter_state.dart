class StationFilterState {
  final double maxRadius;
  final double minPrice;
  final double maxPrice;
  final double minRating;
  final bool onlyAvailable;
  final List<String> batteryTypes;
  final int minCapacity;
  final bool? isDealer;
  final bool isOpenNow;
  final bool is24x7;
  final List<String> chargingSpeeds;
  final List<String> amenities;

  StationFilterState({
    this.maxRadius = 50.0,
    this.minPrice = 0.0,
    this.maxPrice = 200.0,
    this.minRating = 0.0,
    this.onlyAvailable = false,
    this.batteryTypes = const [],
    this.minCapacity = 40,
    this.isDealer,
    this.isOpenNow = false,
    this.is24x7 = false,
    this.chargingSpeeds = const [],
    this.amenities = const [],
  });

  StationFilterState copyWith({
    double? maxRadius,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? onlyAvailable,
    List<String>? batteryTypes,
    int? minCapacity,
    bool? isDealer,
    bool? isOpenNow,
    bool? is24x7,
    List<String>? chargingSpeeds,
    List<String>? amenities,
  }) {
    return StationFilterState(
      maxRadius: maxRadius ?? this.maxRadius,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRating: minRating ?? this.minRating,
      onlyAvailable: onlyAvailable ?? this.onlyAvailable,
      batteryTypes: batteryTypes ?? this.batteryTypes,
      minCapacity: minCapacity ?? this.minCapacity,
      isDealer: isDealer ?? this.isDealer,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      is24x7: is24x7 ?? this.is24x7,
      chargingSpeeds: chargingSpeeds ?? this.chargingSpeeds,
      amenities: amenities ?? this.amenities,
    );
  }
}
