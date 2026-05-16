import 'package:freezed_annotation/freezed_annotation.dart';

part 'insurance_model.freezed.dart';
part 'insurance_model.g.dart';

@freezed
class InsuranceModel with _$InsuranceModel {
  const factory InsuranceModel({
    required String id,
    required String title,
    required String description,
    required double coverageAmount,
    required double premiumAmount,
    required String providerName,
    @Default([]) List<String> features,
    @Default('Active') String status,
  }) = _InsuranceModel;

  factory InsuranceModel.fromJson(Map<String, dynamic> json) => _$InsuranceModelFromJson(json);
}
