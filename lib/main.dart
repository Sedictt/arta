import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'models/survey_response.dart';
import 'services/survey_service.dart';
import 'screens/admin_login.dart';
import 'screens/qr_code_screen.dart';

void main() {
  runApp(const MyApp());
}

// Color Palette
class AppColors {
  static const primary = Color(0xFF1565C0); // Deep Blue
  static const primaryDark = Color(0xFF0D47A1);
  static const secondary = Color(0xFF00B0FF); // Light Blue
  static const accent = Color(0xFFFFC107); // Amber
  static const success = Color(0xFF00C853); // Vibrant Green
  static const background = Color(0xFFF8F9FD); // Very Light Blue-Grey
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1E293B); // Slate 900
  static const textSecondary = Color(0xFF64748B); // Slate 500
  static const border = Color(0xFFE2E8F0); // Slate 200
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FD)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
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
          surface: AppColors.surface,

          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.transparent),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9), // Slate 100
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          floatingLabelStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
          prefixIconColor: AppColors.textSecondary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 8,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: AppColors.border),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
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
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/cityhall_facade.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryDark.withValues(alpha: 0.85),
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            // Left side - Content
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'Valenzuela_Seal.svg.png',
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'City Government of Valenzuela',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'Help Us Serve You Better',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // ARTA Label
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      'ARTA COMPLIANT',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.black87,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Main Title
                  Text(
                    'Client Satisfaction\nMeasurement',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          offset: const Offset(0, 4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Description
                  Text(
                    'Your feedback is crucial for our continuous improvement. This survey tracks the customer experience of government offices in compliance with the Anti-Red Tape Authority (ARTA).',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.6,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                  
                  // Start Button
                  SizedBox(
                    width: 300,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SurveyHomePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: AppColors.secondary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Start Survey', style: TextStyle(fontSize: 20)),
                          SizedBox(width: 16),
                          Icon(Icons.arrow_forward_rounded, size: 28),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Estimated Time: 3 - 5 minutes',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.qr_code_2, color: Colors.white),
                        label: const Text('Scan QR Code'),
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
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                        label: const Text('Admin Access'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Right side - Illustration
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  width: 500,
                  height: 600,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.assignment_turned_in_rounded,
                              size: 120,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'Your Voice Matters',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Help us build a better government by sharing your honest feedback.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                width: 60,
                height: 60,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'City Government of Valenzuela',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Help Us Serve You Better',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
          
          // ARTA Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              'ARTA COMPLIANT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white,
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Main Title
          Text(
            'Client Satisfaction\nMeasurement',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description
          Text(
            'Your feedback is crucial for our continuous improvement. This survey tracks the customer experience of government offices.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Start Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const SurveyHomePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('Start Survey'),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Center(
            child: Text(
              'Estimated Time: 3 - 5 minutes',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
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
                icon: const Icon(Icons.qr_code_2, color: Colors.white, size: 20),
                label: const Text(
                  'Scan QR',
                  style: TextStyle(color: Colors.white),
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
                icon: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                label: const Text(
                  'Admin',
                  style: TextStyle(color: Colors.white),
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
  final SurveyService _surveyService = SurveyService();
  int _currentPage = 0;
  bool _hasShownConsent = false;

  // Demographic Information
  String? _clientType;
  String? _sex;
  String? _region;
  String? _serviceAvailed;
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
    // Validate current page before proceeding
    if (!_validateCurrentPage()) {
      return;
    }
    
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    final missingFields = <String>[];
    
    switch (_currentPage) {
      case 0: // Personal Information
        if (_clientType == null) missingFields.add('Client Type');
        if (_sex == null) missingFields.add('Sex');
        if (_age == null) missingFields.add('Age');
        if (_region == null || _region!.isEmpty) missingFields.add('Region');
        if (_serviceAvailed == null || _serviceAvailed!.isEmpty) missingFields.add('Service Availed');
        if (_date == null) missingFields.add('Date');
        break;
      case 1: // CC Awareness
        if (_cc1Answer == null) missingFields.add('CC1');
        if (_cc2Answer == null) missingFields.add('CC2');
        if (_cc3Answer == null) missingFields.add('CC3');
        break;
      case 2: // Service Quality
        for (var i = 0; i < 9; i++) {
          if (_sqdAnswers['SQD$i'] == null) {
            missingFields.add('SQD$i');
          }
        }
        break;
    }
    
    if (missingFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please complete all required fields: ${missingFields.join(", ")}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      return false;
    }
    return true;
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
      
      // Create survey response object
      final response = SurveyResponse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: _date ?? DateTime.now(),
        clientType: _clientType!,
        sex: _sex!,
        age: _age!,
        region: _region!,
        serviceAvailed: _serviceAvailed,
        cc1Answer: _cc1Answer,
        cc2Answer: _cc2Answer,
        cc3Answer: _cc3Answer,
        sqdAnswers: Map<String, int>.from(
          _sqdAnswers.map((key, value) => MapEntry(key, value ?? 3)),
        ),
        suggestions: _suggestions,
        submittedAt: DateTime.now(),
      );
      
      // Save response locally
      await _surveyService.saveSurveyResponse(response);
      
      debugPrint('Survey submitted and saved: ${response.id}');
      
      // Navigate to thank you page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ThankYouPage(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Image with Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/cityhall_facade.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryDark.withValues(alpha: 0.92),
                      AppColors.primary.withValues(alpha: 0.85),
                      AppColors.background.withValues(alpha: 0.98),
                    ],
                    stops: const [0.0, 0.25, 0.5],
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Column(
                        children: [
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Logo with glow effect
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Image.asset(
              'Valenzuela_Seal.svg.png',
              width: 52,
              height: 52,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ARTA',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Client Satisfaction Survey',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'City Government of Valenzuela',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          // Help button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Icon(Icons.help_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        const Text('Survey Help'),
                      ],
                    ),
                    content: const Text(
                      'This survey helps us measure and improve our services. Your responses are confidential and will be used to enhance the citizen experience.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.help_outline, color: Colors.white, size: 22),
              tooltip: 'Help',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final stepLabels = ['Info', 'CC', 'Quality', 'Feedback'];
    final stepIcons = [
      Icons.person_outline,
      Icons.assignment_outlined,
      Icons.star_outline,
      Icons.lightbulb_outline,
    ];
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        children: [
          // Step indicators row
          Row(
            children: List.generate(4, (index) {
              final isCompleted = index < _currentPage;
              final isCurrent = index == _currentPage;
              final isLast = index == 3;
              
              return Expanded(
                child: Row(
                  children: [
                    // Step Circle with icon
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          width: isCurrent ? 44 : 36,
                          height: isCurrent ? 44 : 36,
                          decoration: BoxDecoration(
                            gradient: isCompleted || isCurrent
                                ? LinearGradient(
                                    colors: isCompleted
                                        ? [AppColors.success, AppColors.success.withValues(alpha: 0.8)]
                                        : [AppColors.primary, AppColors.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isCompleted || isCurrent ? null : AppColors.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted
                                  ? AppColors.success
                                  : isCurrent
                                      ? AppColors.primary
                                      : AppColors.border,
                              width: isCurrent ? 0 : 2,
                            ),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : isCompleted
                                    ? [
                                        BoxShadow(
                                          color: AppColors.success.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                : Icon(
                                    stepIcons[index],
                                    color: isCurrent ? Colors.white : AppColors.textSecondary,
                                    size: isCurrent ? 22 : 18,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stepLabels[index],
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
                            color: isCurrent
                                ? AppColors.primary
                                : isCompleted
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    
                    // Connecting Line
                    if (!isLast)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Stack(
                            children: [
                              Container(
                                height: 3,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.border.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                height: 3,
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                width: isCompleted ? double.infinity : 0,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.success, AppColors.success.withValues(alpha: 0.7)],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
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
              Text(
                'This information helps us understand our clients better. All data will be kept confidential.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
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
              const SizedBox(height: 16),
              _buildServiceAvailedField(),
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
              Text(
                'The Citizen\'s Charter (CC) is an official document that reflects the services of a government agency.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
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
          // Page header with icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary.withValues(alpha: 0.1),
                  AppColors.primary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Quality Dimensions',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rate your experience on the following aspects',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildSatisfactionScale(),
          const SizedBox(height: 28),
          ..._buildSQDQuestions(),
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
              Text(
                'We value your feedback! Please share any suggestions on how we can improve our service.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Enter your suggestions here (optional)...',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                ),
                onSaved: (value) => _suggestions = value ?? '',
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your feedback is confidential and will be used to improve our services.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary.withValues(alpha: 0.1), AppColors.secondary.withValues(alpha: 0.1)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        ...children,
      ],
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
                  backgroundColor: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          setState(() => _date = date);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: IgnorePointer(
        child: TextFormField(
          key: ValueKey(_date),
          initialValue: _date != null ? DateFormat('MMM dd, yyyy').format(_date!) : null,
          decoration: InputDecoration(
            labelText: 'Date of Visit',
            hintText: 'Select date',
            prefixIcon: const Icon(Icons.calendar_today_rounded),
            suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
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
    final regions = [
      'NCR - National Capital Region',
      'CAR - Cordillera Administrative Region',
      'Region I - Ilocos Region',
      'Region II - Cagayan Valley',
      'Region III - Central Luzon',
      'Region IV-A - CALABARZON',
      'Region IV-B - MIMAROPA',
      'Region V - Bicol Region',
      'Region VI - Western Visayas',
      'Region VII - Central Visayas',
      'Region VIII - Eastern Visayas',
      'Region IX - Zamboanga Peninsula',
      'Region X - Northern Mindanao',
      'Region XI - Davao Region',
      'Region XII - SOCCSKSARGEN',
      'Region XIII - Caraga',
      'BARMM - Bangsamoro Autonomous Region',
    ];

    return Autocomplete<String>(
      initialValue: _region != null ? TextEditingValue(text: _region!) : null,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return regions;
        }
        return regions.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        setState(() {
          _region = selection;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (_region != null && controller.text.isEmpty) {
          controller.text = _region!;
        }
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Region of Residence',
            prefixIcon: const Icon(Icons.location_on_outlined),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          onChanged: (value) {
            setState(() {
              _region = value;
            });
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter region' : null,
        );
      },
    );
  }

  Widget _buildServiceAvailedField() {
    final services = [
      'Business Permit',
      'Building Permit',
      'Cedula',
      'Community Tax Certificate',
      'Death Certificate',
      'Birth Certificate',
      'Marriage Certificate',
      'Barangay Clearance',
      'Police Clearance',
      'Health Certificate',
      'Occupancy Permit',
      'Zoning Clearance',
      'Fire Safety Inspection Certificate',
      'Sanitary Permit',
      'Mayor\'s Permit',
    ];

    return Autocomplete<String>(
      initialValue: _serviceAvailed != null ? TextEditingValue(text: _serviceAvailed!) : null,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return services;
        }
        return services.where((String option) {
          return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
        });
      },
      onSelected: (String selection) {
        setState(() {
          _serviceAvailed = selection;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        if (_serviceAvailed != null && controller.text.isEmpty) {
          controller.text = _serviceAvailed!;
        }
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Service Availed',
            prefixIcon: const Icon(Icons.business_center_outlined),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          onChanged: (value) {
            setState(() {
              _serviceAvailed = value;
            });
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Please enter service availed' : null,
        );
      },
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  code,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...options.map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onChanged(option),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: selectedValue == option
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selectedValue == option
                          ? AppColors.primary
                          : AppColors.border,
                      width: selectedValue == option ? 2 : 1,
                    ),
                    boxShadow: selectedValue == option
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedValue == option
                                ? AppColors.primary
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                          color: selectedValue == option
                              ? AppColors.primary
                              : Colors.transparent,
                        ),
                        child: selectedValue == option
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            AppColors.background,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Rating Scale Guide',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildScaleItem('😠', 'Strongly\nDisagree', 1, const Color(0xFFE53935)),
                _buildScaleItem('😕', 'Disagree', 2, const Color(0xFFFF7043)),
                _buildScaleItem('😐', 'Neither', 3, const Color(0xFFFFA726)),
                _buildScaleItem('🙂', 'Agree', 4, const Color(0xFF66BB6A)),
                _buildScaleItem('😄', 'Strongly\nAgree', 5, const Color(0xFF4CAF50)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScaleItem(String emoji, String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
        ],
      ),
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

    final questionIcons = [
      Icons.sentiment_satisfied_rounded,
      Icons.access_time_rounded,
      Icons.checklist_rounded,
      Icons.straighten_rounded,
      Icons.search_rounded,
      Icons.payments_rounded,
      Icons.balance_rounded,
      Icons.handshake_rounded,
      Icons.task_alt_rounded,
    ];

    return List.generate(questions.length, (index) {
      final key = 'SQD$index';
      final hasAnswer = _sqdAnswers[key] != null;
      
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasAnswer 
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.border,
              width: hasAnswer ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: hasAnswer
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: hasAnswer ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question header with gradient background
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      hasAnswer
                          ? AppColors.primary.withValues(alpha: 0.05)
                          : AppColors.background,
                      Colors.white,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question number badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: hasAnswer
                            ? LinearGradient(
                                colors: [AppColors.secondary, AppColors.primary],
                              )
                            : null,
                        color: hasAnswer ? null : AppColors.border.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Icon(
                          questionIcons[index],
                          color: hasAnswer ? Colors.white : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Question text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            questions[index],
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Answer indicator
                    if (hasAnswer)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Emoji rating buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        
                        return Tooltip(
                          message: tooltips[rating],
                          textStyle: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () => setState(() => _sqdAnswers[key] = value),
                            borderRadius: BorderRadius.circular(30),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              width: isSelected ? 56 : 48,
                              height: isSelected ? 56 : 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          selectedColors[rating],
                                          selectedColors[rating].withValues(alpha: 0.85),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isSelected ? null : Colors.grey.shade200,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: selectedColors[rating].withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontSize: isSelected ? 28 : 24,
                                  ),
                                  child: Opacity(
                                    opacity: isSelected ? 1.0 : 0.4,
                                    child: Text(['😠', '😕', '😐', '🙂', '😄'][rating]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Not Applicable button
                        final isSelected = _sqdAnswers[key] == 0;
                        
                        return Tooltip(
                          message: 'Not Applicable',
                          textStyle: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () => setState(() => _sqdAnswers[key] = 0),
                            borderRadius: BorderRadius.circular(30),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              width: isSelected ? 56 : 48,
                              height: isSelected ? 56 : 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? Colors.grey.shade500 : Colors.grey.shade200,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.grey.withValues(alpha: 0.4),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(milliseconds: 250),
                                      style: TextStyle(
                                        fontSize: isSelected ? 24 : 20,
                                      ),
                                      child: Opacity(
                                        opacity: isSelected ? 1.0 : 0.4,
                                        child: const Text('❓'),
                                      ),
                                    ),
                                    if (isSelected)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          'N/A',
                                          style: GoogleFonts.poppins(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildNavigationButtons() {
    final isLastPage = _currentPage == 3;
    final isFirstPage = _currentPage == 0;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Previous button
            if (!isFirstPage)
              Expanded(
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.5),
                  ),
                  child: TextButton(
                    onPressed: _previousPage,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'Back',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (!isFirstPage) const SizedBox(width: 12),
            
            // Next/Submit button
            Expanded(
              flex: isFirstPage ? 1 : 2,
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: isLastPage
                      ? LinearGradient(
                          colors: [AppColors.success, AppColors.success.withValues(alpha: 0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (isLastPage ? AppColors.success : AppColors.primary).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLastPage ? _submitSurvey : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLastPage)
                        const Icon(Icons.check_circle_outline, size: 22, color: Colors.white)
                      else
                        Text(
                          'Continue',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(width: 8),
                      if (isLastPage)
                        Text(
                          'Submit Survey',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        )
                      else
                        const Icon(Icons.arrow_forward_rounded, size: 22, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThankYouPage extends StatelessWidget {
  const ThankYouPage({super.key});

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
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 48 : 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon Animation
                  Container(
                    width: isDesktop ? 160 : 120,
                    height: isDesktop ? 160 : 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: isDesktop ? 100 : 70,
                      color: AppColors.success,
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 48 : 32),
                  
                  // Thank You Title
                  Text(
                    'Thank You!',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 56 : 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    'Your feedback has been submitted successfully',
                    style: GoogleFonts.poppins(
                      fontSize: isDesktop ? 20 : 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Message Card
                  Container(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 48,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Your input helps us improve our services and better serve the community. We truly appreciate you taking the time to share your experience with us.',
                          style: GoogleFonts.poppins(
                            fontSize: isDesktop ? 16 : 14,
                            color: Colors.white.withValues(alpha: 0.95),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isDesktop ? 48 : 32),
                  
                  // Return Button
                  Container(
                    constraints: BoxConstraints(maxWidth: isDesktop ? 400 : double.infinity),
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const WelcomePage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(28),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_outlined,
                                color: AppColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Return to Home',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer
                  Text(
                    'City Government of Valenzuela',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
