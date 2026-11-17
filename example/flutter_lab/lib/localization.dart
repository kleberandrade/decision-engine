// Compatibility with the lab's Flutter >=3.35 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' as m;
import 'browser_bridge.dart';

class LabLanguage extends m.StatefulWidget {
  const LabLanguage({super.key, required this.child});
  final m.Widget child;
  @override
  m.State<LabLanguage> createState() => _LanguageState();
  static String current(m.BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Scope>()?.language ?? 'pt';
  static void change(m.BuildContext context, String language) =>
      context.dependOnInheritedWidgetOfExactType<_Scope>()?.change(language);
}

class _LanguageState extends m.State<LabLanguage> {
  late String language;
  @override
  void initState() {
    super.initState();
    final stored = readLanguage();
    language = stored == 'en' ? 'en' : 'pt';
  }

  void change(String value) {
    setState(() => language = value);
    saveLanguage(value);
  }

  @override
  m.Widget build(m.BuildContext context) =>
      _Scope(language: language, change: change, child: widget.child);
}

class _Scope extends m.InheritedWidget {
  const _Scope(
      {required this.language, required this.change, required super.child});
  final String language;
  final void Function(String) change;
  @override
  bool updateShouldNotify(_Scope old) => language != old.language;
}

String tr(m.BuildContext context, String source) {
  final english = LabLanguage.current(context) == 'en';
  final exact = english ? translations[source] : reverseTranslations[source];
  if (exact != null) return exact;
  var result = source;
  final longPhrases = english ? translations : reverseTranslations;
  for (final entry in longPhrases.entries) {
    if (entry.key.length >= 30 && result.contains(entry.key)) {
      result = result.replaceAll(entry.key, entry.value);
    }
  }
  final fragments = english ? dynamicTranslations : reverseDynamicTranslations;
  for (final entry in fragments.entries) {
    result = result.replaceAll(entry.key, entry.value);
  }
  return result;
}

final reverseTranslations = Map<String, String>.unmodifiable(
    {for (final e in translations.entries) e.value: e.key});
final reverseDynamicTranslations = Map<String, String>.unmodifiable(
    {for (final e in dynamicTranslations.entries) e.value: e.key});

/// Translate authored UI copy at rendering time without changing scenario data.
class Text extends m.StatelessWidget {
  const Text(this.data,
      {super.key,
      this.style,
      this.maxLines,
      this.overflow,
      this.textAlign,
      this.softWrap});
  final String data;
  final m.TextStyle? style;
  final int? maxLines;
  final m.TextOverflow? overflow;
  final m.TextAlign? textAlign;
  final bool? softWrap;
  @override
  m.Widget build(m.BuildContext context) => m.Text(tr(context, data),
      style: style,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      softWrap: softWrap);
}

const translations = <String, String>{
  'Comparações prioritárias para revisão': 'Priority comparisons for review',
  'Prioridade = desvio log absoluto médio das relações indiretas Aik × Akj. Tríades em desacordo não provam qual julgamento está errado. Marcadores #1–#3 destacam prioridades; empates são possíveis.':
      'Priority = mean absolute log deviation from indirect relations Aik × Akj. Conflicting triads do not prove which judgment is wrong. Markers #1–#3 highlight priorities; ties are possible.',
  'Nenhum desacordo de tríade acima da tolerância.':
      'No triad disagreement above tolerance.',
  'Ver impacto antes de ajustar': 'Preview impact before adjusting',
  'Nenhum ajuste testado reduziu o CR para este par.':
      'No tested adjustment reduced CR for this pair.',
  'Sugestões são heurísticas: média geométrica dos caminhos indiretos e três passos intermediários, limitados a 1/9–9. Cada prévia muda só um par e recalcula o CR no núcleo. Não há garantia de solução global ou de que a preferência sugerida seja correta.':
      'Suggestions are heuristic: the geometric mean of indirect paths and three intermediate steps, bounded to 1/9–9. Each preview changes one pair and recalculates CR in the core. There is no guarantee of a global solution or that a suggested preference is correct.',
  'Prévia de ajuste — cenário ainda inalterado':
      'Adjustment preview — scenario still unchanged',
  'A prévia atende CR ≤ 0,10.': 'The preview meets CR ≤ 0.10.',
  'A prévia ainda supera CR 0,10; serão necessárias outras revisões.':
      'The preview still exceeds CR 0.10; further review is needed.',
  'O alvo indireto excede a escala; a sugestão foi limitada a 1/9–9.':
      'The indirect target exceeds the scale; the suggestion was bounded to 1/9–9.',
  'Pesos da prévia': 'Preview weights',
  'Usar no rascunho altera apenas esta comparação e seu inverso. O cenário só recebe pesos ao clicar Aplicar pesos.':
      'Staging changes only this comparison and its reciprocal. Scenario weights change only when you click Apply weights.',
  'Descartar prévia': 'Discard preview',
  'Usar ajuste no rascunho': 'Stage adjustment',
  'Revisar inconsistências': 'Review inconsistencies',
  'São necessários pelo menos 3 critérios para revisar tríades.':
      'At least 3 criteria are needed to review triads.',
  'Prévia ativa: use ou descarte o ajuste antes de aplicar pesos.':
      'Preview active: stage or discard the adjustment before applying weights.',
  'Não foi possível revisar esta matriz. Confira os valores.':
      'Unable to review this matrix. Check the values.',
  'Laboratório': 'Laboratory',
  'Aprender': 'Learn',
  'Exemplos': 'Examples',
  'Documentação': 'Documentation',
  'Navegação': 'Navigation',
  'Idioma': 'Language',
  'Laboratório de decisões': 'Decision laboratory',
  'Local • Dart puro': 'Local • Pure Dart',
  'Explore como os pesos mudam uma escolha. Compare métodos, inspecione os cálculos e teste a estabilidade do ranking.':
      'Explore how weights change a choice. Compare methods, inspect calculations and test ranking stability.',
  'Configurar cenário': 'Configure scenario',
  'Cenário JSON': 'Scenario JSON',
  'Copiar JSON': 'Copy JSON',
  'Cancelar': 'Cancel',
  'Validar e aplicar': 'Validate and apply',
  'Edite critérios (minimize/maximize), pesos, alternativas e limites inclusivos. Use ponto decimal. Copie o JSON para reproduzir o cenário. Até 12 critérios e 30 alternativas.':
      'Edit criteria (minimize/maximize), weights, alternatives and inclusive bounds. Use decimal points. Copy JSON to reproduce the scenario. Up to 12 criteria and 30 alternatives.',
  'Critérios e método': 'Criteria and method',
  'Ranking atual': 'Current ranking',
  'Dados e comparação': 'Data and comparison',
  'Sensibilidade dos pesos': 'Weight sensitivity',
  'Memória de cálculo': 'Calculation trace',
  'Cenário local • Resultados são relativos às alternativas elegíveis. Edite e copie o cenário para reproduzir os cálculos.':
      'Local scenario • Results are relative to eligible alternatives. Edit and copy the scenario to reproduce calculations.',
  'Método de ranking': 'Ranking method',
  'Soma ponderada': 'Weighted sum',
  'minimizar': 'minimize',
  'maximizar': 'maximize',
  'Pesos relativos são normalizados automaticamente.':
      'Relative weights are normalized automatically.',
  'Editor AHP': 'AHP editor',
  'Restaurar': 'Restore',
  'AHP: edite comparações recíprocas para 1–10 critérios, confira a razão de consistência e aplique pesos com CR ≤ 0,10. Com mais de 10 critérios, use pesos manuais. Consistência não prova validade das preferências.':
      'AHP: edit reciprocal comparisons for 1–10 criteria, inspect the consistency ratio and apply weights with CR ≤ 0.10. Above 10 criteria, use manual weights. Consistency does not prove preferences are valid.',
  'Atribua peso positivo a pelo menos um critério.':
      'Assign positive weight to at least one criterion.',
  'MELHOR CONJUNTO ATUAL': 'CURRENT WINNER SET',
  'Sem vencedor': 'No winner',
  'Nenhuma alternativa elegível. Revise os limites no cenário.':
      'No eligible alternative. Review the scenario bounds.',
  'Soma de utilidades ponderadas. Colunas constantes contribuem igualmente.':
      'Sum of weighted utilities. Constant columns contribute equally.',
  'Proximidade do ideal por distâncias euclidianas. Nota não é uma probabilidade.':
      'Closeness to the ideal using Euclidean distances. A score is not a probability.',
  'Critério da varredura': 'Sweep criterion',
  'O peso escolhido varia de 0% a 100%. Os demais preservam suas proporções. A fração de estabilidade não é uma probabilidade.':
      'The selected weight ranges from 0% to 100%. Other weights keep their proportions. The stability fraction is not a probability.',
  'Mantenha peso positivo em outro critério para gerar a varredura.':
      'Keep positive weight on another criterion to generate a sweep.',
  'Amostras em texto': 'Text samples',
  'Nenhuma mudança no conjunto vencedor nas amostras selecionadas.':
      'No winner-set change at the selected samples.',
  'Linhas unem amostras. Os intervalos acima não são limites exatos e não garantem estabilidade entre os pontos.':
      'Lines connect samples. These brackets are not exact boundaries and do not guarantee stability between points.',
  'Editor visual': 'Visual editor',
  'Importar / exportar JSON': 'Import / export JSON',
  'Reiniciar laboratório': 'Restart laboratory',
  'Valores originais • as restrições são aplicadas antes da normalização.':
      'Original values • Constraints apply before normalization.',
  'Alternativa': 'Alternative',
  'Sem restrições.': 'No constraints.',
  'Compare a ordem, não as notas entre métodos. Soma ponderada: utilidade min–max × peso, somada por linha. TOPSIS: normalização vetorial × peso; nota = distância ao anti-ideal / soma das duas distâncias.':
      'Compare ordering, not scores across methods. Weighted sum: min–max utility × weight, summed by row. TOPSIS: vector normalization × weight; score = distance to anti-ideal / sum of both distances.',
  'Sem resultado para inspecionar.': 'No result to inspect.',
  'Matriz normalizada e ponderada • linhas na ordem original das alternativas elegíveis.':
      'Normalized and weighted matrix • Rows follow eligible input order.',
  'A soma de cada linha produz a nota da soma ponderada.':
      'Each row sum gives the weighted-sum score.',
  'No TOPSIS, estas coordenadas ponderadas entram no cálculo das distâncias aos ideais.':
      'In TOPSIS these weighted coordinates determine the distances to the ideals.',
  'Confira os números de todas as alternativas, pesos e limites.':
      'Check the numbers for all alternative values, weights and bounds.',
  'Revise os campos destacados em vermelho antes de aplicar.':
      'Review the highlighted fields before applying.',
  'Use de 1 a 80 caracteres.': 'Use 1 to 80 characters.',
  'Use um número finito entre 0 e 1e12.':
      'Use a finite number between 0 and 1e12.',
  'Use um número finito entre −1e12 e 1e12.':
      'Use a finite number between −1e12 and 1e12.',
  'Editor visual de cenário': 'Visual scenario editor',
  'Altere os campos e aplique para recalcular. Cancelar descarta as edições. Ponto ou vírgula decimal são aceitos.':
      'Edit fields and apply to recalculate. Cancel discards edits. Decimal points or commas are accepted.',
  'Critérios e pesos': 'Criteria and weights',
  'Pesos são relativos; pelo menos um deve ser positivo. São normalizados ao calcular. Remover um critério também remove seus valores e restrições.':
      'Weights are relative; at least one must be positive. They are normalized when calculating. Removing a criterion also removes its values and constraints.',
  'Novo critério': 'New criterion',
  'Adicionar critério': 'Add criterion',
  'Alternativas e valores': 'Alternatives and values',
  'Adicionar alternativa': 'Add alternative',
  'Restrições obrigatórias': 'Hard constraints',
  'Limites inclusivos: mínimo e/ou máximo. Deixe em branco o limite que não se aplica. Alternativas que falham são excluídas antes do ranking.':
      'Inclusive minimum and/or maximum bounds. Leave an unused bound blank. Alternatives that fail are excluded before ranking.',
  'Adicionar restrição': 'Add constraint',
  'Aplicar cenário': 'Apply scenario',
  'Nome do critério': 'Criterion name',
  'Menor é melhor': 'Lower is better',
  'Maior é melhor': 'Higher is better',
  'Peso relativo': 'Relative weight',
  'Nome da alternativa': 'Alternative name',
  'Critério': 'Criterion',
  'Mínimo (opcional)': 'Minimum (optional)',
  'Máximo (opcional)': 'Maximum (optional)',
  'Use números ou frações entre 1/9 e 9 (por exemplo, 3 ou 1/3).':
      'Use numbers or fractions between 1/9 and 9 (for example, 3 or 1/3).',
  'Cada comparação deve estar entre 1/9 e 9.':
      'Each comparison must be between 1/9 and 9.',
  'AHP aceita de 1 a 10 critérios e comparações recíprocas entre 1/9 e 9.':
      'AHP accepts 1 to 10 criteria and reciprocal comparisons between 1/9 and 9.',
  'O cálculo não convergiu. Revise as comparações; nenhum peso foi aplicado.':
      'Calculation did not converge. Review comparisons; no weights were applied.',
  'Matriz de comparações AHP': 'AHP pairwise comparison matrix',
  'Cada célula compara a importância da linha com a coluna, não seus valores observados. Edite acima da diagonal: 1 = igual; 3 = três vezes; 1/3 = um terço. O inverso é preenchido automaticamente e a diagonal vale 1.':
      'Each cell compares the importance of the row with the column, not observed values. Edit above the diagonal: 1 = equal; 3 = three times; 1/3 = one third. The reciprocal is automatic and the diagonal is 1.',
  'Comparações iguais': 'Equal comparisons',
  'Carregar exemplo': 'Load example',
  'Linha / coluna': 'Row / column',
  'Consistente: CR ≤ 0,10. Pesos disponíveis para aplicar.':
      'Consistent: CR ≤ 0.10. Weights are ready to apply.',
  'Inconsistente: CR > 0,10. Revise as comparações antes de aplicar.':
      'Inconsistent: CR > 0.10. Review comparisons before applying.',
  'Para 1 ou 2 critérios, CI e CR são zero por convenção; isso não valida as preferências.':
      'For 1 or 2 criteria CI and CR are zero by convention; this does not validate preferences.',
  'Pesos calculados pelo autovetor principal. CI = (λ − n)/(n − 1); CR = CI/RI. O limite inclusivo é 0,10. Consistência não prova que as preferências são corretas. AHP aqui pondera critérios; não compara alternativas diretamente. Arraste a tabela para os lados em telas menores.':
      'Weights use the principal eigenvector. CI = (λ − n)/(n − 1); CR = CI/RI. The inclusive threshold is 0.10. Consistency does not prove preferences are correct. AHP here weights criteria; it does not directly compare alternatives. Scroll the table horizontally on smaller screens.',
  'Limite de consistência: CR ≤ 0,10': 'Consistency threshold: CR ≤ 0.10',
  'Pronto para aplicar os pesos ao cenário.':
      'Ready to apply weights to the scenario.',
  'Revise a matriz: aplicação bloqueada.':
      'Review the matrix: application blocked.',
  'Aplicar pesos': 'Apply weights',
  'Gráfico de notas por peso amostrado. Consulte os intervalos de mudança abaixo.':
      'Score chart across sampled weights. See transition brackets below.',
  'Cenário inválido: confira nomes/IDs únicos, números finitos, pesos não negativos e pelo menos um peso positivo.':
      'Invalid scenario: check unique names/IDs, finite numbers, nonnegative weights and at least one positive weight.',
  'JSON excede 100.000 caracteres.': 'JSON exceeds 100,000 characters.',
  'Direção deve ser minimize ou maximize.':
      'Direction must be minimize or maximize.',
  'ID de critério duplicado.': 'Duplicate criterion ID.',
  'Cada alternativa deve fornecer exatamente todos os valores dos critérios.':
      'Each alternative must provide exactly all criterion values.',
  'O mínimo não pode exceder o máximo.': 'Minimum cannot exceed maximum.',
  'Método de ranking ou critério de varredura desconhecido.':
      'Unknown ranking method or sweep criterion.',
  'Nomes e IDs devem ter de 1 a 80 caracteres.':
      'Names and IDs must contain 1–80 characters.',
  'Use números finitos com magnitude até 1e12.':
      'Use finite numbers with magnitude at most 1e12.',
  'Use de 1 a 12 critérios e de 1 a 30 alternativas.':
      'Use 1–12 criteria and 1–30 alternatives.',
  'Cada limite precisa de um critério existente e mínimo/máximo.':
      'Each bound needs an existing criterion and minimum/maximum.',
  'Os IDs AHP devem corresponder aos critérios do cenário.':
      'AHP IDs must match the scenario criteria.',
  'AHP deve ser consistente e corresponder aos pesos normalizados do cenário.':
      'AHP must be consistent and match normalized scenario weights.',
};
const dynamicTranslations = <String, String>{
  'Desvio log absoluto médio: ': 'Mean absolute log deviation: ',
  ' • Tríades: ': ' • Triads: ',
  'Maior desacordo via: ': 'Largest disagreement via: ',
  'Comparação atual: ': 'Current comparison: ',
  ' • Sugestão: ': ' • Suggestion: ',
  'CR da prévia: ': 'Preview CR: ',
  'CR antes: ': 'CR before: ',
  'CR depois: ': 'CR after: ',
  'Redução absoluta do CR: ': 'Absolute CR reduction: ',
  'Exibindo as 5 maiores prioridades de ':
      'Showing the top 5 priorities among ',
  ' pares.': ' pairs.',
  'Caractere inesperado': 'Unexpected character',
  'Fim inesperado da entrada': 'Unexpected end of input',
  '(no caractere ': '(at character ',
  '(na linha ': '(at line ',
  'Pesos AHP aplicados • CR ': 'AHP weights applied • CR ',
  'Não foi possível aplicar. ': 'Unable to apply. ',
  'Remover critério ': 'Remove criterion ',
  'Remover alternativa ': 'Remove alternative ',
  'Remover restrição ': 'Remove constraint ',
  'CR usado na validação: ': 'CR used for validation: ',
  'λ máximo ': 'maximum λ ',
  'Importância de ': 'Importance of ',
  ' em relação a ': ' relative to ',
  ' (fixo)': ' (fixed)',
  'dos cenários preservam o vencedor': 'of scenarios preserve the winner',
  ' mudanças amostradas': ' sampled transitions',
  'cenários •': 'scenarios •',
  'Limites inclusivos: ': 'Inclusive bounds: ',
  'normalizado → ponderado': 'normalized → weighted',
  '(ordem das linhas)': '(row order)',
  ' está abaixo do mínimo ': ' is below minimum ',
  ' excede o máximo ': ' exceeds maximum ',
  ' elegíveis': ' eligible',
  ' elegível': ' eligible',
  ' excluídas': ' excluded',
  ' excluída': ' excluded',
  'Critério ': 'Criterion ',
  'Alternativa ': 'Alternative ',
  'Restrição ': 'Constraint ',
  'Peso relativo ': 'Relative weight ',
  ' de 100': ' of 100',
  'Custo': 'Cost',
  'Latência': 'Latency',
  'Disponibilidade': 'Availability',
  'inválido': 'invalid',
};
