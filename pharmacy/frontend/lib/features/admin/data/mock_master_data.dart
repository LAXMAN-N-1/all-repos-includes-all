import 'package:flutter/material.dart';

class DrugModel {
  final String id;
  final String genericName;
  final String brandName;
  final String manufacturer;
  final String category;
  final String dosageForm;
  final String strength;
  final bool isActive;

  DrugModel({
    required this.id,
    required this.genericName,
    required this.brandName,
    required this.manufacturer,
    required this.category,
    required this.dosageForm,
    required this.strength,
    required this.isActive,
  });
}

class LabTestModel {
  final String code;
  final String name;
  final String category;
  final String sampleType;
  final double price;
  final String tat; // Turn Around Time

  LabTestModel({
    required this.code,
    required this.name,
    required this.category,
    required this.sampleType,
    required this.price,
    required this.tat,
  });
}

class InsuranceProvider {
  final String id;
  final String name;
  final String coverageType; // Full, Copay
  final String contact;
  final String status;

  InsuranceProvider({
    required this.id,
    required this.name,
    required this.coverageType,
    required this.contact,
    required this.status,
  });
}

final List<DrugModel> mockDrugs = [
  DrugModel(id: "DRG-001", genericName: "Paracetamol", brandName: "Dolo 650", manufacturer: "Micro Labs", category: "Analgesic", dosageForm: "Tablet", strength: "650mg", isActive: true),
  DrugModel(id: "DRG-002", genericName: "Amoxicillin", brandName: "Mox 500", manufacturer: "Sun Pharma", category: "Antibiotic", dosageForm: "Capsule", strength: "500mg", isActive: true),
  DrugModel(id: "DRG-003", genericName: "Metformin", brandName: "Glycomet", manufacturer: "USV Ltd", category: "Antidiabetic", dosageForm: "Tablet", strength: "500mg", isActive: true),
  DrugModel(id: "DRG-004", genericName: "Atorvastatin", brandName: "Atorva", manufacturer: "Zydus Cadila", category: "Statin", dosageForm: "Tablet", strength: "10mg", isActive: true),
  DrugModel(id: "DRG-005", genericName: "Pantoprazole", brandName: "Pan 40", manufacturer: "Alkem", category: "Antacid", dosageForm: "Tablet", strength: "40mg", isActive: false),
];

final List<LabTestModel> mockLabTests = [
  LabTestModel(code: "L101", name: "Complete Blood Count (CBC)", category: "Hematology", sampleType: "Blood", price: 350.0, tat: "6 hrs"),
  LabTestModel(code: "L102", name: "Lipid Profile", category: "Biochemistry", sampleType: "Blood", price: 600.0, tat: "12 hrs"),
  LabTestModel(code: "L103", name: "Thyroid Profile (T3, T4, TSH)", category: "Biochemistry", sampleType: "Blood", price: 550.0, tat: "24 hrs"),
  LabTestModel(code: "L104", name: "HbA1c", category: "Diabetology", sampleType: "Blood", price: 450.0, tat: "4 hrs"),
];

final List<InsuranceProvider> mockInsurance = [
  InsuranceProvider(id: "INS-001", name: "Star Health", coverageType: "Full Coverage", contact: "claims@starhealth.in", status: "Active"),
  InsuranceProvider(id: "INS-002", name: "HDFC Ergo", coverageType: "Copay (80/20)", contact: "support@hdfcergo.com", status: "Active"),
  InsuranceProvider(id: "INS-003", name: "ICICI Lombard", coverageType: "Full Coverage", contact: "claims@icicilombard.com", status: "Active"),
];
