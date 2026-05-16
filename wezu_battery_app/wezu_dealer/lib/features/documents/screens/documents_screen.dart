import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/document_provider.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});
  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  String _categoryFilter = 'All';
  dynamic _selectedDocument;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _stagger(int i, {required Widget child}) {
    final begin = i * 0.12;
    final end = (begin + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(
        animation: _c,
        builder: (c, _) {
          final t = Curves.easeOut
              .transform(((_c.value - begin) / (end - begin)).clamp(0.0, 1.0));
          return Opacity(
              opacity: t,
              child: Transform.translate(
                  offset: Offset(0, 16 * (1 - t)), child: child));
        });
  }

  IconData _docIcon(String type) {
    switch (type.toUpperCase()) {
      case 'GST_CERTIFICATE':
        return LucideIcons.fileText;
      case 'PAN_CARD':
        return LucideIcons.creditCard;
      case 'BUSINESS_LICENSE':
        return LucideIcons.building;
      case 'INSURANCE_POLICY':
        return LucideIcons.shield;
      case 'CANCELLED_CHEQUE':
        return LucideIcons.banknote;
      case 'SAFETY_CERTIFICATE':
        return LucideIcons.shieldCheck;
      case 'ELECTRICAL_COMPLIANCE':
        return LucideIcons.zap;
      default:
        return LucideIcons.file;
    }
  }

  void _showUploadDialog(BuildContext context) {
    final docTypeC = TextEditingController();
    String selectedCategory = 'verification';
    String pickedFileName = '';
    Uint8List? pickedBytes;
    final docTypes = ['GST_CERTIFICATE', 'PAN_CARD', 'BUSINESS_LICENSE', 'INSURANCE_POLICY', 'CANCELLED_CHEQUE', 'SAFETY_CERTIFICATE', 'ELECTRICAL_COMPLIANCE', 'OTHER'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          backgroundColor: AppColors.cardBg,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Upload Document',
              style: TextStyle(
                  color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          content: SizedBox(
            width: 400,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: docTypeC.text.isEmpty ? null : docTypeC.text,
                items: docTypes
                    .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.replaceAll('_', ' '),
                            style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) => docTypeC.text = v ?? '',
                decoration: InputDecoration(
                  labelText: 'Document Type',
                  prefixIcon: const Icon(LucideIcons.fileText, size: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                dropdownColor: AppColors.cardBg,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                items: [
                  'verification',
                  'compliance',
                  'financial',
                  'operational'
                ]
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c[0].toUpperCase() + c.substring(1),
                            style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (v) =>
                    setDState(() => selectedCategory = v ?? 'verification'),
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(LucideIcons.tag, size: 16),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                dropdownColor: AppColors.cardBg,
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.pageBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.border, style: BorderStyle.solid)),
                child: Column(children: [
                  Icon(LucideIcons.uploadCloud,
                      size: 28, color: AppColors.textTertiary),
                  const SizedBox(height: 8),
                  Text(pickedFileName.isNotEmpty ? pickedFileName : 'Supported formats: PDF, JPG, PNG', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
                        withData: true,
                      );
                      if (result != null && result.files.single.bytes != null) {
                        setDState(() {
                          pickedFileName = result.files.single.name;
                          pickedBytes = result.files.single.bytes;
                        });
                      }
                    },
                    icon: const Icon(LucideIcons.file, size: 14),
                    label: Text(pickedFileName.isNotEmpty ? 'Change File' : 'Browse Files', style: const TextStyle(fontSize: 12)),
                  ),
                ]),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (docTypeC.text.isEmpty || pickedBytes == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a file and document type'), backgroundColor: AppColors.red));
                  return;
                }
                Navigator.pop(ctx);

                final fileUrl = await ref.read(documentsProvider.notifier).uploadFileBytes(pickedBytes!, pickedFileName);
                if (!mounted) return;
                if (fileUrl == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File upload failed'), backgroundColor: AppColors.red));
                  return;
                }

                final success = await ref.read(documentsProvider.notifier).uploadDocument(
                  documentType: docTypeC.text,
                  fileUrl: fileUrl,
                  category: selectedCategory,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? 'Document uploaded successfully'
                        : 'Upload failed'),
                    backgroundColor:
                        success ? AppColors.primary : AppColors.red,
                  ));
                }
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentsProvider);
    final docs = state.documents;

    // KPI
    final verified =
        docs.where((d) => d.status.toUpperCase() == 'VERIFIED').length;
    final pending =
        docs.where((d) => d.status.toUpperCase() == 'PENDING').length;
    final expiringSoon = docs.where((d) {
      if (d.validUntil == null) return false;
      final exp = DateTime.tryParse(d.validUntil!);
      if (exp == null) return false;
      return exp.difference(DateTime.now()).inDays <= 30;
    }).length;

    // Gather unique categories
    final categories = {
      'All',
      ...docs.map((d) => d.category ?? 'verification')
    };
    final filtered = _categoryFilter == 'All'
        ? docs
        : docs
            .where((d) => (d.category ?? 'verification') == _categoryFilter)
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // KPI Row
        _stagger(0,
            child: Row(children: [
              Expanded(
                  child: _KpiCard(
                      label: 'TOTAL DOCUMENTS',
                      value: '${docs.length}',
                      icon: LucideIcons.fileText,
                      accent: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _KpiCard(
                      label: 'VERIFIED',
                      value: '$verified',
                      icon: LucideIcons.checkCircle,
                      accent: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(
                  child: _KpiCard(
                      label: 'PENDING',
                      value: '$pending',
                      icon: LucideIcons.clock,
                      accent: AppColors.amber)),
              const SizedBox(width: 12),
              Expanded(
                  child: _KpiCard(
                      label: 'EXPIRING SOON',
                      value: '$expiringSoon',
                      icon: LucideIcons.alertTriangle,
                      accent: expiringSoon > 0
                          ? AppColors.red
                          : AppColors.textTertiary)),
            ])),
        const SizedBox(height: 20),

        // Filter + Upload
        _stagger(1,
            child: Row(children: [
              ...categories.map((cat) {
                final sel = _categoryFilter == cat;
                final label = cat == 'All'
                    ? 'All'
                    : cat[0].toUpperCase() + cat.substring(1);
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () => setState(() => _categoryFilter = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: sel
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.border),
                      ),
                      child: Text(label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  sel ? FontWeight.w600 : FontWeight.w400,
                              color: sel
                                  ? AppColors.primary
                                  : AppColors.textSecondary)),
                    ),
                  ),
                );
              }),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(LucideIcons.upload, size: 16),
                label: const Text('Upload Document'),
                onPressed: () => _showUploadDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ])),
        const SizedBox(height: 16),

        // Documents Table + Detail Panel
        _stagger(2,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                  flex: _selectedDocument != null ? 3 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(18),
                              child: Text('Documents (${filtered.length})',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700))),
                          const Divider(height: 1),
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(12)),
                            child: state.isLoading
                                ? const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Center(
                                        child: CircularProgressIndicator()))
                                : state.error != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(40),
                                        child: Center(
                                            child: Text('Error: ${state.error}',
                                                style: const TextStyle(
                                                    color: AppColors.red))))
                                    : filtered.isEmpty
                                        ? const Padding(
                                            padding: EdgeInsets.all(40),
                                            child: Center(
                                                child: Text(
                                                    'No documents found',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .textSecondary))))
                                        : SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: DataTable(
                                              headingRowColor:
                                                  WidgetStateProperty.all(
                                                      AppColors
                                                          .pageBg
                                                          .withValues(
                                                              alpha: 0.5)),
                                              columns: const [
                                                DataColumn(
                                                    label: Text('DOCUMENT',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                                DataColumn(
                                                    label: Text('CATEGORY',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                                DataColumn(
                                                    label: Text('STATUS',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                                DataColumn(
                                                    label: Text('VERSION',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                                DataColumn(
                                                    label: Text('VALID UNTIL',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                                DataColumn(
                                                    label: Text('',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11))),
                                              ],
                                              rows: filtered.map((d) {
                                                final statusUpper =
                                                    d.status.toUpperCase();
                                                final sColor = statusUpper ==
                                                        'VERIFIED'
                                                    ? AppColors.primary
                                                    : statusUpper == 'PENDING'
                                                        ? AppColors.amber
                                                        : AppColors.red;
                                                final validStr =
                                                    d.validUntil != null
                                                        ? d.validUntil!
                                                            .substring(0, 10)
                                                        : 'N/A';
                                                final isExpiring = d
                                                            .validUntil !=
                                                        null &&
                                                    (DateTime.tryParse(d
                                                                    .validUntil!)
                                                                ?.difference(
                                                                    DateTime
                                                                        .now())
                                                                .inDays ??
                                                            999) <=
                                                        30;
                                                final isSelected =
                                                    _selectedDocument?.id ==
                                                        d.id;

                                                return DataRow(
                                                  color: WidgetStateProperty
                                                      .resolveWith((states) =>
                                                          isSelected
                                                              ? AppColors
                                                                  .primary
                                                                  .withValues(
                                                                      alpha:
                                                                          0.06)
                                                              : null),
                                                  onSelectChanged: (_) =>
                                                      setState(() =>
                                                          _selectedDocument =
                                                              d),
                                                  cells: [
                                                    DataCell(Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 32,
                                                            height: 32,
                                                            decoration: BoxDecoration(
                                                                color: AppColors
                                                                    .primary
                                                                    .withValues(
                                                                        alpha:
                                                                            0.12),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                            child: Icon(
                                                                _docIcon(d
                                                                    .documentType),
                                                                size: 14,
                                                                color: AppColors
                                                                    .primary),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Text(
                                                              d.documentType
                                                                  .replaceAll(
                                                                      '_', ' '),
                                                              style: const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      13)),
                                                        ])),
                                                    DataCell(Text(
                                                        d.category ??
                                                            'verification',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .textSecondary))),
                                                    DataCell(Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 3),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              sColor.withValues(
                                                                  alpha: 0.1),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                          border: Border.all(
                                                              color: sColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.3))),
                                                      child: Text(statusUpper,
                                                          style: TextStyle(
                                                              color: sColor,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                    )),
                                                    DataCell(Text(
                                                        'v${d.version}',
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: AppColors
                                                                .textTertiary,
                                                            fontFamily:
                                                                'monospace'))),
                                                    DataCell(Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(validStr,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: isExpiring
                                                                      ? AppColors
                                                                          .red
                                                                      : AppColors
                                                                          .textTertiary)),
                                                          if (isExpiring) ...[
                                                            const SizedBox(
                                                                width: 6),
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          2),
                                                              decoration: BoxDecoration(
                                                                  color: AppColors
                                                                      .red
                                                                      .withValues(
                                                                          alpha:
                                                                              0.1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              3)),
                                                              child: const Text(
                                                                  'EXPIRING',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          8,
                                                                      color: AppColors
                                                                          .red,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700)),
                                                            )
                                                          ],
                                                        ])),
                                                    DataCell(Icon(
                                                        LucideIcons
                                                            .chevronRight,
                                                        size: 16,
                                                        color: AppColors
                                                            .textTertiary)),
                                                  ],
                                                );
                                              }).toList(),
                                            )),
                          ),
                        ]),
                  )),

              // Detail Side Panel
              if (_selectedDocument != null) ...[
                const SizedBox(width: 16),
                Expanded(
                    flex: 2,
                    child: _buildDocumentDetailPanel(_selectedDocument!)),
              ],
            ])),
      ]),
    );
  }

  Widget _buildDocumentDetailPanel(dynamic d) {
    final statusUpper = d.status.toUpperCase();
    final sColor = statusUpper == 'VERIFIED'
        ? AppColors.primary
        : statusUpper == 'PENDING'
            ? AppColors.amber
            : AppColors.red;
    final validStr =
        d.validUntil != null ? d.validUntil!.substring(0, 10) : 'Permanent';

    return Container(
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: AppColors.pageBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12))),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(_docIcon(d.documentType),
                  size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(d.documentType.replaceAll('_', ' '),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text('Version ${d.version}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textTertiary)),
                ])),
            IconButton(
                icon: const Icon(LucideIcons.x,
                    size: 16, color: AppColors.textTertiary),
                onPressed: () => setState(() => _selectedDocument = null)),
          ]),
        ),
        const Divider(height: 1),

        // Body
        Padding(
            padding: const EdgeInsets.all(18),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(LucideIcons.shieldCheck,
                    size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                const Text('Verification Status',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: sColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: sColor.withValues(alpha: 0.3))),
                  child: Text(statusUpper,
                      style: TextStyle(
                          color: sColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ]),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              const Text('DOCUMENT INFO',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTertiary,
                      letterSpacing: 0.5)),
              const SizedBox(height: 12),
              _infoRow(
                  'Category', (d.category ?? 'verification').toUpperCase()),
              const SizedBox(height: 10),
              _infoRow('Valid Until', validStr),
              const SizedBox(height: 10),
              _infoRow('Upload Date', 'N/A'),
              const SizedBox(height: 24),

              // Action buttons
              SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.eye, size: 14),
                    label: const Text('View Document',
                        style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Opening document viewer...'),
                          backgroundColor: AppColors.primary));
                    },
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(LucideIcons.uploadCloud, size: 14),
                    label: const Text('Upload New Version',
                        style: TextStyle(fontSize: 12)),
                    onPressed: () => _showUploadDialog(context),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12)),
                  )),
            ])),
      ]),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      const SizedBox(width: 16),
      Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary))),
    ]);
  }
}

class _KpiCard extends StatefulWidget {
  final String label, value;
  final IconData icon;
  final Color accent;
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.accent});
  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: _hovered ? AppColors.cardBgHover : AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: _hovered
                    ? widget.accent.withValues(alpha: 0.2)
                    : AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: widget.accent,
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                        color: widget.accent.withValues(alpha: 0.4),
                        blurRadius: 6)
                  ])),
          Row(children: [
            Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(widget.icon, size: 14, color: widget.accent)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(widget.label,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.6))),
          ]),
          const SizedBox(height: 12),
          Text(widget.value,
              style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
        ]),
      ),
    );
  }
}
