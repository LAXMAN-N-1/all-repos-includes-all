import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/services/auth_service.dart';

class DashboardAlertsScreen extends StatefulWidget {
  const DashboardAlertsScreen({Key? key}) : super(key: key);

  @override
  State<DashboardAlertsScreen> createState() => _DashboardAlertsScreenState();
}

class _DashboardAlertsScreenState extends State<DashboardAlertsScreen> {
  String _selectedFilter = 'All';

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _alerts = [];

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      print("Fetching alerts from: ${authService.apiClient.client.options.baseUrl}/alerts");
      final response = await authService.apiClient.client.get('/alerts');
      print("Alerts response received: ${response.statusCode}");
      print("Data type: ${response.data.runtimeType}");
      print("Data content: ${response.data}");
      
      if (mounted) {
        setState(() {
          _alerts = List<Map<String, dynamic>>.from(response.data);
          print("Parsed ${_alerts.length} alerts");
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching alerts: $e");
      if (mounted) {
        setState(() {
          _error = "Failed to load alerts: ${e.toString()}";
          _isLoading = false;
        });
      }
    }
  }

  // Helper to map icon names to Flutter icons
  IconData _getIconData(String name) {
    switch (name) {
      case 'warning_amber_rounded': return Icons.warning_amber_rounded;
      case 'access_time_filled': return Icons.access_time_filled;
      case 'check_circle': return Icons.check_circle;
      case 'payment': return Icons.payment;
      case 'security': return Icons.security;
      default: return Icons.notifications;
    }
  }

  // Helper to map hex string to Color
  Color _getColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.blue;
    try {
      String cleanHex = hex.replaceFirst('#', '');
      if (cleanHex.length == 6) {
        cleanHex = 'FF$cleanHex'; // Add alpha if missing
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (e) {
      print("Error parsing color $hex: $e");
      return Colors.blue;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Just now';
    try {
      DateTime dt = date is String ? DateTime.parse(date) : date as DateTime;
      return "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'Recent';
    }
  }

  @override
  Widget build(BuildContext context) {
    
    List<Map<String, dynamic>> filteredAlerts = _selectedFilter == 'All' 
        ? _alerts 
        : _alerts.where((a) => a['severity'] == _selectedFilter).toList();

    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("System Alerts", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Critical system notifications and health warnings", style: TextStyle(color: Colors.white60)),
                  ],
                ),
                // Filter Chips
                Row(
                  children: ["All", "Critical", "Warning", "Info", "Error"].map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedFilter = filter);
                        },
                        selectedColor: AuraColors.primary.withOpacity(0.2),
                        labelStyle: TextStyle(color: isSelected ? AuraColors.primary : Colors.white60),
                        backgroundColor: Colors.transparent,
                        side: BorderSide(color: isSelected ? AuraColors.primary : Colors.white12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Alerts List
            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AuraColors.primary))
                  : _error != null
                      ? Center(child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(_error!, style: const TextStyle(color: Colors.white60)),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _fetchAlerts, child: const Text("Retry"))
                          ],
                        ))
                      : filteredAlerts.isEmpty 
                          ? const Center(child: Text("No alerts found.", style: TextStyle(color: Colors.white30)))
                          : ListView.builder(
                              itemCount: filteredAlerts.length,
                              itemBuilder: (context, index) {
                                final alert = filteredAlerts[index];
                                print("Rendering alert $index: ${alert['title']}");
                                return _buildAlertCard(
                                  alert['title']?.toString() ?? 'Alert',
                                  alert['message']?.toString() ?? '',
                                  alert['severity']?.toString() ?? 'Info',
                                  _formatDate(alert['created_at']),
                                  _getIconData(alert['icon_name']?.toString() ?? ''),
                                  _getColor(alert['color_hex']?.toString()),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertCard(String title, String message, String severity, String time, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AuraColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: 2),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(color: Colors.white30, fontSize: 10)),
          ],
        ),
        trailing: const Icon(Icons.more_vert, color: Colors.white30),
      ),
    );
  }
}
