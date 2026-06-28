import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/assessment/presentation/pages/assessment_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/lessons/presentation/pages/lessons_page.dart';
import '../../features/lessons/presentation/pages/lesson_detail_page.dart';
import '../../features/reading/presentation/pages/reading_page.dart';
import '../../features/writing/presentation/pages/writing_page.dart';
import '../../features/speaking/presentation/pages/speaking_page.dart';
import '../../features/listening/presentation/pages/listening_page.dart';
import '../../features/grammar/presentation/pages/grammar_page.dart';
import '../../features/vocabulary/presentation/pages/vocabulary_page.dart';
import '../../features/games/presentation/pages/games_page.dart';
import '../../features/games/presentation/pages/word_match_game.dart';
import '../../features/games/presentation/pages/hangman_game.dart';
import '../../features/games/presentation/pages/word_search_game.dart';
import '../../features/tests/presentation/pages/tests_page.dart';
import '../../features/progress/presentation/pages/progress_page.dart';
import '../../features/ai_teacher/presentation/pages/ai_teacher_page.dart';
import '../../features/chatbot/presentation/pages/chatbot_page.dart';
import '../../features/daily_words/presentation/pages/daily_words_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_login_page.dart';
import '../../features/parent/presentation/pages/parent_dashboard_page.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String assessment = '/assessment';
  static const String home = '/home';
  static const String lessons = '/lessons';
  static const String lessonDetail = '/lesson/:id';
  static const String reading = '/reading';
  static const String writing = '/writing';
  static const String speaking = '/speaking';
  static const String listening = '/listening';
  static const String grammar = '/grammar';
  static const String vocabulary = '/vocabulary';
  static const String games = '/games';
  static const String wordMatch = '/game/word-match';
  static const String hangman = '/game/hangman';
  static const String wordSearch = '/game/word-search';
  static const String tests = '/tests';
  static const String progress = '/progress';
  static const String aiTeacher = '/ai-teacher';
  static const String chatbot = '/chatbot';
  static const String dailyWords = '/daily-words';
  static const String stories = '/stories';
  static const String poems = '/poems';
  static const String idioms = '/idioms';
  static const String proverbs = '/proverbs';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String adminLogin = '/admin-login';
  static const String admin = '/admin';
  static const String parent = '/parent';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: splash,
        pageBuilder: (context, state) => _buildPage(const SplashPage(), state),
      ),
      GoRoute(
        path: onboarding,
        pageBuilder: (context, state) => _buildPage(const OnboardingPage(), state),
      ),
      GoRoute(
        path: login,
        pageBuilder: (context, state) => _buildPage(const LoginPage(), state),
      ),
      GoRoute(
        path: register,
        pageBuilder: (context, state) => _buildPage(const RegisterPage(), state),
      ),
      GoRoute(
        path: forgotPassword,
        pageBuilder: (context, state) => _buildPage(const ForgotPasswordPage(), state),
      ),
      GoRoute(
        path: assessment,
        pageBuilder: (context, state) => _buildPage(const AssessmentPage(), state),
      ),
      GoRoute(
        path: home,
        pageBuilder: (context, state) => _buildPage(const HomePage(), state),
      ),
      GoRoute(
        path: lessons,
        pageBuilder: (context, state) => _buildPage(const LessonsPage(), state),
      ),
      GoRoute(
        path: '/lesson/:id',
        pageBuilder: (context, state) {
          final lessonId = state.pathParameters['id'] ?? '';
          return _buildPage(LessonDetailPage(lessonId: lessonId), state);
        },
      ),
      GoRoute(
        path: reading,
        pageBuilder: (context, state) => _buildPage(const ReadingPage(), state),
      ),
      GoRoute(
        path: writing,
        pageBuilder: (context, state) => _buildPage(const WritingPage(), state),
      ),
      GoRoute(
        path: speaking,
        pageBuilder: (context, state) => _buildPage(const SpeakingPage(), state),
      ),
      GoRoute(
        path: listening,
        pageBuilder: (context, state) => _buildPage(const ListeningPage(), state),
      ),
      GoRoute(
        path: grammar,
        pageBuilder: (context, state) => _buildPage(const GrammarPage(), state),
      ),
      GoRoute(
        path: vocabulary,
        pageBuilder: (context, state) => _buildPage(const VocabularyPage(), state),
      ),
      GoRoute(
        path: games,
        pageBuilder: (context, state) => _buildPage(const GamesPage(), state),
      ),
      GoRoute(
        path: wordMatch,
        pageBuilder: (context, state) => _buildPage(const WordMatchGame(), state),
      ),
      GoRoute(
        path: hangman,
        pageBuilder: (context, state) => _buildPage(const HangmanGame(), state),
      ),
      GoRoute(
        path: wordSearch,
        pageBuilder: (context, state) => _buildPage(const WordSearchGame(), state),
      ),
      GoRoute(
        path: tests,
        pageBuilder: (context, state) => _buildPage(const TestsPage(), state),
      ),
      GoRoute(
        path: progress,
        pageBuilder: (context, state) => _buildPage(const ProgressPage(), state),
      ),
      GoRoute(
        path: aiTeacher,
        pageBuilder: (context, state) => _buildPage(const AiTeacherPage(), state),
      ),
      GoRoute(
        path: chatbot,
        pageBuilder: (context, state) => _buildPage(const ChatbotPage(), state),
      ),
      GoRoute(
        path: dailyWords,
        pageBuilder: (context, state) => _buildPage(const DailyWordsPage(), state),
      ),
      GoRoute(
        path: profile,
        pageBuilder: (context, state) => _buildPage(const ProfilePage(), state),
      ),
      GoRoute(
        path: adminLogin,
        pageBuilder: (context, state) => _buildPage(const AdminLoginPage(), state),
      ),
      GoRoute(
        path: admin,
        pageBuilder: (context, state) => _buildPage(const AdminDashboardPage(), state),
      ),
      GoRoute(
        path: parent,
        pageBuilder: (context, state) => _buildPage(const ParentDashboardPage(), state),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri}'),
            TextButton(
              onPressed: () => context.go(home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );

  static CustomTransitionPage<void> _buildPage(Widget child, GoRouterState state) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
