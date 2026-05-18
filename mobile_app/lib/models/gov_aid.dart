class GovAid {
  GovAid({
    required this.id,
    required this.schemeName,
    required this.agency,
    required this.aidType,
    required this.maxAmountRm,
    required this.interestRateLabel,
    required this.tenureMonths,
    required this.approvalSpeedLabel,
    required this.requiresBumiputera,
    required this.requiresVeteran,
    required this.industryKeywords,
    required this.digitalisationOnly,
    required this.description,
  });

  final int id;
  final String schemeName;
  final String agency;
  final String aidType;
  final double? maxAmountRm;
  final String? interestRateLabel;
  final int? tenureMonths;
  final String approvalSpeedLabel;
  final bool requiresBumiputera;
  final bool requiresVeteran;
  final String? industryKeywords;
  final bool digitalisationOnly;
  final String? description;

  factory GovAid.fromJson(Map<String, dynamic> j) => GovAid(
        id: j['id'] as int,
        schemeName: j['scheme_name'] as String,
        agency: j['agency'] as String,
        aidType: j['aid_type'] as String,
        maxAmountRm: j['max_amount_rm'] == null ? null : (j['max_amount_rm'] as num).toDouble(),
        interestRateLabel: j['interest_rate_label'] as String?,
        tenureMonths: j['tenure_months'] as int?,
        approvalSpeedLabel: j['approval_speed_label'] as String,
        requiresBumiputera: j['requires_bumiputera'] as bool,
        requiresVeteran: j['requires_veteran'] as bool,
        industryKeywords: j['industry_keywords'] as String?,
        digitalisationOnly: j['digitalisation_only'] as bool,
        description: j['description'] as String?,
      );
}
