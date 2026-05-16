import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/document_model.dart';
import '../../utils/app_logger.dart';

class DocumentsViewModel extends ChangeNotifier {
  final AppLogger _logger = AppLogger('DocumentsViewModel');
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  List<Document> _documents = [];

  bool get isLoading => _isLoading;
  List<Document> get documents => _documents;

  DocumentsViewModel() {
    _loadDocuments();
  }

  void _loadDocuments() {
    // Mock Initial Data
    _documents = [
      Document(
        id: 'DL',
        title: 'Driving License',
        status: DocumentStatus.verified,
        fileUrl:
            'https://via.placeholder.com/300x200?text=Driving+License', // Mock
        lastUpdated: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Document(
        id: 'INS',
        title: 'Vehicle Insurance',
        status: DocumentStatus.rejected,
        fileUrl: 'https://via.placeholder.com/300x200?text=Insurance', // Mock
        lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
        rejectionReason: 'Image is blurry. Please re-upload.',
      ),
      Document(
        id: 'PAN',
        title: 'PAN Card',
        status: DocumentStatus.pending,
        fileUrl: 'https://via.placeholder.com/300x200?text=PAN+Card', // Mock
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      Document(
        id: 'RC',
        title: 'Vehicle Registration (RC)',
        status: DocumentStatus.missing,
      ),
    ];
    notifyListeners();
  }

  Future<void> pickAndUploadDocument(String docId, ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);

      if (image != null) {
        _isLoading = true;
        notifyListeners();

        // Simulate Upload
        await Future.delayed(const Duration(seconds: 2));

        final index = _documents.indexWhere((d) => d.id == docId);
        if (index != -1) {
          _documents[index] = _documents[index].copyWith(
            status: DocumentStatus.pending,
            fileUrl: image.path, // In real app, this would be the uploaded URL
            lastUpdated: DateTime.now(),
            rejectionReason: null, // Clear rejection reason on new upload
          );
        }

        _logger.info('Document $docId uploaded successfully');
      }
    } catch (e) {
      _logger.error('Error picking document', e);
      // Handle error (e.g., show toast)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
