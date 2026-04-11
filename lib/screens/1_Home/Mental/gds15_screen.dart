import 'dart:convert';
import 'package:flutter/material.dart';

// Importações do Projeto
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/select_patient_screen.dart';
// IMPORTAÇÃO DO DESIGN SYSTEM
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// --- Modelo de Dados Local ---
class GdsOption {
  // Criado para manter compatibilidade com a lógica de seleção
  final String text; 
  const GdsOption({required this.text});
}

class Question {
  final int id; 
  final String text;
  final bool scoresForYes; // True se 'Sim' pontua (indica depressão)
  const Question({required this.id, required this.text, required this.scoresForYes});
}

// --- Enum de Estado ---
enum AssessmentState { initial, calculated, saving, error }

// --- Lista de Itens do GDS-15 ---
const List<Question> gds15Questions = [
  Question(id: 0, text: '1. Você está basicamente satisfeito com a sua vida?', scoresForYes: false),
  Question(id: 1, text: '2. Você abandonou muitas de suas atividades e interesses?', scoresForYes: true),
  Question(id: 2, text: '3. Você sente que sua vida está vazia?', scoresForYes: true),
  Question(id: 3, text: '4. Você se sente frequentemente entediado(a)?', scoresForYes: true),
  Question(id: 4, text: '5. Você está com bom humor na maior parte do tempo?', scoresForYes: false),
  Question(id: 5, text: '6. Você tem medo de que algo ruim lhe aconteça?', scoresForYes: true),
  Question(id: 6, text: '7. Você se sente feliz na maior parte do tempo?', scoresForYes: false),
  Question(id: 7, text: '8. Você se sente frequentemente desamparado(a)?', scoresForYes: true),
  Question(id: 8, text: '9. Você prefere ficar em casa a sair e fazer coisas novas?', scoresForYes: true),
  Question(id: 9, text: '10. Você sente que tem mais problemas de memória do que a maioria?', scoresForYes: true),
  Question(id: 10, text: '11. Você acha que é maravilhoso estar vivo?', scoresForYes: false),
  Question(id: 11, text: '12. Você se sente inútil ou sem valor?', scoresForYes: true),
  Question(id: 12, text: '13. Você se sente cheio(a) de energia?', scoresForYes: false),
  Question(id: 13, text: '14. Você sente que sua situação é sem esperança?', scoresForYes: true),
  Question(id: 14, text: '15. Você acha que a maioria das pessoas está em melhor situação do que você?', scoresForYes: true),
];

// --- Serviços de Lógica ---

class GdsValidationService {
  static String? validateCompletion(Map<int, bool> answers) {
    if (answers.length < gds15Questions.length) {
      return 'Por favor, responda a todas as 15 perguntas para calcular o resultado.';
    }
    return null;
  }
}

class GdsCalculationService {
  static int calculateScore(Map<int, bool> answers) {
    int currentScore = 0;
    answers.forEach((questionId, userAnswer) {
      final question = gds15Questions.firstWhere((q) => q.id == questionId);
      if (question.scoresForYes == userAnswer) {
        currentScore++;
      }
    });
    return currentScore;
  }

  static String getInterpretation(int score) {
    if (score <= 5) return 'Normal / Sem indicativo de depressão.';
    if (score <= 10) return 'Sugestivo de depressão leve a moderada.';
    return 'Sugestivo de depressão grave.';
  }
}

// --- Tela Principal ---

class Gds15Screen extends StatefulWidget {
  const Gds15Screen({super.key});

  @override
  State<Gds15Screen> createState() => _Gds15ScreenState();
}

class _Gds15ScreenState extends State<Gds15Screen> {
  final Map<int, bool> _answers = {};
  int _totalScore = 0;
  String _interpretation = '';

  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultSectionKey = GlobalKey();
  final GlobalKey _notesKey = GlobalKey();

  AssessmentState _currentState = AssessmentState.initial;

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Métodos Auxiliares ---
  void _resetTest() {
    setState(() {
      _answers.clear();
      _totalScore = 0;
      _interpretation = '';
      _notesController.clear();
      _currentState = AssessmentState.initial;
    });
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AssessmentColors.errorRed, duration: const Duration(seconds: 3)),
    );
  }

  void _scrollToKey(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      }
    });
  }

  bool get _isSaving => _currentState == AssessmentState.saving;
  int get _totalItems => gds15Questions.length;
  int get _answeredItems => _answers.length;

  // --- Lógica de Cálculo ---
  void _calculateScore() {
    final validationError = GdsValidationService.validateCompletion(_answers);
    if (validationError != null) {
      setState(() {
        _totalScore = 0;
        _interpretation = validationError;
        _currentState = AssessmentState.error;
      });
      _scrollToKey(_resultSectionKey);
      return;
    }

    final score = GdsCalculationService.calculateScore(_answers);
    final interpretationText = GdsCalculationService.getInterpretation(score);

    setState(() {
      _totalScore = score;
      _interpretation = interpretationText;
      _currentState = AssessmentState.calculated;
    });
    _scrollToKey(_resultSectionKey);
  }

  // --- Lógica de Salvar ---
  void _showSaveConfirmation(Color sectionColor) {
    if (_currentState != AssessmentState.calculated) {
      _showErrorSnackBar('Calcule um resultado válido antes de salvar.');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Salvamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('GDS-15', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Score: $_totalScore / 15'),
            const SizedBox(height: 8),
            Text('Interpretação: $_interpretation'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPatientScreen(sectionColor);
            },
            // Botão Salvar no Dialog com a cor da seção
            style: ElevatedButton.styleFrom(backgroundColor: sectionColor, foregroundColor: Colors.white),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToPatientScreen(Color sectionColor) async {
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
      List<Map<String, dynamic>> detailedAnswers = [];
      for (var question in gds15Questions) {
        bool? answer = _answers[question.id];
        int points = 0;
        if (answer != null && question.scoresForYes == answer) {
          points = 1;
        }
        detailedAnswers.add({
          'question': question.text,
          'answer': answer == null ? 'Não respondido' : (answer ? 'Sim' : 'Não'),
          'points': points,
        });
      }
      final notesMap = {
        'detailed_answers': detailedAnswers,
        'physio_notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      final newAssessment = Assessment(
        patientId: patient.id!,
        testName: 'Escala de Depressão Geriátrica (GDS-15)',
        score: '$_totalScore / 15',
        interpretation: _interpretation,
        date: DateTime.now().toIso8601String(),
        notes: jsonEncode(notesMap),
      );

      await DatabaseHelper.instance.insertAssessment(newAssessment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resultado salvo para ${patient.name}'),
            backgroundColor: AssessmentColors.successGreen, // Sucesso sempre verde
          ),
        );
        setState(() => _currentState = AssessmentState.calculated);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erro ao salvar: $e');
        setState(() => _currentState = AssessmentState.calculated);
      }
    }
  }

  // --- Widgets de Construção da UI ---

  Widget _buildProgressIndicator(Color sectionColor) {
    return AssessmentProgressIndicator(
      current: _answeredItems,
      total: _totalItems,
      label: 'Progresso da Avaliação',
      color: sectionColor, // Barra na cor da seção
    );
  }

  Widget _buildQuestionItem(Question question, Color sectionColor) {
    final bool? currentAnswer = _answers[question.id];

    // Lógica de Feedback Visual (Pílula)
    // No GDS, pontuar (+1) é ruim, não pontuar (0) é bom.
    // Mantemos as cores semânticas (Laranja/Verde) para o resultado individual
    final bool scoresPoint = currentAnswer != null && (currentAnswer == question.scoresForYes);
    
    // Cores da borda do Card seguem a seção se respondido
    final bool isAnswered = _answers.containsKey(question.id);
    Color borderColor = Colors.grey.shade200;
    double borderWidth = 1.0;

    if (isAnswered) {
      borderColor = sectionColor.withOpacity(0.3);
    } 

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 0,
      // --- ALTERAÇÃO: Fundo Transparente ---
      color: Colors.transparent,
      // ------------------------------------
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: borderWidth),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.text,
                    style: AssessmentTextStyles.itemTitle.copyWith(fontSize: 16),
                  ),
                ),
                if (currentAnswer != null)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: scoresPoint 
                          ? AssessmentColors.warningOrange.withOpacity(0.1) 
                          : AssessmentColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      scoresPoint ? '+1 ponto' : '0 pontos',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: scoresPoint ? AssessmentColors.warningOrange : AssessmentColors.successGreen
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? sectionColor : null))),
                    child: AssessmentRadioItem<bool>(
                      title: 'Sim',
                      value: true,
                      groupValue: currentAnswer,
                      onChanged: (val) => _onAnswerSelected(question.id, true),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(radioTheme: RadioThemeData(fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? sectionColor : null))),
                    child: AssessmentRadioItem<bool>(
                      title: 'Não',
                      value: false,
                      groupValue: currentAnswer,
                      onChanged: (val) => _onAnswerSelected(question.id, false),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onAnswerSelected(int id, bool value) {
    setState(() {
      _answers[id] = value;
      if (_currentState == AssessmentState.error) {
        _currentState = AssessmentState.initial;
      }
    });
  }

  Widget _buildNotesSection(Color sectionColor) {
    return AssessmentSection(
      key: _notesKey,
      title: 'Anotações (Opcional)',
      initiallyExpanded: false,
      onExpansionChanged: (isExpanded) {
        if (isExpanded) _scrollToKey(_notesKey);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Observações sobre o humor',
              hintText: 'Ex: Paciente relatou eventos recentes...',
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
    final bool showResult = _currentState == AssessmentState.calculated || _currentState == AssessmentState.error;
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
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              // Botão Calcular na cor da seção
              backgroundColor: sectionColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CALCULAR PONTUAÇÃO'),
          ),

          const SizedBox(height: 16),

          if (showResult) ...[
            if (isError)
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: AssessmentColors.errorRed.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(color: AssessmentColors.errorRed),
                 ),
                 child: Text(_interpretation, textAlign: TextAlign.center, style: const TextStyle(color: AssessmentColors.errorRed, fontWeight: FontWeight.bold)),
               )
            else
              AssessmentResultContainer(
                children: [
                  const Text("SCORE FINAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
                  // Resultado na cor da seção
                  Text('$_totalScore / 15', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: sectionColor)),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text("INTERPRETAÇÃO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
                  Text(_interpretation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  if (_totalScore > 5)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AssessmentColors.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 16, color: AssessmentColors.warningOrange),
                          const SizedBox(width: 8),
                          Expanded(child: Text("Atenção: Indicativo de depressão.", style: TextStyle(fontSize: 12, color: AssessmentColors.warningOrange, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    )
                ],
              ),

            const SizedBox(height: 20),

            if (!isError)
              ElevatedButton.icon(
                icon: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'SALVANDO...' : 'SALVAR RESULTADO'),
                onPressed: _isSaving ? null : () => _showSaveConfirmation(sectionColor),
                style: ElevatedButton.styleFrom(
                  // Botão Salvar na cor da seção
                  backgroundColor: sectionColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    // Detecta a cor do botão "Cognição"
    final Gradient cognitiveGradient = AssessmentGradients.cognitive;
    final Color sectionColor = (cognitiveGradient is LinearGradient) 
        ? cognitiveGradient.colors.last 
        : Colors.purple;

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('GDS-15'),
        // --- ALTERAÇÃO: Fundo transparente/igual ao scaffold ---
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
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
            // Barra de Progresso na cor da seção
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
                    text: 'Responda como se sentiu na última semana.',
                    icon: Icons.calendar_today,
                    showBackground: true,
                  ),
                  const SizedBox(height: 16),
                  // Lista de Perguntas
                  ...gds15Questions.map((q) => _buildQuestionItem(q, sectionColor)),
                  const SizedBox(height: 16),
                  _buildNotesSection(sectionColor),
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