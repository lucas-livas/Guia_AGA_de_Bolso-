import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatar datas
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Listas de dados
  List<Patient> _deletedPatients = [];
  List<Map<String, dynamic>> _deletedAssessments = []; // Mapa contendo dados da avaliação + nome do paciente
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeTrash();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeTrash() async {
    setState(() => _isLoading = true);
    // Limpeza automática dos 90 dias
    await DatabaseHelper.instance.cleanupOldData();
    // Carrega dados
    await _loadData();
  }

  Future<void> _loadData() async {
    final patients = await DatabaseHelper.instance.queryDeletedRows();
    final assessments = await DatabaseHelper.instance.getAllDeletedAssessmentsWithPatientName();
    
    if (mounted) {
      setState(() {
        _deletedPatients = patients;
        _deletedAssessments = assessments;
        _isLoading = false;
      });
    }
  }

  int _calculateDaysRemaining(String? deletedAtIso) {
    if (deletedAtIso == null) return 0;
    final deletedDate = DateTime.parse(deletedAtIso);
    final expiryDate = deletedDate.add(const Duration(days: 90));
    final now = DateTime.now();
    final diff = expiryDate.difference(now).inDays;
    return diff < 0 ? 0 : diff;
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return '-';
    }
  }

  // --- AÇÕES DE PACIENTE ---

  Future<void> _restorePatient(Patient patient) async {
    await DatabaseHelper.instance.restorePatient(patient.id!);
    _showSnack('Paciente ${patient.name} restaurado.', AssessmentColors.successGreen);
    _loadData();
  }

  Future<void> _hardDeletePatient(Patient patient) async {
    final confirm = await _showConfirmDialog(
      'Excluir Paciente?', 
      'Deseja apagar definitivamente ${patient.name}? Todas as avaliações dele também serão apagadas.'
    );
    if (confirm) {
      await DatabaseHelper.instance.hardDelete(patient.id!);
      _showSnack('Paciente apagado permanentemente.', AssessmentColors.textPrimary);
      _loadData();
    }
  }

  // --- AÇÕES DE AVALIAÇÃO ---

  Future<void> _restoreAssessment(int id, String testName) async {
    await DatabaseHelper.instance.restoreAssessment(id);
    _showSnack('Avaliação "$testName" restaurada.', AssessmentColors.successGreen);
    _loadData();
  }

  Future<void> _hardDeleteAssessment(int id) async {
    final confirm = await _showConfirmDialog('Excluir Avaliação?', 'Esta ação não pode ser desfeita.');
    if (confirm) {
      await DatabaseHelper.instance.hardDeleteAssessment(id);
      _showSnack('Avaliação apagada permanentemente.', AssessmentColors.textPrimary);
      _loadData();
    }
  }

  // --- HELPERS UI ---

  Future<bool> _showConfirmDialog(String title, String content) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(color: AssessmentColors.errorRed)),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AssessmentColors.errorRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- LISTAS ---

  Widget _buildPatientsList() {
    if (_deletedPatients.isEmpty) return _buildEmptyState('Nenhum paciente na lixeira');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deletedPatients.length,
      itemBuilder: (context, index) {
        final patient = _deletedPatients[index];
        final days = _calculateDaysRemaining(patient.deletedAt);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey.shade100,
              child: const Icon(Icons.person_off, color: Colors.grey),
            ),
            title: Text(patient.name, style: AssessmentTextStyles.itemTitle),
            subtitle: Text('Expira em $days dias', style: const TextStyle(fontSize: 12, color: AssessmentColors.errorRed)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.restore, color: AssessmentColors.successGreen), onPressed: () => _restorePatient(patient)),
                IconButton(icon: Icon(Icons.delete_forever, color: AssessmentColors.errorRed), onPressed: () => _hardDeletePatient(patient)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssessmentsList() {
    if (_deletedAssessments.isEmpty) return _buildEmptyState('Nenhuma avaliação na lixeira');

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _deletedAssessments.length,
      itemBuilder: (context, index) {
        final item = _deletedAssessments[index];
        // Convertendo o Map de volta para objeto Assessment para facilitar
        final assessment = Assessment.fromMap(item);
        final patientName = item['patient_name'] ?? 'Desconhecido';
        final days = _calculateDaysRemaining(assessment.deletedAt);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AssessmentColors.lightBlue.withOpacity(0.2),
              child: Icon(Icons.assignment, color: AssessmentColors.primaryBlue),
            ),
            title: Text(assessment.testName, style: AssessmentTextStyles.itemTitle),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paciente: $patientName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('Data: ${_formatDate(assessment.date)} • Expira em $days dias', style: const TextStyle(fontSize: 11, color: AssessmentColors.errorRed)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.restore, color: AssessmentColors.successGreen), onPressed: () => _restoreAssessment(assessment.id!, assessment.testName)),
                IconButton(icon: Icon(Icons.delete_forever, color: AssessmentColors.errorRed), onPressed: () => _hardDeleteAssessment(assessment.id!)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Lixeira'),
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AssessmentColors.primaryBlue,
          unselectedLabelColor: AssessmentColors.textSecondary,
          indicatorColor: AssessmentColors.primaryBlue,
          tabs: const [
            Tab(text: 'Fichas de Pacientes', icon: Icon(Icons.person_remove_outlined)),
            Tab(text: 'Avaliações', icon: Icon(Icons.assessment_outlined)),
          ],
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AssessmentColors.primaryBlue))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildPatientsList(),
              _buildAssessmentsList(),
            ],
          ),
    );
  }
}