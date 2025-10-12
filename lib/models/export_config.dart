enum ExportFormat {
  excel,
  pdf,
  arta,
  csv,
}

class ExportConfig {
  final ExportFormat format;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? region;
  final String? serviceType;
  final List<String> selectedFields;
  final bool includeCharts;
  final String? customNotes;

  ExportConfig({
    required this.format,
    this.startDate,
    this.endDate,
    this.region,
    this.serviceType,
    this.selectedFields = const [],
    this.includeCharts = true,
    this.customNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'format': format.name,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'region': region,
      'serviceType': serviceType,
      'selectedFields': selectedFields,
      'includeCharts': includeCharts,
      'customNotes': customNotes,
    };
  }

  factory ExportConfig.fromJson(Map<String, dynamic> json) {
    return ExportConfig(
      format: ExportFormat.values.firstWhere((e) => e.name == json['format']),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      region: json['region'],
      serviceType: json['serviceType'],
      selectedFields: List<String>.from(json['selectedFields'] ?? []),
      includeCharts: json['includeCharts'] ?? true,
      customNotes: json['customNotes'],
    );
  }
}
