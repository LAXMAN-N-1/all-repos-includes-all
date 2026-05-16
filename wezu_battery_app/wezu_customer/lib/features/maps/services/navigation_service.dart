import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

enum NavigationApp { googleMaps, appleMaps, waze }

class NavigationService {
  static Future<void> navigateTo(
    double lat,
    double lng, {
    String? label,
    NavigationApp? preference,
  }) async {
    // 1. Web/Desktop specific logic
    if (kIsWeb) {
      final url = Uri.parse(
          "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // 2. Try direct Google Maps App Scheme (Best for Mobile if installed)
    if (Platform.isAndroid || preference == NavigationApp.googleMaps) {
      final androidUrl = Uri.parse("google.navigation:q=$lat,$lng&mode=d");
      final iosUrl =
          Uri.parse("comgooglemaps://?daddr=$lat,$lng&directionsmode=driving");

      final url = Platform.isAndroid ? androidUrl : iosUrl;

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
        return;
      }
    }

    // 3. Waze Specific
    if (preference == NavigationApp.waze) {
      final url = Uri.parse("waze://?ll=$lat,$lng&navigate=yes");
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
        return;
      }
    }

    // 4. Apple Maps (iOS only)
    if (Platform.isIOS) {
      final url = Uri.parse(
          "maps://?daddr=$lat,$lng&q=${Uri.encodeComponent(label ?? 'Station')}");
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
        return;
      }
    }

    // 5. Fallback: Universal Google Maps link
    final googleMapsUrl = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // 6. Final geo factor for Android if everything else fails
      if (Platform.isAndroid) {
        final geoUrl = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
        if (await canLaunchUrl(geoUrl)) {
          await launchUrl(geoUrl);
        }
      }
    }
  }

  static Future<List<NavigationApp>> getInstalledApps() async {
    if (kIsWeb)
      return []; // Cannot detect installed apps on Web browser reliably

    List<NavigationApp> installed = [];

    // Waze check
    try {
      if (await canLaunchUrl(Uri.parse("waze://"))) {
        installed.add(NavigationApp.waze);
      }
    } catch (_) {}

    if (!kIsWeb && Platform.isIOS) {
      try {
        if (await canLaunchUrl(Uri.parse("comgooglemaps://"))) {
          installed.add(NavigationApp.googleMaps);
        }
      } catch (_) {}
      installed.add(NavigationApp.appleMaps); // Always available on iOS
    } else if (!kIsWeb && Platform.isAndroid) {
      installed.add(NavigationApp.googleMaps); // Default on Android
    }

    return installed;
  }
}
