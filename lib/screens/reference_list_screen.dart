import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// Importações de dados e telas
import 'package:guia_aga_de_bolso/data/reference_data.dart';
import 'package:guia_aga_de_bolso/screens/reference_detail_screen.dart';

class ReferenceListScreen extends StatelessWidget {
  const ReferenceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final testNames = referenceData.keys.toList();
    
    // Cor temática: Teal (para combinar com o botão "Guias" da Home)
    const Color themeColor = Color(0xFF009688);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guias e Referências'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black, // Contraste na AppBar branca
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: AssessmentColors.backgroundLight,
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        // Adicionamos +1 ao itemCount para incluir o título da seção
        itemCount: testNames.length + 1,
        itemBuilder: (context, index) {
          
          // Item 0 é o Título da Seção
          if (index == 0) {
            return const AssessmentSubmenuTitle(
              title: 'BIBLIOTECA DE ESCALAS',
              color: themeColor,
            );
          }

          // Ajustamos o índice para pegar o item correto da lista (index - 1)
          final testName = testNames[index - 1];

          return AssessmentSubmenuItem(
            icon: Icons.menu_book_outlined, // Ícone genérico de livro/guia
            title: testName,
            subtitle: 'Toque para ver diretrizes e pontuações.',
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