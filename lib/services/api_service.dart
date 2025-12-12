import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/survey_response.dart';

class ApiService {
  // IMPORTANT: Change this based on where you're running the Flutter app:
  //
  // Windows/Web/Desktop:     'http://localhost:3000'
  // Android Emulator:        'http://10.0.2.2:3000'
  // iOS Simulator:           'http://localhost:3000'
  // Physical Device:         'http://YOUR_PC_IP:3000' (e.g., 'http://192.168.1.100:3000')
  // Production:              Your deployed backend URL

  static const String baseUrl =
      'http://localhost:3000'; // ← CHANGE THIS IF NEEDED

  // Get auth headers with token
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Submit survey to MongoDB via backend API
  Future<Map<String, dynamic>> submitSurvey(SurveyResponse response) async {
    try {
      final url = Uri.parse('$baseUrl/api/surveys');

      // Convert SurveyResponse to the format expected by backend
      final Map<String, dynamic> requestBody = {
        'date': response.date.toIso8601String(),
        'clientType': response.clientType,
        'sex': response.sex,
        'age': response.age,
        'region': response.region,
        'serviceAvailed': response.serviceAvailed,
        'cc1Answer': response.cc1Answer,
        'cc2Answer': response.cc2Answer,
        'cc3Answer': response.cc3Answer,
        'sqdAnswers': response.sqdAnswers,
        'suggestions': response.suggestions,
        'extraAnswers': response.extraAnswers,
      };

      final httpResponse = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timeout - please check your internet connection',
              );
            },
          );

      final responseData = jsonDecode(httpResponse.body);

      if (httpResponse.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'] ?? 'Survey submitted successfully',
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to submit survey',
          'error': responseData['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server',
        'error': e.toString(),
      };
    }
  }

  // Fetch all surveys from backend (for admin dashboard)
  Future<Map<String, dynamic>> fetchSurveys({
    int page = 1,
    int limit = 10,
    String? clientType,
    String? region,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (clientType != null) queryParams['clientType'] = clientType;
      if (region != null) queryParams['region'] = region;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final url = Uri.parse(
        '$baseUrl/api/surveys',
      ).replace(queryParameters: queryParams);

      final headers = await _getAuthHeaders();
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch surveys');
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching surveys',
        'error': e.toString(),
      };
    }
  }

  // Check backend health
  Future<bool> checkBackendHealth() async {
    try {
      final url = Uri.parse('$baseUrl/');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Fetch analytics summary
  Future<Map<String, dynamic>> fetchAnalyticsSummary() async {
    try {
      final url = Uri.parse('$baseUrl/api/analytics/summary');
      final headers = await _getAuthHeaders();

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch analytics summary');
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching analytics',
        'error': e.toString(),
      };
    }
  }

  // Fetch satisfaction distribution
  Future<Map<String, dynamic>> fetchSatisfactionDistribution() async {
    try {
      final url = Uri.parse('$baseUrl/api/analytics/satisfaction-distribution');
      final headers = await _getAuthHeaders();

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch satisfaction distribution');
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching distribution',
        'error': e.toString(),
      };
    }
  }

  // Fetch analytics by client type
  Future<Map<String, dynamic>> fetchByClientType() async {
    try {
      final url = Uri.parse('$baseUrl/api/analytics/by-client-type');
      final headers = await _getAuthHeaders();

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch client type stats');
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error fetching client type stats',
        'error': e.toString(),
      };
    }
  }

  // Delete survey
  Future<Map<String, dynamic>> deleteSurvey(String surveyId) async {
    try {
      final url = Uri.parse('$baseUrl/api/surveys/$surveyId');
      final headers = await _getAuthHeaders();

      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete survey');
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting survey',
        'error': e.toString(),
      };
    }
  }
}
