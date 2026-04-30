import 'dart:convert';
import 'package:flutter/material.dart';

// Importações do Projeto
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/select_patient_screen.dart';
// IMPORTAÇÃO DO DESIGN SYSTEM
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

import 'package:guia_aga_de_bolso/data/assessment_items/berg_items.dart';
import 'package:guia_aga_de_bolso/services/assessment/calculation/berg_calculation_service.dart';

// --- Tela Principal ---
class BergScreen extends StatefulWidget {
  const BergScreen({super.key});

  @override
  State<BergScreen> createState() => _BergScreenState();
}

class _BergScreenState extends State<BergScreen> {
  // --- Controllers ---
  final Map<int, AnswerOption> _answers = {};
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // --- State Management ---
  late final List<GlobalKey> _itemKeys;
  late final List<ExpansibleController> _controllers;
  bool _isSaving = false;
  late final Color _sectionColor;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(bergBalanceItems.length, (_) => GlobalKey());
    _controllers = List.generate(bergBalanceItems.length, (_) => ExpansibleController());
    _sectionColor = _getSectionColor();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Helpers ---
  Color _getSectionColor() {
    final gradient = AssessmentGradients.functional;
    if (gradient is LinearGradient) {
      return gradient.colors.last;
    }
    return AssessmentColors.successGreen;
  }

  // --- Lógica de Estado ---
  int get _currentScore => BergCalculationService.calculateScore(_answers);
  int get _answeredCount => _answers.length;
  bool get _isComplete => _answeredCount == bergBalanceItems.length;

  // --- Lógica de Acordeão ---
  void _handleExpansion(int index, bool isExpanded) {
    if (isExpanded) {
      for (int i = 0; i < _controllers.length; i++) {
        if (i != index && _controllers[i].isExpanded) {
          _controllers[i].collapse();
        }
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_itemKeys[index].currentContext != null) {
          Scrollable.ensureVisible(
            _itemKeys[index].currentContext!,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      });
    }
  }

  void _resetTest() {
    setState(() {
      _answers.clear();
      _notesController.clear();
    });
    
    for (var controller in _controllers) {
      if (controller.isExpanded) controller.collapse();
    }
    
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // --- Lógica de Salvar ---
  Future<void> _saveAssessment() async {
    if (!_isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Responda a todas as 14 questões antes de salvar.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final selectedPatient = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectPatientScreen()),
    );

    if (selectedPatient != null && selectedPatient is Patient) {
      await _savePatientAssessment(selectedPatient);
    }
    
    if (mounted) setState(() => _isSaving = false);
  }

  Future<void> _savePatientAssessment(Patient patient) async {
    final List<Map<String, dynamic>> detailedAnswers = [];
    
    for (int i = 0; i < bergBalanceItems.length; i++) {
      final answer = _answers[i];
      detailedAnswers.add({
        'task': bergBalanceItems[i].task,
        'score': answer?.points ?? 0,
        'level': answer?.text ?? 'Não respondido',
      });
    }
    
    final notesMap = {
      'detailed_answers': detailedAnswers,
      'physio_notes': _notesController.text.isNotEmpty ? _notesController.text : null,
    };

    final assessment = Assessment(
      patientId: patient.id!,
      testName: 'Escala de Equilíbrio de Berg',
      score: '$_currentScore / ${BergCalculationService.maxScore}',
      interpretation: BergCalculationService.getInterpretation(_currentScore),
      date: DateTime.now().toIso8601String(),
      notes: jsonEncode(notesMap),
    );

    await DatabaseHelper.instance.insertAssessment(assessment);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Salvo para ${patient.name}'),
          backgroundColor: AssessmentColors.successGreen,
        ),
      );
      Navigator.pop(context);
    }
  }

  // --- Widget Builders ---
  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AssessmentProgressIndicator(
            current: _answeredCount,
            total: bergBalanceItems.length,
            label: 'Progresso do Teste',
            color: _sectionColor,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Pontuação Parcial:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              Text(
                '$_currentScore / ${BergCalculationService.maxScore}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _sectionColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 80),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Observações Gerais (Opcional)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _sectionColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildScoreBadge(int points) {
    Color badgeColor;
    if (points >= 3) {
      badgeColor = AssessmentColors.successGreen;
    } else if (points >= 1) {
      badgeColor = AssessmentColors.warningOrange;
    } else {
      badgeColor = AssessmentColors.errorRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$points pts',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: badgeColor,
          fontSize: 11,
        ),
      ),
    );
  }

  List<Widget> _buildRadioOptions(List<AnswerOption> options, AnswerOption? selectedOption) {
    return options.map((option) {
      return Theme(
        data: Theme.of(context).copyWith(
          radioTheme: RadioThemeData(
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return _sectionColor;
              }
              return null;
            }),
          ),
        ),
        child: AssessmentRadioItem<AnswerOption>(
          title: option.text,
          value: option,
          groupValue: selectedOption,
          onChanged: (val) {
            if (val != null) {
              setState(() {
                // Encontra o índice correspondente
                for (int i = 0; i < bergBalanceItems.length; i++) {
                  if (bergBalanceItems[i].options.contains(val)) {
                    _answers[i] = val;
                    break;
                  }
                }
              });
            }
          },
        ),
      );
    }).toList();
  }

  Widget _buildBergItem(int index, BergItem item) {
    final selectedOption = _answers[index];
    final isAnswered = selectedOption != null;

    return AssessmentSection(
      expansionTileKey: _itemKeys[index],
      controller: _controllers[index],
      title: item.task,
      onExpansionChanged: (isExpanded) => _handleExpansion(index, isExpanded),
      trailing: isAnswered ? _buildScoreBadge(selectedOption.points) : null,
      initiallyExpanded: index == 0 && _answeredCount == 0,
      children: _buildRadioOptions(item.options, selectedOption),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Escala de Equilíbrio de Berg'),
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _sectionColor),
            onPressed: _resetTest,
            tooltip: 'Reiniciar',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressSection(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: bergBalanceItems.length + 1,
              itemBuilder: (context, index) {
                if (index < bergBalanceItems.length) {
                  return _buildBergItem(index, bergBalanceItems[index]);
                } else {
                  return _buildNotesField();
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveAssessment,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isComplete ? _sectionColor : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: _isComplete ? 2 : 0,
          ),
          icon: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(
            _isSaving ? 'SALVANDO...' : (_isComplete ? 'FINALIZAR E SALVAR' : 'Complete todos os itens'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}