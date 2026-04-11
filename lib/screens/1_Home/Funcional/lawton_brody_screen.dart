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
class AnswerOption {
  final String text;
  final int points;
  const AnswerOption({required this.text, required this.points});
}

class LawtonBrodyItem {
  final String category;
  final List<AnswerOption> options;
  const LawtonBrodyItem({required this.category, required this.options});
}

// --- Lista Completa dos Itens de Lawton-Brody ---
const List<LawtonBrodyItem> lawtonBrodyItems = [
  LawtonBrodyItem(
    category: 'A. Capacidade para usar o telefone',
    options: [
      AnswerOption(text: 'Utiliza o telefone por iniciativa própria', points: 1),
      AnswerOption(text: 'Disca alguns números bem conhecidos', points: 1),
      AnswerOption(text: 'Atende o telefone, mas não disca', points: 1),
      AnswerOption(text: 'Não utiliza o telefone', points: 0),
    ],
  ),
  LawtonBrodyItem(
    category: 'B. Fazer compras',
    options: [
      AnswerOption(text: 'Faz todas as compras necessárias de forma independente', points: 1),
      AnswerOption(text: 'Faz pequenas compras de forma independente', points: 0),
      AnswerOption(text: 'Necessita de companhia para fazer compras', points: 0),
      AnswerOption(text: 'Totalmente incapaz de fazer compras', points: 0),
    ],
  ),
  LawtonBrodyItem(
    category: 'C. Preparo de refeições',
    options: [
      AnswerOption(text: 'Planeja, prepara e serve as refeições de forma independente', points: 1),
      AnswerOption(text: 'Prepara as refeições se os ingredientes forem fornecidos', points: 0),
      AnswerOption(text: 'Aquece e serve as refeições, mas não as prepara', points: 0),
      AnswerOption(text: 'Necessita que as refeições sejam preparadas e servidas', points: 0),
    ],
  ),
  LawtonBrodyItem(
    category: 'D. Cuidar da casa',
    options: [
      AnswerOption(text: 'Cuida da casa sozinho(a) ou com ajuda ocasional', points: 1),
      AnswerOption(text: 'Executa tarefas domésticas leves diariamente', points: 1),
      AnswerOption(text: 'Necessita de ajuda com todas as tarefas domésticas', points: 1),
      AnswerOption(text: 'Não participa de nenhuma tarefa doméstica', points: 0),
    ],
  ),
  LawtonBrodyItem(
    category: 'E. Lavar roupa',
    options: [
      AnswerOption(text: 'Lava sua roupa por completo', points: 1),
      AnswerOption(text: 'Lava pequenas peças de roupa', points: 1),
      AnswerOption(text: 'Toda a lavagem de roupa precisa ser feita por outra pessoa', points: 0),
    ],
  ),
  LawtonBrodyItem(
    category: 'F. Meio de transporte',
    options: [
      AnswerOption(text: 'Viaja de forma independente em transporte público ou dirige', points: 1),
      AnswerOption(text: 'Pega um táxi, mas não usa outro transporte público', points: 1),
      AnswerOption(text: 'Viaja em transporte público quando acompanhado', points: 1),
      AnswerOption(text: 'Não sai de casa', points: 0),
    ],
  ),
  LawtonBrodyItem(
    category: 'G. Responsabilidade sobre os medicamentos',
    options: [
      AnswerOption(text: 'É responsável pelo uso de medicamentos em doses corretas', points: 1),
      AnswerOption(text: 'É responsável se seus medicamentos forem preparados', points: 0),
      AnswerOption(text: 'Não é capaz de se encarregar de seus medicamentos', points: 0),
    ],
  ),
  LawtonBrodyItem(
    category: 'H. Capacidade para lidar com as finanças',
    options: [
      AnswerOption(text: 'Lida com assuntos financeiros de forma independente', points: 1),
      AnswerOption(text: 'Lida com despesas do dia a dia, mas precisa de ajuda com banco', points: 1),
      AnswerOption(text: 'Incapaz de lidar com dinheiro', points: 0),
    ],
  ),
];

// --- Serviços de Lógica ---

class LawtonBrodyValidationService {
  static String? validateCompletion(Map<int, AnswerOption> answers) {
    if (answers.length < lawtonBrodyItems.length) {
      return 'Por favor, responda a todas as 8 categorias para calcular.';
    }
    return null;
  }
}

class LawtonBrodyCalculationService {
  static int calculateScore(Map<int, AnswerOption> answers) {
    return answers.values.fold(0, (sum, answer) => sum + answer.points);
  }

  static String getInterpretation(int score) {
    if (score == 8) return 'Independência total.';
    if (score > 0) return 'Dependência parcial.';
    return 'Dependência total.';
  }
}

// --- Tela Principal ---

class LawtonBrodyScreen extends StatefulWidget {
  const LawtonBrodyScreen({super.key});
  @override
  State<LawtonBrodyScreen> createState() => _LawtonBrodyScreenState();
}

class _LawtonBrodyScreenState extends State<LawtonBrodyScreen> {
  // Estado
  final Map<int, AnswerOption> _answers = {};
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Controle de Acordeão
  late List<GlobalKey> _itemKeys;
  // Usamos ExpansionTileController padrão agora
  late List<ExpansibleController> _controllers; 

  // Estado geral
  int _totalScore = 0;
  String _interpretation = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializa chaves e controladores para os 8 itens
    _itemKeys = List.generate(lawtonBrodyItems.length, (_) => GlobalKey());
    _controllers = List.generate(lawtonBrodyItems.length, (_) => ExpansibleController());
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Lógica de Acordeão e Scroll Suave ---
  void _handleExpansion(int index, bool isExpanded) {
    if (isExpanded) {
      // 1. Fecha todas as outras guias
      for (int i = 0; i < _controllers.length; i++) {
        if (i != index) {
          if (_controllers[i].isExpanded) _controllers[i].collapse();
        }
      }

      // 2. Centraliza o item na tela com delay para animação
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_itemKeys[index].currentContext != null) {
          Scrollable.ensureVisible(
            _itemKeys[index].currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.5, 
          );
        }
      });
    }
  }

  // --- Métodos Auxiliares ---
  void _resetTest() {
    setState(() {
      _answers.clear();
      _totalScore = 0;
      _interpretation = '';
      _notesController.clear();
    });
    for (var controller in _controllers) {
      if (controller.isExpanded) controller.collapse();
    }
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  int get _answeredCount => _answers.length;
  bool get _isComplete => _answeredCount == lawtonBrodyItems.length;

  // --- Lógica de Salvar ---
  Future<void> _saveAssessment(Color sectionColor) async {
    if (!_isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Responda a todas as 8 categorias antes de salvar.')),
      );
      return;
    }

    // Calcula antes de salvar
    final score = LawtonBrodyCalculationService.calculateScore(_answers);
    final interpretation = LawtonBrodyCalculationService.getInterpretation(score);

    setState(() {
      _totalScore = score;
      _interpretation = interpretation;
      _isSaving = true;
    });

    final selectedPatient = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectPatientScreen()),
    );

    if (selectedPatient != null && selectedPatient is Patient) {
      List<Map<String, dynamic>> detailedAnswers = [];
      for (int i = 0; i < lawtonBrodyItems.length; i++) {
        detailedAnswers.add({
          'category': lawtonBrodyItems[i].category,
          'answer': _answers[i]?.text ?? 'Não respondido',
          'points': _answers[i]?.points ?? 0,
        });
      }
      final notesMap = {
        'detailed_answers': detailedAnswers,
        'physio_notes': _notesController.text.isNotEmpty ? _notesController.text : null,
      };

      final newAssessment = Assessment(
        patientId: selectedPatient.id!,
        testName: 'Escala de Lawton-Brody (AIVDs)',
        score: '$_totalScore / 8',
        interpretation: _interpretation,
        date: DateTime.now().toIso8601String(),
        notes: jsonEncode(notesMap),
      );

      await DatabaseHelper.instance.insertAssessment(newAssessment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resultado salvo para ${selectedPatient.name}'),
            backgroundColor: AssessmentColors.successGreen, // Sucesso é sempre verde
          ),
        );
        Navigator.pop(context);
      }
    }
    
    if (mounted) setState(() => _isSaving = false);
  }

  // --- UI Widgets ---

  Widget _buildLawtonItem(int index, LawtonBrodyItem item, Color sectionColor) {
    final selectedOption = _answers[index];
    final isAnswered = selectedOption != null;

    return AssessmentSection(
      // Chaves e Controladores para o Acordeão
      key: _itemKeys[index],
      controller: _controllers[index],
      
      title: item.category,
      
      // Callback de expansão
      onExpansionChanged: (isExpanded) => _handleExpansion(index, isExpanded),

      // Pílula visual de pontuação ao lado do título
      trailing: isAnswered 
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                // Usa a cor da seção para indicar completude
                color: sectionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: sectionColor.withOpacity(0.3)),
              ),
              child: Text(
                '${selectedOption.points} pts',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: sectionColor, // Texto na cor da seção
                  fontSize: 12
                ),
              ),
            )
          : null,
      
      // Primeiro item começa aberto se nada respondido
      initiallyExpanded: index == 0 && _answeredCount == 0,
      
      children: item.options.map((option) {
        return AssessmentRadioItem<AnswerOption>(
          title: option.text,
          value: option,
          groupValue: selectedOption,
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _answers[index] = val;
              });
              // Opcional: Avançar automaticamente
              // if (index < lawtonBrodyItems.length - 1) _controllers[index + 1].expand();
            }
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

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE COR ADAPTATIVA (Mesma do TUG e MIF) ---
    // Detecta a cor do botão "Funcional" baseado no tema atual
    final Gradient functionalGradient = AssessmentGradients.functional;
    final Color sectionColor = (functionalGradient is LinearGradient) 
        ? functionalGradient.colors.last 
        : AssessmentColors.successGreen;

    // Calculo dinâmico para a barra de progresso
    final currentScore = LawtonBrodyCalculationService.calculateScore(_answers);

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Escala de Lawton-Brody (AIVDs)'),
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: sectionColor), // Ícone na cor da seção
            onPressed: _resetTest, 
            tooltip: 'Reiniciar'
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Progresso e Placar
          Container(
            padding: const EdgeInsets.all(16),
            // Fundo da cor do tema (creme/branco)
            color: AssessmentColors.backgroundLight,
            child: Column(
              children: [
                AssessmentProgressIndicator(
                  current: _answeredCount,
                  total: lawtonBrodyItems.length,
                  label: 'Progresso da Avaliação',
                  color: sectionColor, // Barra na cor da seção
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pontuação Parcial:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text(
                      '$currentScore / 8', 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: sectionColor), // Score na cor da seção
                    ),
                  ],
                )
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: lawtonBrodyItems.length + 1, 
              itemBuilder: (context, index) {
                if (index < lawtonBrodyItems.length) {
                  return _buildLawtonItem(index, lawtonBrodyItems[index], sectionColor);
                } else {
                  // Seção de Anotações no final da lista
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Observações Gerais (Opcional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        // Borda e foco na cor da seção
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: sectionColor, width: 2),
                        ),
                        filled: true,
                        // Fundo da cor do tema
                        fillColor: AssessmentColors.backgroundLight,
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AssessmentColors.backgroundLight,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : () => _saveAssessment(sectionColor),
          style: ElevatedButton.styleFrom(
            // Botão habilitado usa cor da seção, desabilitado usa cinza
            backgroundColor: _isComplete ? sectionColor : Colors.grey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: _isComplete ? 2 : 0,
          ),
          icon: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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