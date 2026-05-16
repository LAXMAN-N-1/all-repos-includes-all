import 'package:flutter/material.dart';
import '../../core/responsive/responsive.dart';

/// Define columns for the DataTableView
class DataTableColumn {
  final String label;
  final bool numeric;
  final String? tooltip;

  const DataTableColumn({
    required this.label,
    this.numeric = false,
    this.tooltip,
  });
}

/// A responsive, paginated data table unified from Wezu and Evination
///
/// Features built in:
/// 1. Card container with header & actions
/// 2. Horizontal scroll on mobile
/// 3. Pagination controls at bottom
/// 4. Empty/Loading state support
class DataTableView extends StatelessWidget {
  final String title;
  final List<DataTableColumn> columns;
  final List<DataRow> rows;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNextPage;
  final VoidCallback? onPreviousPage;
  final Widget? headerAction;
  final String emptyMessage;

  const DataTableView({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.isLoading = false,
    this.currentPage = 1,
    this.totalPages = 1,
    this.onNextPage,
    this.onPreviousPage,
    this.headerAction,
    this.emptyMessage = 'No records found',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (headerAction != null) headerAction!,
              ],
            ),
          ),

          const Divider(height: 1),

          // Table Section
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(48.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.table_rows_outlined, size: 48, color: theme.colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(emptyMessage, style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: isMobile ? MediaQuery.sizeOf(context).width - 32 : 0,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                  ),
                  dataRowMaxHeight: 64,
                  dividerThickness: 0.5,
                  columns: columns.map((col) {
                    return DataColumn(
                      label: Text(
                        col.label,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      numeric: col.numeric,
                      tooltip: col.tooltip,
                    );
                  }).toList(),
                  rows: rows,
                ),
              ),
            ),

          // Pagination Section
          if (totalPages > 1) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Page $currentPage of $totalPages',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    onPressed: currentPage > 1 ? onPreviousPage : null,
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous Page',
                  ),
                  IconButton(
                    onPressed: currentPage < totalPages ? onNextPage : null,
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next Page',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
