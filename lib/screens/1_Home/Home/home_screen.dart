import 'package:flutter/material.dart';

// --- Imports do Projeto ---
import 'package:guia_aga_de_bolso/Temas_Paletas/Temas_Gerenciador.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';
import 'package:guia_aga_de_bolso/widgets/side_menu_drawer.dart';

// --- Imports de Telas ---
import 'package:guia_aga_de_bolso/screens/2_Pacientes/patient_list_screen.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/add_edit_patient_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Funcional/functional_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Mental/mental_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Clinico/clinical_conditions_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/social_support/social_support_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Referencias/reference_list_screen.dart';

// --- Modelo de Dados de Navegação ---
class NavItem {
  final IconData icon;
  final String label;
  final Widget destination;
  final Gradient Function() gradientBuilder;

  const NavItem({
    required this.icon,
    required this.label,
    required this.destination,
    required this.gradientBuilder,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- Itens do Menu ---
  final List<NavItem> _menuItems = [
    // Índice 0
    NavItem(
      icon: Icons.assignment_outlined,
      label: 'Fichas de Pacientes',
      destination: const PatientListScreen(),
      gradientBuilder: () => AssessmentGradients.patient
    ),
    // Índice 1
    NavItem(
      icon: Icons.group_add_outlined,
      label: 'Adicionar Paciente',
      destination: const AddEditPatientScreen(),
      gradientBuilder: () => AssessmentGradients.patient
    ),
    // Índice 2
    NavItem(
      icon: Icons.directions_run,
      label: 'FUNCIONAL',
      destination: const FunctionalSubmenuScreen(),
      gradientBuilder: () => AssessmentGradients.functional
    ),
    // Índice 3
    NavItem(
      icon: Icons.psychology_outlined,
      label: 'SAÚDE MENTAL',
      destination: const MentalSubmenuScreen(),
      gradientBuilder: () => AssessmentGradients.cognitive
    ),
    // Índice 4
    NavItem(
      icon: Icons.medical_services_outlined,
      label: 'CLÍNICO',
      destination: const ClinicalConditionsSubmenuScreen(),
      gradientBuilder: () => AssessmentGradients.clinical
    ),
    // Índice 5
    NavItem(
      icon: Icons.group_outlined,
      label: 'SUPORTE SOCIAL',
      destination: const SocialSupportSubmenuScreen(),
      gradientBuilder: () => AssessmentGradients.social
    ),
    // Índice 6
    NavItem(
      icon: Icons.menu_book_outlined,
      label: 'GUIAS & REFERÊNCIAS',
      destination: const ReferenceListScreen(),
      gradientBuilder: () => AssessmentGradients.guides
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/logo_aga.png'), context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // --- Lógica de Negócio ---
  void _navigateTo(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  // --- Construção da UI ---
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppTheme>(
      valueListenable: ThemeManager().currentThemeNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          backgroundColor: AssessmentColors.backgroundLight,
          appBar: _buildAppBar(),
          drawer: const SideMenuDrawer(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Botão 0: Fichas de Pacientes (-wide)
                _buildAnimatedCard(0, _navCardFactory(0, wide: true)),
                const SizedBox(height: 16),

                // Botão 1: Adicionar Paciente (wide)
                _buildAnimatedCard(1, _navCardFactory(1, wide: true)),

                const SizedBox(height: 24),

                const SizedBox(height: 24),
                const AssessmentSectionHeader(title: 'DIMENSÕES DA AVALIAÇÃO'),
                const SizedBox(height: 16),
                _buildGridRow(2, 3),
                const SizedBox(height: 16),
                _buildGridRow(4, 5),

                const SizedBox(height: 24),
                _buildAnimatedCard(6, _navCardFactory(6, wide: true)),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AssessmentColors.backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: AssessmentColors.textPrimary),
      centerTitle: true,
      title: Image.asset(
        "assets/images/logo_aga.png",
        height: 60,
        errorBuilder: (_, __, ___) => Text(
          "Guia AGA",
          style: TextStyle(color: AssessmentColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


  Widget _buildGridRow(int idx1, int idx2) {
    return Row(
      children: [
        Expanded(child: _buildAnimatedCard(idx1, _navCardFactory(idx1))),
        const SizedBox(width: 16),
        Expanded(child: _buildAnimatedCard(idx2, _navCardFactory(idx2))),
      ],
    );
  }

  Widget _navCardFactory(int index, {bool wide = false}) {
    final item = _menuItems[index];
    final currentGradient = item.gradientBuilder();

    if (wide) {
      return AssessmentWideNavCard(
        label: item.label,
        icon: item.icon,
        gradient: currentGradient,
        onTap: () => _navigateTo(item.destination),
      );
    }
    return AssessmentSquareNavCard(
      label: item.label,
      icon: item.icon,
      gradient: currentGradient,
      onTap: () => _navigateTo(item.destination),
    );
  }

  Widget _buildAnimatedCard(int index, Widget card) {
    return card;
  }
}

