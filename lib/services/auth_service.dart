import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin_user.dart';

class AuthService {
  static const String _usersKey = 'admin_users';
  static const String _currentUserKey = 'current_user';
  static const String _sessionKey = 'session_token';

  // Hash password
  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Initialize default super admin
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

  // Get all users
  Future<List<AdminUser>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    
    if (usersJson == null || usersJson.isEmpty) {
      return [];
    }
    
    final List<dynamic> usersList = json.decode(usersJson);
    return usersList.map((json) => AdminUser.fromJson(json)).toList();
  }

  // Save users
  Future<void> _saveUsers(List<AdminUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = json.encode(users.map((u) => u.toJson()).toList());
    await prefs.setString(_usersKey, usersJson);
  }

  // Login
  Future<AdminUser?> login(String username, String password) async {
    final users = await getAllUsers();
    final passwordHash = hashPassword(password);
    
    try {
      final user = users.firstWhere(
        (u) => u.username == username && 
               u.passwordHash == passwordHash && 
               u.isActive,
      );
      
      // Update last login
      final updatedUser = user.copyWith(lastLogin: DateTime.now());
      await updateUser(updatedUser);
      
      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, json.encode(updatedUser.toJson()));
      await prefs.setString(_sessionKey, DateTime.now().millisecondsSinceEpoch.toString());
      
      return updatedUser;
    } catch (e) {
      return null;
    }
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
    await prefs.remove(_currentUserKey);
    await prefs.remove(_sessionKey);
  }

  // Create user
  Future<bool> createUser(AdminUser user) async {
    final users = await getAllUsers();
    
    // Check if username or email already exists
    if (users.any((u) => u.username == user.username || u.email == user.email)) {
      return false;
    }
    
    users.add(user);
    await _saveUsers(users);
    return true;
  }

  // Update user
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

  // Delete user
  Future<bool> deleteUser(String userId) async {
    final users = await getAllUsers();
    final initialLength = users.length;
    
    users.removeWhere((u) => u.id == userId);
    
    if (users.length == initialLength) return false;
    
    await _saveUsers(users);
    return true;
  }

  // Change password
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

  // Check session validity
  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString(_sessionKey);
    
    if (sessionToken == null) return false;
    
    final sessionTime = DateTime.fromMillisecondsSinceEpoch(int.parse(sessionToken));
    final now = DateTime.now();
    
    // Session expires after 8 hours
    return now.difference(sessionTime).inHours < 8;
  }
}
