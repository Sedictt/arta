import 'package:intl/intl.dart';
import '../models/survey_response.dart';
import '../models/export_config.dart';

class ExportService {
  // Export to Excel format (simulated - returns data structure)
  Future<Map<String, dynamic>> exportToExcel(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) async {
    final filteredResponses = _filterResponses(responses, config);
    
    return {
      'format': 'xlsx',
      'sheets': {
        'Summary': _generateSummarySheet(filteredResponses),
        'Raw Data': _generateRawDataSheet(filteredResponses),
        'Statistics': _generateStatisticsSheet(filteredResponses),
      },
      'metadata': {
        'generated_at': DateTime.now().toIso8601String(),
        'total_records': filteredResponses.length,
        'filters_applied': _getFiltersApplied(config),
      },
    };
  }

  // Export to PDF format (simulated - returns data structure)
  Future<Map<String, dynamic>> exportToPDF(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) async {
    final filteredResponses = _filterResponses(responses, config);
    
    return {
      'format': 'pdf',
      'sections': {
        'cover': {
          'title': 'ARTA Client Satisfaction Survey Report',
          'subtitle': 'City Government of Valenzuela',
          'date': DateFormat('MMMM dd, yyyy').format(DateTime.now()),
        },
        'executive_summary': _generateExecutiveSummary(filteredResponses),
        'charts': config.includeCharts ? _generateChartData(filteredResponses) : null,
        'detailed_analysis': _generateDetailedAnalysis(filteredResponses),
        'recommendations': _generateRecommendations(filteredResponses),
      },
      'metadata': {
        'generated_at': DateTime.now().toIso8601String(),
        'total_pages': _calculatePages(filteredResponses),
        'total_records': filteredResponses.length,
      },
    };
  }

  // Export to ARTA format
  Future<Map<String, dynamic>> exportToARTA(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) async {
    final filteredResponses = _filterResponses(responses, config);
    
    // Calculate ARTA-required metrics
    final totalResponses = filteredResponses.length;
    final avgSQDScore = _calculateAverageSQDScore(filteredResponses);
    final satisfactionRate = _calculateSatisfactionRate(filteredResponses);
    
    return {
      'format': 'arta_compliant',
      'report_period': {
        'start_date': config.startDate?.toIso8601String() ?? 
                      filteredResponses.first.submittedAt.toIso8601String(),
        'end_date': config.endDate?.toIso8601String() ?? 
                    filteredResponses.last.submittedAt.toIso8601String(),
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
      'satisfaction_distribution': _calculateSatisfactionDistribution(filteredResponses),
      'demographic_breakdown': _calculateDemographicBreakdown(filteredResponses),
      'service_breakdown': _calculateServiceBreakdown(filteredResponses),
      'regional_breakdown': _calculateRegionalBreakdown(filteredResponses),
      'recommendations': _generateARTARecommendations(filteredResponses, avgSQDScore),
      'compliance_score': _calculateComplianceScore(avgSQDScore, satisfactionRate),
      'raw_data': filteredResponses.map((r) => _formatARTAResponse(r)).toList(),
    };
  }

  // Export to CSV format
  Future<String> exportToCSV(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) async {
    final filteredResponses = _filterResponses(responses, config);
    
    final List<List<dynamic>> rows = [
      [
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
        'SQD0 - Service Satisfaction',
        'SQD1 - Transaction Time',
        'SQD2 - Requirements Followed',
        'SQD3 - Steps Simplicity',
        'SQD4 - Information Access',
        'SQD5 - Fees Reasonableness',
        'SQD6 - Fairness',
        'SQD7 - Staff Courtesy',
        'SQD8 - Service Delivery',
        'Average SQD Score',
        'Satisfaction Level',
        'Suggestions',
      ]
    ];

    for (var response in filteredResponses) {
      rows.add([
        response.id,
        DateFormat('yyyy-MM-dd HH:mm:ss').format(response.submittedAt),
        DateFormat('yyyy-MM-dd').format(response.date),
        response.clientType,
        response.sex,
        response.age,
        response.region,
        response.serviceAvailed ?? '',
        response.cc1Answer ?? '',
        response.cc2Answer ?? '',
        response.cc3Answer ?? '',
        response.sqdAnswers['SQD0'] ?? '',
        response.sqdAnswers['SQD1'] ?? '',
        response.sqdAnswers['SQD2'] ?? '',
        response.sqdAnswers['SQD3'] ?? '',
        response.sqdAnswers['SQD4'] ?? '',
        response.sqdAnswers['SQD5'] ?? '',
        response.sqdAnswers['SQD6'] ?? '',
        response.sqdAnswers['SQD7'] ?? '',
        response.sqdAnswers['SQD8'] ?? '',
        response.averageSQDScore.toStringAsFixed(2),
        response.satisfactionLevel,
        response.suggestions.replaceAll(',', ';').replaceAll('\n', ' '),
      ]);
    }

    return rows.map((row) => row.map((cell) => '"$cell"').join(',')).join('\n');
  }

  // Helper: Filter responses based on config
  List<SurveyResponse> _filterResponses(
    List<SurveyResponse> responses,
    ExportConfig config,
  ) {
    return responses.where((response) {
      if (config.startDate != null && response.submittedAt.isBefore(config.startDate!)) {
        return false;
      }
      if (config.endDate != null && response.submittedAt.isAfter(config.endDate!)) {
        return false;
      }
      if (config.region != null && response.region != config.region) {
        return false;
      }
      if (config.serviceType != null && response.serviceAvailed != config.serviceType) {
        return false;
      }
      return true;
    }).toList();
  }

  // Helper: Generate summary sheet
  Map<String, dynamic> _generateSummarySheet(List<SurveyResponse> responses) {
    return {
      'total_responses': responses.length,
      'date_range': {
        'start': responses.isEmpty ? null : responses.first.submittedAt.toIso8601String(),
        'end': responses.isEmpty ? null : responses.last.submittedAt.toIso8601String(),
      },
      'average_satisfaction': _calculateAverageSQDScore(responses),
      'satisfaction_rate': _calculateSatisfactionRate(responses),
      'top_services': _getTopServices(responses, 5),
      'top_regions': _getTopRegions(responses, 5),
    };
  }

  // Helper: Generate raw data sheet
  List<Map<String, dynamic>> _generateRawDataSheet(List<SurveyResponse> responses) {
    return responses.map((r) => {
      'id': r.id,
      'date': DateFormat('yyyy-MM-dd').format(r.date),
      'client_type': r.clientType,
      'sex': r.sex,
      'age': r.age,
      'region': r.region,
      'service': r.serviceAvailed,
      'avg_score': r.averageSQDScore,
      'satisfaction': r.satisfactionLevel,
    }).toList();
  }

  // Helper: Generate statistics sheet
  Map<String, dynamic> _generateStatisticsSheet(List<SurveyResponse> responses) {
    return {
      'demographics': {
        'by_age': _groupByAge(responses),
        'by_sex': _groupBySex(responses),
        'by_client_type': _groupByClientType(responses),
      },
      'satisfaction_metrics': {
        'very_satisfied': responses.where((r) => r.satisfactionLevel == 'Very Satisfied').length,
        'satisfied': responses.where((r) => r.satisfactionLevel == 'Satisfied').length,
        'neutral': responses.where((r) => r.satisfactionLevel == 'Neutral').length,
        'dissatisfied': responses.where((r) => r.satisfactionLevel == 'Dissatisfied').length,
        'very_dissatisfied': responses.where((r) => r.satisfactionLevel == 'Very Dissatisfied').length,
      },
      'sqd_averages': _calculateSQDAverages(responses),
    };
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
    final satisfied = responses.where((r) => 
      r.satisfactionLevel == 'Very Satisfied' || r.satisfactionLevel == 'Satisfied'
    ).length;
    return (satisfied / responses.length) * 100;
  }

  // Helper: Calculate CC metrics
  Map<String, dynamic> _calculateCCMetrics(List<SurveyResponse> responses) {
    final cc1Distribution = <String, int>{};
    final cc2Distribution = <String, int>{};
    final cc3Distribution = <String, int>{};

    for (var response in responses) {
      if (response.cc1Answer != null) {
        cc1Distribution[response.cc1Answer!] = (cc1Distribution[response.cc1Answer!] ?? 0) + 1;
      }
      if (response.cc2Answer != null) {
        cc2Distribution[response.cc2Answer!] = (cc2Distribution[response.cc2Answer!] ?? 0) + 1;
      }
      if (response.cc3Answer != null) {
        cc3Distribution[response.cc3Answer!] = (cc3Distribution[response.cc3Answer!] ?? 0) + 1;
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
    final aware = responses.where((r) => 
      r.cc1Answer != null && r.cc1Answer!.contains('know what a CC is')
    ).length;
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
  Map<String, int> _calculateSatisfactionDistribution(List<SurveyResponse> responses) {
    return {
      'Very Satisfied': responses.where((r) => r.satisfactionLevel == 'Very Satisfied').length,
      'Satisfied': responses.where((r) => r.satisfactionLevel == 'Satisfied').length,
      'Neutral': responses.where((r) => r.satisfactionLevel == 'Neutral').length,
      'Dissatisfied': responses.where((r) => r.satisfactionLevel == 'Dissatisfied').length,
      'Very Dissatisfied': responses.where((r) => r.satisfactionLevel == 'Very Dissatisfied').length,
    };
  }

  // Helper: Calculate demographic breakdown
  Map<String, dynamic> _calculateDemographicBreakdown(List<SurveyResponse> responses) {
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
  List<String> _generateARTARecommendations(List<SurveyResponse> responses, double avgScore) {
    final recommendations = <String>[];
    
    if (avgScore < 3.5) {
      recommendations.add('Immediate improvement needed in service quality');
      recommendations.add('Conduct staff training on customer service');
    } else if (avgScore < 4.0) {
      recommendations.add('Continue monitoring service quality metrics');
      recommendations.add('Address specific areas with lower scores');
    } else {
      recommendations.add('Maintain current service quality standards');
      recommendations.add('Share best practices across departments');
    }
    
    // Check CC awareness
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

  // Helper: Format ARTA response
  Map<String, dynamic> _formatARTAResponse(SurveyResponse response) {
    return {
      'response_id': response.id,
      'transaction_date': DateFormat('yyyy-MM-dd').format(response.date),
      'submission_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(response.submittedAt),
      'demographics': {
        'client_type': response.clientType,
        'sex': response.sex,
        'age': response.age,
        'region': response.region,
      },
      'service_availed': response.serviceAvailed,
      'cc_responses': {
        'cc1': response.cc1Answer,
        'cc2': response.cc2Answer,
        'cc3': response.cc3Answer,
      },
      'sqd_scores': response.sqdAnswers,
      'average_sqd_score': response.averageSQDScore,
      'satisfaction_level': response.satisfactionLevel,
      'suggestions': response.suggestions,
    };
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
      distribution[response.clientType] = (distribution[response.clientType] ?? 0) + 1;
    }
    return distribution;
  }

  List<Map<String, dynamic>> _getTopServices(List<SurveyResponse> responses, int limit) {
    final serviceCount = _calculateServiceBreakdown(responses);
    final sorted = serviceCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => {'service': e.key, 'count': e.value}).toList();
  }

  List<Map<String, dynamic>> _getTopRegions(List<SurveyResponse> responses, int limit) {
    final regionCount = _calculateRegionalBreakdown(responses);
    final sorted = regionCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => {'region': e.key, 'count': e.value}).toList();
  }

  Map<String, double> _calculateSQDAverages(List<SurveyResponse> responses) {
    return _calculateSQDBreakdown(responses);
  }

  String _getFiltersApplied(ExportConfig config) {
    final filters = <String>[];
    if (config.startDate != null) filters.add('Start Date: ${DateFormat('yyyy-MM-dd').format(config.startDate!)}');
    if (config.endDate != null) filters.add('End Date: ${DateFormat('yyyy-MM-dd').format(config.endDate!)}');
    if (config.region != null) filters.add('Region: ${config.region}');
    if (config.serviceType != null) filters.add('Service: ${config.serviceType}');
    return filters.isEmpty ? 'None' : filters.join(', ');
  }

  Map<String, dynamic> _generateExecutiveSummary(List<SurveyResponse> responses) {
    return {
      'total_responses': responses.length,
      'average_satisfaction': _calculateAverageSQDScore(responses),
      'satisfaction_rate': _calculateSatisfactionRate(responses),
      'key_findings': [
        'Total ${responses.length} responses collected',
        'Average satisfaction score: ${_calculateAverageSQDScore(responses).toStringAsFixed(2)}/5.0',
        'Satisfaction rate: ${_calculateSatisfactionRate(responses).toStringAsFixed(1)}%',
      ],
    };
  }

  Map<String, dynamic> _generateChartData(List<SurveyResponse> responses) {
    return {
      'satisfaction_distribution': _calculateSatisfactionDistribution(responses),
      'sqd_breakdown': _calculateSQDBreakdown(responses),
      'regional_breakdown': _calculateRegionalBreakdown(responses),
      'service_breakdown': _calculateServiceBreakdown(responses),
    };
  }

  Map<String, dynamic> _generateDetailedAnalysis(List<SurveyResponse> responses) {
    return {
      'demographics': _calculateDemographicBreakdown(responses),
      'service_analysis': _calculateServiceBreakdown(responses),
      'regional_analysis': _calculateRegionalBreakdown(responses),
      'cc_analysis': _calculateCCMetrics(responses),
      'sqd_analysis': _calculateSQDBreakdown(responses),
    };
  }

  List<String> _generateRecommendations(List<SurveyResponse> responses) {
    return _generateARTARecommendations(responses, _calculateAverageSQDScore(responses));
  }

  int _calculatePages(List<SurveyResponse> responses) {
    // Estimate pages based on content
    return (responses.length / 10).ceil() + 5; // 5 pages for headers, charts, etc.
  }
}
