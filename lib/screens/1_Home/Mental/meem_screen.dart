import 'dart:convert';
import 'package:flutter/material.dart';

// Importações do Projeto
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/select_patient_screen.dart';
// IMPORTAÇÃO DO DESIGN SYSTEM
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// --- Enums ---
enum EducationLevel {
  illiterate('Analfabeto', 20),
  fundamentalIncompleto('1 a 4 anos', 25),
  fundamentalCompleto('5 a 8 anos', 26),
  medioOuSuperior('9 anos ou mais', 28);

  const EducationLevel(this.description, this.cutoffScore);
  final String description;
  final int cutoffScore;
}

enum AssessmentState { initial, calculated, saving, error }

// --- Serviços de Lógica ---

class MEEMValidationService {
  static String? validateEducation(EducationLevel? level) {
    if (level == null) {
      return 'Selecione o nível de escolaridade para calcular o resultado.';
    }
    return null;
  }
}

class MEEMCalculationService {
  static int calculateSectionScore(List<bool> items) {
    return items.where((item) => item).length;
  }

  static int calculateTotalScore({
    required List<bool> orientationTime,
    required List<bool> orientationPlace,
    required List<bool> registration,
    required int attentionScore,
    required List<bool> recall,
    required int languageScore,
  }) {
    return calculateSectionScore(orientationTime) +
        calculateSectionScore(orientationPlace) +
        calculateSectionScore(registration) +
        attentionScore +
        calculateSectionScore(recall) +
        languageScore;
  }

  static String getInterpretation(int totalScore, EducationLevel level) {
    final cutoff = level.cutoffScore;
    final interpretationText = totalScore < cutoff
        ? 'Sugestivo de déficit cognitivo.'
        : 'Normal para a escolaridade.';

    return 'Nota de corte para ${level.description}: $cutoff\n$interpretationText';
  }
}

// --- Tela Principal ---

class MeemScreen extends StatefulWidget {
  const MeemScreen({super.key});

  @override
  State<MeemScreen> createState() => _MeemScreenState();
}

class _MeemScreenState extends State<MeemScreen> {
  // --- Variáveis de Estado ---
  AssessmentState _currentState = AssessmentState.initial;

  // Respostas
  final List<bool> _orientationTime = List.filled(5, false);
  final List<bool> _orientationPlace = List.filled(5, false);
  final List<bool> _registration = List.filled(3, false);
  bool _useSpellingTest = true;
  final List<bool> _spellingLetters = List.filled(5, false);
  final List<bool> _subtractionResults = List.filled(5, false);
  final List<bool> _recall = List.filled(3, false);
  final List<bool> _naming = List.filled(2, false);
  bool _repetition = false;
  final List<bool> _command = List.filled(3, false);
  bool _reading = false;
  bool _writing = false;
  bool _copying = false;
  EducationLevel? _educationLevel;

  // Resultados
  int _totalScore = 0;
  String _interpretation = '';

  // Controladores
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultCardKey = GlobalKey();
  
  // Controle de Acordeão
  final Map<String, GlobalKey> _sectionKeys = {};
  final Map<String, ExpansibleController> _sectionControllers = {};

  final List<String> _sectionIds = [
    'orientationTime', 'orientationPlace', 'registration', 
    'attention', 'recall', 'language', 'education'
  ];

  @override
  void initState() {
    super.initState();
    _initializeSections();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeSections() {
    for (var id in _sectionIds) {
      _sectionKeys[id] = GlobalKey();
      _sectionControllers[id] = ExpansibleController();
    }
  }

  // --- Lógica de Acordeão Suave ---
  void _handleExpansion(String activeId, bool isExpanded) {
    if (isExpanded) {
      // 1. Fecha as outras
      for (var id in _sectionIds) {
        if (id != activeId) {
          if (_sectionControllers[id]?.isExpanded ?? false) _sectionControllers[id]?.collapse();
        }
      }
      // 2. Centraliza
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_sectionKeys[activeId]?.currentContext != null) {
          Scrollable.ensureVisible(
            _sectionKeys[activeId]!.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.1, 
          );
        }
      });
    }
  }

  // --- Getters de Score ---
  int get _orientationTimeScore => MEEMCalculationService.calculateSectionScore(_orientationTime);
  int get _orientationPlaceScore => MEEMCalculationService.calculateSectionScore(_orientationPlace);
  int get _registrationScore => MEEMCalculationService.calculateSectionScore(_registration);
  int get _attentionScore => _useSpellingTest
      ? MEEMCalculationService.calculateSectionScore(_spellingLetters)
      : MEEMCalculationService.calculateSectionScore(_subtractionResults);
  int get _recallScore => MEEMCalculationService.calculateSectionScore(_recall);
  int get _languageScore =>
      MEEMCalculationService.calculateSectionScore(_naming) +
      (_repetition ? 1 : 0) +
      MEEMCalculationService.calculateSectionScore(_command) +
      (_reading ? 1 : 0) +
      (_writing ? 1 : 0) +
      (_copying ? 1 : 0);
  
  bool get _isSaving => _currentState == AssessmentState.saving;

  // --- Getters de Progresso ---
  int get _totalItems => 31; 
  int get _answeredItems {
    int count = 0;
    count += _orientationTime.where((v) => v).length;
    count += _orientationPlace.where((v) => v).length;
    count += _registration.where((v) => v).length;
    count += _useSpellingTest
        ? _spellingLetters.where((v) => v).length
        : _subtractionResults.where((v) => v).length;
    count += _recall.where((v) => v).length;
    count += _naming.where((v) => v).length;
    if (_repetition) count++;
    count += _command.where((v) => v).length;
    if (_reading) count++;
    if (_writing) count++;
    if (_copying) count++;
    if (_educationLevel != null) count++;
    return count;
  }

  // --- Lógica de Cálculo ---
  void _calculateTotalScore() {
    final validationError = MEEMValidationService.validateEducation(_educationLevel);
    if (validationError != null) {
      setState(() {
        _currentState = AssessmentState.error;
        _totalScore = 0;
        _interpretation = validationError;
      });
      // Abre a seção de escolaridade se tiver erro nela
      if(!(_sectionControllers['education']?.isExpanded ?? false)) _sectionControllers['education']?.expand();
      
      return;
    }

    final total = MEEMCalculationService.calculateTotalScore(
      orientationTime: _orientationTime,
      orientationPlace: _orientationPlace,
      registration: _registration,
      attentionScore: _attentionScore,
      recall: _recall,
      languageScore: _languageScore,
    );

    final interpretationText = MEEMCalculationService.getInterpretation(total, _educationLevel!);

    setState(() {
      _totalScore = total;
      _interpretation = interpretationText;
      _currentState = AssessmentState.calculated;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if(_resultCardKey.currentContext != null) {
          Scrollable.ensureVisible(_resultCardKey.currentContext!, alignment: 0.5);
       }
    });
  }

  void _resetTest() {
    setState(() {
      _orientationTime.fillRange(0, _orientationTime.length, false);
      _orientationPlace.fillRange(0, _orientationPlace.length, false);
      _registration.fillRange(0, _registration.length, false);
      _spellingLetters.fillRange(0, _spellingLetters.length, false);
      _subtractionResults.fillRange(0, _subtractionResults.length, false);
      _recall.fillRange(0, _recall.length, false);
      _naming.fillRange(0, _naming.length, false);
      _repetition = false;
      _command.fillRange(0, _command.length, false);
      _reading = false;
      _writing = false;
      _copying = false;
      _educationLevel = null;
      _interpretation = '';
      _totalScore = 0;
      _currentState = AssessmentState.initial;
    });
    
    for(var controller in _sectionControllers.values) {
      if(controller.isExpanded) controller.collapse();
    }
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AssessmentColors.errorRed, duration: const Duration(seconds: 3)),
    );
  }

  // --- Lógica de Salvar ---
  void _showSaveConfirmation(Color sectionColor) {
    if (_currentState != AssessmentState.calculated || _educationLevel == null) {
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
            const Text('MEEM', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Score: $_totalScore/30'),
            const SizedBox(height: 8),
            Text('Corte (${_educationLevel!.description}): ${_educationLevel!.cutoffScore}'),
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

  Future<void> _saveResultToPatient(Color sectionColor) async {
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
      Map<String, dynamic> createAnswer(String category, bool value) {
        return {'category': category, 'answer': value ? 'Acertou' : 'Errou', 'points': value ? 1 : 0};
      }

      List<Map<String, dynamic>> detailedAnswers = [];
      detailedAnswers.add(createAnswer('Ano', _orientationTime[0]));
      detailedAnswers.add(createAnswer('Estação', _orientationTime[1]));
      detailedAnswers.add(createAnswer('Mês', _orientationTime[2]));
      detailedAnswers.add(createAnswer('Dia do mês', _orientationTime[3]));
      detailedAnswers.add(createAnswer('Dia da semana', _orientationTime[4]));
      detailedAnswers.add(createAnswer('País', _orientationPlace[0]));
      detailedAnswers.add(createAnswer('Estado', _orientationPlace[1]));
      detailedAnswers.add(createAnswer('Cidade', _orientationPlace[2]));
      detailedAnswers.add(createAnswer('Local', _orientationPlace[3]));
      detailedAnswers.add(createAnswer('Andar/Cômodo', _orientationPlace[4]));
      detailedAnswers.add(createAnswer('Registro: CASA', _registration[0]));
      detailedAnswers.add(createAnswer('Registro: CARRO', _registration[1]));
      detailedAnswers.add(createAnswer('Registro: JANELA', _registration[2]));
      
      if (_useSpellingTest) {
        for(int i=0; i<5; i++) {
          detailedAnswers.add(createAnswer('Atenção: Letra ${i+1}', _spellingLetters[i]));
        }
      } else {
        for(int i=0; i<5; i++) {
          detailedAnswers.add(createAnswer('Atenção: Subtração ${i+1}', _subtractionResults[i]));
        }
      }
      
      detailedAnswers.add(createAnswer('Evocação: CASA', _recall[0]));
      detailedAnswers.add(createAnswer('Evocação: CARRO', _recall[1]));
      detailedAnswers.add(createAnswer('Evocação: JANELA', _recall[2]));
      detailedAnswers.add(createAnswer('Nomear Relógio', _naming[0]));
      detailedAnswers.add(createAnswer('Nomear Caneta', _naming[1]));
      detailedAnswers.add(createAnswer('Repetir Frase', _repetition));
      detailedAnswers.add(createAnswer('Comando (Mão)', _command[0]));
      detailedAnswers.add(createAnswer('Comando (Dobra)', _command[1]));
      detailedAnswers.add(createAnswer('Comando (Chão)', _command[2]));
      detailedAnswers.add(createAnswer('Ler e agir', _reading));
      detailedAnswers.add(createAnswer('Escrever frase', _writing));
      detailedAnswers.add(createAnswer('Copiar desenho', _copying));

      final notesMap = {
        'detailed_answers': detailedAnswers,
        'education_level_selected': _educationLevel?.description ?? 'Não informado',
      };

      final newAssessment = Assessment(
        patientId: patient.id!,
        testName: 'Mini-Exame do Estado Mental (MEEM)',
        score: '$_totalScore/30',
        interpretation: _interpretation,
        date: DateTime.now().toIso8601String(),
        notes: jsonEncode(notesMap),
      );

      await DatabaseHelper.instance.insertAssessment(newAssessment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Salvo para ${patient.name}'), backgroundColor: AssessmentColors.successGreen),
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
      label: 'Progresso do Teste',
      color: sectionColor, 
    );
  }

  Widget _buildOrientationTimeSection(Color sectionColor) {
    return AssessmentSection(
      // --- CHAVE PARA SCROLL AUTOMÁTICO ---
      expansionTileKey: _sectionKeys['orientationTime'],
      controller: _sectionControllers['orientationTime'],
      title: '1. Orientação Temporal',
      maxPoints: 5,
      currentPoints: _orientationTimeScore,
      initiallyExpanded: true,
      onExpansionChanged: (expanded) => _handleExpansion('orientationTime', expanded),
      children: [
        const AssessmentInstructionText(text: 'Instrução: "Vou fazer algumas perguntas sobre o tempo atual."'),
        _buildCheckbox('Em que ano estamos?', _orientationTime[0], (v) => setState(() => _orientationTime[0] = v ?? false), sectionColor),
        _buildCheckbox('Em que estação do ano estamos?', _orientationTime[1], (v) => setState(() => _orientationTime[1] = v ?? false), sectionColor),
        _buildCheckbox('Em que mês estamos?', _orientationTime[2], (v) => setState(() => _orientationTime[2] = v ?? false), sectionColor),
        _buildCheckbox('Qual o dia do mês (data)?', _orientationTime[3], (v) => setState(() => _orientationTime[3] = v ?? false), sectionColor),
        _buildCheckbox('Qual o dia da semana?', _orientationTime[4], (v) => setState(() => _orientationTime[4] = v ?? false), sectionColor),
      ],
    );
  }

  // Helper para Checkbox com cor customizada
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

  Widget _buildOrientationPlaceSection(Color sectionColor) {
    return AssessmentSection(
      expansionTileKey: _sectionKeys['orientationPlace'],
      controller: _sectionControllers['orientationPlace'],
      title: '2. Orientação Espacial',
      maxPoints: 5,
      currentPoints: _orientationPlaceScore,
      onExpansionChanged: (expanded) => _handleExpansion('orientationPlace', expanded),
      children: [
        const AssessmentInstructionText(text: 'Instrução: "Agora, vou fazer perguntas sobre onde estamos."'),
        _buildCheckbox('Em que país estamos?', _orientationPlace[0], (v) => setState(() => _orientationPlace[0] = v ?? false), sectionColor),
        _buildCheckbox('Em que estado estamos?', _orientationPlace[1], (v) => setState(() => _orientationPlace[1] = v ?? false), sectionColor),
        _buildCheckbox('Em que cidade estamos?', _orientationPlace[2], (v) => setState(() => _orientationPlace[2] = v ?? false), sectionColor),
        _buildCheckbox('Em que local estamos (hospital, casa)?', _orientationPlace[3], (v) => setState(() => _orientationPlace[3] = v ?? false), sectionColor),
        _buildCheckbox('Em que andar/cômodo estamos?', _orientationPlace[4], (v) => setState(() => _orientationPlace[4] = v ?? false), sectionColor),
      ],
    );
  }

  Widget _buildRegistrationSection(Color sectionColor) {
    return AssessmentSection(
      expansionTileKey: _sectionKeys['registration'],
      controller: _sectionControllers['registration'],
      title: '3. Registro',
      maxPoints: 3,
      currentPoints: _registrationScore,
      onExpansionChanged: (expanded) => _handleExpansion('registration', expanded),
      children: [
        const AssessmentInstructionText(text: 'Instrução: "Repita: CASA, CARRO, JANELA."'),
        _buildCheckbox('CASA', _registration[0], (v) => setState(() => _registration[0] = v ?? false), sectionColor),
        _buildCheckbox('CARRO', _registration[1], (v) => setState(() => _registration[1] = v ?? false), sectionColor),
        _buildCheckbox('JANELA', _registration[2], (v) => setState(() => _registration[2] = v ?? false), sectionColor),
      ],
    );
  }

  Widget _buildAttentionSection(Color sectionColor) {
    return AssessmentSection(
      expansionTileKey: _sectionKeys['attention'],
      controller: _sectionControllers['attention'],
      title: '4. Atenção e Cálculo',
      maxPoints: 5,
      currentPoints: _attentionScore,
      onExpansionChanged: (expanded) => _handleExpansion('attention', expanded),
      children: [
        const AssessmentInstructionText(text: 'Escolha UMA das opções:'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Soletrar MUNDO'),
                  selected: _useSpellingTest,
                  onSelected: (val) => setState(() => _useSpellingTest = true),
                  selectedColor: sectionColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: _useSpellingTest ? sectionColor : Colors.black),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Subtrair 7 (100)'),
                  selected: !_useSpellingTest,
                  onSelected: (val) => setState(() => _useSpellingTest = false),
                  selectedColor: sectionColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: !_useSpellingTest ? sectionColor : Colors.black),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_useSpellingTest) ...[
          const AssessmentInstructionText(text: 'Soletrar MUNDO de trás para frente (O-D-N-U-M).', showBackground: true),
          _buildCheckbox('O', _spellingLetters[0], (v) => setState(() => _spellingLetters[0] = v ?? false), sectionColor),
          _buildCheckbox('D', _spellingLetters[1], (v) => setState(() => _spellingLetters[1] = v ?? false), sectionColor),
          _buildCheckbox('N', _spellingLetters[2], (v) => setState(() => _spellingLetters[2] = v ?? false), sectionColor),
          _buildCheckbox('U', _spellingLetters[3], (v) => setState(() => _spellingLetters[3] = v ?? false), sectionColor),
          _buildCheckbox('M', _spellingLetters[4], (v) => setState(() => _spellingLetters[4] = v ?? false), sectionColor),
        ] else ...[
          const AssessmentInstructionText(text: '100 - 7 sucessivamente.', showBackground: true),
          _buildCheckbox('93', _subtractionResults[0], (v) => setState(() => _subtractionResults[0] = v ?? false), sectionColor),
          _buildCheckbox('86', _subtractionResults[1], (v) => setState(() => _subtractionResults[1] = v ?? false), sectionColor),
          _buildCheckbox('79', _subtractionResults[2], (v) => setState(() => _subtractionResults[2] = v ?? false), sectionColor),
          _buildCheckbox('72', _subtractionResults[3], (v) => setState(() => _subtractionResults[3] = v ?? false), sectionColor),
          _buildCheckbox('65', _subtractionResults[4], (v) => setState(() => _subtractionResults[4] = v ?? false), sectionColor),
        ]
      ],
    );
  }

  Widget _buildRecallSection(Color sectionColor) {
    return AssessmentSection(
      expansionTileKey: _sectionKeys['recall'],
      controller: _sectionControllers['recall'],
      title: '5. Evocação',
      maxPoints: 3,
      currentPoints: _recallScore,
      onExpansionChanged: (expanded) => _handleExpansion('recall', expanded),
      children: [
        const AssessmentInstructionText(text: 'Quais eram as 3 palavras?'),
        _buildCheckbox('CASA', _recall[0], (v) => setState(() => _recall[0] = v ?? false), sectionColor),
        _buildCheckbox('CARRO', _recall[1], (v) => setState(() => _recall[1] = v ?? false), sectionColor),
        _buildCheckbox('JANELA', _recall[2], (v) => setState(() => _recall[2] = v ?? false), sectionColor),
      ],
    );
  }

  Widget _buildLanguageSection(Color sectionColor) {
    return AssessmentSection(
      expansionTileKey: _sectionKeys['language'],
      controller: _sectionControllers['language'],
      title: '6. Linguagem',
      maxPoints: 9,
      currentPoints: _languageScore,
      onExpansionChanged: (expanded) => _handleExpansion('language', expanded),
      children: [
        const AssessmentSectionHeader(title: 'a) Nomeação (2 pontos)', backgroundColor: Colors.transparent),
        _buildCheckbox('Nomear Relógio', _naming[0], (v) => setState(() => _naming[0] = v ?? false), sectionColor),
        _buildCheckbox('Nomear Caneta', _naming[1], (v) => setState(() => _naming[1] = v ?? false), sectionColor),
        
        const AssessmentSectionHeader(title: 'b) Repetição (1 ponto)', backgroundColor: Colors.transparent),
        Theme(
          data: Theme.of(context).copyWith(checkboxTheme: CheckboxThemeData(fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? sectionColor : null))),
          child: AssessmentCheckboxItem(title: 'Repetição', subtitle: '"NEM AQUI, NEM ALI, NEM LÁ"', value: _repetition, onChanged: (v) => setState(() => _repetition = v ?? false), activeColor: sectionColor),
        ),
        
        const AssessmentSectionHeader(title: 'c) Comando de 3 Estágios (3 pontos)', backgroundColor: Colors.transparent),
        const AssessmentInstructionText(text: 'Dê ao paciente uma folha de papel em branco.'),
        _buildCheckbox('1. Pegar papel com mão direita', _command[0], (v) => setState(() => _command[0] = v ?? false), sectionColor),
        _buildCheckbox('2. Dobrar ao meio', _command[1], (v) => setState(() => _command[1] = v ?? false), sectionColor),
        _buildCheckbox('3. Colocar no chão', _command[2], (v) => setState(() => _command[2] = v ?? false), sectionColor),
        
        const AssessmentSectionHeader(title: 'd) Leitura e Escrita (2 pontos)', backgroundColor: Colors.transparent),
        Theme(
          data: Theme.of(context).copyWith(checkboxTheme: CheckboxThemeData(fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? sectionColor : null))),
          child: AssessmentCheckboxItem(title: 'Leitura', subtitle: 'Ler "FECHE OS OLHOS" e executar', value: _reading, onChanged: (v) => setState(() => _reading = v ?? false), activeColor: sectionColor),
        ),
        Theme(
          data: Theme.of(context).copyWith(checkboxTheme: CheckboxThemeData(fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? sectionColor : null))),
          child: AssessmentCheckboxItem(title: 'Escrita', subtitle: 'Escrever frase completa (sujeito+verbo)', value: _writing, onChanged: (v) => setState(() => _writing = v ?? false), activeColor: sectionColor),
        ),
        
        const AssessmentSectionHeader(title: 'e) Cópia (1 ponto)', backgroundColor: Colors.transparent),
        const AssessmentInstructionText(text: 'Peça para copiar o desenho abaixo:'),
        Center(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => const FullscreenImageViewer(imagePath: 'assets/images/Pentágono_do_MEEM.png'),
              ));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 120, 
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: _pentagonHeroTag,
                  child: Image.asset(
                    'assets/images/Pentágono_do_MEEM.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        alignment: Alignment.center,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, color: Colors.grey, size: 40),
                            SizedBox(height: 4),
                            Text('Imagem não encontrada', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        Theme(
          data: Theme.of(context).copyWith(checkboxTheme: CheckboxThemeData(fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? sectionColor : null))),
          child: AssessmentCheckboxItem(
            title: 'Cópia Correta', 
            subtitle: 'Dois pentágonos interceptados formando um quadrilátero', 
            value: _copying, 
            onChanged: (v) => setState(() => _copying = v ?? false),
            activeColor: sectionColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEducationSection(Color sectionColor) {
    return AssessmentSection(
      expansionTileKey: _sectionKeys['education'],
      controller: _sectionControllers['education'],
      title: '7. Escolaridade',
      onExpansionChanged: (expanded) => _handleExpansion('education', expanded),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<EducationLevel>(
            initialValue: _educationLevel,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: sectionColor, width: 2)),
              labelText: 'Nível de Escolaridade',
              filled: true,
              fillColor: Colors.white,
            ),
            items: EducationLevel.values.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text('${level.description} (Corte: ${level.cutoffScore})'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _educationLevel = value),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(Color sectionColor) {
    final bool isCalculated = _currentState == AssessmentState.calculated;
    final bool isError = _currentState == AssessmentState.error;

    return Padding(
      key: _resultCardKey,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: _calculateTotalScore,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: sectionColor, 
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('CALCULAR PONTUAÇÃO TOTAL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 16),

          if (isCalculated || isError) ...[
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
                  Text('$_totalScore / 30', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: sectionColor)), // Score na cor da seção
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text("INTERPRETAÇÃO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
                  Text(_interpretation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            
            const SizedBox(height: 16),
            
            if (!isError)
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(_isSaving ? 'SALVANDO...' : 'SALVAR RESULTADO'),
                onPressed: _isSaving ? null : () => _showSaveConfirmation(sectionColor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: sectionColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
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
    final Gradient cognitiveGradient = AssessmentGradients.cognitive;
    final Color sectionColor = (cognitiveGradient is LinearGradient) 
        ? cognitiveGradient.colors.last 
        : Colors.purple; 

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Mini-Exame do Estado Mental'),
        // --- ALTERAÇÃO: Fundo transparente/igual ao scaffold ---
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: sectionColor), onPressed: _resetTest),
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
                children: [
                  _buildOrientationTimeSection(sectionColor),
                  _buildOrientationPlaceSection(sectionColor),
                  _buildRegistrationSection(sectionColor),
                  _buildAttentionSection(sectionColor),
                  _buildRecallSection(sectionColor),
                  _buildLanguageSection(sectionColor),
                  _buildEducationSection(sectionColor),
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

// Tag e visualizador em nível de biblioteca para exibir a imagem em tela cheia
const String _pentagonHeroTag = 'pentagono_meem';

class FullscreenImageViewer extends StatelessWidget {
  final String imagePath;
  const FullscreenImageViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: _pentagonHeroTag,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, color: Colors.white, size: 48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}