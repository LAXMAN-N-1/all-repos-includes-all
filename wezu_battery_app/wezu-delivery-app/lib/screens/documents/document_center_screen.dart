import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_colors.dart';
import '../../models/document_model.dart';
import 'documents_view_model.dart';

class DocumentCenterScreen extends StatelessWidget {
  const DocumentCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DocumentsViewModel(),
      child: const _DocumentCenterContent(),
    );
  }
}

class _DocumentCenterContent extends StatelessWidget {
  const _DocumentCenterContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DocumentsViewModel>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Document Center'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF233D4C),
        elevation: 0.5,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.documents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final doc = viewModel.documents[index];
                return _buildDocumentCard(context, viewModel, doc);
              },
            ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context,
    DocumentsViewModel viewModel,
    Document doc,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    doc.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF233D4C),
                    ),
                  ),
                ),
                _buildStatusBadge(doc.status),
              ],
            ),
            const SizedBox(height: 12),
            if (doc.rejectionReason != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        doc.rejectionReason!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (doc.lastUpdated != null)
                  Text(
                    'Last updated: ${_formatDate(doc.lastUpdated!)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  )
                else
                  const Text(
                    'Not uploaded',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                Row(
                  children: [
                    if (doc.fileUrl != null)
                      TextButton.icon(
                        onPressed: () {
                          // Show preview (mock)
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Previewing Document...'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('View'),
                      ),
                    const SizedBox(width: 8),
                    if (doc.status != DocumentStatus.verified)
                      ElevatedButton.icon(
                        onPressed: () =>
                            _showUploadDialog(context, viewModel, doc),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        icon: const Icon(Icons.upload_file, size: 16),
                        label: Text(doc.fileUrl == null ? 'Upload' : 'Update'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DocumentStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case DocumentStatus.verified:
        color = Colors.green;
        text = 'Verified';
        icon = Icons.check_circle;
        break;
      case DocumentStatus.pending:
        color = Colors.orange;
        text = 'Pending';
        icon = Icons.access_time_filled;
        break;
      case DocumentStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        icon = Icons.error;
        break;
      case DocumentStatus.missing:
        color = Colors.grey;
        text = 'Missing';
        icon = Icons.help;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(
    BuildContext context,
    DocumentsViewModel viewModel,
    Document doc,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Upload Document',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickAndUploadDocument(doc.id, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                viewModel.pickAndUploadDocument(doc.id, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
