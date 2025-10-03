import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/survey_response.dart';
import 'api_service.dart';

class SurveyService {
  static const String _surveysKey = 'survey_responses';
  static const String _adminPasswordKey = 'admin_password';
  final ApiService _apiService = ApiService();

  // Save survey response (with MongoDB sync)
  Future<Map<String, dynamic>> saveSurveyResponse(SurveyResponse response) async {
    // First, try to save to MongoDB via backend API
    final apiResult = await _apiService.submitSurvey(response);
    
    // Always save locally as backup (offline capability)
    final prefs = await SharedPreferences.getInstance();
    final surveys = await getAllSurveyResponses();
    surveys.add(response);
    
    final jsonList = surveys.map((s) => s.toJson()).toList();
    await prefs.setString(_surveysKey, jsonEncode(jsonList));
    
    // Return the API result to inform the UI
    return apiResult;
  }

  // Get all survey responses
  Future<List<SurveyResponse>> getAllSurveyResponses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_surveysKey);
    
    if (jsonString == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => SurveyResponse.fromJson(json)).toList();
  }

  // Get responses by date range
  Future<List<SurveyResponse>> getResponsesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final allResponses = await getAllSurveyResponses();
    return allResponses.where((response) {
      return response.submittedAt.isAfter(start) &&
          response.submittedAt.isBefore(end);
    }).toList();
  }

  // Get responses by client type
  Future<List<SurveyResponse>> getResponsesByClientType(
    String clientType,
  ) async {
    final allResponses = await getAllSurveyResponses();
    return allResponses
        .where((response) => response.clientType == clientType)
        .toList();
  }

  // Get responses by region
  Future<List<SurveyResponse>> getResponsesByRegion(String region) async {
    final allResponses = await getAllSurveyResponses();
    return allResponses
        .where((response) => response.region == region)
        .toList();
  }

  // Calculate average SQD scores
  Future<Map<String, double>> getAverageSQDScores() async {
    final responses = await getAllSurveyResponses();
    if (responses.isEmpty) return {};

    final Map<String, List<int>> sqdScores = {};
    
    for (var response in responses) {
      response.sqdAnswers.forEach((key, value) {
        sqdScores.putIfAbsent(key, () => []).add(value);
      });
    }

    return sqdScores.map((key, values) {
      final avg = values.reduce((a, b) => a + b) / values.length;
      return MapEntry(key, avg);
    });
  }

  // Get satisfaction distribution
  Future<Map<String, int>> getSatisfactionDistribution() async {
    final responses = await getAllSurveyResponses();
    final distribution = <String, int>{
      'Very Satisfied': 0,
      'Satisfied': 0,
      'Neutral': 0,
      'Dissatisfied': 0,
      'Very Dissatisfied': 0,
    };

    for (var response in responses) {
      distribution[response.satisfactionLevel] =
          (distribution[response.satisfactionLevel] ?? 0) + 1;
    }

    return distribution;
  }

  // Admin authentication
  Future<void> setAdminPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    // In production, use proper encryption
    await prefs.setString(_adminPasswordKey, password);
  }

  Future<bool> verifyAdminPassword(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedPassword = prefs.getString(_adminPasswordKey);
    
    // Default password if not set
    if (storedPassword == null) {
      return password == 'admin123';
    }
    
    return password == storedPassword;
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_surveysKey);
  }

  // Get total response count
  Future<int> getTotalResponseCount() async {
    final responses = await getAllSurveyResponses();
    return responses.length;
  }

  // Get responses by date (for charts)
  Future<Map<DateTime, int>> getResponsesByDate() async {
    final responses = await getAllSurveyResponses();
    final Map<DateTime, int> dateCount = {};

    for (var response in responses) {
      final date = DateTime(
        response.submittedAt.year,
        response.submittedAt.month,
        response.submittedAt.day,
      );
      dateCount[date] = (dateCount[date] ?? 0) + 1;
    }

    return dateCount;
  }
}
