import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// --- Imports do Projeto ---
import 'package:guia_aga_de_bolso/Temas_Paletas/Temas_Gerenciador.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';
import 'package:guia_aga_de_bolso/widgets/side_menu_drawer.dart';

// --- Imports de Telas ---
import 'package:guia_aga_de_bolso/screens/2_Pacientes/patient_list_screen.dart';
// NOVO: Importamos a tela de adicionar paciente
import 'package:guia_aga_de_bolso/screens/2_Pacientes/add_edit_patient_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Funcional/functional_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Mental/mental_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Clinico/clinical_conditions_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Func_e_Suporte_Social/social_support_submenu_screen.dart';
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
  // --- Configurações ---
  static const bool _adsEnabled = false;
  static const String _adUnitId = 'ca-app-pub-3940256099942544/9214589741';

  // --- Estado ---
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  // --- Itens do Menu ---
  // ATENÇÃO: Os índices (posições) mudaram porque inserimos um novo item na posição 1.
  final List<NavItem> _menuItems = [
    // Índice 0
    NavItem(
      icon: Icons.assignment_outlined,
      label: 'Fichas de Pacientes',
      destination: const PatientListScreen(),
      gradientBuilder: () => AssessmentGradients.patient
    ),
    // Índice 1 - NOVO BOTÃO ADICIONADO AQUI
    NavItem(
      icon: Icons.group_add_outlined,
      label: 'Adicionar Paciente',
      destination: const AddEditPatientScreen(),
      gradientBuilder: () => AssessmentGradients.patient // Mantivemos o gradiente de paciente
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
      label: 'COGNIÇÃO',
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
      label: 'SÓCIO AMBIENTAL',
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
    if (_adsEnabled) _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  // --- Lógica de Negócio ---
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) { if (mounted) setState(() => _isBannerAdLoaded = true); },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('Erro no AdMob: $error');
        },
      ),
    )..load();
  }

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
          body: Column(
            children: [
              Expanded(child: _buildMainContent()),
              _buildAdFooter(),
            ],
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

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Botão 0: Fichas de Pacientes
          _buildAnimatedCard(0, _navCardFactory(0, wide: true)),

          const SizedBox(height: 16), // Novo espaçamento para separar os botões

          // Botão 1: Novo botão "Adicionar Paciente" (também usamos a versão 'wide' - larga)
          _buildAnimatedCard(1, _navCardFactory(1, wide: true)),

          const SizedBox(height: 24),
          const AssessmentSectionHeader(title: 'DIMENSÕES DA AVALIAÇÃO'),
          const SizedBox(height: 16),

          // Lembre-se: os números foram ajustados (+1) por conta da nova adição
          _buildGridRow(2, 3), // Antes era 1 e 2 (Funcional e Cognitivo)
          const SizedBox(height: 16),
          _buildGridRow(4, 5), // Antes era 3 e 4 (Clínico e Sócio Ambiental)

          const SizedBox(height: 24),

          // Botão 6: Guias e Referências (Antes era o índice 5)
          _buildAnimatedCard(6, _navCardFactory(6, wide: true)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAdFooter() {
    if (!_adsEnabled || !_isBannerAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SafeArea(
      top: false,
      child: SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
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

  Widget _buildAnimatedCard(int index, Widget child) {
    return StaggeredAnimated(
      delay: Duration(milliseconds: 300 + index * 100),
      child: child,
    );
  }
}

class StaggeredAnimated extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const StaggeredAnimated({super.key, required this.child, this.delay = Duration.zero});

  @override
  State<StaggeredAnimated> createState() => _StaggeredAnimatedState();
}

class _StaggeredAnimatedState extends State<StaggeredAnimated> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  late final Animation<Offset> _offset = Tween(begin: const Offset(0, 0.15), end: Offset.zero).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
  late final Animation<double> _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}