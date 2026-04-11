// lib/screens/2_Pacientes/patient_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Imports do Banco e Modelos
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';

// Imports de Telas de Edição e Submenus
import 'package:guia_aga_de_bolso/screens/2_Pacientes/add_edit_patient_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Funcional/functional_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Mental/mental_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Clinico/clinical_conditions_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Func_e_Suporte_Social/social_support_submenu_screen.dart';

// Design System e Serviços
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';
import 'package:guia_aga_de_bolso/services/pdf_service.dart' show PdfService;

class PatientDetailsScreen extends StatefulWidget {
  final Patient initialPatient;
  const PatientDetailsScreen({super.key, required this.initialPatient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  late Patient _patient;
  late Future<List<Assessment>> _assessmentsFuture;
  int _selectedIndex = 0;
  late final PageController _pageController;
  

  @override
  void initState() {
    super.initState();
    _patient = widget.initialPatient;
    _loadAssessments();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadAssessments() {
    setState(() {
      _assessmentsFuture = DatabaseHelper.instance.getAssessmentsForPatient(_patient.id!);
    });
  }

  Future<void> _refreshPatientData() async {
    final updatedPatient = await DatabaseHelper.instance.getPatientById(_patient.id!);
    if (updatedPatient != null) {
      setState(() => _patient = updatedPatient);
    }
    _loadAssessments();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onPageChanged(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
  }

  void _showAddAssessmentMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("SELECIONE A DIMENSÃO", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF64748B), fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 15),
            _menuItem(Icons.directions_walk, "Avaliação Funcional", const Color(0xFF10B981), () => _pushToSubmenu(const FunctionalSubmenuScreen())),
            _menuItem(Icons.psychology, "Avaliação Cognitiva", const Color(0xFF8B5CF6), () => _pushToSubmenu(const MentalSubmenuScreen())),
            _menuItem(Icons.medical_services, "Avaliação Clínica", const Color(0xFFEF4444), () => _pushToSubmenu(const ClinicalConditionsSubmenuScreen())),
            _menuItem(Icons.people, "Avaliação Socioambiental", const Color(0xFFF59E0B), () => _pushToSubmenu(const SocialSupportSubmenuScreen())),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      onTap: onTap,
    );
  }

  void _pushToSubmenu(Widget submenu) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => submenu)).then((_) => _loadAssessments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        title: Column(
          children: [
            Text(_patient.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Prontuário AGA', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: Color(0xFF2563EB), size: 22),
            onPressed: () => PdfService.generatePatientRecord(_patient),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(key: const ValueKey('ficha_tab'), child: _buildFichaTab()),
          SizedBox(key: const ValueKey('assessments_tab'), child: _buildAllAssessmentsTab()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2563EB),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), label: "Ficha"),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Avaliações"),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedIndex == 0 
          ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditPatientScreen(patient: _patient))).then((_) => _refreshPatientData())
          : _showAddAssessmentMenu,
        backgroundColor: const Color(0xFF1E293B),
        icon: Icon(_selectedIndex == 0 ? Icons.edit_rounded : Icons.add_rounded, color: Colors.white),
        label: Text(_selectedIndex == 0 ? "Editar Ficha" : "Nova Avaliação", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- ABA 1: FICHA COMPLETA (DADOS + COMPLEMENTARES + ANAMNESE) ---
  Widget _buildFichaTab() {
    return SingleChildScrollView(
      key: const PageStorageKey('ficha_scroll'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      child: Column(
        children: [
          PatientIdentityCard(
            name: _patient.name,
            birthDate: _patient.birthDate,
            gender: _patient.gender,
            maritalStatus: _patient.maritalStatus,
            emergencyContact: _patient.emergencyContact,
          ),
          const SizedBox(height: 16),
          _buildModernCard("DADOS COMPLEMENTARES", [
            _infoLine(Icons.work_rounded, "Ocupação", _patient.occupation),
            _infoLine(Icons.school_rounded, "Escolaridade", _patient.educationLevel),
            _infoLine(Icons.language_rounded, "Nacionalidade", _patient.nationality),
            _infoLine(Icons.location_on_rounded, "Naturalidade", _patient.placeOfBirth),
            _infoLine(Icons.palette_rounded, "Raça / Cor", _patient.race),
          ]),
          const SizedBox(height: 16),
          _buildModernCard("ANAMNESE E HISTÓRIA CLÍNICA", [
            _anamneseBlock("Queixa Principal (QP)", _patient.chiefComplaint),
            _anamneseBlock("História da Doença Atual (HDA)", _patient.hda),
            _anamneseBlock("Histórico Médico Pregresso (HMP)", _patient.pastMedicalHistory),
            _anamneseBlock("Histórias Social e Familiar", _patient.socialHistory),
            _anamneseBlock("Ambiente Domiciliar", _patient.homeEnvironment),
            _anamneseBlock("Outras Observações", _patient.notes),
          ]),
        ],
      ),
    );
  }

  Widget _buildModernCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF64748B), fontSize: 11, letterSpacing: 1.1)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value.isEmpty ? "---" : value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _anamneseBlock(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          const SizedBox(height: 4),
          Text(content.isEmpty ? "Nada consta." : content, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
          const Divider(height: 20),
        ],
      ),
    );
  }

  // --- ABA 2: AVALIAÇÕES COM DIVISÃO POR CATEGORIA ---
  Widget _buildAllAssessmentsTab() {
    return FutureBuilder<List<Assessment>>(
      future: _assessmentsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        
        final list = snapshot.data!;
        if (list.isEmpty) return const Center(child: Text("Nenhuma avaliação registrada."));

        return ListView(
          key: const PageStorageKey('assessments_list'),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
          children: [
            _buildCategoryGroup("FUNCIONAL", list, ['Katz', 'Lawton', 'Berg', 'TUG'], const Color(0xFF10B981)),
            _buildCategoryGroup("COGNITIVA", list, ['MEEM', 'GDS'], const Color(0xFF8B5CF6)),
            _buildCategoryGroup("CLÍNICA", list, ['MNA'], const Color(0xFFEF4444)),
            _buildCategoryGroup("SOCIOAMBIENTAL", list, ['MOS'], const Color(0xFFF59E0B)),
          ],
        );
      },
    );
  }

  Widget _buildCategoryGroup(String title, List<Assessment> all, List<String> keywords, Color color) {
    final filtered = all.where((a) => keywords.any((k) => a.testName.contains(k))).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color, letterSpacing: 1.1)),
            ],
          ),
        ),
        ...filtered.map((a) => _buildAssessmentTile(a)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAssessmentTile(Assessment a) {
    final date = DateTime.tryParse(a.date) ?? DateTime.now();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: ListTile(
        title: Text(a.testName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("${DateFormat('dd/MM/yy').format(date)} • Score: ${a.score}"),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
        onTap: () { /* Ver Detalhes */ },
      ),
    );
  }
}