import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import '../services/survey_service.dart';
import '../models/survey_response.dart';
import '../main.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final SurveyService _surveyService = SurveyService();
  int _totalResponses = 0;
  Map<String, double> _avgScores = {};
  Map<String, int> _satisfactionDist = {};
  List<SurveyResponse> _recentResponses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    _totalResponses = await _surveyService.getTotalResponseCount();
    _avgScores = await _surveyService.getAverageSQDScores();
    _satisfactionDist = await _surveyService.getSatisfactionDistribution();
    
    final allResponses = await _surveyService.getAllSurveyResponses();
    _recentResponses = allResponses.reversed.take(10).toList();
    
    setState(() => _isLoading = false);
  }

  Future<void> _exportToCSV() async {
    final responses = await _surveyService.getAllSurveyResponses();
    
    List<List<dynamic>> rows = [
      [
        'ID',
        'Date',
        'Client Type',
        'Sex',
        'Age',
        'Region',
        'CC1',
        'CC2',
        'CC3',
        'SQD0',
        'SQD1',
        'SQD2',
        'SQD3',
        'SQD4',
        'SQD5',
        'SQD6',
        'SQD7',
        'SQD8',
        'Avg Score',
        'Satisfaction Level',
        'Suggestions',
        'Submitted At'
      ]
    ];

    for (var response in responses) {
      rows.add([
        response.id,
        DateFormat('yyyy-MM-dd').format(response.date),
        response.clientType,
        response.sex,
        response.age,
        response.region,
        response.cc1Answer ?? '',
        response.cc2Answer ?? '',
        response.cc3Answer ?? '',
        response.sqdAnswers['SQD0'] ?? '',
        response.sqdAnswers['SQD1'] ?? '',
        response.sqdAnswers['SQD2'] ?? '',
        response.sqdAnswers['SQD3'] ?? '',
        response.sqdAnswers['SQD4'] ?? '',
        response.sqdAnswers['SQD5'] ?? '',
        response.sqdAnswers['SQD6'] ?? '',
        response.sqdAnswers['SQD7'] ?? '',
        response.sqdAnswers['SQD8'] ?? '',
        response.averageSQDScore.toStringAsFixed(2),
        response.satisfactionLevel,
        response.suggestions,
        DateFormat('yyyy-MM-dd HH:mm').format(response.submittedAt),
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.download, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'CSV data prepared. In production, this would download.',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      
      // In a real app, you would save this to a file
      debugPrint('CSV Data:\n$csv');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCSV,
            tooltip: 'Export to CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildSatisfactionChart(),
                  const SizedBox(height: 24),
                  _buildAverageScoresChart(),
                  const SizedBox(height: 24),
                  _buildRecentResponses(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Responses',
            _totalResponses.toString(),
            Icons.people,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Avg Satisfaction',
            _avgScores.isEmpty
                ? '0.0'
                : (_avgScores.values.reduce((a, b) => a + b) /
                        _avgScores.length)
                    .toStringAsFixed(1),
            Icons.star,
            AppColors.secondary,
          ),
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
    return Card(
      elevation: 3,
      shadowColor: color.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.trending_up, color: color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSatisfactionChart() {
    if (_satisfactionDist.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Satisfaction Distribution',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _satisfactionDist.entries.map((entry) {
                    final colors = {
                      'Very Satisfied': Colors.green,
                      'Satisfied': Colors.lightGreen,
                      'Neutral': Colors.amber,
                      'Dissatisfied': Colors.orange,
                      'Very Dissatisfied': Colors.red,
                    };
                    
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.value}',
                      color: colors[entry.key],
                      radius: 80,
                      titleStyle: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: _satisfactionDist.entries.map((entry) {
                final colors = {
                  'Very Satisfied': Colors.green,
                  'Satisfied': Colors.lightGreen,
                  'Neutral': Colors.amber,
                  'Dissatisfied': Colors.orange,
                  'Very Dissatisfied': Colors.red,
                };
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[entry.key],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.key,
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageScoresChart() {
    if (_avgScores.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Average SQD Scores',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5,
                  barGroups: _avgScores.entries.map((entry) {
                    final index = int.parse(entry.key.replaceAll('SQD', ''));
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: AppColors.secondary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(1),
                            style: GoogleFonts.poppins(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            'SQD${value.toInt()}',
                            style: GoogleFonts.poppins(fontSize: 10),
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
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
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
