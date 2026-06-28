class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://api.smartenglisheveryday.com/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String streakKey = 'streak_count';
  static const String lastLoginKey = 'last_login';

  // Hive Boxes
  static const String userBox = 'user_box';
  static const String lessonsBox = 'lessons_box';
  static const String progressBox = 'progress_box';
  static const String wordsBox = 'words_box';
  static const String cacheBox = 'cache_box';

  // Assets
  static const String logoPath = 'assets/images/logo.png';
  static const String logoSvgPath = 'assets/images/logo.svg';
  static const String onboarding1 = 'assets/images/onboarding1.svg';
  static const String onboarding2 = 'assets/images/onboarding2.svg';
  static const String onboarding3 = 'assets/images/onboarding3.svg';
  static const String onboarding4 = 'assets/images/onboarding4.svg';
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';
  static const String celebrationAnimation = 'assets/animations/celebration.json';
  static const String robotAnimation = 'assets/animations/robot.json';

  // CEFR Levels
  static const List<String> cefrLevels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  // English Variants
  static const List<String> englishVariants = [
    'British English',
    'American English',
    'Australian English',
    'Canadian English',
    'New Zealand English',
  ];

  // Countries
  static const List<Map<String, String>> countries = [
    {'code': 'GB', 'name': 'United Kingdom', 'flag': '🇬🇧'},
    {'code': 'US', 'name': 'United States', 'flag': '🇺🇸'},
    {'code': 'AU', 'name': 'Australia', 'flag': '🇦🇺'},
    {'code': 'NZ', 'name': 'New Zealand', 'flag': '🇳🇿'},
    {'code': 'CA', 'name': 'Canada', 'flag': '🇨🇦'},
  ];

  // Pagination
  static const int pageSize = 20;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);
  static const Duration splashDuration = Duration(seconds: 3);

  // Game Settings
  static const int wordMatchPairs = 8;
  static const int hangmanMaxAttempts = 6;
  static const int wordSearchGridSize = 10;
  static const int quizTimeLimit = 30; // seconds per question

  // Assessment
  static const int grammarQuizQuestions = 20;
  static const int vocabularyQuizQuestions = 20;
  static const int assessmentSteps = 6;

  // Daily Goals
  static const int defaultDailyGoalMinutes = 15;
  static const List<int> dailyGoalOptions = [5, 10, 15, 20, 30, 60];

  // Max lengths
  static const int maxUsernameLength = 30;
  static const int minUsernameLength = 3;
  static const int maxPasswordLength = 128;
  static const int minPasswordLength = 8;
  static const int maxBioLength = 200;
  static const int writingMinWords = 50;
  static const int writingMaxWords = 500;

  // Notification Channels
  static const String dailyReminderChannel = 'daily_reminder';
  static const String achievementChannel = 'achievement';
  static const String streakChannel = 'streak_reminder';

  // Support
  static const String supportEmail = 'support@smartenglisheveryday.com';
  static const String privacyPolicyUrl = 'https://smartenglisheveryday.com/privacy';
  static const String termsUrl = 'https://smartenglisheveryday.com/terms';
  static const String websiteUrl = 'https://smartenglisheveryday.com';
}
