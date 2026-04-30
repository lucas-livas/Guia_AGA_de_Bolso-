class AnswerOption {
  final String text;
  final int points;
  const AnswerOption({required this.text, required this.points});
}

class BergItem {
  final String task;
  final List<AnswerOption> options;
  const BergItem({required this.task, required this.options});
}

const List<BergItem> bergBalanceItems = [
  BergItem(task: '1. Levantar-se de uma cadeira', options: [
    AnswerOption(text: '(4) Capaz de levantar sem usar as mãos e estabilizar-se independentemente.', points: 4),
    AnswerOption(text: '(3) Capaz de levantar independentemente usando as mãos.', points: 3),
    AnswerOption(text: '(2) Capaz de levantar usando as mãos após várias tentativas.', points: 2),
    AnswerOption(text: '(1) Necessita de ajuda mínima para levantar ou estabilizar-se.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda moderada ou máxima para levantar.', points: 0),
  ]),
  BergItem(task: '2. Permanecer em pé sem apoio', options: [
    AnswerOption(text: '(4) Capaz de permanecer em pé por 2 minutos com segurança.', points: 4),
    AnswerOption(text: '(3) Capaz de permanecer em pé por 2 minutos com supervisão.', points: 3),
    AnswerOption(text: '(2) Capaz de permanecer em pé por 30 segundos sem apoio.', points: 2),
    AnswerOption(text: '(1) Necessita de várias tentativas para permanecer em pé por 30 seg.', points: 1),
    AnswerOption(text: '(0) Incapaz de permanecer em pé por 30 segundos sem ajuda.', points: 0),
  ]),
  BergItem(task: '3. Permanecer sentado sem apoio nas costas', options: [
    AnswerOption(text: '(4) Capaz de sentar-se com segurança por 2 minutos.', points: 4),
    AnswerOption(text: '(3) Capaz de sentar-se por 2 minutos com supervisão.', points: 3),
    AnswerOption(text: '(2) Capaz de sentar-se por 30 segundos.', points: 2),
    AnswerOption(text: '(1) Capaz de sentar-se por 10 segundos.', points: 1),
    AnswerOption(text: '(0) Incapaz de sentar-se sem apoio por 10 segundos.', points: 0),
  ]),
  BergItem(task: '4. Sentar-se a partir da posição em pé', options: [
    AnswerOption(text: '(4) Senta-se com segurança com uso mínimo das mãos.', points: 4),
    AnswerOption(text: '(3) Controla a descida usando as mãos.', points: 3),
    AnswerOption(text: '(2) Usa a parte de trás das pernas contra a cadeira para controlar.', points: 2),
    AnswerOption(text: '(1) Senta-se independentemente, mas tem descida descontrolada.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para sentar-se.', points: 0),
  ]),
  BergItem(task: '5. Transferências', options: [
    AnswerOption(text: '(4) Capaz de transferir-se com segurança com uso mínimo das mãos.', points: 4),
    AnswerOption(text: '(3) Capaz de transferir-se com segurança com uso das mãos.', points: 3),
    AnswerOption(text: '(2) Capaz de transferir-se com indicações verbais e/ou supervisão.', points: 2),
    AnswerOption(text: '(1) Necessita de uma pessoa para ajudar.', points: 1),
    AnswerOption(text: '(0) Necessita de duas pessoas para ajudar ou supervisão.', points: 0),
  ]),
  BergItem(task: '6. Permanecer em pé sem apoio e com os olhos fechados', options: [
    AnswerOption(text: '(4) Capaz de permanecer em pé por 10 segundos com segurança.', points: 4),
    AnswerOption(text: '(3) Capaz de permanecer em pé por 10 segundos com supervisão.', points: 3),
    AnswerOption(text: '(2) Capaz de permanecer em pé por 3 segundos.', points: 2),
    AnswerOption(text: '(1) Incapaz de manter olhos fechados por 3s, mas fica em pé.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para não cair.', points: 0),
  ]),
  BergItem(task: '7. Permanecer em pé sem apoio com os pés juntos', options: [
    AnswerOption(text: '(4) Capaz de colocar pés juntos e ficar em pé por 1 minuto seguro.', points: 4),
    AnswerOption(text: '(3) Capaz de colocar pés juntos e ficar em pé por 1 minuto com supervisão.', points: 3),
    AnswerOption(text: '(2) Capaz de colocar pés juntos e ficar em pé por 30 segundos.', points: 2),
    AnswerOption(text: '(1) Necessita de ajuda para juntar, mas fica 15 segundos.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para juntar e não fica 15 segundos.', points: 0),
  ]),
  BergItem(task: '8. Esticar-se à frente com o braço estendido', options: [
    AnswerOption(text: '(4) Consegue esticar-se à frente > 25 cm com segurança.', points: 4),
    AnswerOption(text: '(3) Consegue esticar-se à frente > 12 cm com segurança.', points: 3),
    AnswerOption(text: '(2) Consegue esticar-se à frente > 5 cm com segurança.', points: 2),
    AnswerOption(text: '(1) Estica-se à frente, mas necessita de supervisão.', points: 1),
    AnswerOption(text: '(0) Perde o equilíbrio ao tentar/necessita de apoio.', points: 0),
  ]),
  BergItem(task: '9. Apanhar um objeto do chão', options: [
    AnswerOption(text: '(4) Capaz de apanhar o objeto com facilidade e segurança.', points: 4),
    AnswerOption(text: '(3) Capaz de apanhar o objeto, mas necessita de supervisão.', points: 3),
    AnswerOption(text: '(2) Incapaz de apanhar, mas alcança 2-5 cm do objeto.', points: 2),
    AnswerOption(text: '(1) Incapaz de apanhar e necessita de supervisão ao tentar.', points: 1),
    AnswerOption(text: '(0) Incapaz de tentar/necessita de ajuda.', points: 0),
  ]),
  BergItem(task: '10. Virar-se e olhar para trás', options: [
    AnswerOption(text: '(4) Olha para trás de ambos os lados com boa distribuição.', points: 4),
    AnswerOption(text: '(3) Olha para trás de um lado apenas.', points: 3),
    AnswerOption(text: '(2) Vira-se apenas para o lado; necessita de supervisão.', points: 2),
    AnswerOption(text: '(1) Necessita de supervisão ao virar-se.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para não perder o equilíbrio.', points: 0),
  ]),
  BergItem(task: '11. Girar 360 graus', options: [
    AnswerOption(text: '(4) Capaz de girar 360 graus com segurança em < 4 segundos.', points: 4),
    AnswerOption(text: '(3) Capaz de girar 360 graus com segurança de um lado apenas.', points: 3),
    AnswerOption(text: '(2) Capaz de girar 360 graus com segurança, mas lentamente.', points: 2),
    AnswerOption(text: '(1) Necessita de supervisão ou instruções verbais.', points: 1),
    AnswerOption(text: '(0) Necessita de ajuda para não perder o equilíbrio.', points: 0),
  ]),
  BergItem(task: '12. Colocar um pé alternadamente à frente', options: [
    AnswerOption(text: '(4) Capaz de realizar sem ajuda por 20 passos.', points: 4),
    AnswerOption(text: '(3) Capaz de realizar 20 passos com supervisão.', points: 3),
    AnswerOption(text: '(2) Capaz de realizar 10-15 passos.', points: 2),
    AnswerOption(text: '(1) Capaz de dar 2-9 passos.', points: 1),
    AnswerOption(text: '(0) Incapaz de tentar/necessita de ajuda.', points: 0),
  ]),
  BergItem(task: '13. Ficar em pé sobre uma perna', options: [
    AnswerOption(text: '(4) Capaz de ficar em pé por 20+ segundos.', points: 4),
    AnswerOption(text: '(3) Capaz de ficar em pé por 10-20 segundos.', points: 3),
    AnswerOption(text: '(2) Capaz de ficar em pé por 3-10 segundos.', points: 2),
    AnswerOption(text: '(1) Necessita de várias tentativas para ficar em pé < 3 seg.', points: 1),
    AnswerOption(text: '(0) Incapaz de tentar.', points: 0),
  ]),
];
