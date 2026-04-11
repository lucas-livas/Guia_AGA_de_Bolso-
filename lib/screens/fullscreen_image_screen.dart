// lib/screens/fullscreen_image_screen.dart

import 'package:flutter/material.dart';

class FullscreenImageScreen extends StatelessWidget {
  final String imagePath;

  const FullscreenImageScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto para focar na imagem
      body: GestureDetector(
        // Faz a tela inteira ser um "botão" de fechar
        onTap: () {
          Navigator.pop(context); // Volta para a tela anterior
        },
        child: Center(
          child: InteractiveViewer( // Permite zoom e pan
            panEnabled: true,
            minScale: 1.0, // Começa com a imagem no tamanho original
            maxScale: 5.0, // Permite ampliar até 5x
            child: Image.asset(imagePath),
          ),
        ),
      ),
    );
  }
}