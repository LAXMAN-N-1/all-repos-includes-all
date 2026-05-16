class VendorRegistrationModel {
  final String email;
  final String password;
  final String companyName;
  final String? businessType;
  final String contactPerson;
  final String phone;
  final String address;
  final String city;
  final String? state;
  final String? zipCode;
  
  final String? servicesDescription;
  final String? pricingRange;
  final String? serviceAreas;
  
  final String? businessLicenseUrl;
  final String? insuranceCertUrl;
  
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;

  VendorRegistrationModel({
    required this.email,
    required this.password,
    required this.companyName,
    this.businessType,
    required this.contactPerson,
    required this.phone,
    required this.address,
    required this.city,
    this.state,
    this.zipCode,
    this.servicesDescription,
    this.pricingRange,
    this.serviceAreas,
    this.businessLicenseUrl,
    this.insuranceCertUrl,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'company_name': companyName,
      'business_type': businessType,
      'contact_person': contactPerson,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'services_description': servicesDescription,
      'pricing_range': pricingRange,
      'service_areas': serviceAreas,
      'business_license_url': businessLicenseUrl,
      'insurance_cert_url': insuranceCertUrl,
      'bank_name': bankName,
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
    };
  }
}
