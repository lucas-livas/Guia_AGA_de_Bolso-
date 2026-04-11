// Arquivo: lib/screens/1_Home/Home/splash_screen.dart

import 'package:flutter/material.dart';

// Ajusta este import de acordo com o caminho real do teu HomeScreen
import 'package:guia_aga_de_bolso/screens/1_Home/Home/home_screen.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Função que aguarda 2,5 segundos e depois navega para a HomeScreen
  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    
    // Substitui a SplashScreen pela HomeScreen para que o utilizador 
    // não consiga voltar para a Splash clicando em "Voltar"
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  // Função que calcula os minutos do dia e devolve a mensagem correta
  String _getWelcomeMessage() {
    final now = DateTime.now();
    // Converter a hora atual em minutos totais para facilitar a comparação
    final int minutes = now.hour * 60 + now.minute;

    // Madrugada: 23:51 até 04:59 (1431 minutos até aos 299 minutos do dia seguinte)
    // Como atravessa a meia-noite, a lógica da madrugada é a que "sobra" dos outros intervalos.

    // Dia: 05:00 (300 min) até 11:50 (710 min)
    if (minutes >= 300 && minutes <= 710) {
      return "Bom dia! Bem vindo ao Guia AGA";
    }
    // Tarde: 11:51 (711 min) até 17:50 (1070 min)
    else if (minutes >= 711 && minutes <= 1070) {
      return "Boa tarde! Bem vindo ao Guia AGA";
    }
    // Noite: 17:51 (1071 min) até 23:50 (1430 min)
    else if (minutes >= 1071 && minutes <= 1430) {
      return "Boa noite! Bem vindo ao Guia AGA";
    }
    // Madrugada: O resto (23:51 às 23:59 e 00:00 às 04:59)
    else {
      return "Boa madrugada! Bem vindo ao Guia AGA";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco e limpo para destacar o logo
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // O Logótipo da Aplicação
            Image.asset(
              'assets/images/logo_aga.png',
              width: 200, 
            ),
            const SizedBox(height: 40),
            
            // Mensagem dinâmica consoante a hora
            Text(
              _getWelcomeMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1), // O Azul Marinho que usámos nos PDFs
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}