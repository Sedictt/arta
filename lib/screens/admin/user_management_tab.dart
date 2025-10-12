import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/admin_user.dart';
import '../../services/auth_service.dart';
import '../../main.dart';

class UserManagementTab extends StatefulWidget {
  final AdminUser currentUser;
  
  const UserManagementTab({super.key, required this.currentUser});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final AuthService _authService = AuthService();
  List<AdminUser> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    _users = await _authService.getAllUsers();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Management',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddUserDialog(),
                icon: const Icon(Icons.add),
                label: Text('Add User', style: GoogleFonts.poppins()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 3,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Username', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Email', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Role', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Created', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Last Login', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Status', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
                ],
                rows: _users.map((user) {
                  return DataRow(
                    cells: [
                      DataCell(Text(user.username, style: GoogleFonts.poppins())),
                      DataCell(Text(user.email, style: GoogleFonts.poppins())),
                      DataCell(_buildRoleBadge(user.role)),
                      DataCell(Text(
                        DateFormat('MMM dd, yyyy').format(user.createdAt),
                        style: GoogleFonts.poppins(fontSize: 12),
                      )),
                      DataCell(Text(
                        user.lastLogin != null
                            ? DateFormat('MMM dd, HH:mm').format(user.lastLogin!)
                            : 'Never',
                        style: GoogleFonts.poppins(fontSize: 12),
                      )),
                      DataCell(_buildStatusBadge(user.isActive)),
                      DataCell(Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _showEditUserDialog(user),
                            tooltip: 'Edit User',
                          ),
                          IconButton(
                            icon: const Icon(Icons.lock_reset, size: 20),
                            onPressed: () => _showChangePasswordDialog(user),
                            tooltip: 'Change Password',
                          ),
                          if (user.id != widget.currentUser.id)
                            IconButton(
                              icon: Icon(
                                user.isActive ? Icons.block : Icons.check_circle,
                                size: 20,
                                color: user.isActive ? Colors.red : Colors.green,
                              ),
                              onPressed: () => _toggleUserStatus(user),
                              tooltip: user.isActive ? 'Deactivate' : 'Activate',
                            ),
                          if (user.id != widget.currentUser.id)
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                              onPressed: () => _deleteUser(user),
                              tooltip: 'Delete User',
                            ),
                        ],
                      )),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final colors = {
      UserRole.superAdmin: Colors.purple,
      UserRole.admin: Colors.blue,
      UserRole.viewer: Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: colors[role]!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors[role]!),
      ),
      child: Text(
        role.name,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: colors[role],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? Colors.green : Colors.red),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.viewer;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add New User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.name, style: GoogleFonts.poppins()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('All fields are required', style: GoogleFonts.poppins())),
                  );
                  return;
                }

                final newUser = AdminUser(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  username: usernameController.text,
                  email: emailController.text,
                  passwordHash: _authService.hashPassword(passwordController.text),
                  role: selectedRole,
                  createdAt: DateTime.now(),
                );

                final success = await _authService.createUser(newUser);
                if (success) {
                  Navigator.pop(context);
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User created successfully', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Username or email already exists', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: Text('Create', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditUserDialog(AdminUser user) {
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email);
    UserRole selectedRole = user.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role.name, style: GoogleFonts.poppins()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedRole = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedUser = user.copyWith(
                  username: usernameController.text,
                  email: emailController.text,
                  role: selectedRole,
                );

                await _authService.updateUser(updatedUser);
                Navigator.pop(context);
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User updated successfully', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: Text('Update', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(AdminUser user) {
    final passwordController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Change password for: ${user.username}',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text != confirmController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Passwords do not match', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Password must be at least 6 characters', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await _authService.changePassword(user.id, passwordController.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Password changed successfully', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            child: Text('Change', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(AdminUser user) async {
    final updatedUser = user.copyWith(isActive: !user.isActive);
    await _authService.updateUser(updatedUser);
    _loadUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'User ${updatedUser.isActive ? "activated" : "deactivated"}',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _deleteUser(AdminUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete ${user.username}? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.deleteUser(user.id);
      _loadUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deleted successfully', style: GoogleFonts.poppins()),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
