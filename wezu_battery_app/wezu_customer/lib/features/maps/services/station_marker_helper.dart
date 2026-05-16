import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/station.dart';

/// Color logic for map markers based on swap status:
/// 🟢 Green  — >5 batteries available
/// 🟠 Orange — 1–4 batteries available
/// 🔴 Red    — 0 batteries, station online
/// ⚫ Grey   — Station offline/maintenance
class StationMarkerHelper {
  static Color getMarkerColor(Station station) {
    if (station.status == 'maintenance' || station.status == 'offline') {
      return const Color(0xFF64748B); // Slate Grey
    }
    if (station.availableBatteries == 0) {
      return const Color(0xFFEF4444); // Critical Red
    }
    if (station.availableBatteries < 5) {
      return const Color(0xFFF59E0B); // Vibrant Orange
    }
    if (station.availableBatteries < 10) {
      return const Color(0xFF84CC16); // Light Green
    }
    return const Color(0xFF10B981); // Emerald Green
  }

  static String getStatusLabel(Station station) {
    if (station.status == 'maintenance' || station.status == 'offline') {
      return 'Unavailable';
    }
    if (station.availableBatteries == 0) return 'Empty';
    if (station.availableBatteries < 5) return 'Low Stock';
    if (station.availableBatteries < 10) return 'Good';
    return 'Available';
  }

  static BitmapDescriptor getDefaultMarkerIcon(Station station) {
    if (station.status == 'maintenance' || station.status == 'offline') {
      return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueViolet); // Grey-ish hue
    }
    if (station.availableBatteries == 0) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
    if (station.availableBatteries < 5) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
    }
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
  }

  /// Generate a custom circular marker with availability count
  static Future<BitmapDescriptor> getCustomMarkerIcon(Station station) async {
    final color = getMarkerColor(station);
    final count = station.availableBatteries;

    const double size = 60; // Reduced to 60
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
    canvas.drawCircle(
        const Offset(size / 2, size / 2 + 2), size / 2.5, shadowPaint);

    // Outer ring
    final outerPaint = Paint()..color = color;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2.3, outerPaint);

    // Inner white circle
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 3.2, innerPaint);

    // Number or icon text
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final displayText = station.status == 'maintenance' ? '✕' : '$count';
    textPainter.text = TextSpan(
      text: displayText,
      style: TextStyle(
        fontSize: size / 3.5,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
          size / 2 - textPainter.width / 2, size / 2 - textPainter.height / 2),
    );

    final image =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }

  /// For cluster bubbles: use the most urgent colour in the group
  static Color getMostUrgentColor(List<Station> stations) {
    if (stations
        .any((s) => s.status == 'maintenance' || s.status == 'offline')) {
      return Colors.grey;
    }
    if (stations.any((s) => s.availableBatteries == 0)) return Colors.red;
    if (stations.any((s) => s.availableBatteries < 5)) return Colors.orange;
    return Colors.green;
  }

  /// Generate cluster icon with most urgent color
  static Future<BitmapDescriptor> getClusterIcon(
      int count, List<Station> stations) async {
    final color = getMostUrgentColor(stations);

    const double size = 60; // Reduced to 60
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4);
    canvas.drawCircle(
        const Offset(size / 2, size / 2), size / 2.2, shadowPaint);
    canvas.drawCircle(
        const Offset(size / 2, size / 2), size / 2.5, Paint()..color = color);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: count.toString(),
      style: const TextStyle(
          fontSize: size / 3, fontWeight: FontWeight.bold, color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(size / 2 - textPainter.width / 2,
            size / 2 - textPainter.height / 2));

    final image =
        await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }
}
