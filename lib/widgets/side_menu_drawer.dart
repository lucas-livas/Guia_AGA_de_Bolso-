import 'package:flutter/material.dart';
// IMPORTS CORRIGIDOS:
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';
import 'package:guia_aga_de_bolso/screens/3_Configuracoes/theme_selection_screen.dart';
// IMPORTAÇÃO DA NOVA TELA DE LIXEIRA
import 'package:guia_aga_de_bolso/screens/3_Configuracoes/trash_screen.dart'; 

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AssessmentColors.backgroundLight,
      surfaceTintColor: AssessmentColors.backgroundLight,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 30),
            decoration: BoxDecoration(
              color: AssessmentColors.primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.health_and_safety, size: 45, color: Colors.grey),
                ),
                SizedBox(height: 15),
                Text(
                  "Guia AGA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Menu Principal",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildMenuItem(
            context,
            icon: Icons.palette_outlined,
            text: 'Paleta de Cores',
            onTap: () {
              Navigator.pop(context); // Fecha o menu
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ThemeSelectionScreen()),
              );
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.delete_outline,
            text: 'Lixeira',
            onTap: () {
              Navigator.pop(context); // Fecha o menu
              // --- CORREÇÃO AQUI: Navegar para a TrashScreen ---
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrashScreen()),
              );
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.headset_mic_outlined,
            text: 'SAC',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidade "SAC" em breve.')),
              );
            },
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 16, color: AssessmentColors.textDisabled),
                const SizedBox(width: 8),
                Text(
                  "Versão 1.1.0",
                  style: TextStyle(color: AssessmentColors.textDisabled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AssessmentColors.primaryBlue),
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AssessmentColors.textPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: AssessmentColors.textDisabled),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}