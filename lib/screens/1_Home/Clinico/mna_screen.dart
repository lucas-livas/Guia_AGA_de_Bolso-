import 'dart:convert';
import 'package:flutter/material.dart';

// Importações do Projeto
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/select_patient_screen.dart';
// IMPORTAÇÃO DO DESIGN SYSTEM
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// --- ENUMS E ESTADOS ---
enum AssessmentState { initial, triagemComplete, globalComplete, calculated, saving, error }

// --- MODELOS DE DADOS ---
class AnswerOption {
  final String text;
  final double points;
  const AnswerOption({required this.text, required this.points});
}

class ManItem {
  final String id;
  final String question;
  final List<AnswerOption> options;
  const ManItem({required this.id, required this.question, required this.options});
}

// --- DADOS DAS QUESTÕES (MANTIDOS IGUAIS) ---
const List<ManItem> manTriagemItems = [
  ManItem(id: 'A', question: 'A. Houve diminuição da ingestão alimentar nos últimos 3 meses?', options: [
    AnswerOption(text: 'Diminuição severa', points: 0.0),
    AnswerOption(text: 'Diminuição moderada', points: 1.0),
    AnswerOption(text: 'Sem diminuição', points: 2.0),
  ]),
  ManItem(id: 'B', question: 'B. Perda de peso nos últimos 3 meses?', options: [
    AnswerOption(text: 'Perda > 3 kg', points: 0.0),
    AnswerOption(text: 'Não sabe informar', points: 1.0),
    AnswerOption(text: 'Perda entre 1 e 3 kg', points: 2.0),
    AnswerOption(text: 'Sem perda de peso', points: 3.0),
  ]),
  ManItem(id: 'C', question: 'C. Mobilidade', options: [
    AnswerOption(text: 'Restrito ao leito ou à cadeira', points: 0.0),
    AnswerOption(text: 'Deambula, mas não sai de casa', points: 1.0),
    AnswerOption(text: 'Sai de casa normalmente', points: 2.0),
  ]),
  ManItem(id: 'D', question: 'D. Passou por estresse psicológico ou doença aguda nos últimos 3 meses?', options: [
    AnswerOption(text: 'Sim', points: 0.0),
    AnswerOption(text: 'Não', points: 2.0),
  ]),
  ManItem(id: 'E', question: 'E. Problemas neuropsicológicos', options: [
    AnswerOption(text: 'Demência ou depressão grave', points: 0.0),
    AnswerOption(text: 'Demência leve', points: 1.0),
    AnswerOption(text: 'Sem problemas psicológicos', points: 2.0),
  ]),
  ManItem(id: 'F', question: 'F. Índice de Massa Corporal (IMC)', options: [
    AnswerOption(text: 'IMC < 19', points: 0.0),
    AnswerOption(text: 'IMC de 19 a < 21', points: 1.0),
    AnswerOption(text: 'IMC de 21 a < 23', points: 2.0),
    AnswerOption(text: 'IMC >= 23', points: 3.0),
  ]),
];

const List<ManItem> manGlobalItems = [
  ManItem(id: 'G', question: 'G. O paciente vive em sua própria casa?', options: [
    AnswerOption(text: 'Não', points: 0.0),
    AnswerOption(text: 'Sim', points: 1.0),
  ]),
  ManItem(id: 'H', question: 'H. Utiliza mais de três medicamentos diferentes por dia?', options: [
    AnswerOption(text: 'Sim', points: 0.0),
    AnswerOption(text: 'Não', points: 1.0),
  ]),
  ManItem(id: 'I', question: 'I. Lesões de pele ou escaras?', options: [
    AnswerOption(text: 'Sim', points: 0.0),
    AnswerOption(text: 'Não', points: 1.0),
  ]),
  ManItem(id: 'J', question: 'J. Quantas refeições faz por dia?', options: [
    AnswerOption(text: '1 refeição', points: 0.0),
    AnswerOption(text: '2 refeições', points: 1.0),
    AnswerOption(text: '3 refeições', points: 2.0),
  ]),
  ManItem(id: 'L', question: 'L. O paciente consome duas ou mais porções diárias de fruta ou produtos hortícolas?', options: [
    AnswerOption(text: 'Não', points: 0.0),
    AnswerOption(text: 'Sim', points: 1.0),
  ]),
  ManItem(id: 'M', question: 'M. Quantos copos de líquidos o paciente consome por dia?', options: [
    AnswerOption(text: 'Menos de 3 copos', points: 0.0),
    AnswerOption(text: '3 a 5 copos', points: 0.5),
    AnswerOption(text: 'Mais de 5 copos', points: 1.0),
  ]),
  ManItem(id: 'N', question: 'N. Modo de se alimentar', options: [
    AnswerOption(text: 'Não é capaz de se alimentar sozinho', points: 0.0),
    AnswerOption(text: 'Alimenta-se sozinho, porém com dificuldade', points: 1.0),
    AnswerOption(text: 'Alimenta-se sozinho sem dificuldade', points: 2.0),
  ]),
  ManItem(id: 'O', question: 'O. O paciente acredita ter algum problema nutricional?', options: [
    AnswerOption(text: 'Acredita estar desnutrido', points: 0.0),
    AnswerOption(text: 'Não sabe dizer', points: 1.0),
    AnswerOption(text: 'Acredita não ter um problema nutricional', points: 2.0),
  ]),
  ManItem(id: 'P', question: 'P. Em comparação a outras pessoas da mesma idade, como o paciente considera a sua própria saúde?', options: [
    AnswerOption(text: 'Pior', points: 0.0),
    AnswerOption(text: 'Não sabe', points: 0.5),
    AnswerOption(text: 'Igual', points: 1.0),
    AnswerOption(text: 'Melhor', points: 2.0),
  ]),
  ManItem(id: 'Q', question: 'Q. Perímetro braquial (PB) em cm', options: [
    AnswerOption(text: 'PB < 21', points: 0.0),
    AnswerOption(text: '21 <= PB <= 22', points: 0.5),
    AnswerOption(text: 'PB > 22', points: 1.0),
  ]),
  ManItem(id: 'R', question: 'R. Perímetro da perna (PP) em cm', options: [
    AnswerOption(text: 'PP < 31', points: 0.0),
    AnswerOption(text: 'PP >= 31', points: 1.0),
  ]),
];

// --- SERVICOS DE CALCULO ---
class MNACalculationService {
  static double calculateTriagemScore(Map<String, AnswerOption> answers) {
    return answers.values.fold(0.0, (sum, answer) => sum + answer.points);
  }

  static double calculateGlobalScore(Map<String, AnswerOption> globalAnswers, double questionKScore) {
    final globalSum = globalAnswers.values.fold(0.0, (sum, answer) => sum + answer.points);
    return globalSum + questionKScore;
  }

  static String getInterpretation(double? triagemScore, double? totalScore, bool isCompleteAssessment) {
    if (triagemScore == null) return '';
    
    if (!isCompleteAssessment) {
      if (triagemScore >= 12) return 'Estado nutricional normal.';
      if (triagemScore >= 8) return 'Risco de desnutrição.';
      return 'Desnutrido.';
    }
    
    if (totalScore == null) return '';
    if (totalScore >= 24) return 'Estado nutricional normal.';
    if (totalScore >= 17) return 'Risco de desnutrição.';
    return 'Desnutrido.';
  }

  static String getScoreText(double? triagemScore, double? globalScore, double? totalScore, bool isCompleteAssessment) {
    if (!isCompleteAssessment) {
      return '${triagemScore?.toStringAsFixed(1) ?? "0.0"} / 14.0';
    }
    return '${totalScore?.toStringAsFixed(1) ?? "0.0"} / 30.0';
  }
}

// --- CONTROLADOR DE VALIDAÇÃO ---
class MNAValidationService {
  static String? validateBodyMeasurements(Map<String, AnswerOption> triagemAnswers, Map<String, AnswerOption> globalAnswers) {
    final hasIMC = triagemAnswers.containsKey('F');
    final hasLegCircumference = globalAnswers.containsKey('R');
    
    if (!hasIMC && !hasLegCircumference) {
      return 'Informe pelo menos o IMC (Questão F) ou a Circunferência da Panturrilha (Questão R)';
    }
    return null;
  }

  static String? validateTriagemCompletion(Map<String, AnswerOption> answers) {
    if (answers.length < manTriagemItems.length) {
      return 'Por favor, responda a todas as 6 questões da Triagem (A-F).';
    }
    return null;
  }

  static String? validateGlobalCompletion(Map<String, AnswerOption> answers, List<bool> questionKAnswers) {
    if (answers.length < manGlobalItems.length) {
      return 'Por favor, responda a todas as 12 questões da Avaliação Global (G-R).';
    }
    final bodyMeasurementError = validateBodyMeasurements(Map<String, AnswerOption>.from(answers), answers);
    if (bodyMeasurementError != null) return bodyMeasurementError;
    return null;
  }
}

class MnaScreen extends StatefulWidget {
  const MnaScreen({super.key});

  @override
  State<MnaScreen> createState() => _MnaScreenState();
}

class _MnaScreenState extends State<MnaScreen> {
  // --- Variáveis de Estado ---
  final Map<String, AnswerOption> _triagemAnswers = {};
  final Map<String, AnswerOption> _globalAnswers = {};
  final List<bool> _questionKAnswers = List.filled(3, false);
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultSectionKey = GlobalKey();

  // Controle de Acordeão
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, ExpansibleController> _sectionControllers = {};

  AssessmentState _currentState = AssessmentState.initial;
  bool _showGlobalAssessment = false;

  double? _triagemScore;
  double? _globalScore;
  double? _totalScore;
  String _interpretation = '';

  @override
  void initState() {
    super.initState();
    _initializeKeys();
  }

  void _initializeKeys() {
    final allIds = [
      ...manTriagemItems.map((i) => i.id),
      ...manGlobalItems.map((i) => i.id),
      'K'
    ];
    for (var id in allIds) {
      _sectionKeys[id] = GlobalKey();
      _sectionControllers[id] = ExpansibleController();
    }
  }

  void _handleExpansion(String activeId, bool isExpanded) {
    if (isExpanded) {
      _sectionControllers.forEach((key, controller) {
        if (key != activeId) {
          if (controller.isExpanded) controller.collapse();
        }
      });
      
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_sectionKeys[activeId]?.currentContext != null) {
          Scrollable.ensureVisible(
            _sectionKeys[activeId]!.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.4, 
          );
        }
      });
    }
  }

  // --- Getters Computados ---
  double get _questionKScore {
    int simCount = _questionKAnswers.where((val) => val).length;
    return switch (simCount) {
      3 => 1.0,
      2 => 0.5,
      _ => 0.0,
    };
  }

  int get _triagemProgress => _triagemAnswers.length;
  int get _globalProgress => _globalAnswers.length + (_questionKAnswers.any((v) => v) ? 1 : 0);
  bool get _isSaving => _currentState == AssessmentState.saving;
  bool get _isCalculated => _currentState == AssessmentState.calculated;

  int get _totalQuestions => _showGlobalAssessment 
    ? manTriagemItems.length + manGlobalItems.length + 1 
    : manTriagemItems.length;

  int get _answeredQuestions => _showGlobalAssessment
    ? _triagemProgress + _globalProgress
    : _triagemProgress;

  // --- Métodos Principais ---
  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetTest() {
    setState(() {
      _triagemAnswers.clear();
      _globalAnswers.clear();
      _questionKAnswers.fillRange(0, _questionKAnswers.length, false);
      _notesController.clear();
      _showGlobalAssessment = false;
      _currentState = AssessmentState.initial;
      _triagemScore = null;
      _globalScore = null;
      _totalScore = null;
      _interpretation = '';
    });
    // Fecha todos os acordeões
    _sectionControllers.forEach((_, c) {
        if (c.isExpanded) c.collapse();
    });
    
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _calculateScore() {
    final triagemError = MNAValidationService.validateTriagemCompletion(_triagemAnswers);
    if (triagemError != null) {
      setState(() {
        _currentState = AssessmentState.error;
        _interpretation = triagemError;
      });
      _scrollToResult();
      return;
    }

    _triagemScore = MNACalculationService.calculateTriagemScore(_triagemAnswers);

    if (!_showGlobalAssessment) {
      _interpretation = MNACalculationService.getInterpretation(_triagemScore, null, false);
      setState(() {
        _currentState = AssessmentState.calculated;
      });
      _scrollToResult();
      return;
    }

    final globalError = MNAValidationService.validateGlobalCompletion(_globalAnswers, _questionKAnswers);
    if (globalError != null) {
      setState(() {
        _currentState = AssessmentState.error;
        _interpretation = globalError;
      });
      _scrollToResult();
      return;
    }

    _globalScore = MNACalculationService.calculateGlobalScore(_globalAnswers, _questionKScore);
    _totalScore = _triagemScore! + _globalScore!;
    _interpretation = MNACalculationService.getInterpretation(_triagemScore, _totalScore, true);

    setState(() {
      _currentState = AssessmentState.calculated;
    });
    _scrollToResult();
  }

  Future<void> _saveResultToPatient(Color sectionColor) async {
    if (_currentState != AssessmentState.calculated || _triagemScore == null) {
      _showErrorSnackBar('Calcule um resultado válido antes de salvar.');
      return;
    }

    setState(() => _currentState = AssessmentState.saving);

    final selectedPatient = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectPatientScreen()),
    );

    if (selectedPatient != null && selectedPatient is Patient) {
      await _performSave(selectedPatient);
    } else {
      setState(() => _currentState = AssessmentState.calculated);
    }
  }

  Future<void> _performSave(Patient patient) async {
    try {
      final (testName, scoreString, detailedAnswers) = _prepareAssessmentData();
      
      final notesMap = {
        'detailed_answers': detailedAnswers,
        'physio_notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      final newAssessment = Assessment(
        patientId: patient.id!,
        testName: testName,
        score: scoreString,
        interpretation: _interpretation,
        date: DateTime.now().toIso8601String(),
        notes: jsonEncode(notesMap),
      );

      await DatabaseHelper.instance.insertAssessment(newAssessment);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resultado salvo para ${patient.name}'),
            backgroundColor: AssessmentColors.successGreen,
          ),
        );
        setState(() => _currentState = AssessmentState.calculated);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro ao salvar resultado: $e');
        setState(() => _currentState = AssessmentState.calculated);
      }
    }
  }

  (String, String, List<Map<String, dynamic>>) _prepareAssessmentData() {
    final detailedAnswers = <Map<String, dynamic>>[];
    String testName;
    String scoreString;

    for (var item in manTriagemItems) {
      final answer = _triagemAnswers[item.id];
      detailedAnswers.add({
        'question': item.question,
        'answer': answer?.text ?? 'Não respondido',
        'points': answer?.points ?? 0,
      });
    }

    if (!_showGlobalAssessment) {
      testName = 'MNA® - Triagem';
      scoreString = '${_triagemScore?.toStringAsFixed(1) ?? 0} / 14.0';
    } else {
      testName = 'MNA® - Completa';
      scoreString = '${_totalScore?.toStringAsFixed(1) ?? 0} / 30.0';

      for (var item in manGlobalItems.where((item) => ['G','H','I','J'].contains(item.id))) {
        final answer = _globalAnswers[item.id];
        detailedAnswers.add({
          'question': item.question,
          'answer': answer?.text ?? 'Não respondido',
          'points': answer?.points ?? 0,
        });
      }

      final kOptions = ['Leite ou derivados', 'Leguminosas ou ovos', 'Carne, peixe ou aves'];
      for (int i = 0; i < 3; i++) {
        detailedAnswers.add({
          'question': 'K. Paciente consome: ${kOptions[i]}?',
          'answer': _questionKAnswers[i] ? 'Sim' : 'Não',
          'points': i == 2 ? _questionKScore : 0,
        });
      }

      for (var item in manGlobalItems.where((item) => ['L','M','N','O','P','Q','R'].contains(item.id))) {
        final answer = _globalAnswers[item.id];
        detailedAnswers.add({
          'question': item.question,
          'answer': answer?.text ?? 'Não respondido',
          'points': answer?.points ?? 0,
        });
      }
    }

    return (testName, scoreString, detailedAnswers);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AssessmentColors.errorRed, duration: const Duration(seconds: 3)),
    );
  }

  void _scrollToResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resultSectionKey.currentContext != null) {
        Scrollable.ensureVisible(
          _resultSectionKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      }
    });
  }

  void _showSaveConfirmation(Color sectionColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Salvamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _showGlobalAssessment ? 'MNA® - Avaliação Global' : 'MNA® - Triagem',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Score: ${_showGlobalAssessment ? _totalScore?.toStringAsFixed(1) : _triagemScore?.toStringAsFixed(1)}'),
            const SizedBox(height: 8),
            Text('Interpretação: $_interpretation'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveResultToPatient(sectionColor);
            },
            style: ElevatedButton.styleFrom(backgroundColor: sectionColor, foregroundColor: Colors.white),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS OTIMIZADOS ---
  
  Widget _buildProgressIndicator(Color sectionColor) {
    return AssessmentProgressIndicator(
      current: _answeredQuestions,
      total: _totalQuestions,
      label: _showGlobalAssessment ? 'Progresso da Avaliação Completa' : 'Progresso da Triagem',
      color: sectionColor, 
    );
  }

  Widget _buildRadioSection(ManItem item, Map<String, AnswerOption> answerMap, Color sectionColor) {
    final currentAnswer = answerMap[item.id];
    final maxPoints = item.options.map((o) => o.points).reduce((a, b) => a > b ? a : b).toInt();
    final currentPoints = currentAnswer?.points.toInt() ?? 0;

    return AssessmentSection(
      // --- ALTERAÇÃO: Usar expansionTileKey ---
      expansionTileKey: _sectionKeys[item.id],
      controller: _sectionControllers[item.id],
      title: item.question,
      currentPoints: currentPoints,
      maxPoints: maxPoints,
      initiallyExpanded: currentAnswer != null,
      onExpansionChanged: (expanded) => _handleExpansion(item.id, expanded),
      
      children: item.options.map((option) {
        return AssessmentRadioItem<AnswerOption>(
          title: option.text,
          subtitle: '(${option.points.toStringAsFixed(1)} ponto(s))',
          value: option,
          groupValue: currentAnswer,
          onChanged: (val) {
            setState(() {
              if (val != null) {
                answerMap[item.id] = val;
                _currentState = AssessmentState.initial;
              }
            });
          },
        );
      }).map((radioWidget) {
        // Wrapper para forçar a cor do Radio Button
        return Theme(
          data: Theme.of(context).copyWith(
            radioTheme: RadioThemeData(
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return sectionColor;
                }
                return null;
              }),
            ),
          ),
          child: radioWidget,
        );
      }).toList(),
    );
  }

  Widget _buildQuestionKSection(Color sectionColor) {
    return AssessmentSection(
      expansionTileKey: _sectionKeys['K'],
      controller: _sectionControllers['K'],
      title: 'K. O paciente consome:',
      currentPoints: _questionKScore.toInt(),
      maxPoints: 1,
      initiallyExpanded: _questionKAnswers.any((v) => v),
      onExpansionChanged: (expanded) => _handleExpansion('K', expanded),
      
      children: [
        _buildCheckbox('Pelo menos 1 porção diária de leite ou derivados?', _questionKAnswers[0], (v) => setState(() => _questionKAnswers[0] = v ?? false), sectionColor),
        _buildCheckbox('2 ou mais porções semanais de leguminosas ou ovos?', _questionKAnswers[1], (v) => setState(() => _questionKAnswers[1] = v ?? false), sectionColor),
        _buildCheckbox('Carne, peixe ou aves todos os dias?', _questionKAnswers[2], (v) => setState(() => _questionKAnswers[2] = v ?? false), sectionColor),
      ],
    );
  }

  // Helper para Checkbox
  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged, Color activeColor) {
    return Theme(
      data: Theme.of(context).copyWith(
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return activeColor;
            }
            return null;
          }),
        ),
      ),
      child: AssessmentCheckboxItem(title: title, value: value, onChanged: onChanged, activeColor: activeColor),
    );
  }

  List<Widget> _buildTriagemWidgets(Color sectionColor) {
    return [
      AssessmentSectionHeader(
        title: "Triagem Nutricional",
        description: "Responda as questões A-F para avaliação inicial",
        // Fundo sutil
        backgroundColor: sectionColor.withOpacity(0.1),
      ),
      ...manTriagemItems.map((item) => _buildRadioSection(item, _triagemAnswers, sectionColor)),
    ];
  }

  List<Widget> _buildGlobalWidgets(Color sectionColor) {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _showGlobalAssessment = false;
              _currentState = AssessmentState.initial;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
            });
          },
          icon: Icon(Icons.arrow_back_ios_new, size: 16, color: sectionColor),
          label: Text(
            'Voltar para a Triagem',
            style: TextStyle(fontSize: 15, color: sectionColor, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            side: BorderSide(color: sectionColor.withOpacity(0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      AssessmentSectionHeader(
        title: "Avaliação Global Completa",
        description: "Responda as questões G-R para avaliação detalhada",
        backgroundColor: sectionColor.withOpacity(0.1),
      ),
      ...manGlobalItems.where((item) => ['G','H','I','J'].contains(item.id))
          .map((item) => _buildRadioSection(item, _globalAnswers, sectionColor)),
      _buildQuestionKSection(sectionColor),
      ...manGlobalItems.where((item) => ['L','M','N','O','P','Q','R'].contains(item.id))
          .map((item) => _buildRadioSection(item, _globalAnswers, sectionColor)),
    ];
  }

  Widget _buildNotesSection(Color sectionColor) {
    return AssessmentSection(
      title: 'Anotações (Opcional)',
      initiallyExpanded: false,
      onExpansionChanged: (expanded) {
        if(expanded) {
           Future.delayed(const Duration(milliseconds: 300), _scrollToResult);
        }
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Observações sobre a nutrição',
              hintText: 'Ex: Relata perda de apetite, dificuldade de mastigação...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              // Foco na cor da seção
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: sectionColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(Color sectionColor) {
    final bool isError = _currentState == AssessmentState.error;

    return Padding(
      key: _resultSectionKey,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _calculateScore,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              // Botão Calcular na cor da seção
              backgroundColor: sectionColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(_showGlobalAssessment ? 'Calcular Score Total (30)' : 'Calcular Score Triagem (14)'),
          ),

          const SizedBox(height: 16),

          if (_isCalculated) ...[
            AssessmentResultContainer(
              children: [
                const Text("PONTUAÇÃO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
                // Score na cor da seção
                Text(
                  MNACalculationService.getScoreText(_triagemScore, _globalScore, _totalScore, _showGlobalAssessment),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: sectionColor),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                const Text("INTERPRETAÇÃO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
                Text(
                  _interpretation,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AssessmentColors.textPrimary),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            ElevatedButton.icon(
              icon: _isSaving 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_outlined),
              label: Text(_isSaving ? 'SALVANDO...' : 'Salvar Resultado'),
              onPressed: _isSaving ? null : () => _showSaveConfirmation(sectionColor),
              style: ElevatedButton.styleFrom(
                // Botão Salvar na cor da seção
                backgroundColor: sectionColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ] else if (isError) ...[
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: AssessmentColors.errorRed.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: AssessmentColors.errorRed),
               ),
               child: Text(_interpretation, style: const TextStyle(color: AssessmentColors.errorRed, fontWeight: FontWeight.bold)),
             ),
          ],

          if (!_showGlobalAssessment && _triagemProgress == manTriagemItems.length) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _showGlobalAssessment = true;
                  _currentState = AssessmentState.initial;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: sectionColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Realizar Avaliação Global Completa', style: TextStyle(fontSize: 16, color: sectionColor, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward, color: sectionColor, size: 20),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE COR ADAPTATIVA ---
    // Detecta a cor do botão "Clínica" (Vermelho/Rosa por padrão)
    final Gradient clinicalGradient = AssessmentGradients.clinical;
    final Color sectionColor = (clinicalGradient is LinearGradient) 
        ? clinicalGradient.colors.last 
        : const Color(0xFFD32F2F); // Fallback Red

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: Text(_showGlobalAssessment ? 'MNA® - Avaliação Global' : 'MNA® - Triagem'),
        // --- ALTERAÇÃO: Fundo transparente ---
        backgroundColor: AssessmentColors.backgroundLight,
        elevation: 0,
        foregroundColor: AssessmentColors.textPrimary,
        centerTitle: true,
        actions: [
          IconButton(
            // Ícone na cor da seção
            icon: Icon(Icons.refresh_outlined, color: sectionColor), 
            tooltip: 'Reiniciar Teste', 
            onPressed: _resetTest
          ),
        ],
      ),
      body: Column(
        children: [
          // --- ALTERAÇÃO: Fundo branco removido ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            // color: Colors.white, // REMOVIDO
            child: _buildProgressIndicator(sectionColor),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AssessmentInstructionText(
                    text: 'Nota: Se o IMC (Questão F) não puder ser medido, use a Circunferência da Panturrilha (Questão R) como alternativa.',
                    icon: Icons.info_outline,
                    showBackground: true,
                  ),
                  const SizedBox(height: 16),
                  ..._showGlobalAssessment ? _buildGlobalWidgets(sectionColor) : _buildTriagemWidgets(sectionColor),
                  if (_triagemProgress > 0) ...[
                    const SizedBox(height: 8),
                    _buildNotesSection(sectionColor),
                  ],
                  _buildResultSection(sectionColor),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}