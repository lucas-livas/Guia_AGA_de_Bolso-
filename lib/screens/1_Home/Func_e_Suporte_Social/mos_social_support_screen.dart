import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Para gráficos de barras

// Importações do Projeto
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/select_patient_screen.dart';
// IMPORTAÇÃO DO DESIGN SYSTEM
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// --- Modelos de Dados Locais ---
class MosOption {
  final String text;
  final int value; // Pontuação de 1 a 5
  const MosOption({required this.text, required this.value});
}

class MosQuestion {
  final String text;
  final int id; // Número original da questão (1-19)
  
  static const List<MosOption> standardOptions = [
    MosOption(text: '1 - Nenhuma das vezes', value: 1),
    MosOption(text: '2 - Um pouco das vezes', value: 2),
    MosOption(text: '3 - Algumas das vezes', value: 3),
    MosOption(text: '4 - Na maior parte do tempo', value: 4),
    MosOption(text: '5 - Todo o tempo', value: 5),
  ];
  const MosQuestion({required this.id, required this.text});
}

// --- Enum de Estado ---
enum AssessmentState { initial, calculated, saving, error }

// --- Lista Completa das 19 Questões ---
const List<MosQuestion> mosQuestions = [
  MosQuestion(id: 1, text: 'Há alguém para ajudá-lo se você estivesse confinado à cama?'),
  MosQuestion(id: 2, text: 'Há alguém com quem você pode contar para ouvi-lo quando precisa falar?'),
  MosQuestion(id: 3, text: 'Há alguém para lhe dar um bom conselho sobre uma crise?'),
  MosQuestion(id: 4, text: 'Há alguém para levá-lo ao médico se você precisasse?'),
  MosQuestion(id: 5, text: 'Há alguém que demonstra amor e afeição por você?'),
  MosQuestion(id: 6, text: 'Há alguém para se divertir com você?'),
  MosQuestion(id: 7, text: 'Há alguém para lhe dar informações para ajudá-lo a entender uma situação?'),
  MosQuestion(id: 8, text: 'Há alguém em quem confiar ou com quem falar sobre você ou seus problemas?'),
  MosQuestion(id: 9, text: 'Há alguém que te abraça?'),
  MosQuestion(id: 10, text: 'Há alguém para se reunir para relaxar?'),
  MosQuestion(id: 11, text: 'Há alguém para preparar suas refeições se você não pudesse?'),
  MosQuestion(id: 12, text: 'Há alguém cujo conselho você realmente deseja?'),
  MosQuestion(id: 13, text: 'Há alguém para fazer coisas para ajudá-lo a tirar as coisas da cabeça?'),
  MosQuestion(id: 14, text: 'Há alguém para ajudar nas tarefas diárias se você estivesse doente?'),
  MosQuestion(id: 15, text: 'Há alguém para compartilhar suas preocupações e medos mais íntimos?'),
  MosQuestion(id: 16, text: 'Há alguém a quem recorrer para sugestões sobre um problema pessoal?'),
  MosQuestion(id: 17, text: 'Há alguém para fazer algo agradável com você?'),
  MosQuestion(id: 18, text: 'Há alguém que entende seus problemas?'),
  MosQuestion(id: 19, text: 'Há alguém para amar e fazer você se sentir querido?'),
];

// --- Definição das Subescalas (USADO APENAS PARA CÁLCULO) ---
const Map<String, List<int>> mosScalesCalculation = {
  'emotional': [2, 3, 7, 8, 12, 15, 16, 18],
  'tangible': [1, 4, 11, 14],
  'affectionate': [5, 9, 19],
  'positive': [6, 10, 17],
};

// --- Definição Visual (DIVIDIDA PARA PERFORMANCE DA UI) ---
const Map<String, List<int>> mosSectionsUI = {
  'emotional_1': [2, 3, 7, 8],      // Parte 1 (4 itens)
  'emotional_2': [12, 15, 16, 18],  // Parte 2 (4 itens)
  'tangible': [1, 4, 11, 14],
  'affectionate': [5, 9, 19],
  'positive': [6, 10, 17],
};

// --- Serviços de Lógica ---

class MosValidationService {
  static String? validateCompletion(Map<int, MosOption> answers) {
    if (answers.length < mosQuestions.length) {
      return 'Por favor, responda a todas as 19 questões para calcular.';
    }
    return null;
  }
}

typedef MosScores = ({
  double emotional,
  double tangible,
  double affectionate,
  double positive,
  double overall
});

class MosCalculationService {
  static double _calculateScaleScore(Map<int, MosOption> answers, List<int> itemIndices) {
    double sum = 0;
    for (int index in itemIndices) {
      sum += answers[index]!.value;
    }
    final double meanScore = sum / itemIndices.length;
    final double transformedScore = 100 * (meanScore - 1) / 4;
    return double.parse(transformedScore.toStringAsFixed(2));
  }

  static MosScores calculateScores(Map<int, MosOption> answers) {
    final emotional = _calculateScaleScore(answers, mosScalesCalculation['emotional']!);
    final tangible = _calculateScaleScore(answers, mosScalesCalculation['tangible']!);
    final affectionate = _calculateScaleScore(answers, mosScalesCalculation['affectionate']!);
    final positive = _calculateScaleScore(answers, mosScalesCalculation['positive']!);

    final overallIndices = List<int>.generate(19, (i) => i + 1);
    final overall = _calculateScaleScore(answers, overallIndices);

    return (
      emotional: emotional,
      tangible: tangible,
      affectionate: affectionate,
      positive: positive,
      overall: overall
    );
  }
}

// --- Tela Principal ---

class MosSocialSupportScreen extends StatefulWidget {
  const MosSocialSupportScreen({super.key});

  @override
  State<MosSocialSupportScreen> createState() => _MosSocialSupportScreenState();
}

class _MosSocialSupportScreenState extends State<MosSocialSupportScreen> {
  bool _isLoading = true;

  // Estado
  final Map<int, MosOption> _answers = {};
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultCardKey = GlobalKey();
  
  // Controle de Acordeão
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, ExpansibleController> _sectionControllers = {};

  // Scores
  double _emotionalScore = 0;
  double _tangibleScore = 0;
  double _affectionateScore = 0;
  double _positiveScore = 0;
  double _overallScore = 0;
  String _interpretation = '';
  
  AssessmentState _currentState = AssessmentState.initial;

  // Lista de IDs das seções para facilitar
  final List<String> _sectionIds = [
    'emotional_1', 
    'emotional_2', 
    'tangible', 
    'affectionate', 
    'positive', 
    'additional', 
    'notes'
  ];

  @override
  void initState() {
    super.initState();
    _initializeKeys();
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeKeys() {
    for (var id in _sectionIds) {
      _sectionKeys[id] = GlobalKey();
      _sectionControllers[id] = ExpansibleController();
    }
  }

  // --- Lógica de Acordeão Otimizada ---
  void _handleExpansion(String activeId, bool isExpanded) {
    if (isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (var id in _sectionIds) {
          if (id != activeId) {
            if (_sectionControllers[id]?.isExpanded ?? false) {
              _sectionControllers[id]?.collapse();
            }
          }
        }
      });
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_sectionKeys[activeId]?.currentContext != null) {
          Scrollable.ensureVisible(
            _sectionKeys[activeId]!.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            alignment: 0.25,
          );
        }
      });
    }
  }

  // --- Getters ---
  bool get _isSaving => _currentState == AssessmentState.saving;
  int get _totalItems => mosQuestions.length;
  int get _answeredItems => _answers.length;

  // --- Métodos Principais ---
  void _resetTest() {
    setState(() {
      _answers.clear();
      _emotionalScore = _tangibleScore = _affectionateScore = _positiveScore = _overallScore = 0;
      _interpretation = '';
      _notesController.clear();
      _currentState = AssessmentState.initial;
    });
    // Fecha tudo
    for (var controller in _sectionControllers.values) {
        if (controller.isExpanded) controller.collapse();
    }
    
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _calculateScores() {
    final validationError = MosValidationService.validateCompletion(_answers);
    if (validationError != null) {
      setState(() {
        _emotionalScore = _tangibleScore = _affectionateScore = _positiveScore = _overallScore = 0;
        _interpretation = validationError;
        _currentState = AssessmentState.error;
      });
      _scrollToResult();
      return;
    }

    final scores = MosCalculationService.calculateScores(_answers);

    setState(() {
      _emotionalScore = scores.emotional;
      _tangibleScore = scores.tangible;
      _affectionateScore = scores.affectionate;
      _positiveScore = scores.positive;
      _overallScore = scores.overall;
      _interpretation = 'Pontuações calculadas (escala 0-100).';
      _currentState = AssessmentState.calculated;
    });
    _scrollToResult();
  }

  void _scrollToResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resultCardKey.currentContext != null) {
        Scrollable.ensureVisible(
          _resultCardKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AssessmentColors.errorRed, duration: const Duration(seconds: 3)),
    );
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
            const Text('MOS Social Support Survey', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Score Geral: ${_overallScore.toStringAsFixed(1)} / 100'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPatientScreen(sectionColor);
            },
            // Botão do diálogo usa a cor da seção
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
      MaterialPageRoute(builder: (context) => const SelectPatientScreen()));

    if (selectedPatient != null && selectedPatient is Patient) {
      await _performSave(selectedPatient, sectionColor);
    } else {
      setState(() => _currentState = AssessmentState.calculated);
    }
  }

  Future<void> _performSave(Patient patient, Color sectionColor) async {
    try {
      List<Map<String, dynamic>> detailedAnswers = [];
      for (int i = 0; i < mosQuestions.length; i++) {
        final question = mosQuestions[i];
        final answer = _answers[question.id];
        detailedAnswers.add({
          'question_id': question.id,
          'question_text': question.text,
          'answer_value': answer?.value ?? 'N/A',
          'answer_text': answer?.text ?? 'Não respondido',
        });
      }
      final notesMap = {
        'scores_0_100': {
          'emotional': _emotionalScore,
          'tangible': _tangibleScore,
          'affectionate': _affectionateScore,
          'positive_interaction': _positiveScore,
          'overall': _overallScore,
        },
        'detailed_answers': detailedAnswers,
        'physio_notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      final newAssessment = Assessment(
        patientId: patient.id!,
        testName: 'MOS Social Support Survey',
        score: 'Geral: ${_overallScore.toStringAsFixed(1)} / 100',
        interpretation: 'Ver detalhes nas anotações.',
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
        _showErrorSnackBar('Erro ao salvar resultado: $e');
        setState(() => _currentState = AssessmentState.calculated);
      }
    }
  }

  // --- Widgets de Construção ---

  Widget _buildProgressIndicator(Color sectionColor) {
    return AssessmentProgressIndicator(
      current: _answeredItems,
      total: _totalItems,
      label: 'Progresso da Avaliação',
      color: sectionColor, // Barra na cor da seção
    );
  }

  List<Widget> _buildQuestionList(Color sectionColor) {
    final sections = mosSectionsUI.entries.map((entry) {
      final sectionKey = entry.key;
      final questionIds = entry.value;
      
      final titles = {
        'emotional_1': 'Suporte Emocional / Informacional (Parte 1)',
        'emotional_2': 'Suporte Emocional / Informacional (Parte 2)',
        'tangible': 'Suporte Tangível (Material)',
        'affectionate': 'Suporte Afetivo',
        'positive': 'Interação Social Positiva',
      };

      return AssessmentSection(
        // --- ALTERAÇÃO: Usar expansionTileKey para o novo widget transparente ---
        expansionTileKey: _sectionKeys[sectionKey],
        controller: _sectionControllers[sectionKey],
        title: titles[sectionKey] ?? 'Seção',
        currentPoints: questionIds.where((id) => _answers.containsKey(id)).length,
        maxPoints: questionIds.length,
        onExpansionChanged: (expanded) => _handleExpansion(sectionKey, expanded),
        
        children: questionIds.map((questionId) {
          final question = mosQuestions.firstWhere((q) => q.id == questionId);
          return _buildQuestionItem(question, sectionColor);
        }).toList(),
      );
    }).toList();

    sections.add(
      AssessmentSection(
        // --- ALTERAÇÃO: Usar expansionTileKey ---
        expansionTileKey: _sectionKeys['additional'],
        controller: _sectionControllers['additional'],
        title: 'Item Adicional (Interação)',
        currentPoints: _answers.containsKey(13) ? 1 : 0,
        maxPoints: 1,
        onExpansionChanged: (expanded) => _handleExpansion('additional', expanded),
        children: [
          _buildQuestionItem(mosQuestions.firstWhere((q) => q.id == 13), sectionColor)
        ],
      ),
    );

    return sections;
  }

  Widget _buildQuestionItem(MosQuestion question, Color sectionColor) {
    final selectedOption = _answers[question.id];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 4.0),
            child: Text(
              question.text,
              style: AssessmentTextStyles.itemTitle.copyWith(fontSize: 15),
            ),
          ),
          ...MosQuestion.standardOptions.map((option) {
            return AssessmentRadioItem<MosOption>(
              title: option.text,
              value: option,
              groupValue: selectedOption,
              onChanged: (val) {
                setState(() {
                  if (val != null) {
                    _answers[question.id] = val;
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
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNotesSection(Color sectionColor) {
    return AssessmentSection(
      // --- ALTERAÇÃO: Usar expansionTileKey ---
      expansionTileKey: _sectionKeys['notes'],
      controller: _sectionControllers['notes'],
      title: 'Anotações (Opcional)',
      onExpansionChanged: (expanded) => _handleExpansion('notes', expanded),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: 'Observações sobre o suporte social',
              hintText: 'Ex: Paciente relata isolamento...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              // Borda de foco na cor da seção
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
      key: _resultCardKey,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _calculateScores,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              // Botão Calcular na cor da seção
              backgroundColor: sectionColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CALCULAR PONTUAÇÕES'),
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
                  const Text("SCORE GERAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
                  // Resultado na cor da seção
                  Text('${_overallScore.toStringAsFixed(1)} / 100', style:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: sectionColor)),
                  const SizedBox(height: 24),
                   Center(child: Text("GRÁFICO DE SUPORTE SOCIAL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AssessmentColors.textPrimary))),
                  const SizedBox(height: 16),
                  _buildScoreChart(sectionColor),
                ],
              ),
            
            const SizedBox(height: 20),

            if (!isError)
              ElevatedButton.icon(
                icon: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_outlined),
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
          ],
        ],
      ),
    );
  }

  Widget _buildScoreChart(Color sectionColor) {
    final scores = [_emotionalScore, _tangibleScore, _affectionateScore, _positiveScore, _overallScore];
    const labels = ['Emocional/\nInfo', 'Tangível', 'Afetivo', 'Interação\nPositiva', 'Geral'];
    // A última barra (Geral) usa a cor da seção
    final barColors = [Colors.blue.shade600, Colors.green.shade600, Colors.red.shade600, Colors.orange.shade600, sectionColor];

    return AspectRatio(
      aspectRatio: 1.6,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 8.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100, minY: 0,
            gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade300, strokeWidth: 0.8)),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, interval: 20, getTitlesWidget: (val, _) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 42, getTitlesWidget: (val, _) {
                final index = val.toInt();
                return (index >= 0 && index < labels.length) 
                  ? Padding(padding: const EdgeInsets.only(top: 6.0), child: Text(labels[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))) 
                  : const Text('');
              })),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            barGroups: List.generate(scores.length, (index) => BarChartGroupData(
              x: index,
              barRods: [BarChartRodData(toY: scores[index], color: barColors[index], width: 18, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
            )),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                  '${labels[group.x.toInt()].replaceAll('\n', ' ')}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [TextSpan(text: rod.toY.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500))]
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget de Carregamento ---
  Widget _buildLoadingScreen(Color sectionColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           CircularProgressIndicator(color: sectionColor),
          const SizedBox(height: 20),
          Text(
            "Carregando MOS...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget de Conteúdo Principal ---
  Widget _buildContent(Color sectionColor) {
    return Column(
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
                  text: 'Para cada item, indique com que frequência o tipo de suporte esteve disponível para você.',
                  showBackground: true,
                  icon: Icons.info_outline,
                ),
                const SizedBox(height: 16),
                ..._buildQuestionList(sectionColor),
                _buildNotesSection(sectionColor),
                const SizedBox(height: 24),
                _buildResultSection(sectionColor),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE COR ADAPTATIVA ---
    // Detecta a cor do botão "Sócio Ambiental" (Social)
    final Gradient socialGradient = AssessmentGradients.social;
    final Color sectionColor = (socialGradient is LinearGradient) 
        ? socialGradient.colors.last 
        : const Color(0xFFFBC02D); // Amarelo/Dourado padrão se falhar

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('MOS Social Support Survey'),
        // --- ALTERAÇÃO: Fundo transparente/igual ao scaffold ---
        backgroundColor: AssessmentColors.backgroundLight,
        elevation: 0, // Sem sombra
        foregroundColor: AssessmentColors.textPrimary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_outlined, color: sectionColor), // Ícone na cor da seção
            onPressed: _resetTest
          )
        ],
      ),
      body: _isLoading ? _buildLoadingScreen(sectionColor) : _buildContent(sectionColor),
    );
  }
}