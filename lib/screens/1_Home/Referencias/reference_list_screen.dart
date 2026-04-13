import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// Importações de dados e telas
import 'package:guia_aga_de_bolso/data/reference_data.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Referencias/reference_detail_screen.dart';

class ReferenceListScreen extends StatelessWidget {
  const ReferenceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testNames = referenceData.keys.toList();
    
    // 1. Extrai a cor do gradiente de GUIAS para manter a consistência visual
    final Gradient gradient = AssessmentGradients.guides;
    final Color themeColor = (gradient is LinearGradient) 
        ? gradient.colors.last 
        : AssessmentColors.primaryBlue;

    return Scaffold(
      // 2. Padroniza o fundo da tela
      backgroundColor: AssessmentColors.backgroundLight,
      
      appBar: AppBar(
        title: const Text('Guias e Referências'),
        centerTitle: true,
        // 3. Usa as cores globais de fundo e texto para o AppBar
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
      ),
      
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: testNames.length + 1,
        itemBuilder: (context, index) {
          
          if (index == 0) {
            return AssessmentSubmenuTitle(
              title: 'BIBLIOTECA DE ESCALAS',
              // 4. Aplica a cor dinâmica no título da seção
              color: themeColor,
            );
          }

          final testName = testNames[index - 1];

          return AssessmentSubmenuItem(
            icon: Icons.menu_book_outlined,
            title: testName,
            subtitle: 'Toque para ver diretrizes e pontuações.',
            // 5. Aplica a cor dinâmica nos ícones da lista
            iconColor: themeColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReferenceDetailScreen(testName: testName),
                ),
              );
            },
          );
        },
      ),
    );
  }
}