// Arquivo: lib/models/medication_data.dart
import 'dart:convert';

// --- 1. O que o paciente toma (Dados Dinâmicos) ---
class PrescribedMedication {
  String drugName;
  String presentation; // Comprimido, Injeção, etc.
  String dosage;       // 25mg, 50mg
  String frequency;    // 1x ao dia, 8/8h
  String time;         // 07:00
  String notes;        // Observações extras

  PrescribedMedication({
    required this.drugName,
    required this.presentation,
    required this.dosage,
    required this.frequency,
    required this.time,
    this.notes = '',
  });

  // Converter para Map (para salvar como JSON)
  Map<String, dynamic> toMap() {
    return {
      'drugName': drugName,
      'presentation': presentation,
      'dosage': dosage,
      'frequency': frequency,
      'time': time,
      'notes': notes,
    };
  }

  // Criar a partir de Map (ao ler do JSON)
  factory PrescribedMedication.fromMap(Map<String, dynamic> map) {
    return PrescribedMedication(
      drugName: map['drugName'] ?? '',
      presentation: map['presentation'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      time: map['time'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  // Helpers para lista JSON
  static String encodeList(List<PrescribedMedication> meds) => 
      jsonEncode(meds.map((e) => e.toMap()).toList());

  static List<PrescribedMedication> decodeList(String jsonString) {
    if (jsonString.isEmpty) return [];
    try {
      final List<dynamic> parsed = jsonDecode(jsonString);
      return parsed.map((e) => PrescribedMedication.fromMap(e)).toList();
    } catch (e) {
      return []; // Retorna vazio se não for JSON válido (compatibilidade com dados antigos)
    }
  }
}

// --- 2. O Catálogo de Referência (Bulário Fixo) ---
class DrugReference {
  final String name;
  final String description;
  final String commercialNames;
  final String therapeuticClass;
  final String indications;
  final String dosageInfo;
  final String contraindications;

  const DrugReference({
    required this.name,
    required this.description,
    required this.commercialNames,
    required this.therapeuticClass,
    required this.indications,
    required this.dosageInfo,
    required this.contraindications,
  });
}

// --- 3. Base de Dados Mockada ---
class DrugDatabase {
  static final List<DrugReference> allDrugs = [
    const DrugReference(
      name: 'Losartana Potássica',
      description: 'A losartana é o BRA mais prescrito no Brasil, amplamente distribuído pelo Programa Farmácia Popular. Sua eficácia na redução da morbidade e mortalidade cardiovascular em pacientes hipertensos com hipertrofia ventricular esquerda foi bem documentada. Na geriatria, destaca-se por sua boa tolerabilidade e proteção contra a progressão da nefropatia diabética.',
      commercialNames: 'Cozaar, Aradois, Zart, Torlós.',
      therapeuticClass: 'Antagonista do Receptor de Angiotensina II (BRA II).',
      indications: 'Tratamento de hipertensão arterial; redução do risco de AVC em hipertensos com HVE; proteção renal em pacientes com DM2 e proteinúria.',
      dosageInfo: 'Adulto/Geriátrica: Inicial de 50mg, 1x ao dia. Pode ir a 100mg. Idosos com depleção: iniciar com 25mg.',
      contraindications: 'Hipersensibilidade; gravidez (2º e 3º tri); uso com alisquireno em diabéticos; insuficiência hepática grave.',
    ),
    // Adicione mais medicamentos aqui futuramente...
    const DrugReference(
      name: 'Dipirona',
      description: 'Analgésico e antitérmico muito utilizado.',
      commercialNames: 'Novalgina, Anador.',
      therapeuticClass: 'Analgésico não-opioide / Antipirético.',
      indications: 'Dor e Febre.',
      dosageInfo: 'Adultos: 500mg a 1g a cada 6 horas.',
      contraindications: 'Alergia a pirazolonas, discrasias sanguíneas, porfiria.',
    ),
  ];

  static DrugReference? findByName(String query) {
    try {
      return allDrugs.firstWhere((d) => d.name.toLowerCase().contains(query.toLowerCase()));
    } catch (e) {
      return null;
    }
  }
}