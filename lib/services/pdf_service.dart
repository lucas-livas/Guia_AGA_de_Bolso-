import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

// Imports dos seus Modelos
import 'package:guia_aga_de_bolso/models/patient_model.dart';
import 'package:guia_aga_de_bolso/models/medication_data.dart';

class PdfService {
  // Cores Profissionais
  static const _primaryBlue = PdfColor.fromInt(0xFF0D47A1); // Azul Marinho
  static const _borderColor = PdfColor.fromInt(0xFFBBDEFB); // Azul Claro para bordas

  static Future<void> generatePatientRecord(Patient patient) async {
    final doc = pw.Document();
    
    // Carregamento do Logótipo dos assets
    final ByteData logoData = await rootBundle.load('assets/images/logo_aga.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(logoBytes);

    final List<PrescribedMedication> meds = PrescribedMedication.decodeList(patient.medicationList);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        header: (context) => _buildProfessionalHeader(logoImage),
        footer: (context) => _buildProfessionalFooter(context),
        build: (context) => [
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text('FICHA DO PACIENTE', 
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, letterSpacing: 1.2)
            ),
          ),
          pw.SizedBox(height: 25),

          // --- SEÇÃO: IDENTIFICAÇÃO ---
          _buildSectionHeader('Identificação'),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _primaryBlue, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    _buildProfessionalCell('NOME COMPLETO DO PACIENTE', patient.name, flex: 3),
                    _buildProfessionalCell('DATA DE NASCIMENTO', patient.birthDate, flex: 1, hasLeftBorder: true),
                  ],
                ),
                pw.Divider(height: 0, thickness: 0.8, color: _primaryBlue),
                pw.Row(
                  children: [
                    _buildProfessionalCell('SEXO', patient.gender, flex: 3),
                    _buildProfessionalCell('CONTATO DE EMERGÊNCIA', patient.emergencyContact, flex: 2, hasLeftBorder: true),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 25),

          // --- SEÇÃO: DADOS COMPLEMENTARES ---
          _buildSectionHeader('Dados complementares'),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _primaryBlue, width: 0.8),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  children: [
                    _buildProfessionalCell('PROFISSÃO / OCUPAÇÃO', patient.occupation),
                    _buildProfessionalCell('ESCOLARIDADE', patient.educationLevel, hasLeftBorder: true),
                    _buildProfessionalCell('ESTADO CIVIL', patient.maritalStatus, hasLeftBorder: true),
                  ],
                ),
                pw.Divider(height: 0, thickness: 0.8, color: _primaryBlue),
                pw.Row(
                  children: [
                    _buildProfessionalCell('NACIONALIDADE', patient.nationality),
                    _buildProfessionalCell('NATURALIDADE', patient.placeOfBirth, hasLeftBorder: true),
                    _buildProfessionalCell('RAÇA / COR', patient.race, hasLeftBorder: true),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 25),

          // --- SEÇÃO: ANAMNESE E HISTÓRIA CLÍNICA ---
          _buildSectionHeader('Anamnese e História Clínica'),
          _buildProfessionalLineRow('QUEIXA PRINCIPAL (QP)', patient.chiefComplaint),
          _buildProfessionalLineRow('HISTÓRIA DA DOENÇA ATUAL (HDA)', patient.hda),
          _buildProfessionalLineRow('HISTÓRICO MÉDICO PREGRESSO (HMP)', patient.pastMedicalHistory),
          
          pw.SizedBox(height: 20),
          
          // --- SEÇÃO: MEDICAMENTOS ---
          _buildSectionHeader('Medicamentos em Uso'),
          if (meds.isEmpty)
             _buildProfessionalLineRow('LISTA DE MEDICAMENTOS', 'Nenhum medicamento registrado.')
          else
            pw.Table.fromTextArray(
              headers: ['MEDICAMENTO', 'APRESENTAÇÃO', 'DOSE', 'HORÁRIOS'],
              data: meds.map((m) => [m.drugName.toUpperCase(), m.presentation, m.dosage, '${m.frequency} - ${m.time}']).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: _primaryBlue),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellPadding: const pw.EdgeInsets.all(6),
              border: pw.TableBorder.all(color: _primaryBlue, width: 0.5),
            ),

          pw.SizedBox(height: 20),
          _buildProfessionalLineRow('HISTÓRIAS SOCIAL E FAMILIAR', patient.socialHistory),
          _buildProfessionalLineRow('AMBIENTE DOMICILIAR', patient.homeEnvironment),
          _buildProfessionalLineRow('OUTRAS OBSERVAÇÕES', patient.notes),
        ],
      ),
    );

    final pdfBytes = await doc.save();
    await Printing.sharePdf(
      bytes: pdfBytes, 
      filename: 'Ficha_Clinica_${patient.name.replaceAll(' ', '_')}.pdf',
    );
  }

  // --- COMPONENTES VISUAIS PROFISSIONAIS ---

  static pw.Widget _buildProfessionalHeader(pw.MemoryImage logo) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _primaryBlue, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(logo, width: 60), // Logótipo original à esquerda
              pw.SizedBox(height: 2),
              pw.Text(
                'Avaliação Geriátrica Ampla', 
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'RELATÓRIO CLÍNICO OFICIAL', 
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()), 
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildProfessionalCell(String label, String value, {int flex = 1, bool hasLeftBorder = false}) {
    return pw.Expanded(
      flex: flex,
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: pw.BoxDecoration(
          border: hasLeftBorder ? const pw.Border(left: pw.BorderSide(color: _primaryBlue, width: 0.8)) : null,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
            pw.SizedBox(height: 2),
            pw.Text(value.isEmpty ? '---' : value.toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Container(width: 3, height: 14, color: _primaryBlue),
          pw.SizedBox(width: 6),
          pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: _primaryBlue)),
        ],
      ),
    );
  }

  static pw.Widget _buildProfessionalLineRow(String label, String value) {
    return pw.Container(
      width: double.infinity,
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.only(bottom: 4),
      decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: _borderColor, width: 0.5))),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
          pw.SizedBox(height: 2),
          pw.Text(value.isEmpty ? 'NADA CONSTA' : value, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.justify),
        ],
      ),
    );
  }

  static pw.Widget _buildProfessionalFooter(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Documento gerado digitalmente pelo sistema AGA de Bolso', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
          pw.Text('Página ${context.pageNumber} de ${context.pagesCount}', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        ],
      ),
    );
  }
}