# Arquitetura de Separacão de Lógica de Avaliacao

## Visão Geral

Cada tela de avaliação foi refatorada para separar claramente:
- **UI (View)**: Widgets Flutter, apenas apresentação
- **Lógica de Negócio (Services)**: Cálculos, validações, interpretacões
- **Dados (Models/Items)**: Estrutura das questões e respostas

## Estrutura de Diretórios

```
lib/
├── models/
│   ├── assessment_model.dart          # Modelo principal de Avaliacao
│   └── patient_model.dart             # Modelo de Paciente
├── data/
│   └── assessment_items/               # Questões estáticas de cada teste
│       ├── mna_items.dart              # manTriagemItems + manGlobalItems
│       ├── berg_items.dart             # bergBalanceItems
│       ├── tug_items.dart              # tugItems
│       ├── katz_items.dart             # katzItems
│       ├── lawton_brody_items.dart     # lawtonBrodyItems
│       ├── fim_items.dart              # fimItems
│       ├── gds15_items.dart            # gds15Items
│       ├── meem_items.dart             # meemItems
│       └── mos_items.dart              # mosSocialSupportItems
├── services/
│   └── assessment/
│       ├── calculation/                # Servicos de calculo de score
│       │   ├── mna_calculation_service.dart
│       │   ├── berg_calculation_service.dart
│       │   ├── tug_calculation_service.dart
│       │   ├── katz_calculation_service.dart
│       │   ├── lawton_brody_calculation_service.dart
│       │   ├── fim_calculation_service.dart
│       │   ├── gds15_calculation_service.dart
│       │   ├── meem_calculation_service.dart
│       │   └── mos_calculation_service.dart
│       ├── validation/                 # Servicos de validacão de respostas
│       │   ├── mna_validation_service.dart
│       │   ├── katz_validation_service.dart
│       │   ├── lawton_brody_validation_service.dart
│       │   ├── fim_validation_service.dart
│       │   ├── gds15_validation_service.dart
│       │   ├── meem_validation_service.dart
│       │   └── mos_validation_service.dart
│       └── assessment_service.dart     # Servico unificado (opcional)
└── screens/
    └── ... (telas apenas UI, sem lógica)
```

## Padrão de Serviço de Cálculo

Cada `*CalculationService` segue o mesmo padrão:

```dart
class XXXCalculationService {
  static const int maxScore = ...;

  // Calcula o score total a partir do Map de respostas
  static int/double calculateScore(Map<Key, AnswerOption> answers) {
    return answers.values.fold(0, (sum, ans) => sum + ans.points);
  }

  // Retorna a interpretacão textual do score
  static String getInterpretation(int/double score) {
    if (score >= ...) return '...';
    // ...
  }

  // Retorna o score formatado para exibicão
  static String getScoreText(int/double score) {
    return '$score / $maxScore';
  }
}
```

## Padrão de Serviço de Validação

Cada `*ValidationService`:

```dart
class XXXValidationService {
  // Valida se todas as respostas obrigatórias foram dadas
  static String? validateCompletion(Map<Key, AnswerOption> answers) {
    if (answers.length < totalItems) {
      return 'Responda todas as questões.';
    }
    return null; // OK
  }

  // Valida regras especiais (ex: IMC ou circunferência da panturrilha no MNA)
  static String? validateSpecificRules(...) { ... }
}
```

## Modelo de Item e Resposta

Padronizado para todas as avaliações:

```dart
class AnswerOption {
  final String text;      // Texto da opcão
  final double points;    // Pontuacão (sempre numérico)
  const AnswerOption({required this.text, required this.points});
}

class XXXItem {
  final String id;              // Identificador único (A, B, C...)
  final String question;        # Enunciado
  final List<AnswerOption> options;
  const XXXItem({required this.id, required this.question, required this.options});
}
```

## Estado na Tela (State)

Após separacão, o State da tela contém apenas:

```dart
class _XXXScreenState extends State<XXXScreen> {
  // Estado: respostas do usuário
  final Map<String, AnswerOption> _answers = {};

  // Computed properties (usam os services)
  int get _currentScore => XXXCalculationService.calculateScore(_answers);
  String get _interpretation => XXXCalculationService.getInterpretation(_currentScore);
  bool get _isComplete => _answers.length == xxxItems.length;
  String? get _validationError => XXXValidationService.validateCompletion(_answers);

  // Métodos de UI
  void _onAnswerSelected(String key, AnswerOption option) { ... }
  Future<void> _saveAssessment() async { ... }
  void _resetTest() async { ... }

  @override
  Widget build(BuildContext context) { ... }
}
```

## Benefícios

1. **Testabilidade**: Lógica pode ser testada unitariamente sem Flutter
2. **Manutenibilidade**: Cálculo centralizado, fácil alterar fórmula
3. **Reutilização**: Mesmo serviço pode servir múltiplas telas (ex: detalhes)
4. ** Clareza**: Fácil entender o que a tela faz vs como calcula

## Status Atual

| Tela | Calculation | Validation | Local |
|------|-------------|------------|--------|
| MNA  | ✅ Separado | ✅ Separado | No arquivo |
| TUG  | ✅ Separado | ❌ Falta   | No arquivo |
| Berg | ✅ Separado | ❌ Falta   | No arquivo |
| Katz | ✅ Separado | ✅ Separado | No arquivo |
| Lawton&Brody | ✅ Separado | ✅ Separado | No arquivo |
| MIF  | ✅ Separado | ✅ Separado | No arquivo |
| GDS15| ✅ Separado | ✅ Separado | No arquivo |
| MEEM | ✅ Separado | ✅ Separado | No arquivo |
| MOS  | ✅ Separado | ✅ Separado | No arquivo |

## Próximos Passos

1. **Criar diretórios** `lib/services/assessment/{calculation,validation}`
2. **Extrair** cada `*CalculationService` e `*ValidationService` para arquivos separados
3. **Criar** `BergValidationService` e `TUGValidationService` onde faltam
4. **Atualizar imports** nas telas para usar os serviços extraídos
5. **Extrair** dados estáticos (`*Items`) para `lib/data/assessment_items/`
6. **Testar** cada tela após refatoracão
