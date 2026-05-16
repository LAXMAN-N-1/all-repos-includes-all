import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({Key? key}) : super(key: key);

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  // Center of US roughly
  final LatLng _initialCenter = const LatLng(39.8283, -98.5795);
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> _pharmacyLocations = [
    {"name": "MediLife Pharmacy", "pos": const LatLng(40.7128, -74.0060), "status": "active"}, // NYC
    {"name": "HealthPlus", "pos": const LatLng(34.0522, -118.2437), "status": "active"}, // LA
    {"name": "QuickCure Drugs", "pos": const LatLng(41.8781, -87.6298), "status": "offline"}, // Chicago
    {"name": "PharmaOne", "pos": const LatLng(29.7604, -95.3698), "status": "active"}, // Houston
    {"name": "Wellness Center", "pos": const LatLng(25.7617, -80.1918), "status": "active"}, // Miami
    {"name": "Seattle Care", "pos": const LatLng(47.6062, -122.3321), "status": "new"}, // Seattle
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Live Tenant Map",
                        style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Geographical distribution of active pharmacies",
                        style: TextStyle(color: Colors.white60)),
                  ],
                ),
                Row(
                  children: [
                    _buildLegendItem("Active", Colors.green),
                    const SizedBox(width: 16),
                    _buildLegendItem("Offline", Colors.red),
                    const SizedBox(width: 16),
                    _buildLegendItem("New", Colors.blue),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AuraColors.glassBorder),
                // Clip needed for map corners
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _initialCenter,
                    initialZoom: 4.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.auramed.admin',
                      // Darken the map for dark mode feel
                      tileBuilder: (context, widget, tile) {
                         return ColorFiltered(
                           colorFilter: const ColorFilter.mode(
                             Colors.grey, 
                             BlendMode.saturation
                           ), // Desaturate
                           child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4), 
                                BlendMode.darken
                              ), // Darken
                              child: widget
                           ),
                         );
                      },
                    ),
                    MarkerLayer(
                      markers: _pharmacyLocations.map((loc) {
                        return Marker(
                          point: loc['pos'],
                          width: 40,
                          height: 40,
                          child: _buildMapMarker(loc['status']),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(String status) {
    Color color;
    switch (status) {
      case 'active':
        color = Colors.green;
        break;
      case 'offline':
        color = Colors.red;
        break;
      case 'new':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.6), blurRadius: 8, spreadRadius: 2)
              ],
            ),
            child: Icon(Icons.place, color: color, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
