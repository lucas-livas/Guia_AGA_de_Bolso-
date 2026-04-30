import 'package:guia_aga_de_bolso/data/assessment_items/berg_items.dart';

/// Serviço de cálculo para a Escala de Equilíbrio de Berg.
///
/// Contém a lógica pura de cálculo do score e interpretação,
/// independente de qualquer widget Flutter.
class BergCalculationService {
  static const int maxScore = 56;

  /// Calcula o score total somando os pontos de todas as respostas.
  static int calculateScore(Map<int, AnswerOption> answers) {
    return answers.values.fold(0, (sum, answer) => sum + answer.points);
  }

  /// Retorna a interpretação clínica do score.
  static String getInterpretation(int score) {
    if (score >= 41) return 'Baixo risco de queda.';
    if (score >= 21) return 'Risco de queda médio.';
    return 'Alto risco de queda.';
  }

  /// Retorna o score formatado para exibição.
  static String getScoreText(int score) {
    return '$score / $maxScore';
  }
}
