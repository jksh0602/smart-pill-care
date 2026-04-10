// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/medication_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/elder/elder_main_screen.dart';
import 'screens/guardian/guardian_dashboard_screen.dart';
import 'firebase_options.dart'; // FlutterFire CLI로 자동 생성

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartPillCareApp());
}

class SmartPillCareApp extends StatelessWidget {
  const SmartPillCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
      ],
      child: MaterialApp(
        title: '스마트 복약 관리',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AppRouter(),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.unknown:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case AuthStatus.unauthenticated:
        return const HomeScreen();

      case AuthStatus.authenticated:
        final user = auth.currentUser;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return user.isElder
            ? const ElderMainScreen()
            : const GuardianDashboardScreen();
    }
  }
}