# 🎨 Sistema de Temas e Paletas

## 📋 Visão Geral

O sistema de temas do **Guia AGA de Bolso** é responsável pela personalização visual do aplicativo através de **6 paletas de cores** pré-definidas. O modo noturno **não está implementado** nesta versão.

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│  Camada de Apresentação (Widgets)                          │
│  └─ Uses: AssessmentColors.primaryBlue, backgroundLight    │
├─────────────────────────────────────────────────────────────┤
│  Camada de Abstração (assessment_widgets.dart)            │
│  └─ AssessmentColors / AssessmentGradients (getters)      │
├─────────────────────────────────────────────────────────────┤
│  Gerenciador Central (Temas_Gerenciador.dart)              │
│  ├─ AppTheme (data class)                                  │
│  ├─ ThemeManager (singleton + ValueNotifier)              │
│  └─ palettes [list estática de 6 temas]                   │
├─────────────────────────────────────────────────────────────┤
│  Persistência (SharedPreferences)                          │
│  └─ Salva índice da paleta selecionada                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📦 Componentes

### 1. `AppTheme` (Data Class)

Define uma paleta de cores completa:

```dart
class AppTheme {
  final String name;              // Nome da paleta (ex: "Clássico (Azul)")
  final Color primary;            // Cor principal (brand color)
  final Color light;              // Versão clara (cards, chips)
  final Color dark;               // Versão escura (textos, ícones)
  final Color background;         // Fundo da tela
  final Color textPrimary;        // Cor de texto principal (default: black87)

  // Gradientes para cada seção do app
  final Gradient gradientPatient;
  final Gradient gradientFunctional;
  final Gradient gradientCognitive;
  final Gradient gradientClinical;
  final Gradient gradientSocial;
  final Gradient gradientGuides;
}
```

**Observação:** `textPrimary` tem default `Colors.black87` e pode ser sobrescrito por paleta.

---

### 2. `ThemeManager` (Singleton)

Gerencia o estado atual da paleta selecionada.

#### Propriedades

| Propriedade | Tipo | Descrição |
|-------------|------|-----------|
| `current` | `AppTheme` | Getter estático para o tema ativo (valor atual do notifier) |
| `currentThemeNotifier` | `ValueNotifier<AppTheme>` | Notifier para rebuilds reativos (usado no `ValueListenableBuilder`) |
| `palettes` | `List<AppTheme>` | Lista imutável das 6 paletas disponíveis |

#### Métodos

| Método | Assinatura | Descrição |
|--------|-------------|-----------|
| `loadTheme()` | `Future<void> loadTheme()` | Carrega a paleta salva do `SharedPreferences` (chamado na inicialização) |
| `switchTheme()` | `Future<void> switchTheme(AppTheme newTheme)` | Troca a paleta ativa e persiste a escolha |

#### Uso Básico

```dart
// Obter o tema atual
AppTheme theme = ThemeManager.current;

// Acessar cores
Color primary = ThemeManager.current.primary;
Color bg = ThemeManager.current.background;

// Trocar de paleta (persistido automaticamente)
await ThemeManager().switchTheme(ThemeManager.palettes[2]); // Acolhedor
```

---

### 3. `AssessmentColors` e `AssessmentGradients` (Static Getters)

Camada de abstração que isola o resto do app do gerenciador de temas. Todas as cores/getters devem ser acessados por aqui, **nunca diretamente do `ThemeManager`**.

#### Cores Dinâmicas (segundo a paleta selecionada)

```dart
AssessmentColors.primaryBlue      // ThemeManager.current.primary
AssessmentColors.lightBlue        // ThemeManager.current.light
AssessmentColors.darkBlue         // ThemeManager.current.dark
AssessmentColors.backgroundLight  // ThemeManager.current.background
AssessmentColors.textPrimary      // ThemeManager.current.textPrimary
```

#### Cores Estáticas (semânticas — independentes da paleta)

```dart
AssessmentColors.textSecondary    // Colors.black54
AssessmentColors.textDisabled     // Colors.black38
AssessmentColors.successGreen    // Color(0xFF2E7D32)
AssessmentColors.warningOrange   // Color(0xFFEF6C00)
AssessmentColors.errorRed        // Colors.red
AssessmentColors.cardText        // Colors.white (texto sobre cards coloridos)
AssessmentColors.cardIcon        // Colors.white (ícones sobre cards coloridos)
```

#### Gradientes Dinâmicos

```dart
AssessmentGradients.patient      // gradientPatient
AssessmentGradients.functional   // gradientFunctional
AssessmentGradients.cognitive    // gradientCognitive
AssessmentGradients.clinical     // gradientClinical
AssessmentGradients.social       // gradientSocial
AssessmentGradients.guides       // gradientGuides
```

---

## 🎯 Paletas Disponíveis

| # | Nome | Primary | Background | Descrição |
|---|------|---------|-----------|-----------|
| 1 | **Clássico** | Azul (#1565C0) | #FAFAFA | Padrão profissional, médico |
| 2 | **Natureza** | Verde (#2E7D32) | #F1F8E9 | Calmo, orgânico |
| 3 | **Acolhedor** | Vinho (#AD1457) | #FFF8E1 | Quente, acolhedor |
| 4 | **Oceano** | Teal (#00897B) | #E0F2F1 | Fresco, limpo |
| 5 | **Energético** | Laranja (#EF6C00) | #FFF3E0 | Vibrante, ativo |
| 6 | **Soft** | Rosa (#C2185B) | #FCE4EC | Suave, feminino |

**Gradientes associados:** Cada paleta define 6 gradientes lineares (patient, functional, cognitive, clinical, social, guides) com cores complementares.

---

## 🔧 Integração com o App

### app_initializer.dart

```dart
return ValueListenableBuilder<AppTheme>(
  valueListenable: ThemeManager().currentThemeNotifier,
  builder: (context, currentTheme, child) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: currentTheme.primary,
        scaffoldBackgroundColor: currentTheme.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: currentTheme.primary,
          primary: currentTheme.primary,
          secondary: currentTheme.dark,
          surface: Colors.white,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: currentTheme.background,
          foregroundColor: currentTheme.textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  },
);
```

**Nota:** `brightness` **não é definido** — o app usa apenas modo claro. O `ColorScheme.fromSeed` infere cores automaticamente a partir do `seedColor`.

---

### Tela de Seleção de Paleta (`theme_selection_screen.dart`)

```dart
return ValueListenableBuilder<AppTheme>(
  valueListenable: ThemeManager().currentThemeNotifier,
  builder: (context, currentTheme, child) {
    return Scaffold(
      backgroundColor: AssessmentColors.backgroundLight,
      body: ListView(
        children: ThemeManager.palettes.map((palette) {
          final isSelected = currentTheme.name == palette.name;
          return InkWell(
            onTap: () => ThemeManager().switchTheme(palette),
            child: AnimatedContainer(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? palette.primary : Colors.grey.shade200,
                  width: isSelected ? 2.5 : 1,
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: palette.primary),
                trailing: isSelected ? const Icon(Icons.check) : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  },
);
```

---

## 📱 Estilos de Texto (AssessmentTextStyles)

Classes de estilos de texto centralizadas em `assessment_widgets.dart`:

```dart
AssessmentTextStyles.sectionTitle      // 16sp, w600, black87
AssessmentTextStyles.itemTitle         // 14sp, w500, black87
AssessmentTextStyles.itemSubtitle      // 12sp, black54
AssessmentTextStyles.scorePill         // 12sp, w600
AssessmentTextStyles.instructionText   // 13sp, italic, black54
AssessmentTextStyles.homeCardTitleWide // 18sp, bold, white (sobre gradiente)
AssessmentTextStyles.homeCardTitleSquare // 13sp, bold, #424242 (sobre fundo claro)
```

---

## 🧪 Testes Recomendados

### Manual (ao implementar mudanças visuais)

1. **Inicialização:** App inicia, splash aparece, depois Home carrega com a paleta salva
2. **Seleção de paleta:** Abrir Drawer → Paleta de Cores → selecionar uma → cores mudam instantaneamente
3. **Persistência:** Fechar app completamente → reabrir → mesma paleta deve estar ativa
4. **Consistência:** Navegar por todas as telas (Home, Submenus, Instrumentos) — cores devem estar harmonizadas
5. **Botão Home:** Em todos os submenus, o botão Home (AppBar) deve voltar à tela inicial

### Integração (flutter test)

```dart
testWidgets('deve trocar paleta e persistir', (tester) async {
  await tester.pumpWidget(const AppWrapper());
  expect(AssessmentColors.primaryBlue, Color(0xFF1565C0)); // Clássico

  // Simula troca para Natureza
  await ThemeManager().switchTheme(ThemeManager.palettes[1]);
  await tester.pumpAndSettle();

  expect(AssessmentColors.primaryBlue, Color(0xFF2E7D32)); // Natureza
});
```

---

## ⚠️ Limitações e Restrições

### Modo Noturno
- **NÃO IMPLEMENTADO** — removerdo na revisão de 2026-05-01
- Se for reimplementar no futuro, separar em módulo distinto (`DarkModeManager`)
- Não misturar `ThemeData.brightness` com `ColorScheme.brightness` ao usar `ColorScheme.fromSeed()`

### AdMob na Web
- Anúncios são desabilitados automaticamente com `if (!kIsWeb)` guards
- Nenhuma mudança necessária no sistema de temas para Web

---

## 🚀 Como Estender

### Adicionar Nova Paleta

1. Editar `lib/Temas_Paletas/Temas_Gerenciador.dart`
2. Adicionar novo `AppTheme` na lista `palettes`:
   ```dart
   const AppTheme(
     name: 'Minha Nova Paleta',
     primary: Color(0xFFXXXXXX),
     light: Color(0xFFYYYYYY),
     dark: Color(0xFFZZZZZZ),
     background: Color(0xFFWWWWWW),
     gradientPatient: LinearGradient(colors: [...]),
     // ... definir todos os gradientes
   ),
   ```
3. Testar na tela `theme_selection_screen.dart`

### Alterar Cores de Texto (textPrimary)

Se uma paleta precisar de cor de texto diferente de `Colors.black87`, passar o parâmetro:
```dart
AppTheme(
  name: 'Escuro',
  primary: ...,
  background: Colors.black,
  textPrimary: Colors.white,  // ← customize text color
  // ...
)
```

---

## 🔄 Histórico de Mudanças

| Data | Versão | Descrição |
|------|--------|-----------|
| 2026-04-30 | 1.1.0 | Revisão UX: Home simplificada, Drawer limpo, "Paleta de Cores" no Drawer |
| 2026-05-01 | 1.1.0 | Revertido implementação de modo noturno (incompatibilidade com ColorScheme.fromSeed) |
| 2026-05-01 | 1.1.0 | Adicionada documentação de arquitetura de temas |

---

## 📚 Referências

- [Flutter Theming Guide](https://docs.flutter.dev/cookbook/design/themes)
- [Material 3 ColorScheme](https://m3.material.io/styles/color)
- [ValueNotifier & ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html)

---

**Mantenedor:** Lucas Adriano de Sousa Ramalho  
**Última atualização:** 1 de maio de 2026
