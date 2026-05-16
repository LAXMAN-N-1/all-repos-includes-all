import 'package:flutter/material.dart';

import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/admin/data/mock_master_data.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:frontend/features/admin/services/master_data_service.dart';
import 'package:frontend/core/network/api_client.dart';
import 'package:frontend/core/storage/storage_service.dart';

class DrugDatabaseScreen extends StatefulWidget {
  const DrugDatabaseScreen({Key? key}) : super(key: key);

  @override
  State<DrugDatabaseScreen> createState() => _DrugDatabaseScreenState();
}

class _DrugDatabaseScreenState extends State<DrugDatabaseScreen> {
  late MasterDataService _dataService;
  List<DrugModel> _drugs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dataService = MasterDataService(ApiClient(StorageService()));
    _loadDrugs();
  }

  Future<void> _loadDrugs() async {
    final drugs = await _dataService.getDrugs();
    if (mounted) setState(() {
      _drugs = drugs;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Global Drug Repository", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 4),
                    const Text("Master catalog of medicines available to all tenants", style: TextStyle(color: Colors.white60)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  label: const Text("Add New Drug"),
                  style: ElevatedButton.styleFrom(backgroundColor: AuraColors.primary, foregroundColor: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Search Filter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AuraColors.surface, borderRadius: BorderRadius.circular(8)),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search by Brand Name, Generic Name or Manufacturer...",
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: AuraColors.primary))
                  : Container(
                decoration: BoxDecoration(
                  color: AuraColors.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AuraColors.glassBorder),
                ),
                child: SingleChildScrollView(
                  child: DataTable(
                    headingTextStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    dataTextStyle: const TextStyle(color: Colors.white),
                    columns: const [
                       DataColumn(label: Text("Brand Name")),
                       DataColumn(label: Text("Generic Name")),
                       DataColumn(label: Text("Manufacturer")),
                       DataColumn(label: Text("Form")),
                       DataColumn(label: Text("Category")),
                       DataColumn(label: Text("Status")),
                       DataColumn(label: Text("Actions")),
                    ],
                    rows: _drugs.map((drug) => DataRow(
                      cells: [
                        DataCell(Text(drug.brandName, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(drug.genericName)),
                        DataCell(Text(drug.manufacturer)),
                        DataCell(Text("${drug.dosageForm} ${drug.strength}")),
                        DataCell(Text(drug.category)),
                        DataCell(Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                           decoration: BoxDecoration(
                             color: (drug.isActive ? Colors.green : Colors.grey).withOpacity(0.2),
                             borderRadius: BorderRadius.circular(4),
                           ),
                           child: Text(drug.isActive ? "ACTIVE" : "INACTIVE", style: TextStyle(fontSize: 10, color: drug.isActive ? Colors.green : Colors.grey)),
                        )),
                        DataCell(IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.white30), onPressed: () {})),
                      ],
                    )).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
