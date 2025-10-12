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

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SurveyService _surveyService = SurveyService();
  final AuthService _authService = AuthService();
  final ExportService _exportService = ExportService();
  
  List<SurveyResponse> _recentResponses = [];
  List<SurveyResponse> _allResponses = [];
  bool _isLoading = true;
  
  // Filters
  String? _selectedRegion;
  String? _selectedService;
  DateTimeRange? _selectedDateRange;
  
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
      if (_selectedService != null && response.serviceAvailed != _selectedService) {
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
      final d = DateTime(r.submittedAt.year, r.submittedAt.month, r.submittedAt.day);
      daily[d] = (daily[d] ?? 0) + 1;
    }
    final dates = daily.keys.toList()..sort();
    if (dates.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (int i = 0; i < dates.length; i++) {
      spots.add(FlSpot(i.toDouble(), (daily[dates[i]] ?? 0).toDouble()));
    }

    final maxY = spots.isEmpty ? 10.0 : spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.05), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(24),
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
                child: Icon(Icons.show_chart, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Responses Over Time',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${dates.length} days',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
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
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: AppColors.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.05),
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
                      color: AppColors.primary.withValues(alpha: 0.1),
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
                      interval: dates.length > 10 ? (dates.length / 7).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= dates.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM dd').format(dates[idx]),
                            style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
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
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                    left: BorderSide(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = dates[spot.x.toInt()];
                        return LineTooltipItem(
                          '${DateFormat('MMM dd, yyyy').format(date)}\n${spot.y.toInt()} responses',
                          GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
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
    );
  }

  // Top services and regions breakdown
  Widget _buildTopBreakdowns() {
    final serviceCount = <String, int>{};
    final regionCount = <String, int>{};
    for (final r in _filteredResponses) {
      serviceCount[r.serviceAvailed ?? 'Unknown'] = (serviceCount[r.serviceAvailed ?? 'Unknown'] ?? 0) + 1;
      regionCount[r.region] = (regionCount[r.region] ?? 0) + 1;
    }

    final topServices = serviceCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topRegions = regionCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top Services', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...topServices.take(5).map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(e.key, style: GoogleFonts.poppins(fontSize: 13))),
                            Chip(label: Text(e.value.toString())),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Top Regions', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...topRegions.take(5).map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(e.key, style: GoogleFonts.poppins(fontSize: 13))),
                            Chip(label: Text(e.value.toString())),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
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
    final satisfied = list.where((r) => r.satisfactionLevel == 'Very Satisfied' || r.satisfactionLevel == 'Satisfied').length;
    return satisfied / list.length * 100;
  }

  double _computeAwarenessRate(List<SurveyResponse> list) {
    if (list.isEmpty) return 0.0;
    final aware = list.where((r) => r.cc1Answer != null && r.cc1Answer!.contains('know what a CC is')).length;
    return aware / list.length * 100;
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    _allResponses = await _surveyService.getAllSurveyResponses();
    _recentResponses = _allResponses.reversed.take(10).toList();
    
    setState(() => _isLoading = false);
  }
  
  Future<void> _generateTestData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Test Data', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            child: Text('Generate', style: GoogleFonts.poppins(color: Colors.white)),
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
            content: Text('50 test responses generated!', style: GoogleFonts.poppins()),
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
        title: Text('Clear All Data', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
            child: Text('Delete All', style: GoogleFonts.poppins(color: Colors.white)),
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

  @override
  Widget build(BuildContext context) {
    // Build tabs list based on permissions
    final tabs = <Widget>[
      const Tab(icon: Icon(Icons.dashboard, size: 20), text: 'Analytics'),
      const Tab(icon: Icon(Icons.download, size: 20), text: 'Export'),
    ];
    
    if (widget.currentUser.hasPermission('edit_survey')) {
      tabs.add(const Tab(icon: Icon(Icons.edit, size: 20), text: 'Survey Editor'));
    }
    
    if (widget.currentUser.hasPermission('manage_users')) {
      tabs.add(const Tab(icon: Icon(Icons.people, size: 20), text: 'Users'));
    }
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin Dashboard',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            Text(
              '${widget.currentUser.username} (${widget.currentUser.role.name})',
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: tabs,
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'generate_test') {
                await _generateTestData();
              } else if (value == 'clear_data') {
                await _clearAllData();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate_test',
                child: Row(
                  children: [
                    Icon(Icons.add_chart, size: 20),
                    SizedBox(width: 8),
                    Text('Generate Test Data (50)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_data',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All Data', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Analytics Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterControls(),
                      const SizedBox(height: 16),
                      _buildStatsCards(),
                      const SizedBox(height: 24),
                      _buildTrendChart(),
                      const SizedBox(height: 24),
                      _buildSatisfactionChart(),
                      const SizedBox(height: 24),
                      _buildAverageScoresChart(),
                      const SizedBox(height: 24),
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
    final services = _allResponses
        .map((r) => r.serviceAvailed)
        .where((s) => s != null)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.05), AppColors.secondary.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Filter Data',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filteredResponses.length} results',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedRegion,
                  decoration: InputDecoration(
                    labelText: 'Region',
                    prefixIcon: const Icon(Icons.location_on, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Regions')),
                    ...regions.map((r) => DropdownMenuItem(value: r, child: Text(r))),
                  ],
                  onChanged: (value) => setState(() => _selectedRegion = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedService,
                  decoration: InputDecoration(
                    labelText: 'Service',
                    prefixIcon: const Icon(Icons.business_center, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Services')),
                    ...services.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                  ],
                  onChanged: (value) => setState(() => _selectedService = value),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDateRange = picked);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(
                  _selectedDateRange == null
                      ? 'Date Range'
                      : '${DateFormat('MMM dd').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd').format(_selectedDateRange!.end)}',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
              ),
              if (_selectedRegion != null || _selectedService != null || _selectedDateRange != null) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.clear, size: 18),
                  label: Text('Clear', style: GoogleFonts.poppins(fontSize: 13)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  
  
  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Export Reports', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildExportCard('Excel Report', 'Save Excel-like report as JSON (preview)', Icons.table_chart, Colors.green, _exportExcelJSONSaveAs),
          const SizedBox(height: 16),
          _buildExportCard('PDF Report', 'Save PDF-like report as JSON (preview)', Icons.picture_as_pdf, Colors.red, _exportPDFJSONSaveAs),
          const SizedBox(height: 16),
          _buildExportCard('ARTA Report', 'Save ARTA-compliant report as JSON (preview)', Icons.verified, Colors.blue, _exportARTAJSONSaveAs),
          const SizedBox(height: 16),
          _buildExportCard('CSV Format', 'Export raw data in CSV (Save As...)', Icons.description, Colors.orange, _exportCSVSaveAs),
        ],
      ),
    );
  }
  
  Widget _buildExportCard(String title, String desc, IconData icon, Color color, VoidCallback onTap) {
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
                    Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(desc, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
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
    
    final suggestedName = 'survey_export_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final saveLocation = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [XTypeGroup(label: 'CSV', extensions: ['csv'])],
    );
    if (saveLocation == null) return;

    final data = Uint8List.fromList(utf8.encode(csv));
    final xfile = XFile.fromData(data, mimeType: 'text/csv', name: suggestedName);
    await xfile.saveTo(saveLocation.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CSV saved', style: GoogleFonts.poppins()), backgroundColor: AppColors.success),
    );
  }

  Future<void> _exportExcelJSONSaveAs() async {
    final config = ExportConfig(
      format: ExportFormat.excel,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      region: _selectedRegion,
      serviceType: _selectedService,
      includeCharts: true,
    );
    final data = await _exportService.exportToExcel(_allResponses, config);
    await _saveJsonData(data, suggestedName: 'excel_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json');
  }

  Future<void> _exportPDFJSONSaveAs() async {
    final config = ExportConfig(
      format: ExportFormat.pdf,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      region: _selectedRegion,
      serviceType: _selectedService,
      includeCharts: true,
    );
    final data = await _exportService.exportToPDF(_allResponses, config);
    await _saveJsonData(data, suggestedName: 'pdf_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json');
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
    await _saveJsonData(data, suggestedName: 'arta_report_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json');
  }

  Future<void> _saveJsonData(Map<String, dynamic> data, {required String suggestedName}) async {
    final saveLocation = await getSaveLocation(
      suggestedName: suggestedName,
      acceptedTypeGroups: [XTypeGroup(label: 'JSON', extensions: ['json'])],
    );
    if (saveLocation == null) return;

    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));
    final xfile = XFile.fromData(bytes, mimeType: 'application/json', name: suggestedName);
    await xfile.saveTo(saveLocation.path);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved', style: GoogleFonts.poppins()), backgroundColor: AppColors.success),
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Responses',
                total.toString(),
                Icons.people,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Avg Score',
                avgScore.toStringAsFixed(2),
                Icons.star_rate,
                AppColors.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Satisfaction Rate',
                '${satisfactionRate.toStringAsFixed(1)}%',
                Icons.sentiment_satisfied_alt,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                "CC Awareness",
                '${awarenessRate.toStringAsFixed(1)}%',
                Icons.info_outline,
                Colors.indigo,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Live',
                        style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.withValues(alpha: 0.05), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(24),
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
                child: Icon(Icons.pie_chart, color: Colors.green[700], size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Satisfaction Distribution',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$total responses',
                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 240,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 50,
                      sections: dist.entries.map((entry) {
                        final percentage = (entry.value / total * 100);
                        
                        return PieChartSectionData(
                          value: entry.value.toDouble(),
                          title: '${percentage.toStringAsFixed(1)}%',
                          color: colors[entry.key],
                          radius: 100,
                          titleStyle: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          badgeWidget: entry.value > 0 ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              icons[entry.key],
                              color: colors[entry.key],
                              size: 16,
                            ),
                          ) : null,
                          badgePositionPercentageOffset: 1.3,
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
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
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
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
                                          color: colors[entry.key]?.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: percentage / 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: colors[entry.key],
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${entry.value}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
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
                ),
              ),
            ],
          ),
        ],
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary.withValues(alpha: 0.05), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(24),
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
                child: Icon(Icons.bar_chart, color: AppColors.secondary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Service Quality Dimensions',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.amber[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 350,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 5,
                minY: 0,
                barGroups: avgScores.entries.map((entry) {
                  final index = int.parse(entry.key.replaceAll('SQD', ''));
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
                          colors: [barColor, barColor.withValues(alpha: 0.7)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 28,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 5,
                          color: AppColors.secondary.withValues(alpha: 0.05),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= sqdLabels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'SQD$idx',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.secondary),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sqdLabels[idx],
                                style: GoogleFonts.poppins(fontSize: 8, color: AppColors.textSecondary),
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
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: AppColors.secondary.withValues(alpha: 0.2), width: 2),
                    left: BorderSide(color: AppColors.secondary.withValues(alpha: 0.2), width: 2),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final label = sqdLabels[group.x.toInt()];
                      return BarTooltipItem(
                        '$label\n${rod.toY.toStringAsFixed(2)} / 5.0',
                        GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentResponses() {
    if (_recentResponses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No responses yet',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Responses',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentResponses.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final response = _recentResponses[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
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
                    DateFormat('MMM dd, yyyy HH:mm')
                        .format(response.submittedAt),
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
