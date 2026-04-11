import 'dart:convert';
import 'package:flutter/material.dart';

// Importações do Projeto
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/select_patient_screen.dart';
// IMPORTAÇÃO DO DESIGN SYSTEM
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// --- Modelos Locais ---
class AnswerOption {
  final String text;
  final int points;
  const AnswerOption({required this.text, required this.points});
}

class BergItem {
  final String task;
  final List<AnswerOption> options;
  const BergItem({required this.task, required this.options});
}

// --- Lista de Perguntas (Completa) ---
const List<BergItem> bergBalanceItems = [
  BergItem(task: '1. Levantar-se de uma cadeira', options: [
    AnswerOption(text: '(4) Capaz de levantar sem usar as mãos e estabilizar-se independentemente.', points: 4),
    AnswerOption(text: '(3) Capaz de levantar independentemente usando as mãos.', points: 3),
    AnswerOption(text: '(2) Capaz de levantar usando as mãos após várias tentativas.', points: 2),
    AnswerOption(text: '(1) Necessita de ajuda mínima para levantar ou estabilizar-se.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda moderada ou máxima para levantar.', points: 0),
  ]),
  BergItem(task: '2. Permanecer em pé sem apoio', options: [
    AnswerOption(text: '(4) Capaz de permanecer em pé por 2 minutos com segurança.', points: 4),
    AnswerOption(text: '(3) Capaz de permanecer em pé por 2 minutos com supervisão.', points: 3),
    AnswerOption(text: '(2) Capaz de permanecer em pé por 30 segundos sem apoio.', points: 2),
    AnswerOption(text: '(1) Necessita de várias tentativas para permanecer em pé por 30 seg.', points: 1),
    AnswerOption(text: '(0) Incapaz de permanecer em pé por 30 segundos sem ajuda.', points: 0),
  ]),
  BergItem(task: '3. Permanecer sentado sem apoio nas costas', options: [
    AnswerOption(text: '(4) Capaz de sentar-se com segurança por 2 minutos.', points: 4),
    AnswerOption(text: '(3) Capaz de sentar-se por 2 minutos com supervisão.', points: 3),
    AnswerOption(text: '(2) Capaz de sentar-se por 30 segundos.', points: 2),
    AnswerOption(text: '(1) Capaz de sentar-se por 10 segundos.', points: 1),
    AnswerOption(text: '(0) Incapaz de sentar-se sem apoio por 10 segundos.', points: 0),
  ]),
  BergItem(task: '4. Sentar-se a partir da posição em pé', options: [
    AnswerOption(text: '(4) Senta-se com segurança com uso mínimo das mãos.', points: 4),
    AnswerOption(text: '(3) Controla a descida usando as mãos.', points: 3),
    AnswerOption(text: '(2) Usa a parte de trás das pernas contra a cadeira para controlar.', points: 2),
    AnswerOption(text: '(1) Senta-se independentemente, mas tem descida descontrolada.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para sentar-se.', points: 0),
  ]),
  BergItem(task: '5. Transferências', options: [
    AnswerOption(text: '(4) Capaz de transferir-se com segurança com uso mínimo das mãos.', points: 4),
    AnswerOption(text: '(3) Capaz de transferir-se com segurança com uso das mãos.', points: 3),
    AnswerOption(text: '(2) Capaz de transferir-se com indicações verbais e/ou supervisão.', points: 2),
    AnswerOption(text: '(1) Necessita de uma pessoa para ajudar.', points: 1),
    AnswerOption(text: '(0) Necessita de duas pessoas para ajudar ou supervisão.', points: 0),
  ]),
  BergItem(task: '6. Permanecer em pé sem apoio e com os olhos fechados', options: [
    AnswerOption(text: '(4) Capaz de permanecer em pé por 10 segundos com segurança.', points: 4),
    AnswerOption(text: '(3) Capaz de permanecer em pé por 10 segundos com supervisão.', points: 3),
    AnswerOption(text: '(2) Capaz de permanecer em pé por 3 segundos.', points: 2),
    AnswerOption(text: '(1) Incapaz de manter olhos fechados por 3s, mas fica em pé.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para não cair.', points: 0),
  ]),
  BergItem(task: '7. Permanecer em pé sem apoio com os pés juntos', options: [
    AnswerOption(text: '(4) Capaz de colocar pés juntos e ficar em pé por 1 minuto seguro.', points: 4),
    AnswerOption(text: '(3) Capaz de colocar pés juntos e ficar em pé por 1 minuto com supervisão.', points: 3),
    AnswerOption(text: '(2) Capaz de colocar pés juntos e ficar em pé por 30 segundos.', points: 2),
    AnswerOption(text: '(1) Necessita de ajuda para juntar, mas fica 15 segundos.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para juntar e não fica 15 segundos.', points: 0),
  ]),
  BergItem(task: '8. Esticar-se à frente com o braço estendido', options: [
    AnswerOption(text: '(4) Consegue esticar-se à frente > 25 cm com segurança.', points: 4),
    AnswerOption(text: '(3) Consegue esticar-se à frente > 12 cm com segurança.', points: 3),
    AnswerOption(text: '(2) Consegue esticar-se à frente > 5 cm com segurança.', points: 2),
    AnswerOption(text: '(1) Estica-se à frente, mas necessita de supervisão.', points: 1),
    AnswerOption(text: '(0) Perde o equilíbrio ao tentar/necessita de apoio.', points: 0),
  ]),
  BergItem(task: '9. Apanhar um objeto do chão', options: [
    AnswerOption(text: '(4) Capaz de apanhar o objeto com facilidade e segurança.', points: 4),
    AnswerOption(text: '(3) Capaz de apanhar o objeto, mas necessita de supervisão.', points: 3),
    AnswerOption(text: '(2) Incapaz de apanhar, mas alcança 2-5 cm do objeto.', points: 2),
    AnswerOption(text: '(1) Incapaz de apanhar e necessita de supervisão ao tentar.', points: 1),
    AnswerOption(text: '(0) Incapaz de tentar/necessita de ajuda.', points: 0),
  ]),
  BergItem(task: '10. Virar-se e olhar para trás', options: [
    AnswerOption(text: '(4) Olha para trás de ambos os lados com boa distribuição.', points: 4),
    AnswerOption(text: '(3) Olha para trás de um lado apenas.', points: 3),
    AnswerOption(text: '(2) Vira-se apenas para o lado; necessita de supervisão.', points: 2),
    AnswerOption(text: '(1) Necessita de supervisão ao virar-se.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para não perder o equilíbrio.', points: 0),
  ]),
  BergItem(task: '11. Girar 360 graus', options: [
    AnswerOption(text: '(4) Capaz de girar 360 graus com segurança em < 4 segundos.', points: 4),
    AnswerOption(text: '(3) Capaz de girar 360 graus com segurança de um lado apenas.', points: 3),
    AnswerOption(text: '(2) Capaz de girar 360 graus com segurança, mas lentamente.', points: 2),
    AnswerOption(text: '(1) Necessita de supervisão próxima ou indicações verbais.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda ao girar.', points: 0),
  ]),
  BergItem(task: '12. Colocar os pés alternadamente num degrau', options: [
    AnswerOption(text: '(4) Capaz de colocar cada pé 8 vezes em 20s independente.', points: 4),
    AnswerOption(text: '(3) Capaz de completar 8 passos em > 20s.', points: 3),
    AnswerOption(text: '(2) Capaz de completar 4 passos sem ajuda.', points: 2),
    AnswerOption(text: '(1) Capaz de completar > 2 passos com supervisão mínima.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para não cair/incapaz.', points: 0),
  ]),
  BergItem(task: '13. Permanecer em pé com um pé à frente do outro', options: [
    AnswerOption(text: '(4) Capaz de colocar pé à frente independente e manter 30s.', points: 4),
    AnswerOption(text: '(3) Capaz de colocar pé à frente independente e manter 15s.', points: 3),
    AnswerOption(text: '(2) Capaz de dar pequeno passo independente e manter 30s.', points: 2),
    AnswerOption(text: '(1) Necessita de ajuda para dar passo, mas mantém 15s.', points: 1),
    AnswerOption(text: '(0) Perde o equilíbrio ao tentar dar passo ou ficar em pé.', points: 0),
  ]),
  BergItem(task: '14. Permanecer em pé sobre uma perna', options: [
    AnswerOption(text: '(4) Capaz de levantar perna independente e manter > 10s.', points: 4),
    AnswerOption(text: '(3) Capaz de levantar perna independente e manter 5-10s.', points: 3),
    AnswerOption(text: '(2) Capaz de levantar perna independente e manter 3s.', points: 2),
    AnswerOption(text: '(1) Tenta levantar; incapaz de manter 3s, mas fica em pé.', points: 1),
    AnswerOption(text: '(0) Incapaz de tentar ou necessita de ajuda.', points: 0),
  ]),
];

// --- Serviços Lógicos ---
class BergLogic {
  static const int maxScore = 56;
  
  static int calculateScore(Map<int, AnswerOption> answers) {
    return answers.values.fold(0, (sum, answer) => sum + answer.points);
  }

  static String getInterpretation(int score) {
    if (score >= 41) return 'Baixo risco de queda.';
    if (score >= 21) return 'Risco de queda médio.';
    return 'Alto risco de queda.';
  }
}

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
  int get _currentScore => BergLogic.calculateScore(_answers);
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
      score: '$_currentScore / ${BergLogic.maxScore}',
      interpretation: BergLogic.getInterpretation(_currentScore),
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
                '$_currentScore / ${BergLogic.maxScore}',
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
        color: badgeColor.withOpacity(0.1),
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