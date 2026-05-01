import 'package:flutter/material.dart';
// Importação correta da pasta Temas_Paletas
import 'package:guia_aga_de_bolso/Temas_Paletas/Temas_Gerenciador.dart';
import 'package:guia_aga_de_bolso/widgets/assessment_widgets.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos o Scaffold no ValueListenableBuilder para que a 
    // AppBar e o fundo mudem de cor instantaneamente ao clicar.
    return ValueListenableBuilder<AppTheme>(
      valueListenable: ThemeManager().currentThemeNotifier,
      builder: (context, currentTheme, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Paleta de Cores'),
            // Cores dinâmicas para a barra superior
            backgroundColor: AssessmentColors.backgroundLight,
            foregroundColor: AssessmentColors.textPrimary,
            elevation: 0,
            centerTitle: true,
          ),
          // Cor de fundo dinâmica
          backgroundColor: AssessmentColors.backgroundLight,
          
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Cabeçalho da seção (Sem 'const' para atualizar a cor do texto/fundo)
              AssessmentSectionHeader(
                title: 'PERSONALIZAÇÃO',
                description: 'Escolha a cor principal do aplicativo',
              ),
              const SizedBox(height: 16),
              
              // Gera a lista de cartões baseada nas paletas disponíveis
              ...ThemeManager.palettes.map((theme) {
                // Verifica se este é o tema atualmente selecionado
                final isSelected = currentTheme.name == theme.name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: InkWell(
                    onTap: () {
                      // Troca o tema globalmente
                      ThemeManager().switchTheme(theme);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          // Borda colorida se selecionado, cinza se não
                          color: isSelected ? theme.primary : Colors.grey.shade200,
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: theme.primary,
                          radius: 24,
                          // Ícone de check animado que aparece apenas se selecionado
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.0,
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                        ),
                        title: Text(
                          theme.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            // Título muda para a cor do tema se selecionado
                            color: isSelected ? theme.primary : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          isSelected ? 'Ativo' : 'Toque para ativar',
                          style: TextStyle(
                            color: isSelected ? theme.primary.withValues(alpha: 0.8) : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
