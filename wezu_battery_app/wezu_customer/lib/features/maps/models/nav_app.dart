/// Model for navigation app options used in the map app selection sheet.
enum NavAppType { googleMaps, appleMaps, waze }

class NavApp {
  final NavAppType type;
  final String name;
  final String iconAsset;
  final bool isInstalled;

  const NavApp({
    required this.type,
    required this.name,
    this.iconAsset = '',
    this.isInstalled = true,
  });

  static const googleMaps = NavApp(
      type: NavAppType.googleMaps,
      name: 'Google Maps',
      iconAsset: 'assets/icons/google_maps.png');
  static const appleMaps = NavApp(
      type: NavAppType.appleMaps,
      name: 'Apple Maps',
      iconAsset: 'assets/icons/apple_maps.png');
  static const waze = NavApp(
      type: NavAppType.waze, name: 'Waze', iconAsset: 'assets/icons/waze.png');

  static List<NavApp> get all => [googleMaps, appleMaps, waze];
}
