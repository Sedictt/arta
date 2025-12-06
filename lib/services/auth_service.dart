import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_user.dart';

class AuthService {
  // Different base URLs for different environments
  static const String _emulatorUrl = 'http://10.0.2.2:3000';
  static const String _localhostUrl = 'http://localhost:3000';

  static const String _tokenKey = 'auth_token';
  static const String _currentUserKey = 'current_user';
  static const String _usersKey = 'admin_users'; // For local fallback

  // Login with backend API (tries multiple endpoints)
  Future<AdminUser?> login(String username, String password) async {
    // List of URLs to try, in order of preference
    final urlsToTry = [
      _localhostUrl, // Try localhost first (for desktop)
      _emulatorUrl, // Try emulator IP second
    ];

    for (var i = 0; i < urlsToTry.length; i++) {
      final baseUrl = urlsToTry[i];
      final isLastUrl = i == urlsToTry.length - 1;

      try {
        print('🔐 Attempting login to: $baseUrl/api/admin/login');
        print('👤 Username: $username');

        final url = Uri.parse('$baseUrl/api/admin/login');

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'username': username, 'password': password}),
            )
            .timeout(
              const Duration(seconds: 5), // Short timeout for faster failover
              onTimeout: () {
                print('❌ Login request timeout for $baseUrl');
                throw Exception('Connection timeout');
              },
            );

        print('📡 Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          if (data['success'] == true) {
            final token = data['token'];
            final adminData = data['admin'];

            print('✅ Login successful! Token received.');

            // Save token and user data
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_tokenKey, token);

            // Create AdminUser object
            final user = AdminUser(
              id: adminData['id'],
              username: adminData['username'],
              email: '${adminData['username']}@cgov.ph',
              passwordHash: '', // Not needed from backend
              role: adminData['role'] == 'superadmin'
                  ? UserRole.superAdmin
                  : UserRole.admin,
              createdAt: DateTime.now(),
              lastLogin: DateTime.now(),
            );

            await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));

            return user;
          } else {
            print('❌ Login failed: ${data['message']}');
            // If explicit failure from server, stop trying other URLs (credentials likely wrong)
            return null;
          }
        }
      } catch (e) {
        print('❌ Connection error for $baseUrl: $e');
        // If it's the last URL and failed, return null
        if (isLastUrl) return null;
        // Otherwise continue to next URL
        continue;
      }
    }
    return null;
  }

  // Get stored auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get current user
  Future<AdminUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);

    if (userJson == null) return null;

    return AdminUser.fromJson(json.decode(userJson));
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_currentUserKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Hash password (needed for local user management)
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Initialize default admin (for local fallback)
  Future<void> initializeDefaultAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null || usersJson.isEmpty) {
      final defaultAdmin = AdminUser(
        id: '1',
        username: 'admin',
        email: 'admin@cgov.ph',
        passwordHash: hashPassword('admin123'),
        role: UserRole.superAdmin,
        createdAt: DateTime.now(),
      );

      await _saveUsers([defaultAdmin]);
    }
  }

  // Get all users (local storage for now, can be extended to backend API)
  Future<List<AdminUser>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null || usersJson.isEmpty) {
      return [];
    }

    final List<dynamic> usersList = json.decode(usersJson);
    return usersList.map((json) => AdminUser.fromJson(json)).toList();
  }

  // Save users to local storage
  Future<void> _saveUsers(List<AdminUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }

  // Create user (local storage)
  Future<bool> createUser(AdminUser user) async {
    final users = await getAllUsers();

    // Check if username or email already exists
    if (users.any(
      (u) => u.username == user.username || u.email == user.email,
    )) {
      return false;
    }

    users.add(user);
    await _saveUsers(users);
    return true;
  }

  // Update user (local storage)
  Future<bool> updateUser(AdminUser updatedUser) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == updatedUser.id);

    if (index == -1) return false;

    users[index] = updatedUser;
    await _saveUsers(users);

    // Update current user if it's the same
    final currentUser = await getCurrentUser();
    if (currentUser?.id == updatedUser.id) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(updatedUser.toJson()));
    }

    return true;
  }

  // Delete user (local storage)
  Future<bool> deleteUser(String userId) async {
    final users = await getAllUsers();
    final initialLength = users.length;

    users.removeWhere((u) => u.id == userId);

    if (users.length == initialLength) return false;

    await _saveUsers(users);
    return true;
  }

  // Change password (local storage)
  Future<bool> changePassword(String userId, String newPassword) async {
    final users = await getAllUsers();
    final index = users.indexWhere((u) => u.id == userId);

    if (index == -1) return false;

    final updatedUser = users[index].copyWith(
      passwordHash: hashPassword(newPassword),
    );

    users[index] = updatedUser;
    await _saveUsers(users);
    return true;
  }
}
