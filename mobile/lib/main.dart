import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/services/storage_service.dart';
import 'shared/services/notification_service.dart';
import 'shared/services/auth_service.dart';
import 'core/network/api_client.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

final GetIt sl = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _setupDependencies();
  runApp(const SmartEnglishApp());
}

Future<void> _setupDependencies() async {
  if (sl.isRegistered<StorageService>()) return;

  final storageService = StorageService();
  try { await storageService.initialize(); } catch (_) {}
  sl.registerSingleton<StorageService>(storageService);
  sl.registerSingleton<ApiClient>(ApiClient());
  sl.registerSingleton<AuthService>(AuthService());

  final notificationService = NotificationService();
  try { await notificationService.initialize(); } catch (_) {}
  sl.registerSingleton<NotificationService>(notificationService);
}

class SmartEnglishApp extends StatelessWidget {
  const SmartEnglishApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthBloc(
            authService: sl<AuthService>(),
            storageService: sl<StorageService>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Smart English Everyday',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
