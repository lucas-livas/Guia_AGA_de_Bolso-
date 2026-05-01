import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// Importação das telas de destino
import 'package:guia_aga_de_bolso/screens/1_Home/Mental/meem_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Mental/gds15_screen.dart';

class MentalSubmenuScreen extends StatelessWidget {
  const MentalSubmenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO INTELIGENTE:
    // Em vez de pegar a cor do tema global, pegamos a cor do GRADIENTE DE COGNIÇÃO.
    // Assim, se o botão na home é Laranja/Roxo, aqui será Laranja/Roxo.
    final Gradient gradient = AssessmentGradients.cognitive;
    final Color themeColor = (gradient is LinearGradient) 
        ? gradient.colors.last // Pega a cor mais forte do gradiente
        : AssessmentColors.primaryBlue;

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: const Text('Saúde Mental'),
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: <Widget>[
          
          AssessmentSubmenuTitle(
            title: 'RASTREIO DE HUMOR',
            color: themeColor, // Usa a cor específica da categoria
          ),
          
          AssessmentSubmenuItem(
            icon: Icons.sentiment_dissatisfied_outlined,
            title: 'Escala de Depressão Geriátrica (GDS-15)',
            subtitle: 'Rastreio de sintomas depressivos.',
            iconColor: themeColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Gds15Screen()),
              );
            },
          ),
          
          AssessmentSubmenuTitle(
            title: 'RASTREIO COGNITIVO',
            color: themeColor,
          ),

          AssessmentSubmenuItem(
            icon: Icons.psychology_outlined,
            title: 'Mini-Exame do Estado Mental (MEEM)',
            subtitle: 'Avaliação rápida das funções cognitivas.',
            iconColor: themeColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MeemScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}