class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  static const String googleAuth = '/auth/google';
  static const String appleAuth = '/auth/apple';
  static const String facebookAuth = '/auth/facebook';

  // User
  static const String profile = '/users/profile';
  static const String updateProfile = '/users/profile';
  static const String uploadAvatar = '/users/avatar';
  static const String deleteAccount = '/users/account';
  static const String changePassword = '/users/change-password';
  static const String userProgress = '/users/progress';
  static const String userStats = '/users/stats';
  static const String userAchievements = '/users/achievements';
  static const String userCertificates = '/users/certificates';

  // Assessment
  static const String startAssessment = '/assessment/start';
  static const String submitAssessment = '/assessment/submit';
  static const String assessmentResult = '/assessment/result';
  static const String analyzeReading = '/assessment/analyze-reading';
  static const String analyzeSpeaking = '/assessment/analyze-speaking';
  static const String analyzeWriting = '/assessment/analyze-writing';

  // Lessons
  static const String lessons = '/lessons';
  static const String lessonById = '/lessons/{id}';
  static const String lessonLevels = '/lessons/levels';
  static const String completLesson = '/lessons/{id}/complete';
  static const String lessonProgress = '/lessons/{id}/progress';

  // Reading
  static const String readingPassages = '/reading/passages';
  static const String readingPassageById = '/reading/passages/{id}';
  static const String submitReading = '/reading/submit';
  static const String analyzeReadingPractice = '/reading/analyze';

  // Writing
  static const String writingTopics = '/writing/topics';
  static const String submitWriting = '/writing/submit';
  static const String analyzeWritingPractice = '/writing/analyze';

  // Speaking
  static const String speakingTopics = '/speaking/topics';
  static const String submitSpeaking = '/speaking/submit';
  static const String analyzeSpeakingPractice = '/speaking/analyze';

  // Listening
  static const String listeningAudio = '/listening/audio';
  static const String listeningById = '/listening/audio/{id}';
  static const String submitListening = '/listening/submit';

  // Grammar
  static const String grammarCategories = '/grammar/categories';
  static const String grammarLessons = '/grammar/lessons';
  static const String grammarLessonById = '/grammar/lessons/{id}';
  static const String grammarQuiz = '/grammar/quiz';
  static const String submitGrammarQuiz = '/grammar/quiz/submit';

  // Vocabulary
  static const String vocabularyTopics = '/vocabulary/topics';
  static const String vocabularyWords = '/vocabulary/words';
  static const String wordById = '/vocabulary/words/{id}';
  static const String dailyWords = '/vocabulary/daily';
  static const String searchWords = '/vocabulary/search';
  static const String markWordLearned = '/vocabulary/words/{id}/learned';

  // Games
  static const String gameConfig = '/games/{type}/config';
  static const String submitGameScore = '/games/{type}/score';
  static const String gameLeaderboard = '/games/{type}/leaderboard';

  // Tests
  static const String availableTests = '/tests';
  static const String testById = '/tests/{id}';
  static const String startTest = '/tests/{id}/start';
  static const String submitTest = '/tests/{id}/submit';
  static const String testResults = '/tests/{id}/results';

  // Progress
  static const String progressOverview = '/progress';
  static const String weeklyProgress = '/progress/weekly';
  static const String skillProgress = '/progress/skills';
  static const String streakData = '/progress/streak';
  static const String calendar = '/progress/calendar';

  // AI Teacher
  static const String aiChat = '/ai-teacher/chat';
  static const String aiSession = '/ai-teacher/session';
  static const String aiQuickHelp = '/ai-teacher/quick-help';

  // Chatbot
  static const String chatbotMessage = '/chatbot/message';
  static const String chatbotTopics = '/chatbot/topics';
  static const String chatbotHistory = '/chatbot/history';

  // Content
  static const String stories = '/content/stories';
  static const String storyById = '/content/stories/{id}';
  static const String poems = '/content/poems';
  static const String idioms = '/content/idioms';
  static const String proverbs = '/content/proverbs';

  // Notifications
  static const String registerDevice = '/notifications/register';
  static const String notificationSettings = '/notifications/settings';

  // Admin
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
  static const String adminUserById = '/admin/users/{id}';
  static const String adminContent = '/admin/content';
  static const String adminAnalytics = '/admin/analytics';

  // Parent
  static const String parentChildren = '/parent/children';
  static const String addChild = '/parent/children';
  static const String childProgressById = '/parent/children/{id}/progress';
  static const String childScreenTime = '/parent/children/{id}/screen-time';
  static const String parentWeeklyReport = '/parent/report';
}
