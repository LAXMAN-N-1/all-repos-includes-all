import 'package:flutter/material.dart';

class CommonTable extends StatelessWidget {
  final List<CommonTableHeader> headers;
  final List<List<Widget>> rows;
  final VoidCallback? onRowTap;

  const CommonTable({
    super.key,
    required this.headers,
    required this.rows,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: DataTable(
          headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          dataRowMinHeight: 48,
          dataRowMaxHeight: 60,
          columnSpacing: 24,
          columns: headers.map((header) {
            return DataColumn(
              label: Text(header.label),
              tooltip: header.tooltip,
            );
          }).toList(),
          rows: rows.map((row) {
            return DataRow(
              cells: row.map((cell) => DataCell(cell)).toList(),
              onSelectChanged: onRowTap != null ? (_) => onRowTap!() : null,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CommonTableHeader {
  final String label;
  final String? tooltip;

  CommonTableHeader({required this.label, this.tooltip});
}
