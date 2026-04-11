// Arquivo: lib/screens/2_Pacientes/assessment_trash_screen.dart

import 'package:flutter/material.dart';
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

class AssessmentTrashScreen extends StatefulWidget {
  final Patient patient;

  const AssessmentTrashScreen({super.key, required this.patient});

  @override
  State<AssessmentTrashScreen> createState() => _AssessmentTrashScreenState();
}

class _AssessmentTrashScreenState extends State<AssessmentTrashScreen> {
  List<Assessment> _deletedAssessments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrash();
  }

  Future<void> _loadTrash() async {
    final list = await DatabaseHelper.instance.getDeletedAssessmentsForPatient(widget.patient.id!);
    if (mounted) {
      setState(() {
        _deletedAssessments = list;
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

  Future<void> _restore(Assessment assessment) async {
    await DatabaseHelper.instance.restoreAssessment(assessment.id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Avaliação restaurada.'),
        backgroundColor: AssessmentColors.successGreen,
      ));
      _loadTrash();
    }
  }

  Future<void> _hardDelete(Assessment assessment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Avaliação?', style: TextStyle(color: AssessmentColors.errorRed)),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AssessmentColors.errorRed, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.hardDeleteAssessment(assessment.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Avaliação apagada permanentemente.')));
        _loadTrash();
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Lixeira de avaliações vazia', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Lixeira de Avaliações'),
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AssessmentColors.primaryBlue))
          : _deletedAssessments.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _deletedAssessments.length,
                  itemBuilder: (context, index) {
                    final item = _deletedAssessments[index];
                    final days = _calculateDaysRemaining(item.deletedAt);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ListTile(
                        title: Text(item.testName, style: AssessmentTextStyles.itemTitle),
                        subtitle: Text('Score: ${item.score}\nExpira em $days dias', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore, color: AssessmentColors.successGreen),
                              onPressed: () => _restore(item),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_forever, color: AssessmentColors.errorRed),
                              onPressed: () => _hardDelete(item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}