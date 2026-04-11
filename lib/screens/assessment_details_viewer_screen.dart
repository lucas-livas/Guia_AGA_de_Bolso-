// ============================================================================
// TELA DE VISUALIZAÇÃO DE DETALHES DA AVALIAÇÃO
// ============================================================================

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Necessário para o gráfico do MOS

import 'package:guia_aga_de_bolso/models/assessment_model.dart';
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

// =============================================================================
// 1. MODELOS DE DADOS E ENUMS
// =============================================================================

enum AssessmentType { detailedTest, checklist, simpleTest, unknown }

class ParsedAssessmentData {
  final AssessmentType type;
  final Map<String, dynamic>? detailedAnswers;
  final Map<String, dynamic>? checklistData;
  final String? actualNotes;
  final String? score;
  final String? interpretation;

  const ParsedAssessmentData({
    required this.type,
    this.detailedAnswers,
    this.checklistData,
    this.actualNotes,
    this.score,
    this.interpretation,
  });
}

// Classes auxiliares para o Parser
class _JsonAnalysisResult {
  final bool isJson;
  final Map<String, dynamic>? data;
  final String? rawText;
  const _JsonAnalysisResult({required this.isJson, required this.data, required this.rawText});
}

class _NotesAnalysisResult {
  final bool isJson;
  final Map<String, dynamic>? data;
  final bool hasDetailedAnswers;
  final String? physioNotes;
  const _NotesAnalysisResult({required this.isJson, required this.data, required this.hasDetailedAnswers, required this.physioNotes});
}

class _InterpretationAnalysisResult {
  final bool isJson;
  final Map<String, dynamic>? data;
  const _InterpretationAnalysisResult({required this.isJson, required this.data});
}

// =============================================================================
// 2. PARSER
// =============================================================================

class AssessmentDataParser {
  final Assessment assessment;
  const AssessmentDataParser(this.assessment);

  ParsedAssessmentData parse() {
    final _NotesAnalysisResult notesAnalysis = _parseNotesField();
    final _InterpretationAnalysisResult interpretationAnalysis = _parseInterpretationField();
    return _determineAssessmentType(notesAnalysis, interpretationAnalysis);
  }

  _JsonAnalysisResult _parseJsonField(String? field) {
    if (field == null || field.isEmpty) return const _JsonAnalysisResult(isJson: false, data: null, rawText: null);
    try {
      final dynamic parsedData = jsonDecode(field);
      return _JsonAnalysisResult(isJson: true, data: parsedData is Map<String, dynamic> ? parsedData : null, rawText: field);
    } catch (e) {
      return _JsonAnalysisResult(isJson: false, data: null, rawText: field);
    }
  }

  _NotesAnalysisResult _parseNotesField() {
    final _JsonAnalysisResult result = _parseJsonField(assessment.notes);
    if (result.isJson && result.data != null) {
      final bool hasDetailedAnswers = result.data!.containsKey('detailed_answers') || 
                                      result.data!.containsKey('tug_observations') ||
                                      result.data!.containsKey('scores_0_100');
      final String? physioNotes = result.data!['physio_notes'] as String?;
      return _NotesAnalysisResult(isJson: true, data: result.data, hasDetailedAnswers: hasDetailedAnswers, physioNotes: physioNotes);
    }
    return _NotesAnalysisResult(isJson: false, data: null, hasDetailedAnswers: false, physioNotes: assessment.notes);
  }

  _InterpretationAnalysisResult _parseInterpretationField() {
    final _JsonAnalysisResult result = _parseJsonField(assessment.interpretation);
    return _InterpretationAnalysisResult(isJson: result.isJson, data: result.data);
  }

  ParsedAssessmentData _determineAssessmentType(_NotesAnalysisResult n, _InterpretationAnalysisResult i) {
    if (n.hasDetailedAnswers) return ParsedAssessmentData(type: AssessmentType.detailedTest, detailedAnswers: n.data, actualNotes: n.physioNotes, score: assessment.score, interpretation: assessment.interpretation);
    if (i.isJson && i.data != null) return ParsedAssessmentData(type: AssessmentType.checklist, checklistData: i.data, actualNotes: n.physioNotes, score: assessment.score, interpretation: assessment.interpretation);
    return ParsedAssessmentData(type: AssessmentType.simpleTest, actualNotes: n.physioNotes, score: assessment.score, interpretation: assessment.interpretation);
  }
}

// =============================================================================
// 3. GERADOR DE RESUMO (CHECKLIST)
// =============================================================================

class ChecklistSummaryGenerator {
  final Map<String, dynamic> data;
  const ChecklistSummaryGenerator(this.data);

  List<Widget> generate() {
    final List<Widget> summaryWidgets = [];
    Map<String, dynamic> safeMap(String key) => data[key] as Map<String, dynamic>? ?? {};
    
    if (data.containsKey('visao')) summaryWidgets.add(_buildSummaryLine('Visão', _getVisionSummary(safeMap('visao'))));
    if (data.containsKey('audicao')) summaryWidgets.add(_buildSummaryLine('Audição', _getHearingSummary(safeMap('audicao'))));
    if (data.containsKey('doenca_cardiovascular')) summaryWidgets.add(_buildSummaryLine('Doenças CV', data['doenca_cardiovascular']?.toString() ?? '-'));
    if (data.containsKey('doenca_osteoarticular')) summaryWidgets.add(_buildSummaryLine('Doenças Osteo', data['doenca_osteoarticular']?.toString() ?? '-'));
    if (data.containsKey('polifarmacia')) summaryWidgets.add(_buildSummaryLine('Polifarmácia', data['polifarmacia']?.toString() ?? '-'));
    if (data.containsKey('vacinas')) summaryWidgets.add(_buildSummaryLine('Vacinas', _getVaccineSummary(safeMap('vacinas'))));
    if (data.containsKey('tabagismo')) summaryWidgets.add(_buildSummaryLine('Tabagismo', _getSmokingSummary(safeMap('tabagismo'))));
    if (data.containsKey('alcool')) summaryWidgets.add(_buildSummaryLine('Álcool', _getAlcoholSummary(safeMap('alcool'))));
    if (data.containsKey('continencia_fecal')) summaryWidgets.add(_buildSummaryLine('Cont. Fecal', _getContinenceSummary(safeMap('continencia_fecal'))));
    if (data.containsKey('continencia_urinaria')) summaryWidgets.add(_buildSummaryLine('Cont. Urinária', _getContinenceSummary(safeMap('continencia_urinaria'))));
    
    if (data.containsKey('orteses_proteses')) {
      final orteses = safeMap('orteses_proteses');
      summaryWidgets.add(_buildSummaryLine('Órteses', orteses['orteses']?.toString() ?? 'Nenhuma'));
      summaryWidgets.add(_buildSummaryLine('Próteses', orteses['proteses']?.toString() ?? 'Nenhuma'));
    }
    if (data.containsKey('sono')) summaryWidgets.add(_buildSummaryLine('Sono', _getSleepSummary(safeMap('sono'))));
    if (data.containsKey('quedas')) summaryWidgets.add(_buildSummaryLine('Quedas (12m)', _getFallsSummary(safeMap('quedas'))));
    if (data.containsKey('atividade_fisica')) summaryWidgets.add(_buildSummaryLine('Atividade Física', _getPhysicalActivitySummary(safeMap('atividade_fisica'))));

    if (summaryWidgets.isEmpty && data.isNotEmpty) {
       data.forEach((key, value) { if (value is! Map) summaryWidgets.add(_buildSummaryLine(key, value.toString())); });
    }
    return summaryWidgets;
  }

  // Helpers de texto (Simplificados)
  String _getVisionSummary(Map<String, dynamic> v) => v['normal'] == true ? 'Normal' : 'Déficit ${v['usa_corretores'] == true ? "(c/ correção)" : ""}';
  String _getHearingSummary(Map<String, dynamic> v) => v['normal'] == true ? 'Normal' : 'Déficit ${v['usa_corretores'] == true ? "(c/ correção)" : ""}';
  String _getVaccineSummary(Map<String, dynamic> v) {
    List<String> t = [];
    if (v['influenza']?['status'] == true) t.add('Influenza');
    if (v['pneumococo']?['status'] == true) t.add('Pneumococo');
    if (v['tetano']?['status'] == true) t.add('Tétano');
    if (v['hepatite_b'] == true) t.add('Hepatite B');
    return t.isEmpty ? 'Pendentes' : t.join(', ');
  }
  String _getSmokingSummary(Map<String, dynamic> s) => s['status'] == 'Ex-fumante' ? 'Ex (${s['parou_ha']})' : (s['status'] ?? '-');
  String _getAlcoholSummary(Map<String, dynamic> a) => a['status'] ?? '-';
  String _getContinenceSummary(Map<String, dynamic> c) => c['status'] == 'Incontinência' ? 'Incontinência (${c['tempo']})' : (c['status'] ?? '-');
  String _getSleepSummary(Map<String, dynamic> s) => s['status'] == 'Distúrbio do sono' ? 'Distúrbio (${s['qual_disturbio']})' : (s['status'] ?? '-');
  String _getFallsSummary(Map<String, dynamic> f) => f['ocorreram'] == 'Sim' ? 'Sim (${f['quantas']}x)' : (f['ocorreram'] ?? '-');
  String _getPhysicalActivitySummary(Map<String, dynamic> p) => p['nao_faz'] == true ? 'Sedentário' : 'Ativo';

  Widget _buildSummaryLine(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: AssessmentColors.primaryBlue.withOpacity(0.6)),
          const SizedBox(width: 8),
          Expanded(child: RichText(text: TextSpan(style: AssessmentTextStyles.itemTitle.copyWith(fontWeight: FontWeight.normal), children: [TextSpan(text: '$title: ', style: TextStyle(fontWeight: FontWeight.bold, color: AssessmentColors.textPrimary)), TextSpan(text: value, style: const TextStyle(color: AssessmentColors.textSecondary))]))),
        ],
      ),
    );
  }
}

// =============================================================================
// 4. TELA PRINCIPAL (WIDGET DE VISUALIZAÇÃO)
// =============================================================================

class AssessmentDetailsViewerScreen extends StatelessWidget {
  final Assessment assessment;
  final Patient patient;

  const AssessmentDetailsViewerScreen({super.key, required this.assessment, required this.patient});

  String _formatDate(String dateString) {
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateString));
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ParsedAssessmentData parsedData = AssessmentDataParser(assessment).parse();

    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco padrão do "estilo antigo"
      appBar: AppBar(
        title: Text(assessment.testName),
        backgroundColor: Colors.white,
        foregroundColor: AssessmentColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined, color: AssessmentColors.primaryBlue),
            tooltip: "Gerar PDF",
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Em desenvolvimento...'), backgroundColor: AssessmentColors.primaryBlue));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER PADRONIZADO (Novo Widget)
              AssessmentReportHeader(
                testName: assessment.testName, 
                patientName: patient.name, 
                date: _formatDate(assessment.date)
              ),
              
              // CONTEÚDO ESPECÍFICO
              _buildReportByType(context, parsedData),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportByType(BuildContext context, ParsedAssessmentData parsedData) {
    if (parsedData.detailedAnswers != null && parsedData.detailedAnswers!.containsKey('tug_observations')) {
      return _buildTugViewer(context, parsedData);
    }
    if (parsedData.detailedAnswers != null && parsedData.detailedAnswers!.containsKey('scores_0_100')) {
      return _buildMosViewer(context, parsedData);
    }

    switch (parsedData.type) {
      case AssessmentType.detailedTest:
        return _buildDetailedTestViewer(context, parsedData);
      case AssessmentType.checklist:
        return _buildChecklistViewer(context, parsedData);
      case AssessmentType.simpleTest:
        return _buildSimpleTestViewer(context, parsedData);
      case AssessmentType.unknown:
        return const Text("Tipo de avaliação desconhecido.", style: TextStyle(color: AssessmentColors.errorRed));
    }
  }

  // --- VISUALIZADORES ESPECÍFICOS USANDO WIDGETS PADRONIZADOS ---

  Widget _buildSimpleTestViewer(BuildContext context, ParsedAssessmentData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssessmentReportTitle(title: "Resultados"),
        
        // SCORE E INTERPRETAÇÃO (Novo Widget)
        AssessmentScoreDisplay(
          score: data.score ?? "-", 
          interpretation: data.interpretation ?? "-"
        ),

        if (data.actualNotes != null && data.actualNotes!.isNotEmpty) ...[
          const AssessmentReportTitle(title: "Anotações"),
          AssessmentNotesBox(notes: data.actualNotes!),
        ],
      ],
    );
  }

  Widget _buildChecklistViewer(BuildContext context, ParsedAssessmentData data) {
    if (data.checklistData == null) return const Text("Dados indisponíveis.");
    final List<Widget> checklistWidgets = ChecklistSummaryGenerator(data.checklistData!).generate();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssessmentReportTitle(title: "Resumo do Checklist"),
        if (checklistWidgets.isEmpty) const Text("Nenhum dado registrado."),
        ...checklistWidgets,
        
        if (data.actualNotes != null && data.actualNotes!.isNotEmpty) ...[
          const AssessmentReportTitle(title: "Anotações"),
          AssessmentNotesBox(notes: data.actualNotes!),
        ],
      ],
    );
  }

  Widget _buildTugViewer(BuildContext context, ParsedAssessmentData data) {
    final List<dynamic> obsList = data.detailedAnswers!['tug_observations'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssessmentReportTitle(title: "Resultados"),
        
        // Container customizado do TUG (pode virar widget se usado em outro lugar)
        AssessmentResultContainer(
          children: [
            const Text("TEMPO TOTAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
            Text(data.score ?? "-", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AssessmentColors.primaryBlue)),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text("INTERPRETAÇÃO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
            Text(data.interpretation ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ]
        ),

        const AssessmentReportTitle(title: "Desvios Observados"),
        if (obsList.isNotEmpty)
          ...obsList.map((obs) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AssessmentColors.warningOrange, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(obs.toString(), style: AssessmentTextStyles.itemTitle)),
              ],
            ),
          ))
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Nenhum desvio de marcha observado.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
          ),

        if (data.actualNotes != null && data.actualNotes!.isNotEmpty) ...[
          const AssessmentReportTitle(title: "Anotações Extras"),
          AssessmentNotesBox(notes: data.actualNotes!),
        ],
      ],
    );
  }

  Widget _buildMosViewer(BuildContext context, ParsedAssessmentData data) {
    final scoresMap = data.detailedAnswers!['scores_0_100'] as Map<String, dynamic>;
    final double overall = (scoresMap['overall'] as num).toDouble();
    
    // Configuração do Gráfico
    final scores = [
      (scoresMap['emotional'] as num).toDouble(),
      (scoresMap['tangible'] as num).toDouble(),
      (scoresMap['affectionate'] as num).toDouble(),
      (scoresMap['positive_interaction'] as num).toDouble(),
      overall
    ];
    const labels = ['Emocional', 'Tangível', 'Afetivo', 'Positiva', 'Geral'];
    final barColors = [Colors.blue.shade600, Colors.green.shade600, Colors.red.shade600, Colors.orange.shade600, AssessmentColors.primaryBlue];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssessmentReportTitle(title: "Resultados Gerais"),
        
        AssessmentResultContainer(
          children: [
            const Text("SCORE GERAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
            Text("${overall.toStringAsFixed(1)} / 100", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AssessmentColors.primaryBlue)),
            const SizedBox(height: 24),
            Center(child: Text("GRÁFICO DE SUPORTE SOCIAL", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AssessmentColors.textPrimary))),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.5,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100, minY: 0,
                  gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (val) => FlLine(color: Colors.grey.shade300, strokeWidth: 0.8)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 25, getTitlesWidget: (val, _) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 9)))),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 42, getTitlesWidget: (val, _) {
                      final index = val.toInt();
                      return (index >= 0 && index < labels.length) 
                        ? Padding(padding: const EdgeInsets.only(top: 6.0), child: Text(labels[index], textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold))) 
                        : const Text('');
                    })),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: List.generate(scores.length, (index) => BarChartGroupData(
                    x: index,
                    barRods: [BarChartRodData(toY: scores[index], color: barColors[index], width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
                  )),
                  barTouchData: BarTouchData(enabled: false),
                ),
              ),
            ),
          ],
        ),

        if (data.actualNotes != null && data.actualNotes!.isNotEmpty) ...[
          const AssessmentReportTitle(title: "Anotações"),
          AssessmentNotesBox(notes: data.actualNotes!),
        ],
      ],
    );
  }

  Widget _buildDetailedTestViewer(BuildContext context, ParsedAssessmentData data) {
    final List<dynamic> answers = data.detailedAnswers?['detailed_answers'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssessmentReportTitle(title: "Resultados Gerais"),
        AssessmentScoreDisplay(
          score: data.score ?? "-", 
          interpretation: data.interpretation ?? "-"
        ),

        if (data.detailedAnswers!.containsKey('motor_score'))
          AssessmentInfoRow(label: "Score Motor", value: data.detailedAnswers!['motor_score'].toString()),
        if (data.detailedAnswers!.containsKey('cognitive_score'))
          AssessmentInfoRow(label: "Score Cognitivo", value: data.detailedAnswers!['cognitive_score'].toString()),

        if (data.actualNotes != null && data.actualNotes!.isNotEmpty) ...[
          const AssessmentReportTitle(title: "Anotações"),
          AssessmentNotesBox(notes: data.actualNotes!),
        ],

        const AssessmentReportTitle(title: "Detalhamento"),
        ..._buildDetailedAnswersSection(answers),
      ],
    );
  }

  List<Widget> _buildDetailedAnswersSection(List<dynamic> answers) {
    if (answers.isEmpty) return [const Text("Nenhuma resposta detalhada salva.")];
    final Map<String, dynamic> firstAnswer = answers.first as Map<String, dynamic>;

    if (firstAnswer.containsKey('task')) { 
      return _buildMifOrBergAnswers(answers); 
    } else { 
      return answers.map<Widget>((dynamic answer) {
        final Map<String, dynamic> a = answer as Map<String, dynamic>;
        final String question = a['activity'] ?? a['category'] ?? a['question'] ?? '...';
        final String val = a['answer']?.toString() ?? '';
        final String pts = a['points']?.toString() ?? '0';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question, style: AssessmentTextStyles.itemSubtitle),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(val, style: AssessmentTextStyles.itemTitle)),
                  const SizedBox(width: 12),
                  Text("$pts pts", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AssessmentColors.primaryBlue)),
                ],
              ),
              const Divider(),
            ],
          ),
        );
      }).toList();
    }
  }

  List<Widget> _buildMifOrBergAnswers(List<dynamic> answers) {
    return answers.map<Widget>((dynamic answer) {
      final Map<String, dynamic> a = answer as Map<String, dynamic>;
      final String task = a['task'] ?? '...';
      final String score = a['score']?.toString() ?? '-';
      final String level = a['level']?.toString() ?? ''; 

      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task, style: AssessmentTextStyles.itemSubtitle),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AssessmentColors.primaryBlue.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(score, style: TextStyle(fontWeight: FontWeight.bold, color: AssessmentColors.primaryBlue)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(level, style: AssessmentTextStyles.itemTitle)),
              ],
            ),
            const Divider(),
          ],
        ),
      );
    }).toList();
  }
}