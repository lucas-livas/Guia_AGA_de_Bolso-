# ✅ Refatoração BergScreen — Separacão de Lógica

## Data
2026-04-30

## Objetivo
Separar a lógica de cálculo da UI na tela Berg Balance Scale (Escala de Equilíbrio de Berg).

## Mudancas Implementadas

### 1. Nova Estrutura de Diretórios
```
lib/
├── data/
│   └── assessment_items/
│       └── berg_items.dart          # AnswerOption, BergItem, bergBalanceItems
├── services/
│   └── assessment/
│       └── calculation/
│           └── berg_calculation_service.dart  # BergCalculationService
└── screens/
    └── 1_Home/
        └── Funcional/
            └── berg_screen.dart      # Apenas UI (State + Widgets)
```

### 2. Conteúdo Extraído

**`lib/data/assessment_items/berg_items.dart`**
- `class AnswerOption` (text, points)
- `class BergItem` (task, options)
- `const List<BergItem> bergBalanceItems` (14 itens da escala Berg)

**`lib/services/assessment/calculation/berg_calculation_service.dart`**
- `BergCalculationService` (replace de `BergLogic` original)
  - `static const int maxScore = 56`
  - `static int calculateScore(Map<int, AnswerOption> answers)`
  - `static String getInterpretation(int score)`
  - `static String getScoreText(int score)`

### 3. Modificações em `berg_screen.dart`
- Removidas as `class AnswerOption` e `class BergItem` (agora em `berg_items.dart`)
- Removida constante `bergBalanceItems` (agora em `berg_items.dart`)
- Removida `class BergLogic` (substituída por `BergCalculationService`)
- Adicionados imports:
  ```dart
  import 'package:guia_aga_de_bolso/data/assessment_items/berg_items.dart';
  import 'package:guia_aga_de_bolso/services/assessment/calculation/berg_calculation_service.dart';
  ```
- Substituídas todas as referências:
  - `BergLogic.calculateScore` → `BergCalculationService.calculateScore`
  - `BergLogic.getInterpretation` → `BergCalculationService.getInterpretation`
  - `BergLogic.maxScore` → `BergCalculationService.maxScore`

### 4. Correçõs Adicionais
- `badgeColor.withOpacity(0.1)` → `badgeColor.withValues(alpha: 0.1)` (Flutter 3.x)

## Status de Compilação
✅ **Sem erros**. Apenas warnings de `withOpacity` em outros arquivos (não nesta tela).

## Próximos Passos Sugeridos
1. Aplicar o mesmo padrão para as outras telas de avaliação:
   - TUG (falta ValidationService)
   - MIF/Katz/LawtonBrody/GDS15/MEEM/MOS (já têm CalculationServices — extrair)
   - MNA (já tem ambos services — pode extrair)
2. Criar `ValidationServices` para TUG e Berg
3. Extrair dados constantes (items) para `lib/data/assessment_items/`
4. Criar testes unitários para os services de cálculo

## Padrão Estabelecido
```dart
// Na tela
import 'package:guia_aga_de_bolso/data/assessment_items/xxx_items.dart';
import 'package:guia_aga_de_bolso/services/assessment/calculation/xxx_calculation_service.dart';

// State
int get _currentScore => XxxCalculationService.calculateScore(_answers);
String get _interpretation => XxxCalculationService.getInterpretation(_currentScore);
```
