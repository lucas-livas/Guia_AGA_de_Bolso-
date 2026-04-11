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
    // --- Anti-hipertensivos e Cardiovasculares ---
    const DrugReference(
      name: 'Losartana Potássica',
      description: 'A losartana é o BRA mais prescrito no Brasil, amplamente distribuído pelo Programa Farmácia Popular. Sua eficácia na redução da morbidade e mortalidade cardiovascular em pacientes hipertensos com hipertrofia ventricular esquerda foi bem documentada. Na geriatria, destaca-se por sua boa tolerabilidade e proteção contra a progressão da nefropatia diabética.',
      commercialNames: 'Cozaar, Aradois, Zart, Torlós.',
      therapeuticClass: 'Antagonista do Receptor de Angiotensina II (BRA II).',
      indications: 'Tratamento de hipertensão arterial; redução do risco de AVC em hipertensos com HVE; proteção renal em pacientes com DM2 e proteinúria.',
      dosageInfo: 'Adulto/Geriátrica: Inicial de 50mg, 1x ao dia. Pode ir a 100mg. Idosos com depleção: iniciar com 25mg.',
      contraindications: 'Hipersensibilidade; gravidez (2º e 3º tri); uso com alisquireno em diabéticos; insuficiência hepática grave.',
    ),
    const DrugReference(
      name: 'Hidroclorotiazida',
      description: 'Diurético frequentemente utilizado como primeira escolha no manejo da HAS leve a moderada. Em idosos, exige monitoramento frequente devido ao alto risco de causar hiponatremia e hipocalemia, além de poder agravar incontinência urinária.',
      commercialNames: 'Clorana, Diurex.',
      therapeuticClass: 'Diurético Tiazídico.',
      indications: 'Hipertensão arterial sistêmica, controle de edema.',
      dosageInfo: 'Geriátrica: Geralmente inicia-se com 12,5 mg a 25 mg pela manhã (evitar à noite para prevenir noctúria).',
      contraindications: 'Anúria, insuficiência renal grave, hipersensibilidade a derivados das sulfonamidas.',
    ),
    const DrugReference(
      name: 'Anlodipino',
      description: 'Bloqueador de canal de cálcio muito eficaz no controle pressórico de idosos, particularmente na hipertensão sistólica isolada. É comum causar edema de membros inferiores não relacionado à insuficiência cardíaca.',
      commercialNames: 'Pressat, Roxflan, Cordarex.',
      therapeuticClass: 'Bloqueador de Canal de Cálcio (Diidropiridínico).',
      indications: 'Hipertensão arterial, angina crônica estável.',
      dosageInfo: 'Geriátrica: Iniciar com 2,5 mg a 5 mg, 1x ao dia. Máximo 10 mg/dia.',
      contraindications: 'Hipotensão severa, choque cardiogênico.',
    ),
    const DrugReference(
      name: 'Ácido Acetilsalicílico (AAS)',
      description: 'Bastante utilizado na prevenção secundária de eventos cardiovasculares. O uso na prevenção primária em idosos vem sendo desencorajado devido ao aumento do risco de sangramento gastrointestinal sem benefício claro que supere os riscos.',
      commercialNames: 'Aspirina, Somalgin Cardio, AAS Protect.',
      therapeuticClass: 'Antiagregante Plaquetário.',
      indications: 'Prevenção secundária de IAM e AVC isquêmico.',
      dosageInfo: 'Adultos/Idosos: 100 mg, 1x ao dia.',
      contraindications: 'Úlcera péptica ativa, histórico de sangramento gastrointestinal severo, alergia a salicilatos.',
    ),

    // --- Analgésicos ---
    const DrugReference(
      name: 'Dipirona',
      description: 'Analgésico e antitérmico muito utilizado no Brasil. Considerada segura para idosos quando comparada aos AINEs (anti-inflamatórios não esteroidais), que devem ser evitados na geriatria devido a riscos renais e gástricos.',
      commercialNames: 'Novalgina, Anador, Lisador.',
      therapeuticClass: 'Analgésico não-opioide / Antipirético.',
      indications: 'Dor e febre leves a moderadas.',
      dosageInfo: 'Adultos/Idosos: 500mg a 1g, a cada 6 a 8 horas. Evitar doses máximas diárias prolongadas.',
      contraindications: 'Hipersensibilidade a pirazolonas, discrasias sanguíneas severas, porfiria hepática aguda.',
    ),
    const DrugReference(
      name: 'Paracetamol',
      description: 'Primeira linha para o tratamento de dores osteoarticulares leves (como osteoartrite) em idosos, devido ao baixo perfil de efeitos colaterais gastrointestinais. Requer atenção à dose máxima diária pelo risco de hepatotoxicidade.',
      commercialNames: 'Tylenol, Dôrico.',
      therapeuticClass: 'Analgésico não-opioide / Antipirético.',
      indications: 'Dor leve a moderada, febre.',
      dosageInfo: 'Geriátrica: 500 mg a 750 mg a cada 6-8 horas. Recomenda-se não ultrapassar 3g ao dia no idoso.',
      contraindications: 'Insuficiência hepática grave, alcoolismo crônico.',
    ),

    // --- Controle Metabólico e Endócrino ---
    const DrugReference(
      name: 'Cloridrato de Metformina',
      description: 'Tratamento de primeira linha para Diabetes Mellitus tipo 2. Em idosos, a função renal (Taxa de Filtração Glomerular - TFG) deve ser rigorosamente avaliada antes e durante o uso, pelo risco de acidose lática.',
      commercialNames: 'Glifage, Dimefor, Formet.',
      therapeuticClass: 'Antidiabético Oral (Biguanida).',
      indications: 'Diabetes Mellitus tipo 2.',
      dosageInfo: 'Início com 500 mg, 1 a 2x ao dia com as refeições. Ajustar de acordo com TFG (contraindicado se TFG < 30 mL/min).',
      contraindications: 'Insuficiência renal grave, insuficiência cardíaca congestiva aguda, alcoolismo, condições que predisponham à hipóxia.',
    ),
    const DrugReference(
      name: 'Levotiroxina Sódica',
      description: 'Hormônio tireoidiano para reposição no hipotireoidismo, distúrbio muito comum no envelhecimento. Em idosos, especialmente os cardiopatas, a introdução deve ser lenta ("start low, go slow") para evitar precipitação de arritmias ou angina.',
      commercialNames: 'Puran T4, Synthroid, Euthyrox.',
      therapeuticClass: 'Hormônio Tireoidiano.',
      indications: 'Hipotireoidismo.',
      dosageInfo: 'Geriátrica: Iniciar com 12,5 a 25 mcg ao dia, em jejum (pelo menos 30 min antes do café).',
      contraindications: 'Infarto agudo do miocárdio não tratado, insuficiência adrenal não corrigida, tireotoxicose não tratada.',
    ),
    const DrugReference(
      name: 'Sinvastatina',
      description: 'Estatinas são fundamentais no controle da dislipidemia. Em idosos com polifarmácia, a sinvastatina exige atenção especial a interações medicamentosas (ex: anlodipino, amiodarona) e queixas de mialgia/fraqueza muscular.',
      commercialNames: 'Zocor, Sinvascor.',
      therapeuticClass: 'Hipolipemiante (Estatina).',
      indications: 'Hipercolesterolemia, prevenção de eventos isquêmicos.',
      dosageInfo: 'Geriátrica: 10 mg a 40 mg, preferencialmente à noite. Dose pode precisar de redução com fármacos concomitantes.',
      contraindications: 'Doença hepática ativa, elevação persistente e inexplicada de transaminases.',
    ),

    // --- Trato Gastrointestinal ---
    const DrugReference(
      name: 'Omeprazol',
      description: 'Inibidor de bomba de prótons amplamente utilizado, muitas vezes de forma indiscriminada (cascata de prescrição). O uso crônico em idosos está associado a risco de deficiência de B12, hipomagnesemia e maior risco de quedas e fraturas.',
      commercialNames: 'Losec, Peprazol, Estomazil.',
      therapeuticClass: 'Inibidor da Bomba de Prótons (IBP).',
      indications: 'Tratamento de úlceras pépticas, DRGE (Refluxo), proteção gástrica em uso crônico de AINEs/AAS.',
      dosageInfo: 'Geriátrica: 20 mg a 40 mg ao dia, geralmente em jejum pela manhã.',
      contraindications: 'Hipersensibilidade aos componentes da fórmula. Cuidado no uso prolongado sem indicação clara.',
    ),
    // --- Sistema Nervoso Central (SNC) e Psiquiátricos ---
    const DrugReference(
      name: 'Donepezila',
      description: 'Inibidor da colinesterase usado no tratamento da Doença de Alzheimer leve a moderada. Pode causar efeitos colaterais gastrointestinais e, mais raramente, bradicardia e síncope. O fisioterapeuta deve ter atenção redobrada ao risco de quedas durante a reabilitação motora.',
      commercialNames: 'Eranz, Alzepil, Don.',
      therapeuticClass: 'Inibidor da Acetilcolinesterase.',
      indications: 'Demência na Doença de Alzheimer.',
      dosageInfo: 'Geriátrica: Iniciar com 5 mg, 1x ao dia, à noite. Pode ser aumentada para 10 mg após 4 a 6 semanas.',
      contraindications: 'Hipersensibilidade a derivados de piperidina. Cuidado em pacientes com distúrbios de condução cardíaca (bloqueio sinoatrial ou atrioventricular).',
    ),
    const DrugReference(
      name: 'Sertralina',
      description: 'Antidepressivo Inibidor Seletivo da Recaptação de Serotonina (ISRS). É frequentemente a primeira escolha para idosos devido ao seu perfil cardiovascular seguro. Requer monitoramento no início do tratamento pelo risco de causar hiponatremia (baixo sódio no sangue), o que pode gerar letargia e confusão mental.',
      commercialNames: 'Zoloft, Tolrest, Assert.',
      therapeuticClass: 'Antidepressivo (ISRS).',
      indications: 'Depressão maior, transtornos de ansiedade.',
      dosageInfo: 'Geriátrica: Iniciar com 25 mg, 1x ao dia pela manhã. Aumentar gradualmente se necessário.',
      contraindications: 'Uso concomitante com inibidores da MAO ou pimozida.',
    ),
    const DrugReference(
      name: 'Quetiapina',
      description: 'Antipsicótico atípico. Muito prescrito em baixas doses (off-label) para controle de insônia e agitação em quadros demenciais. Seu uso em idosos exige cautela pois aumenta significativamente o risco de hipotensão ortostática (queda de pressão ao levantar), sedação diurna excessiva e quedas.',
      commercialNames: 'Seroquel, Neotiapim, Quetros.',
      therapeuticClass: 'Antipsicótico Atípico.',
      indications: 'Esquizofrenia, transtorno bipolar. Off-label: agitação na demência, insônia severa.',
      dosageInfo: 'Geriátrica (para agitação/insônia): Doses muito baixas, iniciando com 12,5 mg a 25 mg à noite.',
      contraindications: 'Atenção: Aumento do risco de mortalidade em idosos com psicose relacionada à demência.',
    ),
    const DrugReference(
      name: 'Clonazepam',
      description: 'Benzodiazepínico de longa duração. Consta nos Critérios de Beers como medicação potencialmente inapropriada na geriatria. Causa acúmulo no organismo envelhecido, levando a delírio, declínio cognitivo, sedação profunda e altíssimo índice de fraturas por queda. Caso o paciente faça uso crônico, a conduta ideal em equipe multidisciplinar é o desmame gradual.',
      commercialNames: 'Rivotril, Clopam.',
      therapeuticClass: 'Ansiolítico Benzodiazepínico.',
      indications: 'Transtornos de ansiedade, crises epilépticas.',
      dosageInfo: 'Geriátrica: Evitar o uso. Se estritamente necessário, usar a menor dose possível (ex: 0,25 mg) e por tempo restrito.',
      contraindications: 'Miastenia gravis, insuficiência hepática grave, glaucoma de ângulo fechado, apneia do sono, histórico de quedas frequentes.',
    ),
    const DrugReference(
      name: 'Memantina',
      description: 'Antagonista do receptor NMDA. Geralmente adicionada ao tratamento quando a Doença de Alzheimer progride para a fase moderada a grave. Costuma ser bem tolerada, mas pode causar tontura, dor de cabeça e constipação.',
      commercialNames: 'Ebix, Alois, Heimer.',
      therapeuticClass: 'Antagonista dos receptores NMDA.',
      indications: 'Doença de Alzheimer moderada a grave.',
      dosageInfo: 'Geriátrica: Iniciar com 5 mg ao dia pela manhã. Aumentar 5 mg por semana até atingir a dose alvo de 20 mg ao dia.',
      contraindications: 'Hipersensibilidade ao fármaco. Precaução em pacientes com insuficiência renal grave ou histórico de convulsões.',
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