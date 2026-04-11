import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Clinico/mna_screen.dart';

class ClinicalConditionsSubmenuScreen extends StatelessWidget {
  const ClinicalConditionsSubmenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extrai a cor do gradiente CLÍNICO
    final Gradient gradient = AssessmentGradients.clinical;
    final Color themeColor = (gradient is LinearGradient) 
        ? gradient.colors.last 
        : AssessmentColors.primaryBlue;

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      
      appBar: AppBar(
        title: const Text('Condições Clínicas'),
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary, 
        elevation: 0,
        centerTitle: true,
      ),
      
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: <Widget>[
          
          AssessmentSubmenuTitle(
            title: 'NUTRIÇÃO',
            color: themeColor,
          ),

          AssessmentSubmenuItem(
            icon: Icons.restaurant_menu,
            title: 'Mini Avaliação Nutricional (MAN)',
            subtitle: 'Rastreio de risco nutricional e dietético.',
            iconColor: themeColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MnaScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}