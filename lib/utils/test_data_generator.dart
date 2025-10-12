import 'dart:math';
import '../models/survey_response.dart';
import '../services/survey_service.dart';

class TestDataGenerator {
  static final Random _random = Random();
  
  static final List<String> _clientTypes = ['Citizen', 'Business', 'Government Employee'];
  static final List<String> _sexes = ['Male', 'Female'];
  static final List<String> _regions = [
    'NCR', 'Region I', 'Region II', 'Region III', 'Region IV-A',
    'Region IV-B', 'Region V', 'Region VI', 'Region VII', 'Region VIII',
  ];
  static final List<String> _services = [
    'Business Permit',
    'Building Permit',
    'Cedula',
    'Community Tax Certificate',
    'Marriage License',
    'Birth Certificate',
    'Death Certificate',
    'Barangay Clearance',
    'Police Clearance',
    'Health Certificate',
  ];
  
  static final List<String> _cc1Options = [
    'I know what a CC is and I saw this office\'s CC',
    'I know what a CC is but I did NOT see this office\'s CC',
    'I learned of the CC only when I saw this office\'s CC',
    'I do not know what a CC is and I did not see one in this office',
  ];
  
  static final List<String> _cc2Options = [
    'Easy to see',
    'Somewhat easy to see',
    'Difficult to see',
    'Not visible at all',
    'Not Applicable',
  ];
  
  static final List<String> _cc3Options = [
    'Helped very much',
    'Somewhat helped',
    'Did not help',
    'Not Applicable',
  ];
  
  static final List<String> _suggestions = [
    'Great service!',
    'Very satisfied with the process.',
    'Staff were very helpful and courteous.',
    'Quick and efficient service.',
    'Could improve waiting time.',
    'Need more staff during peak hours.',
    'Online system would be helpful.',
    'Clear signage needed.',
    'More comfortable waiting area.',
    'Excellent customer service!',
    '',
  ];
  
  /// Generate a single random survey response
  static SurveyResponse generateRandomResponse() {
    final now = DateTime.now();
    final daysAgo = _random.nextInt(30);
    final submittedAt = now.subtract(Duration(days: daysAgo));
    
    // Generate SQD answers (mostly positive for realistic data)
    final sqdAnswers = <String, int>{};
    for (int i = 0; i < 9; i++) {
      // Weighted towards higher scores (4-5)
      final score = _random.nextInt(10) < 7 
          ? 4 + _random.nextInt(2)  // 70% chance of 4 or 5
          : 2 + _random.nextInt(3); // 30% chance of 2, 3, or 4
      sqdAnswers['SQD$i'] = score;
    }
    
    return SurveyResponse(
      id: DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(1000).toString(),
      date: submittedAt,
      clientType: _clientTypes[_random.nextInt(_clientTypes.length)],
      sex: _sexes[_random.nextInt(_sexes.length)],
      age: 18 + _random.nextInt(60), // Age between 18-77
      region: _regions[_random.nextInt(_regions.length)],
      serviceAvailed: _services[_random.nextInt(_services.length)],
      cc1Answer: _cc1Options[_random.nextInt(_cc1Options.length)],
      cc2Answer: _cc2Options[_random.nextInt(_cc2Options.length)],
      cc3Answer: _cc3Options[_random.nextInt(_cc3Options.length)],
      sqdAnswers: sqdAnswers,
      suggestions: _suggestions[_random.nextInt(_suggestions.length)],
      submittedAt: submittedAt,
    );
  }
  
  /// Generate and save multiple test responses
  static Future<void> generateTestData(int count) async {
    final surveyService = SurveyService();
    
    for (int i = 0; i < count; i++) {
      final response = generateRandomResponse();
      await surveyService.saveSurveyResponse(response);
      
      // Small delay to ensure unique timestamps
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
  
  /// Clear all existing data
  static Future<void> clearAllData() async {
    final surveyService = SurveyService();
    await surveyService.clearAllData();
  }
  
  /// Generate test data with specific distribution
  static Future<void> generateBalancedTestData({
    int totalResponses = 50,
  }) async {
    final surveyService = SurveyService();
    
    // Generate responses with balanced distribution
    for (int i = 0; i < totalResponses; i++) {
      final response = generateRandomResponse();
      await surveyService.saveSurveyResponse(response);
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }
}
