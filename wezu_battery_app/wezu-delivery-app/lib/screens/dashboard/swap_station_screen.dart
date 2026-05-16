import 'package:flutter/material.dart';
import '../../widgets/dashboard/station_card.dart';
import 'package:url_launcher/url_launcher.dart';

class SwapStationScreen extends StatelessWidget {
  const SwapStationScreen({super.key});

  final List<Map<String, dynamic>> _stations = const [
    {
      'name': 'Wezu Hub - Koramangala',
      'address': '80 Feet Rd, 4th Block, Koramangala',
      'distance': '1.2 km',
      'batteries': 8,
      'lat': 12.9352,
      'lng': 77.6245,
    },
    {
      'name': 'Wezu Station - HSR Layout',
      'address': '27th Main, Sector 1, HSR Layout',
      'distance': '3.5 km',
      'batteries': 4,
      'lat': 12.9121,
      'lng': 77.6446,
    },
    {
      'name': 'Wezu Point - Indiranagar',
      'address': '100 Feet Road, Indiranagar',
      'distance': '5.0 km',
      'batteries': 12,
      'lat': 12.9716,
      'lng': 77.6412,
    },
    {
      'name': 'Wezu Hub - MG Road',
      'address': 'Utility Building, MG Road',
      'distance': '6.2 km',
      'batteries': 2,
      'lat': 12.9766,
      'lng': 77.5993,
    },
  ];

  Future<void> _launchMap(String query) async {
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
    );
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map Placeholder
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[300],
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map, size: 64, color: Colors.grey[500]),
                      const SizedBox(height: 12),
                      Text(
                        'Map View',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Floating Action Button for Map
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    onPressed: () =>
                        _launchMap('Battery Swap Stations near me'),
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.my_location,
                      color: Color(0xFFFD802E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Station List
        Expanded(
          flex: 3,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF5F7FA), // Light background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nearby Stations',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF233D4C),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _stations.length,
                    itemBuilder: (context, index) {
                      final station = _stations[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: StationCard(
                          name: station['name'],
                          distance: station['distance'],
                          batteriesAvailable: station['batteries'],
                          onNavigate: () => _launchMap(station['address']),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
