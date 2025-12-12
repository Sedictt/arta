import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/survey_service.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import '../models/survey_response.dart';
import '../models/admin_user.dart';
import '../models/export_config.dart';
import '../main.dart';
import '../utils/test_data_generator.dart';
import 'admin/user_management_tab.dart';
import 'admin/survey_editor_tab.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';

class AdminDashboard extends StatefulWidget {
  final AdminUser currentUser;

  const AdminDashboard({super.key, required this.currentUser});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SurveyService _surveyService = SurveyService();
  final AuthService _authService = AuthService();
  final ExportService _exportService = ExportService();

  List<SurveyResponse> _allResponses = [];
  bool _isLoading = true;

  // Filters
  String? _selectedRegion;
  String? _selectedService;
  DateTimeRange? _selectedDateRange;

  // Filters for Recent Responses section
  String? _recentRegionFilter;
  String? _recentServiceFilter;

  @override
  void initState() {
    super.initState();
    // Calculate number of tabs based on permissions
    int tabCount = 2; // Analytics, Export
    if (widget.currentUser.hasPermission('edit_survey')) tabCount++;
    if (widget.currentUser.hasPermission('manage_users')) tabCount++;

    _tabController = TabController(length: tabCount, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<SurveyResponse> get _filteredResponses {
    return _allResponses.where((response) {
      if (_selectedRegion != null && response.region != _selectedRegion) {
        return false;
      }
      if (_selectedService != null &&
          response.serviceAvailed != _selectedService) {
        return false;
      }
      if (_selectedDateRange != null) {
        if (response.submittedAt.isBefore(_selectedDateRange!.start) ||
            response.submittedAt.isAfter(_selectedDateRange!.end)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // Trend chart of responses over time (based on filtered set)
  Widget _buildTrendChart() {
    final Map<DateTime, int> daily = {};
    for (final r in _filteredResponses) {
      final d = DateTime(
        r.submittedAt.year,
        r.submittedAt.month,
        r.submittedAt.day,
      );
      daily[d] = (daily[d] ?? 0) + 1;
    }
    final dates = daily.keys.toList()..sort();
    if (dates.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), (daily[dates[i]] ?? 0).toDouble()));
    }

    final maxY = spots.isEmpty
        ? 10.0
        : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 360 ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.show_chart,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Response Trends',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${dates.length} days',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 280,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.4,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.surface,
                            strokeWidth: 2,
                            strokeColor: AppColors.primary,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.2),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: maxY,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.border,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: dates.length > 10
                            ? (dates.length / 7).ceilToDouble()
                            : 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= dates.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('MMM dd').format(dates[idx]),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: maxY / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.textSecondary),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final date = dates[spot.x.toInt()];
                          return LineTooltipItem(
                            '${DateFormat('MMM dd, yyyy').format(date)}\n${spot.y.toInt()} responses',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top services and regions breakdown
  Widget _buildTopBreakdowns() {
    final serviceCount = <String, int>{};
    final regionCount = <String, int>{};
    for (final r in _filteredResponses) {
      serviceCount[r.serviceAvailed ?? 'Unknown'] =
          (serviceCount[r.serviceAvailed ?? 'Unknown'] ?? 0) + 1;
      regionCount[r.region] = (regionCount[r.region] ?? 0) + 1;
    }

    final topServices = serviceCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topRegions = regionCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildBreakdownCard(
                  'Top Services',
                  topServices,
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBreakdownCard(
                  'Top Regions',
                  topRegions,
                  AppColors.secondary,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildBreakdownCard(
                'Top Services',
                topServices,
                AppColors.secondary,
              ),
              const SizedBox(height: 16),
              _buildBreakdownCard(
                'Top Regions',
                topRegions,
                AppColors.secondary,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildBreakdownCard(
    String title,
    List<MapEntry<String, int>> data,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 360 ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            if (data.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No data available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              ...data
                  .take(5)
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textPrimary),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              e.value.toString(),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: color,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Analytics helpers
  Map<String, int> _computeSatisfactionDistribution(List<SurveyResponse> list) {
    final dist = <String, int>{
      'Very Satisfied': 0,
      'Satisfied': 0,
      'Neutral': 0,
      'Dissatisfied': 0,
      'Very Dissatisfied': 0,
    };
    for (final r in list) {
      dist[r.satisfactionLevel] = (dist[r.satisfactionLevel] ?? 0) + 1;
    }
    return dist;
  }

  Map<String, double> _computeSQDAverages(List<SurveyResponse> list) {
    final agg = <String, List<int>>{};
    for (final r in list) {
      r.sqdAnswers.forEach((k, v) {
        agg.putIfAbsent(k, () => []).add(v);
      });
    }
    final result = <String, double>{};
    agg.forEach((k, values) {
      if (values.isNotEmpty) {
        result[k] = values.reduce((a, b) => a + b) / values.length;
      }
    });
    return result;
  }

  double _computeSatisfactionRate(List<SurveyResponse> list) {
    if (list.isEmpty) return 0.0;
    final satisfied = list
        .where(
          (r) =>
              r.satisfactionLevel == 'Very Satisfied' ||
              r.satisfactionLevel == 'Satisfied',
        )
        .length;
    return satisfied / list.length * 100;
  }

  double _computeAwarenessRate(List<SurveyResponse> list) {
    if (list.isEmpty) return 0.0;
    final aware = list
        .where(
          (r) =>
              r.cc1Answer != null && r.cc1Answer!.contains('know what a CC is'),
        )
        .length;
    return aware / list.length * 100;
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    _allResponses = await _surveyService.getAllSurveyResponses();
    // Sort by latest first
    _allResponses.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

    setState(() => _isLoading = false);
  }

  Future<void> _generateTestData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Generate Test Data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will generate 50 random survey responses for testing. Continue?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
            child: Text(
              'Generate',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      await TestDataGenerator.generateBalancedTestData(totalResponses: 50);
      await _loadDashboardData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '50 test responses generated!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear All Data',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will permanently delete all survey responses. This action cannot be undone!',
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
              'Delete All',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);

      await TestDataGenerator.clearAllData();
      await _loadDashboardData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All data cleared!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // Removed old _exportToCSV in favor of Save As implementations

  Widget _buildUserMenu() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) async {
        if (value == 'logout') {
          await _authService.logout();
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/');
          }
        } else if (value == 'generate_test') {
          await _generateTestData();
        } else if (value == 'clear_data') {
          await _clearAllData();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.currentUser.username,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                widget.currentUser.role
                    .toString()
                    .split('.')
                    .last
                    .toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'generate_test',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.add_chart,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Generate Test Data',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'clear_data',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.delete_sweep,
                  size: 16,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Text('Clear All Data', style: GoogleFonts.poppins(fontSize: 13)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  size: 16,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Text(
                widget.currentUser.username[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            if (MediaQuery.of(context).size.width >= 400) ...[
              const SizedBox(width: 10),
              Text(
                widget.currentUser.username,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build tabs list based on permissions
    final tabs = <Widget>[
      const Tab(icon: Icon(Icons.dashboard, size: 20), text: 'Analytics'),
      const Tab(icon: Icon(Icons.download, size: 20), text: 'Export'),
    ];

    if (widget.currentUser.hasPermission('edit_survey')) {
      tabs.add(
        const Tab(icon: Icon(Icons.edit, size: 20), text: 'Survey Editor'),
      );
    }

    if (widget.currentUser.hasPermission('manage_users')) {
      tabs.add(const Tab(icon: Icon(Icons.people, size: 20), text: 'Users'));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isSmallScreen
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: AppColors.primary),
                    accountName: Text(
                      widget.currentUser.username,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: Text(
                      widget.currentUser.email,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.currentUser.username[0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: Text('Analytics', style: GoogleFonts.poppins()),
                    selected: _tabController.index == 0,
                    selectedColor: AppColors.primary,
                    onTap: () {
                      _tabController.animateTo(0);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: Text('Export', style: GoogleFonts.poppins()),
                    selected: _tabController.index == 1,
                    selectedColor: AppColors.primary,
                    onTap: () {
                      _tabController.animateTo(1);
                      Navigator.pop(context);
                    },
                  ),
                  if (widget.currentUser.hasPermission('edit_survey'))
                    ListTile(
                      leading: const Icon(Icons.edit),
                      title: Text(
                        'Survey Editor',
                        style: GoogleFonts.poppins(),
                      ),
                      selected: _tabController.index == 2,
                      selectedColor: AppColors.primary,
                      onTap: () {
                        _tabController.animateTo(2);
                        Navigator.pop(context);
                      },
                    ),
                  if (widget.currentUser.hasPermission('manage_users'))
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: Text('Users', style: GoogleFonts.poppins()),
                      selected: _tabController.index == (tabs.length - 1),
                      selectedColor: AppColors.primary,
                      onTap: () {
                        _tabController.animateTo(tabs.length - 1);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        titleSpacing: 0,
        leading: isSmallScreen
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: AppColors.textPrimary),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 8, 8),
                child: Image.asset('Valenzuela_Seal.svg.png'),
              ),
        title: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin Portal',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),
              if (!isSmallScreen)
                Text(
                  'City Government of Valenzuela',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 12.0),
            child: _buildUserMenu(),
          ),
        ],
        bottom: isSmallScreen
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Tabs on the left
                      Expanded(
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.textSecondary,
                          indicatorColor: AppColors.primary,
                          indicatorWeight: 3,
                          labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: tabs,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Analytics Tab
                SingleChildScrollView(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.width < 360 ? 16 : 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Banner
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width < 360 ? 16 : 24,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${widget.currentUser.username}!',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Here\'s what\'s happening with your survey data today.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Filters (Moved to Top)
                      _buildFilterControls(),
                      const SizedBox(height: 24),

                      // Key Metrics
                      _buildStatsCards(),
                      const SizedBox(height: 24),

                      // Primary Trend Chart (Full Width)
                      _buildTrendChart(),
                      const SizedBox(height: 24),

                      // Secondary Charts (Side by Side)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 900) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildSatisfactionChart()),
                                const SizedBox(width: 24),
                                Expanded(child: _buildAverageScoresChart()),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _buildSatisfactionChart(),
                                const SizedBox(height: 24),
                                _buildAverageScoresChart(),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Breakdowns
                      _buildTopBreakdowns(),

                      const SizedBox(height: 24),
                      _buildRecentResponses(),
                    ],
                  ),
                ),
                // Export Tab
                _buildExportTab(),
                // Survey Editor Tab (if permission)
                if (widget.currentUser.hasPermission('edit_survey'))
                  const SurveyEditorTab(),
                // User Management Tab (if permission)
                if (widget.currentUser.hasPermission('manage_users'))
                  UserManagementTab(currentUser: widget.currentUser),
              ],
            ),
    );
  }

  // Integrated filter controls with improved UI
  Widget _buildFilterControls() {
    final regions = _allResponses.map((r) => r.region).toSet().toList()..sort();
    final services =
        _allResponses
            .map((r) => r.serviceAvailed)
            .where((s) => s != null)
            .cast<String>()
            .toSet()
            .toList()
          ..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Filter Data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_filteredResponses.length} results',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final regionDropdown = DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedRegion,
                  decoration: const InputDecoration(
                    labelText: 'Region',
                    prefixIcon: Icon(Icons.location_on, size: 18),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Regions'),
                    ),
                    ...regions.map(
                      (r) => DropdownMenuItem(value: r, child: Text(r)),
                    ),
                  ],
                  onChanged: (value) => setState(() => _selectedRegion = value),
                );

                final serviceDropdown = DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedService,
                  decoration: const InputDecoration(
                    labelText: 'Service',
                    prefixIcon: Icon(Icons.business_center, size: 18),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Services'),
                    ),
                    ...services.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s)),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _selectedService = value),
                );

                Widget buildDatePicker({
                  required String label,
                  required DateTime? value,
                  required DateTime firstDate,
                  required DateTime lastDate,
                  required Function(DateTime) onChanged,
                }) {
                  return InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: value ?? DateTime.now(),
                        firstDate: firstDate,
                        lastDate: lastDate,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.primary,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: AppColors.textPrimary,
                              ),
                              dialogTheme: DialogThemeData(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) onChanged(picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: label,
                        prefixIcon: const Icon(Icons.calendar_today, size: 18),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                      ),
                      child: Text(
                        value != null
                            ? DateFormat('MMM dd, yyyy').format(value)
                            : 'Select Date',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: value != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                }

                final startDateControl = buildDatePicker(
                  label: 'Start Date',
                  value: _selectedDateRange?.start,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  onChanged: (date) {
                    final currentEnd =
                        _selectedDateRange?.end ?? DateTime.now();
                    final end = date.isAfter(currentEnd) ? date : currentEnd;
                    setState(
                      () => _selectedDateRange = DateTimeRange(
                        start: date,
                        end: end,
                      ),
                    );
                  },
                );

                final endDateControl = buildDatePicker(
                  label: 'End Date',
                  value: _selectedDateRange?.end,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  onChanged: (date) {
                    final currentStart =
                        _selectedDateRange?.start ?? DateTime(2000);
                    final start = date.isBefore(currentStart)
                        ? date
                        : currentStart;
                    setState(
                      () => _selectedDateRange = DateTimeRange(
                        start: start,
                        end: date,
                      ),
                    );
                  },
                );

                final clearButton =
                    (_selectedRegion != null ||
                        _selectedService != null ||
                        _selectedDateRange != null)
                    ? OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedRegion = null;
                            _selectedService = null;
                            _selectedDateRange = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.clear, size: 18),
                        label: const Text('Clear'),
                      )
                    : null;

                if (constraints.maxWidth > 900) {
                  return Row(
                    children: [
                      Expanded(flex: 2, child: regionDropdown),
                      const SizedBox(width: 12),
                      Expanded(flex: 3, child: serviceDropdown),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: startDateControl),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: endDateControl),
                      if (clearButton != null) ...[
                        const SizedBox(width: 12),
                        clearButton,
                      ],
                    ],
                  );
                } else if (constraints.maxWidth < 600) {
                  // Mobile
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      regionDropdown,
                      const SizedBox(height: 12),
                      serviceDropdown,
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: startDateControl),
                          const SizedBox(width: 12),
                          Expanded(child: endDateControl),
                        ],
                      ),
                      if (clearButton != null) ...[
                        const SizedBox(height: 12),
                        clearButton,
                      ],
                    ],
                  );
                } else {
                  // Tablet
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: regionDropdown),
                          const SizedBox(width: 12),
                          Expanded(child: serviceDropdown),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: startDateControl),
                          const SizedBox(width: 12),
                          Expanded(child: endDateControl),
                          if (clearButton != null) ...[
                            const SizedBox(width: 12),
                            clearButton,
                          ],
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Reports',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Export survey data in various formats for reporting and analysis',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          _buildExportCard(
            'PDF Report',
            'Generate a comprehensive PDF report with executive summary, charts analysis, and recommendations',
            Icons.picture_as_pdf,
            Colors.red,
            _exportPDFSaveAs,
          ),
          const SizedBox(height: 16),
          _buildExportCard(
            'Excel Report',
            'Export detailed CSV with summary statistics, SQD breakdown, and all raw data (Excel compatible)',
            Icons.table_chart,
            Colors.green,
            _exportExcelSaveAs,
          ),
          const SizedBox(height: 16),
          _buildExportCard(
            'ARTA Compliance Report',
            'Generate ARTA-compliant JSON report for government compliance reporting',
            Icons.verified,
            Colors.blue,
            _exportARTAJSONSaveAs,
          ),
          const SizedBox(height: 16),
          _buildExportCard(
            'Raw CSV Data',
            'Export raw survey response data in CSV format for custom analysis',
            Icons.description,
            Colors.orange,
            _exportCSVSaveAs,
          ),
        ],
      ),
    );
  }

  Widget _buildExportCard(
    String title,
    String desc,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      desc,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportCSVSaveAs() async {
    final config = ExportConfig(
      format: ExportFormat.csv,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      region: _selectedRegion,
      serviceType: _selectedService,
    );
    final csv = await _exportService.exportToCSV(_allResponses, config);

    final suggestedName =
        'survey_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final saveLocation = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [
        XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );
    if (saveLocation == null) return;

    final data = Uint8List.fromList(utf8.encode(csv));
    final xfile = XFile.fromData(
      data,
      mimeType: 'text/csv',
      name: suggestedName,
    );
    await xfile.saveTo(saveLocation.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'CSV data exported successfully!',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _exportExcelSaveAs() async {
    final config = ExportConfig(
      format: ExportFormat.excel,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      region: _selectedRegion,
      serviceType: _selectedService,
      includeCharts: true,
    );

    final excelCsv = await _exportService.exportToExcel(_allResponses, config);
    final suggestedName =
        'survey_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';

    final saveLocation = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [
        XTypeGroup(label: 'CSV (Excel)', extensions: ['csv']),
      ],
    );
    if (saveLocation == null) return;

    final data = Uint8List.fromList(utf8.encode(excelCsv));
    final xfile = XFile.fromData(
      data,
      mimeType: 'text/csv',
      name: suggestedName,
    );
    await xfile.saveTo(saveLocation.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Excel report saved successfully!',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _exportPDFSaveAs() async {
    final config = ExportConfig(
      format: ExportFormat.pdf,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      region: _selectedRegion,
      serviceType: _selectedService,
      includeCharts: true,
    );

    final pdfBytes = await _exportService.exportToPDF(_allResponses, config);
    final suggestedName =
        'survey_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';

    final saveLocation = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [
        XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
    );
    if (saveLocation == null) return;

    final xfile = XFile.fromData(
      pdfBytes,
      mimeType: 'application/pdf',
      name: suggestedName,
    );
    await xfile.saveTo(saveLocation.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'PDF report saved successfully!',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _exportARTAJSONSaveAs() async {
    final config = ExportConfig(
      format: ExportFormat.arta,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      region: _selectedRegion,
      serviceType: _selectedService,
    );
    final data = await _exportService.exportToARTA(_allResponses, config);
    await _saveJsonData(
      data,
      suggestedName:
          'arta_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json',
    );
  }

  Future<void> _saveJsonData(
    Map<String, dynamic> data, {
    required String suggestedName,
  }) async {
    final saveLocation = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [
        XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (saveLocation == null) return;

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));
    final xfile = XFile.fromData(
      bytes,
      mimeType: 'application/json',
      name: suggestedName,
    );
    await xfile.saveTo(saveLocation.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text('ARTA compliance report saved!', style: GoogleFonts.poppins()),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildStatsCards() {
    final total = _filteredResponses.length;
    final avgScore = _filteredResponses.isEmpty
        ? 0.0
        : _filteredResponses
                  .map((r) => r.averageSQDScore)
                  .reduce((a, b) => a + b) /
              _filteredResponses.length;
    final satisfactionRate = _computeSatisfactionRate(_filteredResponses);
    final awarenessRate = _computeAwarenessRate(_filteredResponses);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;

        final cards = [
          _buildStatCard(
            'Total Responses',
            total.toString(),
            Icons.people_outline,
            Colors.blue,
            Colors.blue.shade50,
          ),
          _buildStatCard(
            'Average Score',
            avgScore.toStringAsFixed(2),
            Icons.star_outline,
            Colors.amber.shade700,
            Colors.amber.shade50,
          ),
          _buildStatCard(
            'Satisfaction Rate',
            '${satisfactionRate.toStringAsFixed(1)}%',
            Icons.sentiment_satisfied_alt,
            Colors.green,
            Colors.green.shade50,
          ),
          _buildStatCard(
            "CC Awareness",
            '${awarenessRate.toStringAsFixed(1)}%',
            Icons.info_outline,
            Colors.indigo,
            Colors.indigo.shade50,
          ),
        ];

        if (isWide) {
          return Row(
            children: cards
                .map(
                  (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: c,
                    ),
                  ),
                )
                .toList(),
          );
        } else {
          // Check if we need to stack vertically for very small screens
          if (constraints.maxWidth < 500) {
            return Column(
              children: cards
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: c,
                    ),
                  )
                  .toList(),
            );
          }
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cards[0]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[1]),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: cards[2]),
                  const SizedBox(width: 16),
                  Expanded(child: cards[3]),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSatisfactionChart() {
    final dist = _computeSatisfactionDistribution(_filteredResponses);
    if (dist.values.every((v) => v == 0)) {
      return const SizedBox.shrink();
    }

    final total = dist.values.reduce((a, b) => a + b);
    final colors = {
      'Very Satisfied': const Color(0xFF10B981),
      'Satisfied': const Color(0xFF34D399),
      'Neutral': const Color(0xFFFBBF24),
      'Dissatisfied': const Color(0xFFF97316),
      'Very Dissatisfied': const Color(0xFFEF4444),
    };

    final icons = {
      'Very Satisfied': Icons.sentiment_very_satisfied,
      'Satisfied': Icons.sentiment_satisfied,
      'Neutral': Icons.sentiment_neutral,
      'Dissatisfied': Icons.sentiment_dissatisfied,
      'Very Dissatisfied': Icons.sentiment_very_dissatisfied,
    };

    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 360 ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.pie_chart,
                    color: Colors.green[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Satisfaction Distribution',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$total responses',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide =
                    constraints.maxWidth >
                    400; // Breakpoint for chart vs legend

                final isSmall = constraints.maxWidth < 320;
                final radius = isSmall ? 50.0 : 80.0;
                final centerRadius = isSmall ? 30.0 : 40.0;

                final pieChart = SizedBox(
                  height: 300,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: centerRadius,
                      sections: dist.entries.map((entry) {
                        final percentage = (entry.value / total * 100);

                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '${percentage.toStringAsFixed(1)}%',
                          color: colors[entry.key],
                          radius: radius,
                          titleStyle: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                          badgeWidget: entry.value > 0
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    icons[entry.key],
                                    color: colors[entry.key],
                                    size: isSmall ? 12 : 16,
                                  ),
                                )
                              : null,
                          badgePositionPercentageOffset: isSmall ? 1.5 : 1.3,
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(
                        touchCallback:
                            (FlTouchEvent event, pieTouchResponse) {},
                      ),
                    ),
                  ),
                );

                final legend = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dist.entries.map((entry) {
                    final percentage = (entry.value / total * 100);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors[entry.key]?.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icons[entry.key],
                              color: colors[entry.key],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: colors[entry.key]?.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: percentage / 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: colors[entry.key],
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${entry.value}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors[entry.key],
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(flex: 2, child: pieChart),
                      const SizedBox(width: 24),
                      Expanded(child: legend),
                    ],
                  );
                } else {
                  return Column(
                    children: [pieChart, const SizedBox(height: 24), legend],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageScoresChart() {
    final avgScores = _computeSQDAverages(_filteredResponses);
    if (avgScores.isEmpty) return const SizedBox.shrink();

    final sqdLabels = [
      'Overall',
      'Time',
      'Requirements',
      'Steps',
      'Info Access',
      'Fees',
      'Fairness',
      'Courtesy',
      'Delivery',
    ];

    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 360 ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.bar_chart,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Service Quality Dimensions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.amber[700], size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Out of 5.0',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 400;
                final barWidth = isSmall ? 16.0 : 28.0;

                return SizedBox(
                  height: 350,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 5,
                      minY: 0,
                      barGroups: avgScores.entries.map((entry) {
                        final index = int.parse(
                          entry.key.replaceAll('SQD', ''),
                        );
                        final score = entry.value;
                        Color barColor;
                        if (score >= 4.5) {
                          barColor = Colors.green;
                        } else if (score >= 4.0) {
                          barColor = Colors.lightGreen;
                        } else if (score >= 3.5) {
                          barColor = Colors.amber;
                        } else if (score >= 3.0) {
                          barColor = Colors.orange;
                        } else {
                          barColor = Colors.red;
                        }

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value,
                              gradient: LinearGradient(
                                colors: [
                                  barColor,
                                  barColor.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              width: barWidth,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 5,
                                color: AppColors.secondary.withValues(
                                  alpha: 0.05,
                                ),
                              ),
                            ),
                          ],
                          showingTooltipIndicators: [],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: isSmall ? 30 : 60,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= sqdLabels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isSmall ? 'D$idx' : 'SQD$idx',
                                      style: GoogleFonts.poppins(
                                        fontSize: isSmall ? 9 : 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondary,
                                      ),
                                    ),
                                    if (!isSmall)
                                      Text(
                                        sqdLabels[idx],
                                        style: GoogleFonts.poppins(
                                          fontSize: 8,
                                          color: AppColors.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.border,
                            strokeWidth: 1,
                            dashArray: [5, 5],
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blueGrey.shade800,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final label = sqdLabels[group.x.toInt()];
                            return BarTooltipItem(
                              '$label\n',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              children: [
                                TextSpan(
                                  text: '${rod.toY.toStringAsFixed(2)} / 5.0',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentResponses() {
    // Get unique regions and services for filters
    final regions = _allResponses.map((r) => r.region).toSet().toList()..sort();
    final services =
        _allResponses
            .map((r) => r.serviceAvailed)
            .where((s) => s != null)
            .cast<String>()
            .toSet()
            .toList()
          ..sort();

    // Apply local filters
    final recentList = _allResponses
        .where((r) {
          if (_recentRegionFilter != null && r.region != _recentRegionFilter) {
            return false;
          }
          if (_recentServiceFilter != null &&
              r.serviceAvailed != _recentServiceFilter) {
            return false;
          }
          return true;
        })
        .take(10)
        .toList();

    return Card(
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.of(context).size.width < 360 ? 16 : 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Filters
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Responses',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (_recentRegionFilter != null ||
                        _recentServiceFilter != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _recentRegionFilter = null;
                            _recentServiceFilter = null;
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: Text(
                          'Clear Filters',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Filter Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;

                    Widget buildFilterDropdown({
                      required String? value,
                      required String label,
                      required IconData icon,
                      required List<String> items,
                      required Function(String?) onChanged,
                    }) {
                      return DropdownButtonFormField<String>(
                        value: value,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: label,
                          prefixIcon: Icon(
                            icon,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.grey,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text(
                              'All ${label.replaceAll("Filter by ", "")}s',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          ...items.map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(
                                item,
                                style: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: onChanged,
                      );
                    }

                    return Flex(
                      direction: isWide ? Axis.horizontal : Axis.vertical,
                      children: [
                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: buildFilterDropdown(
                            value: _recentRegionFilter,
                            label: 'Region',
                            icon: Icons.location_on_outlined,
                            items: regions,
                            onChanged: (value) =>
                                setState(() => _recentRegionFilter = value),
                          ),
                        ),
                        SizedBox(
                          width: isWide ? 16 : 0,
                          height: isWide ? 0 : 12,
                        ),
                        Expanded(
                          flex: isWide ? 1 : 0,
                          child: buildFilterDropdown(
                            value: _recentServiceFilter,
                            label: 'Service',
                            icon: Icons.business_center_outlined,
                            items: services,
                            onChanged: (value) =>
                                setState(() => _recentServiceFilter = value),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (recentList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'No responses found matching filters',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentList.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final response = recentList[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondary.withValues(
                        alpha: 0.2,
                      ),
                      child: Text(
                        response.sex[0],
                        style: GoogleFonts.poppins(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      '${response.clientType} - ${response.region}',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      DateFormat(
                        'MMM dd, yyyy hh:mm a',
                      ).format(response.submittedAt.toLocal()),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        response.averageSQDScore.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
