import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  await Hive.initFlutter();
  await _setupDependencies();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SmartEnglishApp());
}

Future<void> _setupDependencies() async {
  final storageService = StorageService();
  await storageService.initialize();
  sl.registerSingleton<StorageService>(storageService);

  sl.registerSingleton<ApiClient>(ApiClient());
  sl.registerSingleton<AuthService>(AuthService());

  final notificationService = NotificationService();
  await notificationService.initialize();
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
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
