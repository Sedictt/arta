import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'models/survey_response.dart';
// import 'services/survey_service.dart'; // Removed
import 'screens/admin_login.dart';
import 'screens/qr_code_screen.dart';

void main() {
  runApp(const MyApp());
}

// Color Palette
class AppColors {
  static const primary = Color(0xFF7B3FF2); // Purple
  static const secondary = Color(0xFF1E90FF); // Cyan Blue
  static const accent = Color(0xFFB794F6); // Light Purple/Lavender
  static const success = Color(0xFF2E7D32); // Green
  static const background = Color(0xFFF5F7FA); // Light Gray Blue
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF1A1A1A); // Near Black
  static const textSecondary = Color(0xFF546E7A); // Blue Gray
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARTA Customer Satisfaction Survey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary,
              AppColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left side - Content
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo and Title
                Row(
                  children: [
                    Image.asset(
                      'Valenzuela_Seal.svg.png',
                      width: 70,
                      height: 70,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'City Government of Valenzuela',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Help Us Serve You Better',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 80),
                
                // ARTA Label
                Text(
                  'ARTA',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Main Title
                Text(
                  'Client Satisfaction\nSurvey',
                  style: GoogleFonts.poppins(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Description
                Text(
                  'This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback on your recently concluded transaction will help this office provide a better service. Personal information shared will be kept confidential and you always have the option to not answer this form.',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.7,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Start Button
                Container(
                  width: 460,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SurveyHomePage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start Survey',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.arrow_forward_rounded, size: 24),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Estimated Time: 3 - 5 minutes',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Bottom buttons
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const QRCodeScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_2, color: Colors.white, size: 20),
                      label: Text(
                        'QR Code',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdminLogin(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                      label: Text(
                        'Admin',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Right side - Illustration
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white.withValues(alpha: 0.05),
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(60),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.poll_outlined,
                      size: 180,
                      color: AppColors.accent,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Your Feedback Matters',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo and Title
          Row(
            children: [
              Image.asset(
                'Valenzuela_Seal.svg.png',
                width: 50,
                height: 50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'City Government of Valenzuela',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Help Us Serve You Better',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // ARTA Label
          Text(
            'ARTA',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 2,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Main Title
          Text(
            'Client Satisfaction\nSurvey',
            style: GoogleFonts.poppins(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            'This Client Satisfaction Measurement (CSM) tracks the customer experience of government offices. Your feedback on your recently concluded transaction will help this office provide a better service. Personal information shared will be kept confidential and you always have the option to not answer this form.',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Start Button
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SurveyHomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Start Survey',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          Center(
            child: Text(
              'Estimated Time: 3 - 5 minutes',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Bottom buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const QRCodeScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_2, color: Colors.white, size: 18),
                label: Text(
                  'QR Code',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminLogin(),
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 18),
                label: Text(
                  'Admin',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SurveyHomePage extends StatefulWidget {
  const SurveyHomePage({super.key});

  @override
  State<SurveyHomePage> createState() => _SurveyHomePageState();
}

class _SurveyHomePageState extends State<SurveyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  // final SurveyService _surveyService = SurveyService(); // Removed
  int _currentPage = 0;
  bool _hasShownConsent = false;

  // Demographic Information
  String? _clientType;
  String? _sex;
  String? _region;
  DateTime? _date;
  int? _age;

  // CC Awareness Questions
  String? _cc1Answer;
  String? _cc2Answer;
  String? _cc3Answer;

  // Service Quality Dimensions (SQD) - 9 questions with 5-point scale
  final Map<String, int?> _sqdAnswers = {
    'SQD0': null,
    'SQD1': null,
    'SQD2': null,
    'SQD3': null,
    'SQD4': null,
    'SQD5': null,
    'SQD6': null,
    'SQD7': null,
    'SQD8': null,
  };

  String _suggestions = '';

  @override
  void initState() {
    super.initState();
    // Show consent modal after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasShownConsent) {
        _showConsentModal();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showConsentModal() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Title
                  Text(
                    'Data Privacy & Consent',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalInfoSection(
                            icon: Icons.info_outline,
                            title: 'Why We Collect Data',
                            description: 'Your feedback helps us improve services.',
                            color: AppColors.primary,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildModalInfoSection(
                            icon: Icons.assignment_outlined,
                            title: 'What We Collect',
                            description: 'Demographics, service experience, and ratings.',
                            color: AppColors.secondary,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildModalInfoSection(
                            icon: Icons.verified_user_outlined,
                            title: 'Your Rights',
                            description: 'Voluntary participation. All data is confidential.',
                            color: AppColors.accent,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Consent Statement
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary.withValues(alpha: 0.1),
                                  AppColors.primary.withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.secondary.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              'By clicking "I Agree", you consent to the collection and use of your information as described.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade400),
                            foregroundColor: AppColors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Decline',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.secondary, AppColors.primary],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'I Agree',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (result == true) {
      setState(() {
        _hasShownConsent = true;
      });
    } else {
      // User declined, go back to welcome page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const WelcomePage(),
          ),
        );
      }
    }
  }

  Widget _buildModalInfoSection({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitSurvey() async {
    // Check if required fields are filled
    final missingFields = <String>[];
    if (_clientType == null) missingFields.add('Client Type');
    if (_sex == null) missingFields.add('Sex');
    if (_age == null) missingFields.add('Age');
    if (_region == null || _region!.isEmpty) missingFields.add('Region');
    
    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Missing: ${missingFields.join(", ")}. Please complete Personal Information.',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      // Navigate to personal info page
      _pageController.jumpToPage(1);
      setState(() => _currentPage = 1);
      return;
    }
    
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      // Create survey response object (not saved anywhere)
      final response = SurveyResponse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _date ?? DateTime.now(),
        clientType: _clientType!,
        sex: _sex!,
        age: _age!,
        region: _region!,
        cc1Answer: _cc1Answer,
        cc2Answer: _cc2Answer,
        cc3Answer: _cc3Answer,
        sqdAnswers: Map<String, int>.from(
          _sqdAnswers.map((key, value) => MapEntry(key, value ?? 3)),
        ),
        suggestions: _suggestions,
        submittedAt: DateTime.now(),
      );
      
      // Show success message only (no database/local saving)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Survey submitted successfully! Thank you for your feedback.',
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
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Reset form
        _formKey.currentState!.reset();
        setState(() {
          _currentPage = 0;
          _clientType = null;
          _sex = null;
          _region = null;
          _date = null;
          _age = null;
          _cc1Answer = null;
          _cc2Answer = null;
          _cc3Answer = null;
          _sqdAnswers.updateAll((key, value) => null);
          _suggestions = '';
        });
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressIndicator(),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  children: [
                    _buildDemographicPage(),
                    _buildCCAwarenessPage(),
                    _buildServiceQualityPage(),
                    _buildSuggestionsPage(),
                  ],
                ),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ARTA Client Satisfaction Survey',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'City Government of Valenzuela',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: List.generate(4, (index) {
              final isCompleted = index < _currentPage;
              final isCurrent = index == _currentPage;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.secondary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            [
              'Personal Information',
              'Citizen\'s Charter Awareness',
              'Service Quality',
              'Suggestions'
            ][_currentPage],
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDemographicPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Personal Information',
            icon: Icons.person_outline,
            children: [
              const Text(
                'This information helps us understand our clients better. All data will be kept confidential.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildDateField(),
              const SizedBox(height: 16),
              _buildClientTypeField(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildSexField()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAgeField()),
                ],
              ),
              const SizedBox(height: 16),
              _buildRegionField(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCCAwarenessPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Citizen\'s Charter Awareness',
            icon: Icons.info_outline,
            children: [
              const Text(
                'The Citizen\'s Charter (CC) is an official document that reflects the services of a government agency.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildCCQuestion(
                'CC1',
                'Which of the following best describes your awareness of a CC?',
                [
                  'I know what a CC is and I saw this office\'s CC',
                  'I know what a CC is but I did NOT see this office\'s CC',
                  'I learned of the CC only when I saw this office\'s CC',
                  'I do not know what a CC is and I did not see one in this office',
                ],
                _cc1Answer,
                (value) => setState(() => _cc1Answer = value),
              ),
              const SizedBox(height: 24),
              _buildCCQuestion(
                'CC2',
                'If aware of CC (answered 1-3 in CC1), would you say that the CC of this office was...?',
                [
                  'Easy to see',
                  'Somewhat easy to see',
                  'Difficult to see',
                  'Not visible at all',
                  'Not Applicable',
                ],
                _cc2Answer,
                (value) => setState(() => _cc2Answer = value),
              ),
              const SizedBox(height: 24),
              _buildCCQuestion(
                'CC3',
                'If aware of CC (answered codes 1-3 in CC1), how much did the CC help you in your transaction?',
                [
                  'Helped very much',
                  'Somewhat helped',
                  'Did not help',
                  'Not Applicable',
                ],
                _cc3Answer,
                (value) => setState(() => _cc3Answer = value),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceQualityPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Service Quality Dimensions',
            icon: Icons.star_outline,
            children: [
              const Text(
                'Please rate your experience with our service on the following aspects:',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildSatisfactionScale(),
              const SizedBox(height: 24),
              ..._buildSQDQuestions(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Your Suggestions',
            icon: Icons.lightbulb_outline,
            children: [
              const Text(
                'We value your feedback! Please share any suggestions on how we can improve our service.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Enter your suggestions here (optional)...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
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
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                onSaved: (value) => _suggestions = value ?? '',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your feedback is confidential and will be used to improve our services.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _date = date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Text(
          _date != null ? DateFormat('MMM dd, yyyy').format(_date!) : 'Select date',
          style: TextStyle(
            color: _date != null ? Colors.black87 : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  Widget _buildClientTypeField() {
    return DropdownButtonFormField<String>(
      initialValue: _clientType,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Client Type',
        prefixIcon: const Icon(Icons.badge_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: [
        const DropdownMenuItem(value: 'Citizen', child: Text('Citizen')),
        const DropdownMenuItem(value: 'Business', child: Text('Business')),
        DropdownMenuItem(
          value: 'Government',
          child: Text(
            'Government (Employee or another agency)',
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 14),
          ),
        ),
      ],
      onChanged: (value) => setState(() => _clientType = value),
      validator: (value) => value == null ? 'Please select client type' : null,
    );
  }

  Widget _buildSexField() {
    return DropdownButtonFormField<String>(
      initialValue: _sex,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Sex',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
      ],
      onChanged: (value) => setState(() => _sex = value),
      validator: (value) => value == null ? 'Required' : null,
    );
  }

  Widget _buildAgeField() {
    return TextFormField(
      initialValue: _age?.toString(),
      decoration: InputDecoration(
        labelText: 'Age',
        prefixIcon: const Icon(Icons.cake_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        setState(() {
          _age = int.tryParse(value);
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (int.tryParse(value) == null) return 'Invalid';
        return null;
      },
    );
  }

  Widget _buildRegionField() {
    return TextFormField(
      initialValue: _region,
      decoration: InputDecoration(
        labelText: 'Region of Residence',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      onChanged: (value) {
        setState(() {
          _region = value;
        });
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please enter region' : null,
    );
  }

  Widget _buildCCQuestion(
    String code,
    String question,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => onChanged(option),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selectedValue == option
                        ? AppColors.secondary.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selectedValue == option
                          ? AppColors.secondary
                          : Colors.grey.shade300,
                      width: selectedValue == option ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        selectedValue == option
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selectedValue == option
                            ? AppColors.secondary
                            : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: selectedValue == option
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            fontWeight: selectedValue == option
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSatisfactionScale() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScaleItem('😠', 'Strongly\nDisagree', 1),
          _buildScaleItem('😕', 'Disagree', 2),
          _buildScaleItem('😐', 'Neither Agree\nnor Disagree', 3),
          _buildScaleItem('🙂', 'Agree', 4),
          _buildScaleItem('😄', 'Strongly\nAgree', 5),
        ],
      ),
    );
  }

  Widget _buildScaleItem(String emoji, String label, int value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSQDQuestions() {
    final questions = [
      'I am satisfied with the service that I availed.',
      'I spent a reasonable amount of time for my transaction.',
      'The office followed the transaction\'s requirements and steps.',
      'The steps I needed to do for my transaction were easy and simple.',
      'I easily found information about my transaction.',
      'I paid a reasonable amount of fees for my transaction.',
      'I feel the office was fair to everyone.',
      'I was treated courteously by the staff.',
      'I got what I needed from the government office.',
    ];

    return List.generate(questions.length, (index) {
      final key = 'SQD$index';
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'SQD$index',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      questions[index],
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Emoji buttons
              Row(
                children: [
                  ...List.generate(6, (index) {
                    if (index < 5) {
                      // Emoji rating buttons
                      final rating = index;
                      final value = rating + 1;
                      final isSelected = _sqdAnswers[key] == value;
                      final tooltips = [
                        'Strongly Disagree',
                        'Disagree',
                        'Neither Agree nor Disagree',
                        'Agree',
                        'Strongly Agree',
                      ];
                      // Color based on rating
                      final selectedColors = [
                        const Color(0xFFE53935), // Red - Strongly Disagree
                        const Color(0xFFFF7043), // Orange - Disagree
                        const Color(0xFFFFA726), // Light Orange - Neither
                        const Color(0xFF66BB6A), // Light Green - Agree
                        const Color(0xFF4CAF50), // Green - Strongly Agree
                      ];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 5 ? 4 : 0),
                          child: Tooltip(
                            message: tooltips[rating],
                            textStyle: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: () => setState(() => _sqdAnswers[key] = value),
                              borderRadius: BorderRadius.circular(10),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? selectedColors[rating]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? selectedColors[rating]
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      ['😠', '😕', '😐', '🙂', '😄'][rating],
                                      style: TextStyle(
                                        fontSize: isSelected ? 26 : 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Not Applicable button
                      return Expanded(
                        child: Tooltip(
                          message: 'Not Applicable',
                          textStyle: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () => setState(() => _sqdAnswers[key] = 0),
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _sqdAnswers[key] == 0
                                      ? Colors.grey.shade400
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: _sqdAnswers[key] == 0
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade300,
                                    width: _sqdAnswers[key] == 0 ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '❓',
                                    style: TextStyle(
                                      fontSize: _sqdAnswers[key] == 0 ? 26 : 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousPage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppColors.primary, width: 2),
                  foregroundColor: AppColors.primary,
                ),
                child: Text(
                  'Previous',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentPage == 0 ? 1 : 1,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _currentPage < 3 ? _nextPage : _submitSurvey,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _currentPage < 3 ? 'Next' : 'Submit Survey',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
