import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wezu_delivery_app/utils/app_logger.dart';

class KycViewModel extends ChangeNotifier {
  final AppLogger _logger = AppLogger('KycViewModel');
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Step 1: Personal Info
  String? fullName;
  String? email;
  String? address;

  // Step 2: Vehicle Info
  String? vehicleType; // e.g., 'Bike', 'Scooter', 'Car'
  String? vehicleNumber;
  String? vehicleModel;
  String? vehicleYear;
  String? vehicleColor;

  // Step 3: Documents
  XFile? drivingLicense;
  XFile? vehicleInsurance;

  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Method to advance to next step
  void nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 2) {
        _currentStep++;
        notifyListeners();
      }
    }
  }

  // Method to go back
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Pick Image
  Future<void> pickDrivingLicense() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        drivingLicense = image;
        notifyListeners();
      }
    } catch (e) {
      _logger.error('Error picking driving license', e);
      _setError('Failed to pick image');
    }
  }

  Future<void> pickVehicleInsurance() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        vehicleInsurance = image;
        notifyListeners();
      }
    } catch (e) {
      _logger.error('Error picking vehicle insurance', e);
      _setError('Failed to pick image');
    }
  }

  // Remove Image
  void removeDrivingLicense() {
    drivingLicense = null;
    notifyListeners();
  }

  void removeVehicleInsurance() {
    vehicleInsurance = null;
    notifyListeners();
  }

  // Validation
  bool _validateCurrentStep() {
    _setError(null);
    switch (_currentStep) {
      case 0: // Personal Info
        if (fullName == null || fullName!.isEmpty) {
          _setError('Full Name is required');
          return false;
        }
        if (email == null || email!.isEmpty) {
          _setError('Email is required');
          return false;
        }
        if (address == null || address!.isEmpty) {
          _setError('Address is required');
          return false;
        }
        return true;
      case 1: // Vehicle Info
        if (vehicleType == null || vehicleType!.isEmpty) {
          _setError('Vehicle Type is required');
          return false;
        }
        if (vehicleNumber == null || vehicleNumber!.isEmpty) {
          _setError('Vehicle Number is required');
          return false;
        }
        if (vehicleModel == null || vehicleModel!.isEmpty) {
          _setError('Vehicle Model is required');
          return false;
        }

        if (vehicleYear == null || vehicleYear!.isEmpty) {
          _setError('Vehicle Year is required');
          return false;
        }
        if (vehicleColor == null || vehicleColor!.isEmpty) {
          _setError('Vehicle Color is required');
          return false;
        }
        return true;
      case 2: // Documents
        if (drivingLicense == null) {
          _setError('Driving License is required');
          return false;
        }
        if (vehicleInsurance == null) {
          _setError('Vehicle Insurance is required');
          return false;
        }
        return true;
      default:
        return false;
    }
  }

  Future<bool> submitKyc() async {
    try {
      _logger.info('Submitting KYC...');
      _setLoading(true);

      // Mock API call
      await Future.delayed(const Duration(seconds: 2));

      _logger.info('KYC Submitted Successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Error submitting KYC', e, stackTrace);
      _setError('Failed to submit details. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Setters for text fields
  void setFullName(String val) {
    fullName = val;
    notifyListeners();
  }

  void setEmail(String val) {
    email = val;
    notifyListeners();
  }

  void setAddress(String val) {
    address = val;
    notifyListeners();
  }

  void setVehicleType(String? val) {
    vehicleType = val;
    notifyListeners();
  }

  void setVehicleNumber(String val) {
    vehicleNumber = val;
    notifyListeners();
  }

  void setVehicleModel(String val) {
    vehicleModel = val;
    notifyListeners();
  }

  void setVehicleYear(String val) {
    vehicleYear = val;
    notifyListeners();
  }

  void setVehicleColor(String val) {
    vehicleColor = val;
    notifyListeners();
  }
}
