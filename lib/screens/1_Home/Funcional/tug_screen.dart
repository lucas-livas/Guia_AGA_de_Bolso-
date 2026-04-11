import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

// Importações do Projeto
import 'package:guia_aga_de_bolso/data/database_helper.dart';
import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/screens/2_Pacientes/select_patient_screen.dart';
// IMPORTAÇÃO DO DESIGN SYSTEM
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// --- SERVIÇOS LÓGICOS ---
class TugCalculationService {
  static String getInterpretation(double timeInSeconds) {
    if (timeInSeconds < 10) return 'Baixo risco de queda (Independente).';
    if (timeInSeconds <= 20) return 'Risco moderado (Independência parcial).';
    return 'Alto risco de queda (Dependente).';
  }
}

// --- TELA PRINCIPAL ---

class TugScreen extends StatefulWidget {
  const TugScreen({super.key});

  @override
  State<TugScreen> createState() => _TugScreenState();
}

class _TugScreenState extends State<TugScreen> {
  // Cronômetro
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer = Timer(Duration.zero, () {});
  String _displayTime = '00:00.00';
  bool _isRunning = false;

  // Controladores
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController(); 

  final GlobalKey _observationsKey = GlobalKey();

  // Estado
  double? _currentTime;
  String? _currentInterpretation;
  bool _isSaving = false;

  // --- ESTADO DA FICHA DE OBSERVAÇÕES ---
  final Map<String, bool> _observations = {
    'f1_balanco': false,
    'f1_apoio_manual': false,
    'f1_instabilidade': false,
    'f1_tronco': false,
    'f2_velocidade': false,
    'f2_passos_curtos': false,
    'f2_base_alargada': false,
    'f2_arrasto': false,
    'f2_bracos': false,
    'f3_passos_giro': false,
    'f3_instabilidade': false,
    'f3_nao_fluido': false,
    'f4_hesitacao': false,
    'f4_queda_brusca': false,
    'f4_apoio_manual': false,
    'f4_instabilidade': false,
  };

  @override
  void dispose() {
    _timer.cancel();
    _timeController.dispose();
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- LÓGICA DO CRONÔMETRO ---
  void _toggleTimer() {
    if (_isRunning) {
      _stopwatch.stop();
      _timer.cancel();
      final seconds = _stopwatch.elapsedMilliseconds / 1000;
      _updateResult(seconds);
    } else {
      _resetData();
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
        if (mounted) {
          setState(() {
            _displayTime = _formatDuration(_stopwatch.elapsed);
          });
        }
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  void _resetTimer() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer.cancel();
    _resetData();
    setState(() {
      _displayTime = '00:00.00';
      _isRunning = false;
      _observations.updateAll((key, value) => false);
    });
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _resetData() {
    _timeController.clear();
    _notesController.clear();
    setState(() {
      _currentTime = null;
      _currentInterpretation = null;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String milliseconds = (duration.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return "$twoDigitMinutes:$twoDigitSeconds.$milliseconds";
  }

  // --- LÓGICA DE CÁLCULO E INPUT ---
  void _onManualInputChanged(String value) {
    final cleanValue = value.replaceAll(',', '.');
    final seconds = double.tryParse(cleanValue);
    
    if (seconds != null && seconds > 0) {
      setState(() {
        _currentTime = seconds;
        _currentInterpretation = TugCalculationService.getInterpretation(seconds);
      });
    } else {
      setState(() {
        _currentTime = null;
        _currentInterpretation = null;
      });
    }
  }

  void _updateResult(double seconds) {
    _timeController.text = seconds.toStringAsFixed(2);
    _onManualInputChanged(_timeController.text);
  }

  String _getObservationTitle(String key) {
    const titles = {
      'f1_balanco': 'Balanço / Impulso Repetido',
      'f1_apoio_manual': 'Apoio Manual Necessário (Levantar)',
      'f1_instabilidade': 'Instabilidade Inicial',
      'f1_tronco': 'Dificuldade na Extensão do Tronco',
      'f2_velocidade': 'Velocidade Lenta',
      'f2_passos_curtos': 'Passos Curtos / Embaralhamento',
      'f2_base_alargada': 'Base de Suporte Alargada',
      'f2_arrasto': 'Arrasto do Pé',
      'f2_bracos': 'Balanço de Braços Diminuído',
      'f3_passos_giro': 'Múltiplos Passos no Giro',
      'f3_instabilidade': 'Instabilidade no Giro',
      'f3_nao_fluido': 'Giro Não Fluido',
      'f4_hesitacao': 'Hesitação / Erro de Localização',
      'f4_queda_brusca': 'Queda na Cadeira (Plopping)',
      'f4_apoio_manual': 'Apoio Manual (Sentar)',
      'f4_instabilidade': 'Instabilidade Após Sentar',
    };
    return titles[key] ?? key;
  }

  // --- LÓGICA DE SALVAR ---
  Future<void> _saveAssessment() async {
    if (_currentTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, registre um tempo válido.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final selectedPatient = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectPatientScreen()),
    );

    if (selectedPatient != null && selectedPatient is Patient) {
      List<String> activeObsList = [];
      _observations.forEach((key, isActive) {
        if (isActive) activeObsList.add(_getObservationTitle(key));
      });

      final notesMap = {
        'physio_notes': _notesController.text,
        'tug_observations': activeObsList, 
      };

      final assessment = Assessment(
        patientId: selectedPatient.id!,
        testName: 'Timed Up and Go (TUG)',
        score: '${_currentTime!.toStringAsFixed(2)} s',
        interpretation: _currentInterpretation ?? 'Não interpretado',
        date: DateTime.now().toIso8601String(),
        notes: jsonEncode(notesMap),
      );

      await DatabaseHelper.instance.insertAssessment(assessment);

      if (mounted) {
        // Recalculando a cor aqui pois não temos acesso fácil ao contexto do build
        final Gradient gradient = AssessmentGradients.functional;
        final Color snackbarColor = (gradient is LinearGradient) ? gradient.colors.last : AssessmentColors.successGreen;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Salvo na ficha de ${selectedPatient.name}'),
            backgroundColor: snackbarColor, 
          ),
        );
        Navigator.pop(context);
      }
    }
    
    if (mounted) setState(() => _isSaving = false);
  }

  // --- WIDGETS DA UI ---

  Widget _buildObsItem(String key, String title, Color dynamicColor, [String? subtitle]) {
    // Aqui usamos o AssessmentCheckboxItem, mas precisamos garantir que ele use a cor dinâmica
    // Como o widget original pode não ter suporte total a customização de texto via parâmetro,
    // usamos um Theme wrapper para forçar a cor primária naquele pedaço da árvore.
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: dynamicColor,
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return dynamicColor;
            }
            return null;
          }),
        ),
      ),
      child: AssessmentCheckboxItem(
        title: title,
        subtitle: subtitle,
        value: _observations[key] ?? false,
        onChanged: (val) {
          setState(() {
            _observations[key] = val ?? false;
          });
        },
        activeColor: dynamicColor, 
      ),
    );
  }

  // Header customizado que força a cor do título
  Widget _buildCustomHeader(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Fundo sutil com a cor da seção
        color: color.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: color.withOpacity(0.2), width: 1),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600, 
          fontSize: 16, 
          height: 1.25,
          color: color, // AQUI ESTÁ A MÁGICA: Forçamos a cor do texto para ser a do botão
        ),
      ),
    );
  }

  Widget _buildObservationsSection(Color sectionColor) {
    return AssessmentSection(
      key: _observationsKey,
      title: 'Ficha de Observações (Qualitativa)',
      // Forçamos a cor do ícone de expansão também
      controller: null, // Usamos controle interno padrão
      initiallyExpanded: false, 
      onExpansionChanged: (isExpanded) {
          if (isExpanded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_observationsKey.currentContext != null) {
                Scrollable.ensureVisible(_observationsKey.currentContext!, alignment: 0.1);
              }
            });
          }
      },
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AssessmentInstructionText(
            text: 'Assinale os desvios observados durante o teste.',
            // Fundo da instrução sutilmente colorido com a cor da seção
            backgroundColor: sectionColor.withOpacity(0.1),
            icon: Icons.info_outline,
          ),
        ),

        _buildCustomHeader('I. Fase: Sentado para Em Pé', sectionColor),
        _buildObsItem('f1_balanco', 'Balanço / Impulso Repetido', sectionColor, 'Usa balanço para iniciar o movimento'),
        _buildObsItem('f1_apoio_manual', 'Apoio Manual Necessário', sectionColor, 'Usa braços da cadeira ou joelhos'),
        _buildObsItem('f1_instabilidade', 'Instabilidade Inicial', sectionColor, 'Hesitação ou passos curtos'),
        _buildObsItem('f1_tronco', 'Dificuldade na Extensão', sectionColor, 'Permanece curvado ou demora a ficar ereto'),

        _buildCustomHeader('II. Fase: Marcha', sectionColor),
        _buildObsItem('f2_velocidade', 'Velocidade Lenta', sectionColor, 'Marcha visivelmente mais lenta que o esperado'),
        _buildObsItem('f2_passos_curtos', 'Passos Curtos / Embaralhamento', sectionColor, 'Pés arrastados ou passos muito pequenos'),
        _buildObsItem('f2_base_alargada', 'Base de Suporte Alargada', sectionColor, 'Pés separados para aumentar estabilidade'),
        _buildObsItem('f2_arrasto', 'Arrasto do Pé', sectionColor, 'Não eleva o pé adequadamente'),
        _buildObsItem('f2_bracos', 'Balanço de Braços Diminuído', sectionColor, 'Falta de movimento recíproco'),

        _buildCustomHeader('III. Fase: Giro (3 metros)', sectionColor),
        _buildObsItem('f3_passos_giro', 'Múltiplos Passos no Giro', sectionColor, '4 ou mais passos para girar 180°'),
        _buildObsItem('f3_instabilidade', 'Instabilidade / Desequilíbrio', sectionColor, 'Perda de controle ou balanço excessivo'),
        _buildObsItem('f3_nao_fluido', 'Giro Não Fluido', sectionColor, 'Gira de forma "quadrada" ou paradas bruscas'),

        _buildCustomHeader('IV. Fase: Volta para Sentado', sectionColor),
        _buildObsItem('f4_hesitacao', 'Hesitação / Erro de Localização', sectionColor, 'Demora ou erra a posição da cadeira'),
        _buildObsItem('f4_queda_brusca', 'Queda na Cadeira (Plopping)', sectionColor, 'Senta-se de forma brusca e descontrolada'),
        _buildObsItem('f4_apoio_manual', 'Apoio Manual Necessário', sectionColor, 'Usa mãos para controlar a descida'),
        _buildObsItem('f4_instabilidade', 'Instabilidade Após Sentar', sectionColor, 'Dificuldade em manter postura estável'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA DE COR ADAPTATIVA ---
    final Gradient functionalGradient = AssessmentGradients.functional;
    final Color sectionColor = (functionalGradient is LinearGradient) 
        ? functionalGradient.colors.last 
        : AssessmentColors.successGreen;

    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Timed Up and Go (TUG)'),
        backgroundColor: AssessmentColors.backgroundLight,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: sectionColor),
            onPressed: _resetTimer,
            tooltip: 'Reiniciar',
          )
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Principal com cor adaptada
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sectionColor.withOpacity(0.1), // Fundo sutil da cor da seção
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: sectionColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instruções do Teste',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold, 
                      color: sectionColor // Cor do título adaptada
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Levantar, andar 3m, virar, voltar e sentar.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Cronômetro Grande
            Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                ]
              ),
              child: Column(
                children: [
                  Text(
                    _displayTime,
                    style: TextStyle(
                      fontSize: 48, 
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                      color: sectionColor, // Cor do número do tempo
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: _toggleTimer,
                        // Play/Stop continuam Verde/Vermelho por semântica de ação
                        backgroundColor: _isRunning ? AssessmentColors.errorRed : AssessmentColors.successGreen,
                        child: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // Input Manual
            TextField(
              controller: _timeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Tempo em Segundos (Manual)',
                // Ícone na cor da seção
                prefixIcon: Icon(Icons.timer_outlined, color: sectionColor), 
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: sectionColor, width: 2), // Borda na cor da seção
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onManualInputChanged,
            ),

            const SizedBox(height: 20),

            // Resultado
            if (_currentInterpretation != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _currentTime! >= 12 
                      ? AssessmentColors.warningOrange.withOpacity(0.1) 
                      : AssessmentColors.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _currentTime! >= 12 ? AssessmentColors.warningOrange : AssessmentColors.successGreen,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _currentInterpretation!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: _currentTime! >= 12 ? AssessmentColors.warningOrange : AssessmentColors.successGreen
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Ficha de Observações (Passando a cor da seção)
            _buildObservationsSection(sectionColor),

            const SizedBox(height: 20),

            // Anotações Extras
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Outras Observações (Opcional)',
                hintText: 'Ex: Paciente estava com dor, usou calçado inadequado...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: sectionColor, width: 2), // Borda na cor da seção
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 80), 
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveAssessment,
          style: ElevatedButton.styleFrom(
            backgroundColor: sectionColor, // Botão Salvar na cor da seção
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          icon: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.save),
          label: Text(_isSaving ? 'Salvando...' : 'Salvar Resultado', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}