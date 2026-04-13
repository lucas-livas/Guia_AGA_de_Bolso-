// lib/data/reference_data.dart

// Classe para organizar os dados de cada referência
class ReferenceInfo {
  final String objective;
  final String instructions;
  final String scoring;
  final String references;

  const ReferenceInfo({
    required this.objective,
    required this.instructions,
    required this.scoring,
    required this.references,
  });
}

// Nosso "mini-banco de dados" de referências
const referenceData = {
'Timed Up and Go (TUG)': ReferenceInfo(
    objective: 'Avaliar a mobilidade funcional, o risco de quedas e o equilíbrio dinâmico em adultos, especialmente em idosos. É um teste rápido que mede o tempo que uma pessoa leva para se levantar, andar, virar e sentar-se novamente.',
    instructions: '1. O paciente inicia sentado em uma cadeira padrão com braços, com as costas apoiadas.\n'
                  '2. Uma marca é posicionada no chão a 3 metros de distância da cadeira.\n'
                  '3. Ao sinal "JÁ!", o avaliador aciona o cronômetro.\n'
                  '4. O paciente deve se levantar, andar em seu passo normal até a marca, dar a volta, caminhar de volta para a cadeira e sentar-se completamente.\n'
                  '5. O cronômetro é parado assim que as costas do paciente tocam o encosto da cadeira.\n\n'
                  'Nota: O uso de auxílios para a marcha (bengala, andador) é permitido e deve ser anotado.',
    scoring: 'A pontuação é o tempo em segundos para completar o percurso. A interpretação geral é:\n\n'
             '• Até 10s: Baixo risco de quedas, mobilidade normal.\n'
             '• Entre 11s e 13.5s: Risco de quedas presente, mas baixo.\n'
             '• Acima de 13.5s: Alto risco de quedas, déficit significativo na mobilidade.\n'
             '• Acima de 20s: Dependência considerável, risco de quedas muito elevado.\n'
             '• Acima de 30s: Dependência severa e problemas de mobilidade graves.',
    references: 'Artigo Original:\n'
                'Podsiadlo, D., & Richardson, S. (1991). The timed "Up & Go": a test of basic functional mobility for frail elderly persons. Journal of the American Geriatrics Society, 39(2), 142-148.\n\n'
                'Artigo sobre Ponto de Corte para Risco de Quedas:\n'
                'Shumway-Cook, A., Brauer, S., & Woollacott, M. (2000). Predicting the probability for falls in community-dwelling older adults using the Timed Up & Go Test. Physical Therapy, 80(9), 896-903.',
  ),
'Escala de Equilíbrio de Berg': ReferenceInfo(
  objective: 'Avaliar de forma quantitativa o equilíbrio estático e dinâmico em adultos, principalmente idosos, para determinar o risco de quedas. A escala é composta por 14 tarefas comuns do dia a dia que exigem equilíbrio.',
  instructions: 'O avaliador fornece instruções verbais e demonstra cada uma das 14 tarefas. O desempenho é observado e pontuado. Materiais necessários: cronômetro, régua, duas cadeiras (uma com braços, outra sem) e um degrau.\n\n'
                'As 14 tarefas avaliadas são:\n'
                '1. Posição sentada para em pé\n'
                '2. Permanecer em pé sem apoio\n'
                '3. Permanecer sentado sem apoio\n'
                '4. Posição em pé para sentada\n'
                '5. Transferências\n'
                '6. Permanecer em pé de olhos fechados\n'
                '7. Permanecer em pé com os pés juntos\n'
                '8. Alcançar à frente com o braço estendido\n'
                '9. Pegar um objeto do chão\n'
                '10. Virar-se para olhar para trás\n'
                '11. Girar 360 graus\n'
                '12. Colocar os pés alternadamente no degrau\n'
                '13. Permanecer em pé com um pé à frente\n'
                '14. Permanecer em pé sobre uma perna',
  scoring: 'Cada uma das 14 tarefas é pontuada em uma escala ordinal de 0 a 4 (0 = incapaz, 4 = independente e seguro). A pontuação máxima é 56 pontos.\n\n'
           '**Interpretação da Pontuação (Risco de Quedas):**\n'
           '• **41 a 56 pontos:** Baixo risco de quedas. Bom equilíbrio.\n'
           '• **21 a 40 pontos:** Médio risco de quedas. Necessita de intervenção.\n'
           '• **0 a 20 pontos:** Alto risco de quedas. Risco iminente.',
  references: 'Artigo Original (Validação):\n'
              'Berg, K. O., Wood-Dauphinee, S. L., Williams, J. I., & Maki, B. (1992). Measuring balance in the elderly: validation of an instrument. Canadian Journal of Public Health, 83 (Suppl 2), S7-S11.\n\n'
              'Estudo sobre a Confiabilidade:\n'
              'Berg, K., Wood-Dauphinee, S., & Williams, J. I. (1995). The Balance Scale: reliability assessment with elderly residents and patients with an acute stroke. Scandinavian Journal of Rehabilitation Medicine, 27(1), 27-36.',
),
'Mini Exame do Estado Mental (MEEM)': ReferenceInfo(
    objective: 'Realizar um rastreio rápido e quantitativo do estado cognitivo do paciente, avaliando funções como orientação, memória, atenção, cálculo, linguagem e praxia construtiva. É uma ferramenta de rastreio, não de diagnóstico.',
    instructions: 'O exame consiste em 11 tarefas administradas verbalmente pelo avaliador, com duração de 5 a 10 minutos. As tarefas e suas pontuações máximas são:\n\n'
                  **'1. **Orientação Temporal (5 pts):** O fisioterapeuta deve perguntar ao paciente em que ano, estação, mês, dia da semana e em que data estamos.\n'**
                  '2. **Orientação Espacial (5 pts):** O fisioterapeuta deve perguntar ao paciente em que País, estado, cidade, local e andar, estamos.\n'
                  '3. **Registro (3 pts):** Repetir 3 palavras (ex: "carro, vaso, tijolo").\n'
                  '4. **Atenção e Cálculo (5 pts):** Subtrair 7 de 100 (5x) ou soletrar "MUNDO" ao contrário.\n'
                  '5. **Evocação (3 pts):** Lembrar das 3 palavras anteriores.\n'
                  '6. **Linguagem - Nomeação (2 pts):** Fisioterapeuta deve mostrar ao paciente dois objetos do cotidiano (exemplo: um relógio e/ou uma caneta), e pedir para que o paciente diga o nome desses objetos, para cada acerto um ponto\n'
                  '7. **Linguagem - Repetição (1 pt):** Fisioterapeuta deve pedir para que o paciente repita a frase "NEM AQUI, NEM ALI, NEM LÁ".\n'
                  '8. **Linguagem - Comando (3 pts):** Seguir um comando verbal de 3 estágios (exemplo "Pegue o papel com a mão direita, dobre no meio e bote o no chão").\n'
                  '9. **Linguagem - Leitura (1 pt):** O paciente deve, através de um papel ou tela, ler e obedecer a frase "FECHE OS OLHOS".\n'
                  '10. **Linguagem - Escrita (1 pt):** Escrever uma frase completa (A frase deve ter sentido lógico).\n'
                  '11. **Praxia Construtiva (1 pt):** Copiar o desenho de dois pentágonos sobrepostos (se as figuras não tiverem 5 (cinco) lados o ponto não será contado, seu os pentágonos não se sobreporem o ponto não será contado.)\n',
    scoring: 'A pontuação total máxima é de 30 pontos. A interpretação do resultado final depende crucialmente do nível de escolaridade do paciente.\n\n'
             '**Pontos de Corte Sugeridos para a População Brasileira:**\n'
             '• **Analfabetos:** Escore ≤ 13 sugere declínio cognitivo.\n'
             '• **Baixa a Média Escolaridade (1-8 anos):** Escore ≤ 18 sugere declínio cognitivo.\n'
             '• **Alta Escolaridade (>8 anos):** Escore ≤ 26 sugere declínio cognitivo.\n\n'
             'Um escore abaixo do ponto de corte é um sinal de alerta para investigação mais aprofundada.',
    references: 'Artigo Original:\n'
                'Folstein, M. F., Folstein, S. E., & McHugh, P. R. (1975). “Mini-mental state”. A practical method for grading the cognitive state of patients for the clinician. Journal of Psychiatric Research, 12(3), 189-198.\n\n'
                'Validação e Pontos de Corte no Brasil:\n'
                'Brucki, S. M. D., Nitrini, R., Caramelli, P., Bertolucci, P. H. F., & Okamoto, I. H. (2003). Sugestões para o uso do mini-exame do estado mental no Brasil. Arquivos de Neuro-psiquiatria, 61(3B), 777-781.',
  ),
  'Escala de Depressão Geriátrica (GDS-15)': ReferenceInfo(
    objective: 'Avaliar a presença e a severidade de sintomas depressivos em idosos.',
    instructions: 'A escala consiste em 15 perguntas de "sim" ou "não" que abordam sentimentos e comportamentos relacionados à depressão. O paciente responde às perguntas com base em como se sentiu na última semana.',
    scoring: '• 0-4: Sem depressão.\n'
             '• 5-8: Depressão leve.\n'
             '• 9-11: Depressão moderada.\n'
             '• 12-15: Depressão severa.',
    references: 'Yesavage, J. A., Brink, T. L., Rose, T. L., Lum, O., Huang, V., Adey, M., & Leirer, V. O. (1982). Development and validation of a geriatric depression screening scale: a preliminary report. Journal of psychiatric research, 17(1), 37-49.',
  ),
'Escala de Lawton e Brody (AIVDs)': ReferenceInfo(
  objective: 'Avaliar a capacidade funcional de idosos em Atividades Instrumentais de Vida Diária (AIVDs), que são tarefas mais complexas e necessárias para viver de forma independente na comunidade.',
  instructions: 'A escala avalia oito domínios de atividades instrumentais. A pontuação é atribuída com base na capacidade observada ou relatada pelo paciente ou por um cuidador confiável. O profissional deve questionar sobre a capacidade de realizar as seguintes tarefas:\n\n'
                '1. Usar o telefone\n'
                '2. Ir a locais distantes (Transporte)\n'
                '3. Fazer compras\n'
                '4. Preparar refeições\n'
                '5. Realizar tarefas domésticas\n'
                '6. Lavar e passar a roupa\n'
                '7. Tomar as medicações\n'
                '8. Gerenciar as finanças',
  scoring: 'A pontuação final varia de 0 (dependência total) a 8 (independência total), atribuindo 1 ponto para independência e 0 para dependência em cada uma das 8 categorias.\n\n'
           '• 8 pontos: Totalmente independente.\n'
           '• 5 a 7 pontos: Dependência leve a moderada.\n'
           '• 2 a 4 pontos: Dependência moderada a severa.\n'
           '• 0 a 1 ponto: Dependência severa/total.',
  references: 'Artigo Original (A Fonte Primária):\n'
              'Autor(es): Lawton, M. P., & Brody, E. M.\n'
              'Título: Assessment of older people: Self-maintaining and instrumental activities of daily living.\n'
              'Publicação: The Gerontologist, 1969, 9(3), pp. 179-186.\n'
              'Relevância: Este é o estudo seminal onde a escala foi proposta pela primeira vez, descrevendo sua finalidade, os itens avaliados e o método de pontuação. É a referência fundamental para qualquer trabalho sobre o tema.\n\n'
              'Validação e Uso no Contexto Brasileiro:\n'
              'Autor(es): Santos, R. L., & Andrade, V. M.\n'
              'Título: Atividades de vida diária em idosos: um desafio para cuidadores e profissionais da saúde.\n'
              'Publicação: Revista Kairós: Gerontologia, 2013, 16(5), pp. 195-208.\n'
              'Relevância: Este artigo discute a aplicação de escalas como a de Lawton e Brody no contexto da saúde do idoso no Brasil, abordando os desafios e a importância da avaliação funcional para o planejamento do cuidado.\n\n'
              'Manuais e Diretrizes de Geriatria e Gerontologia:\n'
              'Fonte: Sociedade Brasileira de Geriatria e Gerontologia (SBGG) e manuais clínicos de fisioterapia geriátrica.\n'
              'Relevância: A Escala de Lawton e Brody é uma ferramenta padrão recomendada em diversas diretrizes clínicas para a Avaliação Geriátrica Ampla (AGA).',
),
  // Adicione aqui os dados para os outros testes no futuro!
};