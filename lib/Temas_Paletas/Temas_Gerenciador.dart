import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  
  // Cores Sólidas
  final Color primary;
  final Color light;
  final Color dark;
  final Color background;
  final Color textPrimary;

  // Gradientes Dinâmicos
  final Gradient gradientPatient;
  final Gradient gradientFunctional;
  final Gradient gradientCognitive;
  final Gradient gradientClinical;
  final Gradient gradientSocial;
  final Gradient gradientGuides;

  const AppTheme({
    required this.name,
    required this.primary,
    required this.light,
    required this.dark,
    required this.background,
    this.textPrimary = Colors.black87,
    required this.gradientPatient,
    required this.gradientFunctional,
    required this.gradientCognitive,
    required this.gradientClinical,
    required this.gradientSocial,
    required this.gradientGuides,
  });
}

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  // O tema atual é simplesmente a paleta selecionada
  final ValueNotifier<AppTheme> currentThemeNotifier = ValueNotifier(palettes[0]);

  static AppTheme get current => _instance.currentThemeNotifier.value;

  // Método simplificado: apenas troca a paleta
  void switchTheme(AppTheme newTheme) {
    currentThemeNotifier.value = newTheme;
  }

  // --- PALETAS DE CORES E GRADIENTES ---
  static final List<AppTheme> palettes = [
    // 1. CLÁSSICO (AZUL)
    const AppTheme(
      name: 'Clássico (Azul)',
      primary: Color(0xFF1565C0),
      light: Color(0xFFE3F2FD),
      dark: Color(0xFF0D47A1),
      background: Color(0xFFFAFAFA),
      gradientPatient: LinearGradient(colors: [Color(0xFF6FB1FF), Color(0xFF88E4FF)]),
      gradientFunctional: LinearGradient(colors: [Color(0xFFA1FF76), Color(0xFF00B618)]),
      gradientCognitive: LinearGradient(colors: [Color(0xFFF080BE), Color(0xFFD32F2F)]),
      gradientClinical: LinearGradient(colors: [Color(0xFF90BCEE), Color(0xFF0F33FF)]),
      gradientSocial: LinearGradient(colors: [Color(0xFFF7EC8C), Color(0xFFFFD900)]),
      gradientGuides: LinearGradient(colors: [Color(0xFF59C2A5), Color(0xFF6CDDB0)]),
    ),

    // 2. NATUREZA (VERDE)
    const AppTheme(
      name: 'Natureza (Verde)',
      primary: Color(0xFF2E7D32),
      light: Color(0xFFE8F5E9),
      dark: Color(0xFF1B5E20),
      background: Color(0xFFF1F8E9),
      gradientPatient: LinearGradient(colors: [Color(0xFF81C784), Color(0xFF2E7D32)]),
      gradientFunctional: LinearGradient(colors: [Color(0xFFAED581), Color(0xFF558B2F)]),
      gradientCognitive: LinearGradient(colors: [Color(0xFFFFCC80), Color(0xFFEF6C00)]),
      gradientClinical: LinearGradient(colors: [Color(0xFF4DB6AC), Color(0xFF00695C)]),
      gradientSocial: LinearGradient(colors: [Color(0xFFFFF176), Color(0xFFFBC02D)]),
      gradientGuides: LinearGradient(colors: [Color(0xFF90A4AE), Color(0xFF455A64)]),
    ),

    // 3. ACOLHEDOR (VINHO)
    const AppTheme(
      name: 'Acolhedor (Vinho)',
      primary: Color(0xFFAD1457),
      light: Color(0xFFFCE4EC),
      dark: Color(0xFF880E4F),
      background: Color(0xFFFFF8E1),
      gradientPatient: LinearGradient(colors: [Color(0xFFF06292), Color(0xFFC2185B)]),
      gradientFunctional: LinearGradient(colors: [Color(0xFFFF8A65), Color(0xFFD84315)]),
      gradientCognitive: LinearGradient(colors: [Color(0xFFBA68C8), Color(0xFF7B1FA2)]),
      gradientClinical: LinearGradient(colors: [Color(0xFFE57373), Color(0xFFD32F2F)]),
      gradientSocial: LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFA000)]),
      gradientGuides: LinearGradient(colors: [Color(0xFFA1887F), Color(0xFF5D4037)]),
    ),

    // 4. OCEANO (TEAL)
    const AppTheme(
      name: 'Oceano (Teal)',
      primary: Color(0xFF00897B),
      light: Color(0xFFE0F2F1),
      dark: Color(0xFF004D40),
      background: Color(0xFFE0F7FA),
      gradientPatient: LinearGradient(colors: [Color(0xFF4DB6AC), Color(0xFF00796B)]),
      gradientFunctional: LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF0277BD)]),
      gradientCognitive: LinearGradient(colors: [Color(0xFF7986CB), Color(0xFF283593)]),
      gradientClinical: LinearGradient(colors: [Color(0xFF00ACC1), Color(0xFF006064)]),
      gradientSocial: LinearGradient(colors: [Color(0xFF80CBC4), Color(0xFF004D40)]),
      gradientGuides: LinearGradient(colors: [Color(0xFF26A69A), Color(0xFF00897B)]),
    ),

    // 5. ALTO CONTRASTE
    const AppTheme(
      name: 'Alto Contraste',
      primary: Color(0xFF212121),
      light: Color(0xFFE0E0E0),
      dark: Color(0xFF000000),
      background: Color(0xFFFFFFFF),
      textPrimary: Colors.black,
      gradientPatient: LinearGradient(colors: [Color(0xFF757575), Color(0xFF212121)]),
      gradientFunctional: LinearGradient(colors: [Color(0xFF616161), Color(0xFF000000)]),
      gradientCognitive: LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFF424242)]),
      gradientClinical: LinearGradient(colors: [Color(0xFFBDBDBD), Color(0xFF616161)]),
      gradientSocial: LinearGradient(colors: [Color(0xFF757575), Color(0xFF424242)]),
      gradientGuides: LinearGradient(colors: [Color(0xFF9E9E9E), Color(0xFF212121)]),
    ),
  ];
}