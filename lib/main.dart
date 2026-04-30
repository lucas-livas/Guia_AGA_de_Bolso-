import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/app_initializer.dart';
// Certifique-se de que o caminho abaixo está correto de acordo com sua estrutura de pastas
import 'package:guia_aga_de_bolso/Temas_Paletas/Temas_Gerenciador.dart';

void main() async {
  // Inicialização obrigatória para plugins assíncronos (como SharedPreferences)
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega o tema salvo na memória interna antes de iniciar o app
  await ThemeManager().loadTheme();

  runApp(const AppInitializer());
}