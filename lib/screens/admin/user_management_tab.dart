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
  List<AdminUser> _filteredUsers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    _users = await _authService.getAllUsers();
    _filterUsers();
    setState(() => _isLoading = false);
  }

  void _filterUsers() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredUsers = List.from(_users);
      } else {
        _filteredUsers = _users
            .where(
              (u) =>
                  u.username.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  u.email.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final totalUsers = _users.length;
    final activeUsers = _users.where((u) => u.isActive).length;
    final adminUsers = _users
        .where((u) => u.role == UserRole.admin || u.role == UserRole.superAdmin)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep the mobile view for really small screens, but give desktop view more room to breathe
        final isSmall = constraints.maxWidth < 900;
        final horizontalPadding = isSmall ? 16.0 : 32.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(isSmall),
              const SizedBox(height: 32),

              // Stats Row
              _buildStatsRow(totalUsers, activeUsers, adminUsers, isSmall),
              const SizedBox(height: 32),

              // Main Content Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Toolbar
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search users...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (value) {
                                _searchQuery = value;
                                _filterUsers();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: _loadUsers,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh',
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Content
                    if (_filteredUsers.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(48),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_off_outlined,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (isSmall)
                      _buildMobileUserList()
                    else
                      Column(
                        children: [
                          _buildTableHeader(),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredUsers.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) =>
                                _buildDesktopUserRow(_filteredUsers[index]),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildHeaderCell('USER DETAILS')),
          Expanded(flex: 1, child: _buildHeaderCell('ROLE')),
          Expanded(flex: 1, child: _buildHeaderCell('STATUS')),
          Expanded(flex: 2, child: _buildHeaderCell('LAST LOGIN')),
          Expanded(
            flex: 1,
            child: _buildHeaderCell('ACTIONS', align: TextAlign.end),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {TextAlign align = TextAlign.start}) {
    return Text(
      text,
      textAlign: align,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        fontSize: 13,
      ),
    );
  }

  Widget _buildDesktopUserRow(AdminUser user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // User Details
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    user.username[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        user.email,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Role
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildRoleBadge(user.role),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(user.isActive),
            ),
          ),
          // Last Login
          Expanded(
            flex: 2,
            child: Text(
              user.lastLogin != null
                  ? DateFormat('MMM dd, HH:mm').format(user.lastLogin!)
                  : 'Never',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildActions(user),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isSmall) {
    if (isSmall) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Management',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage system access and roles',
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: _buildAddButton()),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Management',
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage system access and roles',
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildAddButton() {
    return ElevatedButton.icon(
      onPressed: () => _showAddUserDialog(),
      icon: const Icon(Icons.add, size: 20),
      label: Text(
        'Add Member',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 4,
        shadowColor: AppColors.primary.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildStatsRow(int total, int active, int admins, bool isSmall) {
    if (isSmall) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            _buildStatItem('Total Users', total.toString(), Colors.blue),
            const Divider(height: 24),
            _buildStatItem('Active Users', active.toString(), Colors.green),
            const Divider(height: 24),
            _buildStatItem('Administrators', admins.toString(), Colors.purple),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total Users',
                total.toString(),
                Colors.blue,
                centered: true,
              ),
            ),
            const VerticalDivider(width: 32, thickness: 1),
            Expanded(
              child: _buildStatItem(
                'Active Users',
                active.toString(),
                Colors.green,
                centered: true,
              ),
            ),
            const VerticalDivider(width: 32, thickness: 1),
            Expanded(
              child: _buildStatItem(
                'Administrators',
                admins.toString(),
                Colors.purple,
                centered: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color, {
    bool centered = false,
  }) {
    return Row(
      mainAxisAlignment: centered
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    final styles = {
      UserRole.superAdmin: (Colors.purple, 'Super Admin'),
      UserRole.admin: (Colors.blue, 'Admin'),
      UserRole.viewer: (Colors.grey, 'Viewer'),
    };

    final style = styles[role]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: style.$1.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.$1.withValues(alpha: 0.2)),
      ),
      child: Text(
        style.$2,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: style.$1,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.red.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? 'Active' : 'Inactive',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AdminUser user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          onPressed: () => _showEditUserDialog(user),
          tooltip: 'Edit',
          style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary),
        ),
        if (user.id != widget.currentUser.id) ...[
          IconButton(
            icon: user.isActive
                ? const Icon(Icons.block_outlined, size: 20)
                : const Icon(Icons.check_circle_outline, size: 20),
            onPressed: () => _toggleUserStatus(user),
            tooltip: user.isActive ? 'Deactivate' : 'Activate',
            color: user.isActive ? Colors.orange : Colors.green,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _deleteUser(user),
            tooltip: 'Delete',
            color: Colors.red,
          ),
        ],
        IconButton(
          icon: const Icon(Icons.key_outlined, size: 20),
          onPressed: () => _showChangePasswordDialog(user),
          tooltip: 'Change Password',
          style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildMobileUserList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUsers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _buildUserListCard(_filteredUsers[index]),
    );
  }

  Widget _buildUserListCard(AdminUser user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  user.username[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      user.email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(user.isActive),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildRoleBadge(user.role),
              const Spacer(),
              Text(
                user.lastLogin != null
                    ? DateFormat('MMM dd, HH:mm').format(user.lastLogin!)
                    : 'Never',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildActions(user)],
          ),
        ],
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
          title: Text(
            'Add New User',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  initialValue: selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                    SnackBar(
                      content: Text(
                        'All fields are required',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  );
                  return;
                }

                final newUser = AdminUser(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  username: usernameController.text,
                  email: emailController.text,
                  passwordHash: _authService.hashPassword(
                    passwordController.text,
                  ),
                  role: selectedRole,
                  createdAt: DateTime.now(),
                );

                final success = await _authService.createUser(newUser);
                if (success) {
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'User created successfully',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Username or email already exists',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: Text(
                'Create',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
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
          title: Text(
            'Edit User',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                initialValue: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                if (!context.mounted) return;
                Navigator.pop(context);
                _loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'User updated successfully',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: Text(
                'Update',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
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
        title: Text(
          'Change Password',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                    content: Text(
                      'Passwords do not match',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Password must be at least 6 characters',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await _authService.changePassword(
                user.id,
                passwordController.text,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Password changed successfully',
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: Text(
              'Change',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleUserStatus(AdminUser user) async {
    final updatedUser = user.copyWith(isActive: !user.isActive);
    await _authService.updateUser(updatedUser);
    _loadUsers();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'User ${updatedUser.isActive ? "activated" : "deactivated"}',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteUser(AdminUser user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete User',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
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
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.deleteUser(user.id);
      _loadUsers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'User deleted successfully',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
