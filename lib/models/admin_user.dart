enum UserRole {
  superAdmin,
  admin,
  viewer,
}

class AdminUser {
  final String id;
  final String username;
  final String email;
  final String passwordHash;
  final UserRole role;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  AdminUser({
    required this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'passwordHash': passwordHash,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      passwordHash: json['passwordHash'],
      role: UserRole.values.firstWhere((e) => e.name == json['role']),
      createdAt: DateTime.parse(json['createdAt']),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      isActive: json['isActive'] ?? true,
    );
  }

  AdminUser copyWith({
    String? username,
    String? email,
    String? passwordHash,
    UserRole? role,
    DateTime? lastLogin,
    bool? isActive,
  }) {
    return AdminUser(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
    );
  }

  bool hasPermission(String permission) {
    switch (role) {
      case UserRole.superAdmin:
        return true;
      case UserRole.admin:
        return permission != 'manage_users' && permission != 'edit_survey';
      case UserRole.viewer:
        return permission == 'view_dashboard' || permission == 'view_reports';
    }
  }
}
