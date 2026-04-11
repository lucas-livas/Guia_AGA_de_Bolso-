// lib/screens/1_Home/Funcional/katz_screen.dart
// Tela do Índice de Katz (AVDs)

// Importações do Dart
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

class KatzItem {
  final String activity;
  final List<AnswerOption> options;
  const KatzItem({required this.activity, required this.options});
}

// --- Lista de Itens do Katz ---
const List<KatzItem> katzIndexItems = [
  KatzItem(activity: '1. Banho', options: [
    AnswerOption(text: 'Independente: Toma banho sozinho ou precisa de ajuda apenas para lavar uma parte do corpo.', points: 1),
    AnswerOption(text: 'Dependente: Precisa de ajuda para mais de uma parte do corpo, para entrar/sair da banheira ou chuveiro.', points: 0),
  ]),
  KatzItem(activity: '2. Vestir-se', options: [
    AnswerOption(text: 'Independente: Pega as roupas e se veste sem ajuda.', points: 1),
    AnswerOption(text: 'Dependente: Não se veste sozinho ou permanece parcialmente despido.', points: 0),
  ]),
  KatzItem(activity: '3. Ir ao Banheiro (Higiene)', options: [
    AnswerOption(text: 'Independente: Vai ao banheiro, se limpa e ajeita as roupas sem ajuda.', points: 1),
    AnswerOption(text: 'Dependente: Usa comadre/compadre ou precisa de ajuda para ir ao banheiro e se limpar.', points: 0),
  ]),
  KatzItem(activity: '4. Transferência', options: [
    AnswerOption(text: 'Independente: Entra e sai da cama e de cadeiras sem ajuda.', points: 1),
    AnswerOption(text: 'Dependente: Precisa de ajuda para se mover da cama para a cadeira.', points: 0),
  ]),
  KatzItem(activity: '5. Continência', options: [
    AnswerOption(text: 'Independente: Controle completo da bexiga e do intestino.', points: 1),
    AnswerOption(text: 'Dependente: Incontinência parcial ou total; uso de fraldas, sondas ou cateteres.', points: 0),
  ]),
  KatzItem(activity: '6. Alimentação', options: [
    AnswerOption(text: 'Independente: Leva a comida do prato à boca sem ajuda.', points: 1),
    AnswerOption(text: 'Dependente: Precisa de ajuda para levar a comida à boca; alimentação por sonda.', points: 0),
  ]),
];

// --- Serviços de Lógica ---

class KatzValidationService {
  static String? validateCompletion(Map<int, AnswerOption> answers) {
    if (answers.length < katzIndexItems.length) {
      return 'Por favor, responda a todas as 6 atividades para calcular.';
    }
    return null;
  }
}

class KatzCalculationService {
  static int calculateScore(Map<int, AnswerOption> answers) {
    return answers.values.fold(0, (sum, answer) => sum + answer.points);
  }

  static String getClassification(int score) {
    switch (score) {
      case 6: return 'Classificação A: Independente em todas as 6 funções.';
      case 5: return 'Classificação B: Independente em 5 funções.';
      case 4: return 'Classificação C: Independente em 4 funções.';
      case 3: return 'Classificação D: Independente em 3 funções.';
      case 2: return 'Classificação E: Independente em 2 funções.';
      case 1: return 'Classificação F: Independente em 1 função.';
      default: return 'Classificação G: Dependente em todas as 6 funções.';
    }
  }
}

// --- Tela Principal ---

class KatzScreen extends StatefulWidget {
  const KatzScreen({super.key});

  @override
  State<KatzScreen> createState() => _KatzScreenState();
}

class _KatzScreenState extends State<KatzScreen> {
  // Estado
  final Map<int, AnswerOption> _answers = {};
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Controle de Acordeão
  late List<GlobalKey> _itemKeys;
  late List<ExpansibleController> _controllers; 

  // Estado geral
  int _totalScore = 0;
  String _interpretation = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializa chaves e controladores para os 6 itens
    _itemKeys = List.generate(katzIndexItems.length, (_) => GlobalKey());
    _controllers = List.generate(katzIndexItems.length, (_) => ExpansibleController());
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
  bool get _isComplete => _answeredCount == katzIndexItems.length;

  // --- Lógica de Salvar ---
  Future<void> _saveAssessment(Color sectionColor) async {
    if (!_isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Responda a todas as 6 atividades antes de salvar.')),
      );
      return;
    }

    // Calcula antes de salvar
    final score = KatzCalculationService.calculateScore(_answers);
    final interpretation = KatzCalculationService.getClassification(score);

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
      for (int i = 0; i < katzIndexItems.length; i++) {
        detailedAnswers.add({
          'activity': katzIndexItems[i].activity,
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
        testName: 'Índice de Katz (AVDs)',
        score: '$_totalScore / 6',
        interpretation: _interpretation,
        date: DateTime.now().toIso8601String(),
        notes: jsonEncode(notesMap),
      );

      await DatabaseHelper.instance.insertAssessment(newAssessment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resultado salvo para ${selectedPatient.name}'),
            backgroundColor: AssessmentColors.successGreen, // Sucesso sempre verde
          ),
        );
        Navigator.pop(context);
      }
    }
    
    if (mounted) setState(() => _isSaving = false);
  }

  // --- UI Widgets ---

  Widget _buildKatzItem(int index, KatzItem item, Color sectionColor) {
    final selectedOption = _answers[index];
    final isAnswered = selectedOption != null;

    return AssessmentSection(
      // --- ALTERAÇÃO: Usar expansionTileKey para funcionar com o novo widget transparente ---
      expansionTileKey: _itemKeys[index],
      controller: _controllers[index],
      title: item.activity,
      onExpansionChanged: (isExpanded) => _handleExpansion(index, isExpanded),

      // Pílula visual de pontuação ao lado do título
      trailing: isAnswered 
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (selectedOption.points == 1 
                        ? AssessmentColors.successGreen 
                        : AssessmentColors.warningOrange).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                selectedOption.points == 1 ? 'Independente' : 'Dependente',
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  color: selectedOption.points == 1 
                        ? AssessmentColors.successGreen 
                        : AssessmentColors.warningOrange,
                  fontSize: 11
                ),
              ),
            )
          : null,
      
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
              // if (index < katzIndexItems.length - 1) _controllers[index + 1].expand();
            }
          },
        );
      }).map((radioWidget) {
        // Wrapper para forçar a cor do Radio Button seguir a cor da seção
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
    // --- LÓGICA DE COR ADAPTATIVA ---
    final Gradient functionalGradient = AssessmentGradients.functional;
    final Color sectionColor = (functionalGradient is LinearGradient) 
        ? functionalGradient.colors.last 
        : AssessmentColors.successGreen;

    final currentScore = KatzCalculationService.calculateScore(_answers);

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Índice de Katz (AVDs)'),
        // --- ALTERAÇÃO: Fundo transparente/igual ao scaffold ---
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            // Ícone na cor da seção
            icon: Icon(Icons.refresh, color: sectionColor), 
            onPressed: _resetTest, 
            tooltip: 'Reiniciar'
          ),
        ],
      ),
      body: Column(
        children: [
          // --- ALTERAÇÃO: Fundo branco removido ---
          Container(
            padding: const EdgeInsets.all(16),
            // color: Colors.white, // REMOVIDO
            child: Column(
              children: [
                AssessmentProgressIndicator(
                  current: _answeredCount,
                  total: katzIndexItems.length,
                  label: 'Progresso da Avaliação',
                  // Barra na cor da seção
                  color: sectionColor, 
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pontuação Parcial:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    Text(
                      '$currentScore / 6', 
                      // Score na cor da seção
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: sectionColor), 
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
              itemCount: katzIndexItems.length + 1, 
              itemBuilder: (context, index) {
                if (index < katzIndexItems.length) {
                  return _buildKatzItem(index, katzIndexItems[index], sectionColor);
                } else {
                  // Seção de Anotações no final
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Observações Gerais (Opcional)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        // Foco na cor da seção
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: sectionColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
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
        // --- ALTERAÇÃO: Fundo branco e sombra removidos ---
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : () => _saveAssessment(sectionColor),
          style: ElevatedButton.styleFrom(
            // Botão habilitado na cor da seção
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