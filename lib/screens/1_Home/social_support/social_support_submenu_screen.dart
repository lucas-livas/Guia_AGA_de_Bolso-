import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/social_support/mos_social_support_screen.dart';

class SocialSupportSubmenuScreen extends StatelessWidget {
  const SocialSupportSubmenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Extrai a cor do gradiente SOCIAL (Amarelo/Dourado)
    final Gradient gradient = AssessmentGradients.social;
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
        title: const Text('Suporte Social'),
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: <Widget>[
          
          AssessmentSubmenuTitle(
            title: 'AVALIAÇÃO DE SUPORTE',
            color: themeColor,
          ),

          AssessmentSubmenuItem(
            icon: Icons.people_outline,
            title: 'MOS Social Support Survey',
            subtitle: 'Avalia a percepção do suporte social e interação.',
            iconColor: themeColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MosSocialSupportScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}