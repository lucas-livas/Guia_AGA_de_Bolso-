import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:guia_aga_de_bolso/Temas_Paletas/Temas_Gerenciador.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Home/splash_screen.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await MobileAds.instance.initialize();
    } catch (_) {
      // ignore errors during ads init; app should still run
    }
    // pequeno atraso para permitir que splash mostre
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
          );
        }

        return ValueListenableBuilder<AppTheme>(
          valueListenable: ThemeManager().currentThemeNotifier,
          builder: (context, currentTheme, child) {
            return MaterialApp(
              title: 'Guia AGA',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primaryColor: currentTheme.primary,
                scaffoldBackgroundColor: currentTheme.background,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: currentTheme.primary,
                  primary: currentTheme.primary,
                  secondary: currentTheme.dark,
                  surface: Colors.white,
                ),
                useMaterial3: true,
                appBarTheme: AppBarTheme(
                  backgroundColor: currentTheme.background,
                  foregroundColor: currentTheme.textPrimary,
                  elevation: 0,
                  centerTitle: true,
                ),
              ),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
