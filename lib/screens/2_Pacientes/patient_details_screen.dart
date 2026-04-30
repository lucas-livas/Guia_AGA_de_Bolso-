// lib/screens/2_Pacientes/patient_details_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Imports do Banco e Modelos
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/medication_data.dart';

// Import do Gerenciador de Temas
import 'package:guia_aga_de_bolso/Temas_Paletas/Temas_Gerenciador.dart';

// Imports de Telas de Edição, Submenus e Visualizador de Avaliação
import 'package:guia_aga_de_bolso/screens/2_Pacientes/add_edit_patient_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Funcional/functional_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Mental/mental_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Clinico/clinical_conditions_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/1_Home/Func_e_Suporte_Social/social_support_submenu_screen.dart';
import 'package:guia_aga_de_bolso/screens/assessment_details_viewer_screen.dart';

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

  // --- NOVAS VARIÁVEIS PARA O MODO DE SELEÇÃO ---
  bool _isSelectionMode = false;
  final Set<int> _selectedAssessmentIds = {};

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

    // Se mudar de aba, cancelamos o modo de seleção por segurança
    if (_isSelectionMode) _cancelSelection();

    setState(() => _selectedIndex = index);
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _onPageChanged(int index) {
    if (_selectedIndex == index) return;
    if (_isSelectionMode) _cancelSelection();
    setState(() => _selectedIndex = index);
  }

  // --- MÉTODOS DO MODO DE SELEÇÃO MULTIPLA ---

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedAssessmentIds.contains(id)) {
        _selectedAssessmentIds.remove(id);
        // Se desmarcou o último, sai do modo de seleção
        if (_selectedAssessmentIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedAssessmentIds.add(id);
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedAssessmentIds.clear();
    });
  }

  void _confirmDeleteAssessments() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Excluir Avaliações?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Tem certeza que deseja excluir as ${_selectedAssessmentIds.length} avaliações selecionadas? Essa ação não pode ser desfeita."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // Fecha o modal

              // DELETA AS AVALIAÇÕES DO BANCO DE DADOS
              // O ideal é criar um método específico no DatabaseHelper para deletar múltiplas avaliações de uma vez, mas aqui faremos em loop por simplicidade.
              for (int id in _selectedAssessmentIds) {
                await DatabaseHelper.instance.deleteAssessment(id);
              }

              // Mostra uma mensagem de sucesso
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Avaliações excluídas com sucesso."), backgroundColor: Colors.red),
              );

              _cancelSelection();
              _loadAssessments(); // Recarrega a lista
            },
            child: const Text("Excluir", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _shareSelectedAssessments() {
    // Como o compartilhamento em PDF requer gerar a interface gráfica de várias avaliações juntas,
    // será necessário criar um método específico no seu PdfService para lidar com uma Lista de Avaliações.

    // Exemplo de como você chamaria (futuramente):
    // PdfService.generateAssessmentsReport(_patient, _selectedAssessmentIds.toList());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("O compartilhamento de avaliações em lote deve ser configurado no PdfService."),
        backgroundColor: Colors.blueGrey,
      ),
    );
    _cancelSelection();
  }

  // --- MENUS E INTERFACE BASE ---

  void _showAddAssessmentMenu(AppTheme theme) {
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
            _menuItem(Icons.directions_walk, "Avaliação Funcional", theme.gradientFunctional.colors.last, () => _pushToSubmenu(const FunctionalSubmenuScreen())),
            _menuItem(Icons.psychology, "Avaliação Cognitiva", theme.gradientCognitive.colors.last, () => _pushToSubmenu(const MentalSubmenuScreen())),
            _menuItem(Icons.medical_services, "Avaliação Clínica", theme.gradientClinical.colors.last, () => _pushToSubmenu(const ClinicalConditionsSubmenuScreen())),
            _menuItem(Icons.people, "Avaliação Socioambiental", theme.gradientSocial.colors.last, () => _pushToSubmenu(const SocialSupportSubmenuScreen())),
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
    return ValueListenableBuilder<AppTheme>(
      valueListenable: ThemeManager().currentThemeNotifier,
      builder: (context, theme, child) {
        return Scaffold(
          backgroundColor: theme.background,

          // APPBAR DINÂMICA: Muda completamente se estamos selecionando itens
          appBar: (_isSelectionMode && _selectedIndex == 1)
          ? AppBar(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: _cancelSelection,
              ),
              title: Text("${_selectedAssessmentIds.length} selecionada(s)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  tooltip: "Compartilhar Selecionadas",
                  onPressed: _shareSelectedAssessments,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  tooltip: "Deletar Selecionadas",
                  onPressed: _confirmDeleteAssessments,
                ),
              ],
            )
          : AppBar(
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
                  icon: Icon(Icons.ios_share_rounded, color: theme.primary, size: 22),
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
              SizedBox(key: const ValueKey('ficha_tab'), child: _buildFichaTab(theme)),
              SizedBox(key: const ValueKey('assessments_tab'), child: _buildAllAssessmentsTab(theme)),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.white,
            selectedItemColor: theme.primary,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), label: "Ficha"),
              BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), label: "Avaliações"),
            ],
          ),

          // ESCONDE O BOTÃO FLUTUANTE DURANTE A SELEÇÃO
          floatingActionButton: _isSelectionMode ? null : FloatingActionButton.extended(
            onPressed: _selectedIndex == 0
              ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditPatientScreen(patient: _patient))).then((_) => _refreshPatientData())
              : () => _showAddAssessmentMenu(theme),
            backgroundColor: theme.primary,
            icon: Icon(_selectedIndex == 0 ? Icons.edit_rounded : Icons.add_rounded, color: Colors.white),
            label: Text(_selectedIndex == 0 ? "Editar Ficha" : "Nova Avaliação", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        );
      }
    );
  }

  // --- ABA 1: FICHA COMPLETA ---
  Widget _buildFichaTab(AppTheme theme) {
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
            _infoLine(Icons.work_rounded, "Ocupação", _patient.occupation, theme),
            _infoLine(Icons.school_rounded, "Escolaridade", _patient.educationLevel, theme),
            _infoLine(Icons.language_rounded, "Nacionalidade", _patient.nationality, theme),
            _infoLine(Icons.location_on_rounded, "Naturalidade", _patient.placeOfBirth, theme),
            _infoLine(Icons.palette_rounded, "Raça / Cor", _patient.race, theme),
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
          const SizedBox(height: 16),
          _buildMedicationsCard(theme),
        ],
      ),
    );
  }

  Widget _buildMedicationsCard(AppTheme theme) {
    List<PrescribedMedication> meds = PrescribedMedication.decodeList(_patient.medicationList);

    return _buildModernCard("MEDICAMENTOS EM USO", [
      if (meds.isEmpty)
        const Text("Nenhum medicamento registrado.", style: TextStyle(fontSize: 13, color: Color(0xFF475569))),

      ...meds.map((med) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medication_rounded, size: 16, color: theme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${med.drugName} ${med.dosage}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4),
              child: Text(
                "Uso: ${med.frequency} • Horário: ${med.time}${med.notes.isNotEmpty ? ' • Obs: ${med.notes}' : ''}",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(height: 10),
          ],
        ),
      )).toList(),
    ]);
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

  Widget _infoLine(IconData icon, String label, String value, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.primary.withOpacity(0.6)),
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

  // --- ABA 2: AVALIAÇÕES ---
  Widget _buildAllAssessmentsTab(AppTheme theme) {
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
            _buildCategoryGroup("FUNCIONAL", list, ['Katz', 'Lawton', 'Berg', 'TUG', 'MIF'], theme.gradientFunctional.colors.last, theme),
            _buildCategoryGroup("COGNITIVA", list, ['MEEM', 'GDS'], theme.gradientCognitive.colors.last, theme),
            _buildCategoryGroup("CLÍNICA", list, ['MNA'], theme.gradientClinical.colors.last, theme),
            _buildCategoryGroup("SOCIOAMBIENTAL", list, ['MOS'], theme.gradientSocial.colors.last, theme),
          ],
        );
      },
    );
  }

  Widget _buildCategoryGroup(String title, List<Assessment> all, List<String> keywords, Color color, AppTheme theme) {
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
        ...filtered.map((a) => _buildAssessmentTile(a, theme)),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAssessmentTile(Assessment a, AppTheme theme) {
    final date = DateTime.tryParse(a.date) ?? DateTime.now();

    // Verifica se esta avaliação específica está selecionada
    final isSelected = _selectedAssessmentIds.contains(a.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        // Altera a cor de fundo e a borda se estiver selecionada
        color: isSelected ? theme.primary.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? theme.primary : const Color(0xFFE2E8F0),
          width: isSelected ? 2 : 1
        ),
      ),
      child: ListTile(
        // Se estivermos no modo seleção, mostra um Checkbox
        leading: _isSelectionMode
            ? Checkbox(
                value: isSelected,
                activeColor: theme.primary,
                onChanged: (bool? value) {
                  _toggleSelection(a.id!);
                },
              )
            : null,
        title: Text(a.testName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text("${DateFormat('dd/MM/yy').format(date)} • Score: ${a.score}"),
        trailing: _isSelectionMode ? null : const Icon(Icons.arrow_forward_ios_rounded, size: 12),

        // Comportamento do Toque Normal
        onTap: () {
          if (_isSelectionMode) {
            // Se já estamos no modo de seleção, tocar na caixa apenas marca/desmarca
            _toggleSelection(a.id!);
          } else {
            // Comportamento padrão: vai para a tela de detalhes da avaliação
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AssessmentDetailsViewerScreen(assessment: a, patient: _patient)),
            );
          }
        },

        // Comportamento do Toque Longo
        onLongPress: () {
          if (!_isSelectionMode) {
            // Entra no modo seleção e marca a primeira
            setState(() {
              _isSelectionMode = true;
              _selectedAssessmentIds.add(a.id!);
            });
          }
        },
      ),
    );
  }
}