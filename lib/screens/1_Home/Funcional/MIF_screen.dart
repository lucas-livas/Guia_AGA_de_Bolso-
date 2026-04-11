import 'dart:convert';
import 'package:flutter/material.dart';

// Importações do Projeto
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/select_patient_screen.dart';
// IMPORTAÇÃO DO DESIGN SYSTEM
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// --- Modelos de Dados Locais ---
class FimAnswerOption {
  final String text;
  final int points;
  const FimAnswerOption({required this.text, required this.points});
}

class FimItem {
  final String category;
  final String task;
  final List<FimAnswerOption> options;
  const FimItem({required this.category, required this.task, required this.options});
}

// --- Enum de Estado ---
enum AssessmentState { initial, calculated, saving, error }

// --- Lista de Opções Padrão ---
const List<FimAnswerOption> fimStandardOptions = [
  FimAnswerOption(text: '7 - Independência Completa', points: 7),
  FimAnswerOption(text: '6 - Independência Modificada (com dispositivo)', points: 6),
  FimAnswerOption(text: '5 - Supervisão ou Preparação', points: 5),
  FimAnswerOption(text: '4 - Assistência Mínima (paciente faz >=75%)', points: 4),
  FimAnswerOption(text: '3 - Assistência Moderada (paciente faz 50-74%)', points: 3),
  FimAnswerOption(text: '2 - Assistência Máxima (paciente faz 25-49%)', points: 2),
  FimAnswerOption(text: '1 - Assistência Total (paciente faz <25%)', points: 1),
];

// --- Lista Completa dos Itens FIM ---
const List<FimItem> fimItems = [
  // --- DOMÍNIO MOTOR ---
  FimItem(category: 'A. Cuidados Pessoais', task: '1. Alimentação', options: fimStandardOptions),
  FimItem(category: 'A. Cuidados Pessoais', task: '2. Higiene Pessoal', options: fimStandardOptions),
  FimItem(category: 'A. Cuidados Pessoais', task: '3. Banho', options: fimStandardOptions),
  FimItem(category: 'A. Cuidados Pessoais', task: '4. Vestir-se - Parte Superior', options: fimStandardOptions),
  FimItem(category: 'A. Cuidados Pessoais', task: '5. Vestir-se - Parte Inferior', options: fimStandardOptions),
  FimItem(category: 'A. Cuidados Pessoais', task: '6. Uso do Vaso Sanitário', options: fimStandardOptions),
  FimItem(category: 'B. Controle dos Esfíncteres', task: '7. Controle da Bexiga', options: fimStandardOptions),
  FimItem(category: 'B. Controle dos Esfíncteres', task: '8. Controle do Intestino', options: fimStandardOptions),
  FimItem(category: 'C. Mobilidade', task: '9. Transferência: Cama, Cadeira, Cadeira de Rodas', options: fimStandardOptions),
  FimItem(category: 'C. Mobilidade', task: '10. Transferência: Vaso Sanitário', options: fimStandardOptions),
  FimItem(category: 'C. Mobilidade', task: '11. Transferência: Banheira ou Chuveiro', options: fimStandardOptions),
  FimItem(category: 'D. Locomoção', task: '12. Marcha / Cadeira de Rodas', options: fimStandardOptions),
  FimItem(category: 'D. Locomoção', task: '13. Escadas', options: fimStandardOptions),
  // --- DOMÍNIO COGNITIVO ---
  FimItem(category: 'E. Comunicação', task: '14. Compreensão', options: fimStandardOptions),
  FimItem(category: 'E. Comunicação', task: '15. Expressão', options: fimStandardOptions),
  FimItem(category: 'F. Cognição Social', task: '16. Interação Social', options: fimStandardOptions),
  FimItem(category: 'F. Cognição Social', task: '17. Resolução de Problemas', options: fimStandardOptions),
  FimItem(category: 'F. Cognição Social', task: '18. Memória', options: fimStandardOptions),
];

// --- Serviços de Lógica ---

class FimValidationService {
  static String? validateCompletion(Map<int, FimAnswerOption> answers) {
    if (answers.length < fimItems.length) {
      return 'Por favor, responda a todos os 18 itens para calcular.';
    }
    return null;
  }
}

class FimCalculationService {
  static (int, int, int) calculateScores(Map<int, FimAnswerOption> answers) {
    int motor = 0;
    int cognitive = 0;

    for (int i = 0; i < fimItems.length; i++) {
      if (i < 13) {
        motor += answers[i]?.points ?? 0;
      } else {
        cognitive += answers[i]?.points ?? 0;
      }
    }
    return (motor, cognitive, motor + cognitive);
  }
}

// --- Tela Principal ---

class FimScreen extends StatefulWidget {
  const FimScreen({super.key});

  @override
  State<FimScreen> createState() => _FimScreenState();
}

class _FimScreenState extends State<FimScreen> {
  // Estado
  final Map<int, FimAnswerOption> _answers = {};
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultCardKey = GlobalKey();
  final GlobalKey _notesKey = GlobalKey();
  
  // Controle de Acordeão (Por Categoria)
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, ExpansibleController> _sectionControllers = {};

  // Estado Geral
  AssessmentState _currentState = AssessmentState.initial;
  int _motorScore = 0;
  int _cognitiveScore = 0;
  int _totalScore = 0;
  String _interpretation = '';

  // Lista de Categorias Únicas
  final List<String> _categories = [
    'A. Cuidados Pessoais',
    'B. Controle dos Esfíncteres',
    'C. Mobilidade',
    'D. Locomoção',
    'E. Comunicação',
    'F. Cognição Social'
  ];

  @override
  void initState() {
    super.initState();
    _initializeKeys();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeKeys() {
    for (var category in _categories) {
      _sectionKeys[category] = GlobalKey();
      _sectionControllers[category] = ExpansibleController(); 
    }
  }

  // --- Lógica de Acordeão Suave ---
  void _handleExpansion(String activeCategory, bool isExpanded) {
    if (isExpanded) {
      // 1. Fecha as outras categorias
      for (var category in _categories) {
        if (category != activeCategory) {
          _sectionControllers[category]?.collapse();
        }
      }
      
      // 2. Centraliza a categoria ativa
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_sectionKeys[activeCategory]?.currentContext != null) {
          Scrollable.ensureVisible(
            _sectionKeys[activeCategory]!.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.2, 
          );
        }
      });
    }
  }

  // --- Getters ---
  bool get _isSaving => _currentState == AssessmentState.saving;
  int get _totalItems => fimItems.length;
  int get _answeredItems => _answers.length;

  // --- Métodos Principais ---
  void _resetTest() {
    setState(() {
      _answers.clear();
      _motorScore = 0;
      _cognitiveScore = 0;
      _totalScore = 0;
      _interpretation = '';
      _notesController.clear();
      _currentState = AssessmentState.initial;
    });
    // Fecha tudo
    for (var controller in _sectionControllers.values) {
      controller.collapse();
    }
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _calculateScore() {
    final validationError = FimValidationService.validateCompletion(_answers);
    if (validationError != null) {
      setState(() {
        _motorScore = 0; _cognitiveScore = 0; _totalScore = 0;
        _interpretation = validationError;
        _currentState = AssessmentState.error;
      });
      _scrollToKey(_resultCardKey);
      return;
    }

    final (motor, cognitive, total) = FimCalculationService.calculateScores(_answers);

    setState(() {
      _motorScore = motor;
      _cognitiveScore = cognitive;
      _totalScore = total;
      _interpretation = 'Pontuações calculadas com sucesso.';
      _currentState = AssessmentState.calculated;
    });
    _scrollToKey(_resultCardKey);
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
            const Text('MIF', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Total: $_totalScore / 126'),
            Text('Motor: $_motorScore / 91'),
            Text('Cognitivo: $_cognitiveScore / 35'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToPatientScreen(sectionColor);
            },
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
      await _performSave(selectedPatient);
    } else {
      setState(() => _currentState = AssessmentState.calculated);
    }
  }

  Future<void> _performSave(Patient patient) async {
    try {
      List<Map<String, dynamic>> detailedAnswers = [];
      for (int i = 0; i < fimItems.length; i++) {
        detailedAnswers.add({
          'category': fimItems[i].category,
          'task': fimItems[i].task,
          'score': _answers[i]?.points ?? 0,
          'level': _answers[i]?.text ?? 'Não respondido',
        });
      }
      
      final notesMap = {
        'detailed_answers': detailedAnswers,
        'motor_score': _motorScore,
        'cognitive_score': _cognitiveScore,
        'physio_notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      final newAssessment = Assessment(
        patientId: patient.id!,
        testName: 'Medida de Independência Funcional (MIF)',
        score: 'Total: $_totalScore', 
        interpretation: 'Motor: $_motorScore, Cognitivo: $_cognitiveScore',
        date: DateTime.now().toIso8601String(),
        notes: jsonEncode(notesMap),
      );

      await DatabaseHelper.instance.insertAssessment(newAssessment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resultado da MIF salvo para ${patient.name}'),
            backgroundColor: AssessmentColors.successGreen, // Sucesso é sempre verde
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

  // --- Widgets de Construção da UI ---

  // Recebe a cor da seção para pintar a barra de progresso
  Widget _buildProgressIndicator(Color sectionColor) {
    return AssessmentProgressIndicator(
      current: _answeredItems,
      total: _totalItems,
      label: 'Progresso da Avaliação',
      color: sectionColor, 
    );
  }

  List<Widget> _buildQuestionList(Color sectionColor) {
    final Map<String, List<FimItem>> groupedItems = {};
    for (var item in fimItems) {
      (groupedItems[item.category] ??= []).add(item);
    }

    return groupedItems.entries.map((entry) {
      String categoryName = entry.key;
      List<FimItem> itemsInCategory = entry.value;
      return _buildItemSection(categoryName, itemsInCategory, sectionColor);
    }).toList();
  }

  Widget _buildItemSection(String category, List<FimItem> itemsInCategory, Color sectionColor) {
    int currentPoints = 0;
    int maxPoints = itemsInCategory.length * 7; 
    
    for (var item in itemsInCategory) {
        int index = fimItems.indexOf(item);
        if (_answers.containsKey(index)) {
            currentPoints += _answers[index]!.points;
        }
    }

    return AssessmentSection(
      key: _sectionKeys[category],
      controller: _sectionControllers[category],
      title: category,
      currentPoints: currentPoints,
      maxPoints: maxPoints,
      onExpansionChanged: (isExpanded) => _handleExpansion(category, isExpanded),
      children: itemsInCategory.map((item) {
        final int originalIndex = fimItems.indexOf(item);
        final FimAnswerOption? selectedOption = _answers[originalIndex];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 4.0),
                child: Text(
                  item.task,
                  style: AssessmentTextStyles.itemTitle.copyWith(fontSize: 16),
                ),
              ),
              ...item.options.map((option) {
                return AssessmentRadioItem<FimAnswerOption>(
                  title: option.text,
                  value: option,
                  groupValue: selectedOption,
                  // Passamos a activeColor para o Radio Button
                  // (Obs: o widget AssessmentRadioItem precisa suportar isso, 
                  // se não suportar, ele usará a cor padrão)
                  // Mas como não podemos alterar o widget global aqui, 
                  // usamos um Theme wrapper para forçar a cor
                  onChanged: (FimAnswerOption? value) {
                    setState(() {
                      if (value != null) {
                        _answers[originalIndex] = value;
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
              const SizedBox(height: 12),
              const Divider(height: 1),
            ],
          ),
        );
      }).toList(),
    );
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
              labelText: 'Observações sobre a funcionalidade',
              hintText: 'Ex: Demanda supervisão em...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              // Foco na cor da seção
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: sectionColor, width: 2),
              ),
              filled: true,
              // Fundo da cor do tema (transparente/creme)
              fillColor: AssessmentColors.backgroundLight,
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
            onPressed: _calculateScore,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              // Botão Calcular na cor da seção
              backgroundColor: sectionColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CALCULAR PONTUAÇÃO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 16),

          if (showResult && !isError)
            AssessmentResultContainer(
              children: [
                const Text("PONTUAÇÃO TOTAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
                // Resultado na cor da seção
                Text("$_totalScore / 126", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: sectionColor)),
                const SizedBox(height: 12),
                
                AssessmentInfoRow(label: "Motor", value: "$_motorScore / 91"),
                AssessmentInfoRow(label: "Cognitivo", value: "$_cognitiveScore / 35"),
                
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                const Text("STATUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
                Text(_interpretation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            )
          else if (showResult && isError)
             Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: AssessmentColors.errorRed.withOpacity(0.1),
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: AssessmentColors.errorRed),
               ),
               child: Text(_interpretation, style: const TextStyle(color: AssessmentColors.errorRed, fontWeight: FontWeight.bold)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE COR ADAPTATIVA (Mesma do TUG) ---
    // Detecta a cor do botão "Funcional" baseado no tema atual
    final Gradient functionalGradient = AssessmentGradients.functional;
    final Color sectionColor = (functionalGradient is LinearGradient) 
        ? functionalGradient.colors.last 
        : AssessmentColors.successGreen;

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Medida de Independência Funcional'),
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            // Ícone Refresh na cor da seção
            icon: Icon(Icons.refresh_outlined, color: sectionColor), 
            tooltip: 'Reiniciar Teste', 
            onPressed: _resetTest
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de progresso com fundo adaptado e cor da seção
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AssessmentColors.backgroundLight, 
            child: _buildProgressIndicator(sectionColor),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Passa a cor para a lista de questões
                  ..._buildQuestionList(sectionColor),
                  const SizedBox(height: 8),
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