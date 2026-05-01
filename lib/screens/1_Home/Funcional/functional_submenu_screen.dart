import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

import 'package:guia_aga_de_bolso/screens/1_Home/Funcional/lawton_brody_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Funcional/tug_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Funcional/berg_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Funcional/katz_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Funcional/mif_screen.dart';

class FunctionalSubmenuScreen extends StatelessWidget {
  const FunctionalSubmenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extrai a cor do gradiente FUNCIONAL
    final Gradient gradient = AssessmentGradients.functional;
    final Color themeColor = (gradient is LinearGradient) 
        ? gradient.colors.last 
        : AssessmentColors.primaryBlue;

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
        ),
        title: const Text('Estado Funcional'),
        centerTitle: true,
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
      ),
      
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: <Widget>[
          
          AssessmentSubmenuTitle(
            title: 'EQUILÍBRIO E MOBILIDADE',
            color: themeColor,
          ),
          
          AssessmentSubmenuItem(
            icon: Icons.timer_outlined,
            title: 'Timed Up and Go (TUG)',
            subtitle: 'Avalia a mobilidade e o risco de quedas.',
            iconColor: themeColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TugScreen())),
          ),
          
          AssessmentSubmenuItem(
            icon: Icons.balance,
            title: 'Escala de Equilíbrio de Berg (EEB)',
            subtitle: 'Avaliação detalhada do equilíbrio estático e dinâmico.',
            iconColor: themeColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BergScreen())),
          ),

          AssessmentSubmenuTitle(
            title: 'ATIVIDADES DE VIDA DIÁRIA',
            color: themeColor,
          ),

          AssessmentSubmenuItem(
            icon: Icons.accessibility_new,
            title: 'Escala de Lawton-Brody (AIVDs)',
            subtitle: 'Avalia as atividades instrumentais (compras, telefone, etc).',
            iconColor: themeColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LawtonBrodyScreen())),
          ),
          
          AssessmentSubmenuItem(
            icon: Icons.self_improvement,
            title: 'Índice de Katz (AVDs)',
            subtitle: 'Avalia as atividades básicas (banho, vestir, etc).',
            iconColor: themeColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KatzScreen())),
          ),

          AssessmentSubmenuTitle(
            title: 'AVALIAÇÃO GLOBAL',
            color: themeColor,
          ),

          AssessmentSubmenuItem(
            icon: Icons.assessment_outlined,
            title: 'Medida de Independência Funcional (MIF)',
            subtitle: 'Avaliação completa da funcionalidade em 18 itens.',
            iconColor: themeColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FimScreen())),
          ),
        ],
      ),
    );
  }
}