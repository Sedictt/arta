import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/survey_response.dart';
import '../models/export_config.dart';

class ExportService {
  // Export to Excel-like CSV format (proper Excel-compatible CSV)
  Future<String> exportToExcel(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) async {
    final filteredResponses = _filterResponses(responses, config);

    // Create Excel-compatible CSV with BOM for proper UTF-8 encoding
    final StringBuffer buffer = StringBuffer();

    // Add BOM for Excel UTF-8 compatibility
    buffer.write('\uFEFF');

    // Summary section
    buffer.writeln('ARTA Customer Satisfaction Survey Report');
    buffer.writeln('City Government of Valenzuela');
    buffer.writeln(
      'Generated: ${DateFormat('MMMM dd, yyyy HH:mm').format(DateTime.now())}',
    );
    buffer.writeln('');

    // Summary statistics
    buffer.writeln('=== SUMMARY ===');
    buffer.writeln('Total Responses,${filteredResponses.length}');
    buffer.writeln(
      'Average SQD Score,${_calculateAverageSQDScore(filteredResponses).toStringAsFixed(2)}',
    );
    buffer.writeln(
      'Satisfaction Rate,${_calculateSatisfactionRate(filteredResponses).toStringAsFixed(1)}%',
    );
    buffer.writeln(
      'CC Awareness Rate,${_calculateAwarenessRate(filteredResponses).toStringAsFixed(1)}%',
    );
    buffer.writeln('');

    // Satisfaction Distribution
    buffer.writeln('=== SATISFACTION DISTRIBUTION ===');
    final satDist = _calculateSatisfactionDistribution(filteredResponses);
    satDist.forEach((key, value) {
      final pct = filteredResponses.isEmpty
          ? 0
          : (value / filteredResponses.length * 100);
      buffer.writeln('$key,$value,${pct.toStringAsFixed(1)}%');
    });
    buffer.writeln('');

    // SQD Breakdown
    buffer.writeln('=== SQD SCORES ===');
    buffer.writeln('Dimension,Average Score');
    final sqdLabels = {
      'SQD0': 'Overall Satisfaction',
      'SQD1': 'Transaction Time',
      'SQD2': 'Requirements',
      'SQD3': 'Steps Simplicity',
      'SQD4': 'Information Access',
      'SQD5': 'Fees Reasonableness',
      'SQD6': 'Fairness',
      'SQD7': 'Staff Courtesy',
      'SQD8': 'Service Delivery',
    };
    final sqdBreakdown = _calculateSQDBreakdown(filteredResponses);
    sqdBreakdown.forEach((key, value) {
      buffer.writeln('${sqdLabels[key] ?? key},${value.toStringAsFixed(2)}');
    });
    buffer.writeln('');

    // Raw data header
    buffer.writeln('=== RAW DATA ===');
    buffer.writeln(_getCSVHeader());

    // Raw data rows
    for (var response in filteredResponses) {
      buffer.writeln(_responseToCSVRow(response));
    }

    return buffer.toString();
  }

  // Export to PDF format with proper PDF generation
  Future<Uint8List> exportToPDF(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) async {
    final filteredResponses = _filterResponses(responses, config);
    final pdf = pw.Document();

    final avgScore = _calculateAverageSQDScore(filteredResponses);
    final satRate = _calculateSatisfactionRate(filteredResponses);
    final awarenessRate = _calculateAwarenessRate(filteredResponses);
    final satDist = _calculateSatisfactionDistribution(filteredResponses);
    final sqdBreakdown = _calculateSQDBreakdown(filteredResponses);

    // Cover Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'ARTA Customer Satisfaction',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Survey Report',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'City Government of Valenzuela',
                style: pw.TextStyle(fontSize: 18),
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                DateFormat('MMMM dd, yyyy').format(DateTime.now()),
                style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 60),
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.blue800, width: 2),
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Total Responses: ${filteredResponses.length}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Average Score: ${avgScore.toStringAsFixed(2)} / 5.0',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    pw.Text(
                      'Satisfaction Rate: ${satRate.toStringAsFixed(1)}%',
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Executive Summary Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'Executive Summary'),
            pw.SizedBox(height: 20),

            _buildPdfSection('Key Metrics', [
              'Total survey responses collected: ${filteredResponses.length}',
              'Average SQD Score: ${avgScore.toStringAsFixed(2)} out of 5.0',
              'Overall Satisfaction Rate: ${satRate.toStringAsFixed(1)}%',
              'Citizen\'s Charter Awareness: ${awarenessRate.toStringAsFixed(1)}%',
            ]),

            pw.SizedBox(height: 20),

            _buildPdfSection('Satisfaction Distribution', [
              'Very Satisfied: ${satDist['Very Satisfied']} (${_pct(satDist['Very Satisfied']!, filteredResponses.length)}%)',
              'Satisfied: ${satDist['Satisfied']} (${_pct(satDist['Satisfied']!, filteredResponses.length)}%)',
              'Neutral: ${satDist['Neutral']} (${_pct(satDist['Neutral']!, filteredResponses.length)}%)',
              'Dissatisfied: ${satDist['Dissatisfied']} (${_pct(satDist['Dissatisfied']!, filteredResponses.length)}%)',
              'Very Dissatisfied: ${satDist['Very Dissatisfied']} (${_pct(satDist['Very Dissatisfied']!, filteredResponses.length)}%)',
            ]),

            pw.SizedBox(height: 20),

            _buildPdfSection('Compliance Status', [
              'Rating: ${_calculateComplianceScore(avgScore, satRate)}',
              avgScore >= 4.0
                  ? 'The agency meets ARTA standards for service quality.'
                  : 'Areas for improvement have been identified.',
            ]),
          ],
        ),
      ),
    );

    // SQD Analysis Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, text: 'Service Quality Dimensions Analysis'),
            pw.SizedBox(height: 20),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blue100),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Dimension',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Avg Score',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        'Rating',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                ..._buildSQDTableRows(sqdBreakdown),
              ],
            ),

            pw.SizedBox(height: 30),

            pw.Header(level: 1, text: 'Recommendations'),
            pw.SizedBox(height: 10),
            ...(_generateARTARecommendations(filteredResponses, avgScore).map(
              (rec) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '• ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Expanded(child: pw.Text(rec)),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );

    // Demographics Page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final byAge = _groupByAge(filteredResponses);
          final bySex = _groupBySex(filteredResponses);
          final byClientType = _groupByClientType(filteredResponses);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'Demographic Analysis'),
              pw.SizedBox(height: 20),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'By Age Group',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        ...byAge.entries.map(
                          (e) => pw.Text('${e.key}: ${e.value}'),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'By Sex',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        pw.SizedBox(height: 10),
                        ...bySex.entries.map(
                          (e) => pw.Text('${e.key}: ${e.value}'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              pw.Text(
                'By Client Type',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 10),
              ...byClientType.entries.map(
                (e) => pw.Text('${e.key}: ${e.value}'),
              ),

              pw.SizedBox(height: 30),

              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Report Generated',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Date: ${DateFormat('MMMM dd, yyyy HH:mm').format(DateTime.now())}',
                    ),
                    pw.Text('Total Records: ${filteredResponses.length}'),
                    pw.Text('Filters: ${_getFiltersApplied(config)}'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  String _pct(int count, int total) {
    if (total == 0) return '0.0';
    return (count / total * 100).toStringAsFixed(1);
  }

  pw.Widget _buildPdfSection(String title, List<String> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8),
        ...items.map(
          (item) => pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            child: pw.Text(item),
          ),
        ),
      ],
    );
  }

  List<pw.TableRow> _buildSQDTableRows(Map<String, double> sqdBreakdown) {
    final sqdLabels = {
      'SQD0': 'Overall Satisfaction',
      'SQD1': 'Transaction Time',
      'SQD2': 'Requirements',
      'SQD3': 'Steps Simplicity',
      'SQD4': 'Information Access',
      'SQD5': 'Fees Reasonableness',
      'SQD6': 'Fairness',
      'SQD7': 'Staff Courtesy',
      'SQD8': 'Service Delivery',
    };

    return sqdBreakdown.entries.map((entry) {
      final score = entry.value;
      String rating;
      PdfColor ratingColor;

      if (score >= 4.5) {
        rating = 'Excellent';
        ratingColor = PdfColors.green700;
      } else if (score >= 4.0) {
        rating = 'Very Good';
        ratingColor = PdfColors.green500;
      } else if (score >= 3.5) {
        rating = 'Good';
        ratingColor = PdfColors.amber700;
      } else if (score >= 3.0) {
        rating = 'Fair';
        ratingColor = PdfColors.orange700;
      } else {
        rating = 'Needs Improvement';
        ratingColor = PdfColors.red700;
      }

      return pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(sqdLabels[entry.key] ?? entry.key),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(score.toStringAsFixed(2)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(rating, style: pw.TextStyle(color: ratingColor)),
          ),
        ],
      );
    }).toList();
  }

  // Export to ARTA format (JSON for government compliance)
  Future<Map<String, dynamic>> exportToARTA(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) async {
    final filteredResponses = _filterResponses(responses, config);

    final totalResponses = filteredResponses.length;
    final avgSQDScore = _calculateAverageSQDScore(filteredResponses);
    final satisfactionRate = _calculateSatisfactionRate(filteredResponses);

    return {
      'format': 'arta_compliant',
      'version': '1.0',
      'report_period': {
        'start_date':
            config.startDate?.toIso8601String() ??
            (filteredResponses.isNotEmpty
                ? filteredResponses.first.submittedAt.toIso8601String()
                : null),
        'end_date':
            config.endDate?.toIso8601String() ??
            (filteredResponses.isNotEmpty
                ? filteredResponses.last.submittedAt.toIso8601String()
                : null),
      },
      'agency_information': {
        'name': 'City Government of Valenzuela',
        'region': 'NCR',
        'province': 'Metro Manila',
        'city': 'Valenzuela',
      },
      'citizen_charter_awareness': _calculateCCMetrics(filteredResponses),
      'service_quality_dimensions': {
        'total_responses': totalResponses,
        'average_score': avgSQDScore,
        'satisfaction_rate': satisfactionRate,
        'sqd_breakdown': _calculateSQDBreakdown(filteredResponses),
      },
      'satisfaction_distribution': _calculateSatisfactionDistribution(
        filteredResponses,
      ),
      'demographic_breakdown': _calculateDemographicBreakdown(
        filteredResponses,
      ),
      'service_breakdown': _calculateServiceBreakdown(filteredResponses),
      'regional_breakdown': _calculateRegionalBreakdown(filteredResponses),
      'recommendations': _generateARTARecommendations(
        filteredResponses,
        avgSQDScore,
      ),
      'compliance_score': _calculateComplianceScore(
        avgSQDScore,
        satisfactionRate,
      ),
      'metadata': {
        'generated_at': DateTime.now().toIso8601String(),
        'total_records': filteredResponses.length,
        'filters_applied': _getFiltersApplied(config),
      },
    };
  }

  // Export to CSV format (simple raw data export)
  Future<String> exportToCSV(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) async {
    final filteredResponses = _filterResponses(responses, config);

    final StringBuffer buffer = StringBuffer();
    buffer.write('\uFEFF'); // BOM for Excel
    buffer.writeln(_getCSVHeader());

    for (var response in filteredResponses) {
      buffer.writeln(_responseToCSVRow(response));
    }

    return buffer.toString();
  }

  String _getCSVHeader() {
    return [
      'ID',
      'Submission Date',
      'Transaction Date',
      'Client Type',
      'Sex',
      'Age',
      'Region',
      'Service Availed',
      'CC1 - Charter Awareness',
      'CC2 - Charter Visibility',
      'CC3 - Charter Helpfulness',
      'SQD0 - Overall',
      'SQD1 - Time',
      'SQD2 - Requirements',
      'SQD3 - Steps',
      'SQD4 - Info Access',
      'SQD5 - Fees',
      'SQD6 - Fairness',
      'SQD7 - Courtesy',
      'SQD8 - Delivery',
      'Average SQD Score',
      'Satisfaction Level',
      'Suggestions',
    ].map((h) => '"$h"').join(',');
  }

  String _responseToCSVRow(SurveyResponse response) {
    return [
      response.id,
      DateFormat('yyyy-MM-dd HH:mm:ss').format(response.submittedAt),
      DateFormat('yyyy-MM-dd').format(response.date),
      response.clientType,
      response.sex,
      response.age.toString(),
      response.region,
      response.serviceAvailed ?? '',
      response.cc1Answer ?? '',
      response.cc2Answer ?? '',
      response.cc3Answer ?? '',
      (response.sqdAnswers['SQD0'] ?? '').toString(),
      (response.sqdAnswers['SQD1'] ?? '').toString(),
      (response.sqdAnswers['SQD2'] ?? '').toString(),
      (response.sqdAnswers['SQD3'] ?? '').toString(),
      (response.sqdAnswers['SQD4'] ?? '').toString(),
      (response.sqdAnswers['SQD5'] ?? '').toString(),
      (response.sqdAnswers['SQD6'] ?? '').toString(),
      (response.sqdAnswers['SQD7'] ?? '').toString(),
      (response.sqdAnswers['SQD8'] ?? '').toString(),
      response.averageSQDScore.toStringAsFixed(2),
      response.satisfactionLevel,
      response.suggestions.replaceAll('"', '""').replaceAll('\n', ' '),
    ].map((cell) => '"$cell"').join(',');
  }

  // Helper: Filter responses based on config
  List<SurveyResponse> _filterResponses(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) {
    return responses.where((response) {
      if (config.startDate != null &&
          response.submittedAt.isBefore(config.startDate!)) {
        return false;
      }
      if (config.endDate != null &&
          response.submittedAt.isAfter(config.endDate!)) {
        return false;
      }
      if (config.region != null && response.region != config.region) {
        return false;
      }
      if (config.serviceType != null &&
          response.serviceAvailed != config.serviceType) {
        return false;
      }
      return true;
    }).toList();
  }

  // Helper: Calculate average SQD score
  double _calculateAverageSQDScore(List<SurveyResponse> responses) {
    if (responses.isEmpty) return 0.0;
    final sum = responses.fold<double>(0, (sum, r) => sum + r.averageSQDScore);
    return sum / responses.length;
  }

  // Helper: Calculate satisfaction rate
  double _calculateSatisfactionRate(List<SurveyResponse> responses) {
    if (responses.isEmpty) return 0.0;
    final satisfied = responses
        .where(
          (r) =>
              r.satisfactionLevel == 'Very Satisfied' ||
              r.satisfactionLevel == 'Satisfied',
        )
        .length;
    return (satisfied / responses.length) * 100;
  }

  // Helper: Calculate CC metrics
  Map<String, dynamic> _calculateCCMetrics(List<SurveyResponse> responses) {
    final cc1Distribution = <String, int>{};
    final cc2Distribution = <String, int>{};
    final cc3Distribution = <String, int>{};

    for (var response in responses) {
      if (response.cc1Answer != null) {
        cc1Distribution[response.cc1Answer!] =
            (cc1Distribution[response.cc1Answer!] ?? 0) + 1;
      }
      if (response.cc2Answer != null) {
        cc2Distribution[response.cc2Answer!] =
            (cc2Distribution[response.cc2Answer!] ?? 0) + 1;
      }
      if (response.cc3Answer != null) {
        cc3Distribution[response.cc3Answer!] =
            (cc3Distribution[response.cc3Answer!] ?? 0) + 1;
      }
    }

    return {
      'cc1_awareness': cc1Distribution,
      'cc2_visibility': cc2Distribution,
      'cc3_helpfulness': cc3Distribution,
      'awareness_rate': _calculateAwarenessRate(responses),
    };
  }

  double _calculateAwarenessRate(List<SurveyResponse> responses) {
    if (responses.isEmpty) return 0.0;
    final aware = responses
        .where(
          (r) =>
              r.cc1Answer != null && r.cc1Answer!.contains('know what a CC is'),
        )
        .length;
    return (aware / responses.length) * 100;
  }

  // Helper: Calculate SQD breakdown
  Map<String, double> _calculateSQDBreakdown(List<SurveyResponse> responses) {
    final Map<String, double> breakdown = {};

    for (int i = 0; i < 9; i++) {
      final key = 'SQD$i';
      final scores = responses
          .map((r) => r.sqdAnswers[key])
          .where((score) => score != null)
          .cast<int>()
          .toList();

      if (scores.isNotEmpty) {
        breakdown[key] = scores.reduce((a, b) => a + b) / scores.length;
      }
    }

    return breakdown;
  }

  // Helper: Calculate satisfaction distribution
  Map<String, int> _calculateSatisfactionDistribution(
    List<SurveyResponse> responses,
  ) {
    return {
      'Very Satisfied': responses
          .where((r) => r.satisfactionLevel == 'Very Satisfied')
          .length,
      'Satisfied': responses
          .where((r) => r.satisfactionLevel == 'Satisfied')
          .length,
      'Neutral': responses
          .where((r) => r.satisfactionLevel == 'Neutral')
          .length,
      'Dissatisfied': responses
          .where((r) => r.satisfactionLevel == 'Dissatisfied')
          .length,
      'Very Dissatisfied': responses
          .where((r) => r.satisfactionLevel == 'Very Dissatisfied')
          .length,
    };
  }

  // Helper: Calculate demographic breakdown
  Map<String, dynamic> _calculateDemographicBreakdown(
    List<SurveyResponse> responses,
  ) {
    return {
      'by_sex': _groupBySex(responses),
      'by_age_group': _groupByAge(responses),
      'by_client_type': _groupByClientType(responses),
    };
  }

  // Helper: Calculate service breakdown
  Map<String, int> _calculateServiceBreakdown(List<SurveyResponse> responses) {
    final Map<String, int> breakdown = {};
    for (var response in responses) {
      final service = response.serviceAvailed ?? 'Unknown';
      breakdown[service] = (breakdown[service] ?? 0) + 1;
    }
    return breakdown;
  }

  // Helper: Calculate regional breakdown
  Map<String, int> _calculateRegionalBreakdown(List<SurveyResponse> responses) {
    final Map<String, int> breakdown = {};
    for (var response in responses) {
      breakdown[response.region] = (breakdown[response.region] ?? 0) + 1;
    }
    return breakdown;
  }

  // Helper: Generate ARTA recommendations
  List<String> _generateARTARecommendations(
    List<SurveyResponse> responses,
    double avgScore,
  ) {
    final recommendations = <String>[];

    if (avgScore < 3.5) {
      recommendations.add('Immediate improvement needed in service quality');
      recommendations.add('Conduct staff training on customer service');
      recommendations.add('Review and streamline service delivery processes');
    } else if (avgScore < 4.0) {
      recommendations.add('Continue monitoring service quality metrics');
      recommendations.add('Address specific areas with lower scores');
      recommendations.add(
        'Implement feedback mechanisms for continuous improvement',
      );
    } else {
      recommendations.add('Maintain current service quality standards');
      recommendations.add('Share best practices across departments');
      recommendations.add('Consider recognizing high-performing staff');
    }

    final awarenessRate = _calculateAwarenessRate(responses);
    if (awarenessRate < 70) {
      recommendations.add('Increase visibility of Citizen\'s Charter');
      recommendations.add('Conduct information campaigns on CC');
    }

    return recommendations;
  }

  // Helper: Calculate compliance score
  String _calculateComplianceScore(double avgScore, double satisfactionRate) {
    if (avgScore >= 4.5 && satisfactionRate >= 90) {
      return 'Excellent';
    } else if (avgScore >= 4.0 && satisfactionRate >= 80) {
      return 'Very Good';
    } else if (avgScore >= 3.5 && satisfactionRate >= 70) {
      return 'Good';
    } else if (avgScore >= 3.0 && satisfactionRate >= 60) {
      return 'Fair';
    } else {
      return 'Needs Improvement';
    }
  }

  // Additional helper methods
  Map<String, int> _groupBySex(List<SurveyResponse> responses) {
    final Map<String, int> distribution = {};
    for (var response in responses) {
      distribution[response.sex] = (distribution[response.sex] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _groupByAge(List<SurveyResponse> responses) {
    final Map<String, int> distribution = {
      '18-25': 0,
      '26-35': 0,
      '36-45': 0,
      '46-55': 0,
      '56+': 0,
    };

    for (var response in responses) {
      if (response.age <= 25) {
        distribution['18-25'] = distribution['18-25']! + 1;
      } else if (response.age <= 35) {
        distribution['26-35'] = distribution['26-35']! + 1;
      } else if (response.age <= 45) {
        distribution['36-45'] = distribution['36-45']! + 1;
      } else if (response.age <= 55) {
        distribution['46-55'] = distribution['46-55']! + 1;
      } else {
        distribution['56+'] = distribution['56+']! + 1;
      }
    }

    return distribution;
  }

  Map<String, int> _groupByClientType(List<SurveyResponse> responses) {
    final Map<String, int> distribution = {};
    for (var response in responses) {
      distribution[response.clientType] =
          (distribution[response.clientType] ?? 0) + 1;
    }
    return distribution;
  }

  String _getFiltersApplied(ExportConfig config) {
    final filters = <String>[];
    if (config.startDate != null) {
      filters.add(
        'Start Date: ${DateFormat('yyyy-MM-dd').format(config.startDate!)}',
      );
    }
    if (config.endDate != null) {
      filters.add(
        'End Date: ${DateFormat('yyyy-MM-dd').format(config.endDate!)}',
      );
    }
    if (config.region != null) {
      filters.add('Region: ${config.region}');
    }
    if (config.serviceType != null) {
      filters.add('Service: ${config.serviceType}');
    }
    return filters.isEmpty ? 'None' : filters.join(', ');
  }
}
