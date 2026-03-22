// lib/main.dart
import 'package:between_pages/features/catalog/services/libro_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/services/auth_service.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const BetweenPagesApp());
}

class BetweenPagesApp extends StatelessWidget {
  const BetweenPagesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => LibroService()),
      ],
      child: MaterialApp(
        title: 'BetweenPages',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            error: AppColors.error,
            background: AppColors.background,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.text,
            onBackground: AppColors.text,
          ),
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            titleTextStyle: TextStyle(
              fontFamily: 'Roboto',
              color: AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            iconTheme: IconThemeData(color: AppColors.textSecondary),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: AppColors.surface,
            indicatorColor: Colors.transparent,
            iconTheme: MaterialStateProperty.resolveWith((states) {
              final color = states.contains(MaterialState.selected)
                  ? AppColors.primary
                  : AppColors.secondary;
              return IconThemeData(color: color);
            }),
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}