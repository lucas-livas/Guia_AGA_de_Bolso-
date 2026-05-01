import 'package:flutter/material.dart';
// Importação do Gerenciador de Temas (Verifique se o caminho bate com sua pasta)
import 'package:guia_aga_de_bolso/Temas_Paletas/Temas_Gerenciador.dart';

// ============================================================================
// 🎨 SEÇÃO 1: CONSTANTES DE DESIGN (CORES DINÂMICAS)
// ============================================================================

class AssessmentColors {
  // Cores Dinâmicas (buscam do tema atual selecionado)
  static Color get primaryBlue => ThemeManager.current.primary;
  static Color get lightBlue => ThemeManager.current.light;
  static Color get darkBlue => ThemeManager.current.dark;
  static Color get backgroundLight => ThemeManager.current.background;
  static Color get textPrimary => ThemeManager.current.textPrimary;

  // Cores Estáticas (Semânticas - não mudam com o tema)
  static const Color textSecondary = Colors.black54;
  static const Color textDisabled = Colors.black38;
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFEF6C00);
  static const Color errorRed = Colors.red;
  
  // Cores para textos/ícones sobre fundos coloridos (ex: Cards da Home)
  static const Color cardText = Colors.white;
  static const Color cardIcon = Colors.white;
}

class AssessmentGradients {
  // Gradientes Dinâmicos (buscam do tema atual)
  static Gradient get patient => ThemeManager.current.gradientPatient;
  static Gradient get functional => ThemeManager.current.gradientFunctional;
  static Gradient get cognitive => ThemeManager.current.gradientCognitive;
  static Gradient get clinical => ThemeManager.current.gradientClinical;
  static Gradient get social => ThemeManager.current.gradientSocial;
  static Gradient get guides => ThemeManager.current.gradientGuides;
}

class AssessmentTextStyles {
  // Estilos de texto (Cores agora são dinâmicas ou padrão preto/cinza)
  
  static const TextStyle sectionTitle = TextStyle(
    fontWeight: FontWeight.w600, fontSize: 16, color: Colors.black87, height: 1.25,
  );
  
  static const TextStyle itemTitle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87, height: 1.4,
  );
  
  static const TextStyle itemSubtitle = TextStyle(
    fontSize: 12, color: AssessmentColors.textSecondary, height: 1.3,
  );
  
  static const TextStyle scorePill = TextStyle(
    fontWeight: FontWeight.w600, fontSize: 12,
  );
  
  static const TextStyle instructionText = TextStyle(
    fontStyle: FontStyle.italic, fontSize: 13, color: AssessmentColors.textSecondary, height: 1.4,
  );

  static const TextStyle homeCardTitleWide = TextStyle(
    color: AssessmentColors.cardText, fontWeight: FontWeight.bold, fontSize: 18,
  );
  
  static const TextStyle homeCardTitleSquare = TextStyle(
    color: Color(0xFF424242), fontWeight: FontWeight.bold, fontSize: 13,
  );
}

// ============================================================================
// 🏠 SEÇÃO 2: WIDGETS DA TELA INICIAL (HOME)
// ============================================================================

class AssessmentWideNavCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const AssessmentWideNavCard({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Icon(icon, color: AssessmentColors.cardIcon, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: AssessmentTextStyles.homeCardTitleWide,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AssessmentSquareNavCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const AssessmentSquareNavCard({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Icon(icon, size: 45, color: AssessmentColors.cardIcon),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  width: double.infinity,
                  color: Colors.white,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AssessmentTextStyles.homeCardTitleSquare,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 📂 SEÇÃO 3: WIDGETS DE SUBMENU
// ============================================================================

class AssessmentSubmenuItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor; 

  const AssessmentSubmenuItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.transparent, // Fundo transparente
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (iconColor ?? AssessmentColors.primaryBlue).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? AssessmentColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AssessmentTextStyles.itemTitle.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AssessmentTextStyles.itemSubtitle,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AssessmentColors.textDisabled),
            ],
          ),
        ),
      ),
    );
  }
}

class AssessmentSubmenuTitle extends StatelessWidget {
  final String title;
  final Color? color;

  const AssessmentSubmenuTitle({super.key, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: color ?? AssessmentColors.textSecondary,
        ),
      ),
    );
  }
}

// ============================================================================
// 📝 SEÇÃO 4: WIDGETS DE AVALIAÇÃO (FORMULÁRIOS)
// ============================================================================

class AssessmentSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final int? maxPoints;
  final int? currentPoints;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final Color? scoreColor;
  final Widget? trailing;
  
  // Controlador para abrir/fechar via código
  final ExpansibleController? controller;
  // Chave específica para o ExpansionTile (importante para o scroll)
  final Key? expansionTileKey; 

  const AssessmentSection({
    super.key, // Chave do widget em si
    this.expansionTileKey, 
    required this.title,
    required this.children,
    this.maxPoints,
    this.currentPoints,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.scoreColor,
    this.trailing,
    this.controller,
  });

  Color _getScoreColor() {
    if (maxPoints == null || currentPoints == null || maxPoints == 0) return AssessmentColors.primaryBlue;
    final percentage = currentPoints! / maxPoints!;
    if (percentage >= 0.7) return AssessmentColors.successGreen;
    if (percentage >= 0.4) return AssessmentColors.warningOrange;
    return AssessmentColors.errorRed;
  }

  @override
  Widget build(BuildContext context) {
    final hasScore = maxPoints != null && currentPoints != null && maxPoints! > 0;
    final finalScoreColor = scoreColor ?? _getScoreColor();

    // MODIFICAÇÃO: Removido Card e Elevation para fundo transparente
    return Column(
      children: [
        Theme(
          // Remove as linhas divisórias padrão do ExpansionTile
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: expansionTileKey, // Usa a chave para o scroll funcionar
            controller: controller,
            title: Row(
              children: [
                Expanded(
                  child: Text(title, style: AssessmentTextStyles.sectionTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 8),
                if (hasScore) _buildScorePill(finalScoreColor),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
            initiallyExpanded: initiallyExpanded,
            onExpansionChanged: onExpansionChanged,
            // Remove padding interno para alinhar melhor
            childrenPadding: EdgeInsets.zero,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            
            // Fundo transparente para se misturar com a tela
            collapsedBackgroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            
            children: [
              // Divisor no topo do conteúdo expandido
              Divider(height: 1, color: Colors.grey.shade300),
              ...children,
            ],
          ),
        ),
        // Divisor abaixo da seção
        Divider(height: 1, color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildScorePill(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text('$currentPoints/$maxPoints', style: AssessmentTextStyles.scorePill.copyWith(color: color)),
    );
  }
}

class AssessmentCheckboxItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? instruction;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final bool enabled;
  final Color? activeColor;
  final Widget? leading;
  final bool showBorder;

  const AssessmentCheckboxItem({
    super.key,
    required this.title,
    this.subtitle,
    this.instruction,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.activeColor,
    this.leading,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: showBorder 
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: Colors.grey.shade300, width: 1))
            : null,
        color: enabled ? Colors.white : Colors.grey.shade50,
        child: CheckboxListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[leading!, const SizedBox(height: 4)],
              Text(title, style: AssessmentTextStyles.itemTitle.copyWith(color: enabled ? AssessmentColors.textPrimary : AssessmentColors.textDisabled)),
              if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: AssessmentTextStyles.itemSubtitle.copyWith(color: enabled ? AssessmentColors.textSecondary : AssessmentColors.textDisabled))],
              if (instruction != null) ...[const SizedBox(height: 4), AssessmentInstructionText(text: instruction!, showBackground: true, backgroundColor: AssessmentColors.lightBlue.withValues(alpha: 0.2))],
            ],
          ),
          value: value,
          onChanged: enabled ? onChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          activeColor: activeColor ?? AssessmentColors.primaryBlue,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}

class AssessmentRadioItem<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;
  final bool enabled;
  final Widget? trailing;

  const AssessmentRadioItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.enabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        color: enabled ? Colors.white : Colors.grey.shade50,
        child: RadioListTile<T>(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AssessmentTextStyles.itemTitle.copyWith(
                  color: enabled ? AssessmentColors.textPrimary : AssessmentColors.textDisabled,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AssessmentTextStyles.itemSubtitle.copyWith(
                    color: enabled ? AssessmentColors.textSecondary : AssessmentColors.textDisabled,
                  ),
                ),
              ],
            ],
          ),
          value: value,
          groupValue: groupValue,
          onChanged: enabled ? onChanged : null,
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          activeColor: AssessmentColors.primaryBlue,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          toggleable: true,
          secondary: trailing,
        ),
      ),
    );
  }
}

class AssessmentInstructionText extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final bool showBackground;

  const AssessmentInstructionText({super.key, required this.text, this.icon, this.backgroundColor, this.showBackground = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: showBackground
          ? BoxDecoration(color: backgroundColor ?? AssessmentColors.lightBlue.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(4), border: Border.all(color: AssessmentColors.primaryBlue.withValues(alpha: 0.2), width: 1))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, size: 16, color: AssessmentColors.primaryBlue), const SizedBox(width: 8)],
          Expanded(child: Text(text, style: AssessmentTextStyles.instructionText)),
        ],
      ),
    );
  }
}

class AssessmentSectionHeader extends StatelessWidget {
  final String title;
  final String? description;
  final Widget? action;
  final Color? backgroundColor;

  const AssessmentSectionHeader({
    super.key,
    required this.title,
    this.description,
    this.action,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor ?? AssessmentColors.primaryBlue.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AssessmentTextStyles.sectionTitle.copyWith(
                    color: AssessmentColors.primaryBlue,
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    style: AssessmentTextStyles.itemSubtitle,
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action!,
          ],
        ],
      ),
    );
  }
}

class AssessmentProgressIndicator extends StatelessWidget {
  final int current;
  final int total;
  final Color? color;
  final String? label;

  const AssessmentProgressIndicator({
    super.key,
    required this.current,
    required this.total,
    this.color,
    this.label,
  });

  double get progress => (total > 0) ? (current / total).clamp(0.0, 1.0) : 0.0;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AssessmentColors.primaryBlue;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AssessmentTextStyles.itemSubtitle,
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$current/$total',
              style: AssessmentTextStyles.scorePill.copyWith(
                fontSize: 11,
                color: effectiveColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================================
// 👤 SEÇÃO 5: WIDGETS DA FICHA DO PACIENTE
// ============================================================================

class PatientIdentityCard extends StatelessWidget {
  final String name;
  final String birthDate;
  final String gender;
  final String maritalStatus;
  final String emergencyContact;

  const PatientIdentityCard({
    super.key,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.maritalStatus,
    required this.emergencyContact,
  });

  String _calculateAge(String date) {
    try {
      DateTime birth;
      if (date.contains('/')) {
        final parts = date.split('/');
        birth = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      } else {
        birth = DateTime.parse(date);
      }
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) age--;
      return age.toString();
    } catch (e) {
      return "?";
    }
  }

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge(birthDate);
    
    IconData genderIcon;
    Color genderColor;
    final String g = gender.toLowerCase();
    
    if (g == 'masculino') { 
      genderIcon = Icons.male; genderColor = Colors.blue; 
    } else if (g == 'feminino') { 
      genderIcon = Icons.female; genderColor = Colors.pinkAccent; 
    } else { 
      genderIcon = Icons.transgender; genderColor = Colors.purpleAccent; 
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade200), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AssessmentColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 40, color: AssessmentColors.primaryBlue),
          ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Text(
                  name, 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(Icons.cake, size: 16, color: Colors.grey), 
                    const SizedBox(width: 6), 
                    Expanded(
                      child: Text(
                        "$birthDate ($age anos)", 
                        style: const TextStyle(fontSize: 13, color: Colors.black87)
                      )
                    )
                  ]
                ),
                const SizedBox(height: 6),
                
                Wrap(
                  spacing: 12, 
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        Icon(genderIcon, size: 16, color: genderColor), 
                        const SizedBox(width: 4), 
                        Text(gender, style: const TextStyle(fontSize: 13, color: Colors.black54))
                      ]
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        const Icon(Icons.favorite, size: 16, color: Colors.pinkAccent), 
                        const SizedBox(width: 4), 
                        Text(maritalStatus, style: const TextStyle(fontSize: 13, color: Colors.black54))
                      ]
                    ),
                  ]
                ),
                const SizedBox(height: 6),
                
                Row(
                  children: [
                    const Icon(Icons.phone_in_talk, size: 16, color: AssessmentColors.successGreen), 
                    const SizedBox(width: 6), 
                    Expanded(
                      child: Text(
                        emergencyContact, 
                        style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)
                      )
                    )
                  ]
                ),
              ]
            )
          ),
        ],
      ),
    );
  }
}

class PatientInfoCard extends StatelessWidget {
  final String occupation;
  final String education;
  final String nationality;
  final String naturalness;
  final String race;
  final String notes;

  const PatientInfoCard({
    super.key,
    required this.occupation,
    required this.education,
    required this.nationality,
    required this.naturalness,
    required this.race,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.grey.shade200), 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(right: 16, top: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.badge_outlined, size: 30, color: AssessmentColors.warningOrange),
          ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                const Text(
                  "DADOS COMPLEMENTARES", 
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)
                ),
                const SizedBox(height: 12),
                
                _iconRow(Icons.work_outline, Colors.brown, "Profissão: ${occupation.isNotEmpty ? occupation : '-'}"),
                _iconRow(Icons.school_outlined, Colors.indigo, "Escolaridade: ${education.isNotEmpty ? education : '-'}"),
                _iconRow(Icons.public, Colors.teal, "Nacionalidade: ${nationality.isNotEmpty ? nationality : '-'}"),
                _iconRow(Icons.location_on_outlined, Colors.teal, "Naturalidade: ${naturalness.isNotEmpty ? naturalness : '-'}"),
                _iconRow(Icons.person_outline, Colors.deepOrange, "Raça/Cor: ${race.isNotEmpty ? race : '-'}"),
                
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 12), 
                  Container(
                    padding: const EdgeInsets.all(10), 
                    decoration: BoxDecoration(
                      color: Colors.grey[50], 
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200)
                    ), 
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, 
                      children: [
                        const Icon(Icons.note_alt_outlined, size: 16, color: Colors.grey), 
                        const SizedBox(width: 8), 
                        Expanded(
                          child: Text(
                            notes, 
                            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black87)
                          )
                        )
                      ]
                    )
                  )
                ],
              ]
            )
          ),
        ],
      ),
    );
  }

  Widget _iconRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6), 
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color.withValues(alpha: 0.8)), 
          const SizedBox(width: 8), 
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))
          )
        ]
      )
    );
  }
}

class PatientDetailRow extends StatelessWidget {
  final String title;
  final String text;
  final IconData? icon;

  const PatientDetailRow({super.key, required this.title, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Card(
      elevation: 0, 
      margin: const EdgeInsets.symmetric(vertical: 4.0), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), 
        side: BorderSide(color: Colors.grey.shade200)
      ), 
      child: Padding(
        padding: const EdgeInsets.all(12.0), 
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: AssessmentColors.primaryBlue.withValues(alpha: 0.6)), 
              const SizedBox(width: 12)
            ], 
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text(title, style: AssessmentTextStyles.itemSubtitle), 
                  const SizedBox(height: 4), 
                  Text(text, style: AssessmentTextStyles.itemTitle.copyWith(fontWeight: FontWeight.normal))
                ]
              )
            )
          ]
        )
      )
    );
  }
}

class PatientSectionHeader extends StatelessWidget {
  final String title;
  const PatientSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8), 
      child: Text(
        title, 
        style: const TextStyle(
          fontSize: 13, 
          fontWeight: FontWeight.bold, 
          letterSpacing: 1.2, 
          color: AssessmentColors.textSecondary
        )
      )
    );
  }
}

// ============================================================================
// 📊 SEÇÃO 6: WIDGETS DE RELATÓRIO (VISUALIZADOR DE DETALHES)
// ============================================================================

class AssessmentReportHeader extends StatelessWidget {
  final String testName;
  final String patientName;
  final String date;

  const AssessmentReportHeader({
    super.key,
    required this.testName,
    required this.patientName,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          testName,
          style: AssessmentTextStyles.homeCardTitleWide.copyWith(
            color: AssessmentColors.primaryBlue, 
            fontSize: 22
          ),
        ),
        const SizedBox(height: 24),
        AssessmentInfoRow(label: "Paciente", value: patientName),
        AssessmentInfoRow(label: "Data da Avaliação", value: date),
        Divider(height: 32, thickness: 1, color: Colors.grey.shade200),
      ],
    );
  }
}

class AssessmentReportTitle extends StatelessWidget {
  final String title;

  const AssessmentReportTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AssessmentColors.primaryBlue,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 40,
            color: AssessmentColors.primaryBlue.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

class AssessmentInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const AssessmentInfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: AssessmentTextStyles.itemTitle.copyWith(fontWeight: FontWeight.normal),
          children: <TextSpan>[
            TextSpan(
              text: '$label: ', 
              style: TextStyle(fontWeight: FontWeight.bold, color: AssessmentColors.textPrimary)
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class AssessmentNotesBox extends StatelessWidget {
  final String notes;

  const AssessmentNotesBox({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: AssessmentColors.lightBlue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AssessmentColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Text(
        notes, 
        style: AssessmentTextStyles.instructionText.copyWith(fontStyle: FontStyle.normal)
      ),
    );
  }
}

class AssessmentResultContainer extends StatelessWidget {
  final List<Widget> children;

  const AssessmentResultContainer({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AssessmentColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class AssessmentScoreDisplay extends StatelessWidget {
  final String score;
  final String interpretation;

  const AssessmentScoreDisplay({
    super.key,
    required this.score,
    required this.interpretation,
  });

  @override
  Widget build(BuildContext context) {
    return AssessmentResultContainer(
      children: [
        const Text("SCORE FINAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
        Text(score, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AssessmentColors.primaryBlue)),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        const Text("INTERPRETAÇÃO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AssessmentColors.textSecondary)),
        Text(interpretation, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}