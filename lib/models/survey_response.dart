class SurveyResponse {
  final String id;
  final DateTime date;
  final String clientType;
  final String sex;
  final int age;
  final String region;
  final String? serviceAvailed;
  final String? cc1Answer;
  final String? cc2Answer;
  final String? cc3Answer;
  final Map<String, int> sqdAnswers;
  final String suggestions;
  final DateTime submittedAt;

  SurveyResponse({
    required this.id,
    required this.date,
    required this.clientType,
    required this.sex,
    required this.age,
    required this.region,
    this.serviceAvailed,
    this.cc1Answer,
    this.cc2Answer,
    this.cc3Answer,
    required this.sqdAnswers,
    required this.suggestions,
    required this.submittedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'clientType': clientType,
      'sex': sex,
      'age': age,
      'region': region,
      'serviceAvailed': serviceAvailed,
      'cc1Answer': cc1Answer,
      'cc2Answer': cc2Answer,
      'cc3Answer': cc3Answer,
      'sqdAnswers': sqdAnswers,
      'suggestions': suggestions,
      'submittedAt': submittedAt.toIso8601String(),
    };
  }

  factory SurveyResponse.fromJson(Map<String, dynamic> json) {
    return SurveyResponse(
      id: json['id'],
      date: DateTime.parse(json['date']),
      clientType: json['clientType'],
      sex: json['sex'],
      age: json['age'],
      region: json['region'],
      serviceAvailed: json['serviceAvailed'],
      cc1Answer: json['cc1Answer'],
      cc2Answer: json['cc2Answer'],
      cc3Answer: json['cc3Answer'],
      sqdAnswers: Map<String, int>.from(json['sqdAnswers']),
      suggestions: json['suggestions'],
      submittedAt: DateTime.parse(json['submittedAt']),
    );
  }

  double get averageSQDScore {
    if (sqdAnswers.isEmpty) return 0;
    final sum = sqdAnswers.values.reduce((a, b) => a + b);
    return sum / sqdAnswers.length;
  }

  String get satisfactionLevel {
    final avg = averageSQDScore;
    if (avg >= 4.5) return 'Very Satisfied';
    if (avg >= 3.5) return 'Satisfied';
    if (avg >= 2.5) return 'Neutral';
    if (avg >= 1.5) return 'Dissatisfied';
    return 'Very Dissatisfied';
  }
}
