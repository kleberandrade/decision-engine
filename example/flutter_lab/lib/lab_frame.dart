// Compatibility with the lab's Flutter >=3.35 minimum.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' hide Text;
import 'package:flutter/services.dart';
import 'localization.dart';
import 'brand.dart';
import 'browser_bridge.dart';

String copy(BuildContext context, String pt, String en) =>
    LabLanguage.current(context) == 'en' ? en : pt;
const repositoryUrl = 'https://github.com/kleberandrade/decision-engine';
const documentationUrl = '$repositoryUrl/blob/main/doc/getting_started.md';
String sourceUrl(BuildContext context, String file) =>
    '$repositoryUrl/blob/main/doc/$file${LabLanguage.current(context) == 'pt' ? '.pt-BR' : ''}.md';
const presetIds = ['baseline', 'budget', 'availability', 'ahp'];

class LabFrame extends StatefulWidget {
  const LabFrame({super.key, required this.laboratory, required this.onPreset});
  final Widget laboratory;
  final ValueChanged<String> onPreset;
  @override
  State<LabFrame> createState() => _LabFrameState();
}

class _LabFrameState extends State<LabFrame> {
  int page = 0;
  void preset(String id) {
    widget.onPreset(id);
    setState(() => page = 0);
  }

  Future<void> link(String url) async {
    if (!openLink(url)) {
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(copy(
                context,
                'Link copiado para a área de transferência.',
                'Link copied to clipboard.'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Column(children: [
        Material(
            color: const Color(0xFF102230),
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: LayoutBuilder(builder: (context, bounds) {
                  final compact = bounds.maxWidth < 900 ||
                      MediaQuery.textScalerOf(context).scale(14) > 20;
                  final brand = SizedBox(
                      width: compact ? null : 240,
                      child: Row(children: [
                        const DecisionMark(),
                        const SizedBox(width: 10),
                        const Expanded(
                            child: Text('DECISION ENGINE',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1)))
                      ]));
                  final language = Row(
                      key: const Key('language-selector'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final code in ['pt', 'en'])
                          Semantics(
                              selected: LabLanguage.current(context) == code,
                              child: IconButton(
                                key: Key('language-$code'),
                                tooltip: code == 'pt'
                                    ? copy(context, 'Português (Brasil)',
                                        'Portuguese (Brazil)')
                                    : copy(context, 'Inglês (Reino Unido)',
                                        'English (United Kingdom)'),
                                isSelected:
                                    LabLanguage.current(context) == code,
                                constraints: const BoxConstraints(
                                    minWidth: 48, minHeight: 48),
                                onPressed: () =>
                                    LabLanguage.change(context, code),
                                icon: LanguageFlag(
                                    language: code,
                                    selected:
                                        LabLanguage.current(context) == code),
                              )),
                      ]);
                  final controls = [
                    for (final entry in [
                      (0, 'Laboratório'),
                      (1, 'Aprender'),
                      (2, 'Exemplos')
                    ])
                      TextButton(
                          key: Key('nav-${entry.$1}'),
                          onPressed: () => setState(() => page = entry.$1),
                          child: Text(entry.$2,
                              style: TextStyle(
                                  fontWeight: page == entry.$1
                                      ? FontWeight.bold
                                      : FontWeight.normal))),
                    TextButton(
                        key: const Key('nav-docs'),
                        onPressed: () =>
                            link(sourceUrl(context, 'getting_started')),
                        child: const Text('Documentação')),
                    IconButton(
                        key: const Key('nav-github'),
                        tooltip: 'GitHub',
                        onPressed: () => link(repositoryUrl),
                        icon: const Icon(Icons.open_in_new))
                  ];
                  if (compact) {
                    return Column(children: [
                      Row(children: [Expanded(child: brand), language]),
                      Row(children: [
                        Expanded(
                            child: Text(copy(
                                context,
                                ['Laboratório', 'Aprender', 'Exemplos'][page],
                                ['Laboratory', 'Learn', 'Examples'][page]))),
                        PopupMenuButton<int>(
                            key: const Key('mobile-navigation'),
                            tooltip: tr(context, 'Navegação'),
                            onSelected: (value) {
                              if (value < 3) {
                                setState(() => page = value);
                              } else {
                                link(value == 3
                                    ? documentationUrl
                                    : repositoryUrl);
                              }
                            },
                            itemBuilder: (_) => [
                                  for (final e in [
                                    (0, 'Laboratório'),
                                    (1, 'Aprender'),
                                    (2, 'Exemplos'),
                                    (3, 'Documentação'),
                                    (4, 'GitHub')
                                  ])
                                    PopupMenuItem(
                                        value: e.$1, child: Text(e.$2))
                                ])
                      ])
                    ]);
                  }
                  return Row(children: [
                    brand,
                    const Spacer(),
                    ...controls,
                    const SizedBox(width: 12),
                    language
                  ]);
                }))),
        Expanded(
            child: IndexedStack(index: page, children: [
          widget.laboratory,
          LearningView(onPreset: preset, onLink: link),
          ExampleView(onPreset: preset)
        ])),
      ]));
}

class LearningView extends StatelessWidget {
  const LearningView({super.key, required this.onPreset, required this.onLink});
  final ValueChanged<String> onPreset;
  final ValueChanged<String> onLink;
  @override
  Widget build(BuildContext context) {
    Widget paragraph(String pt, String en) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child:
            Text(copy(context, pt, en), style: const TextStyle(height: 1.5)));
    Widget heading(String pt, String en) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(copy(context, pt, en),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)));
    return SingleChildScrollView(
        key: const Key('learn-view'),
        padding: const EdgeInsets.all(24),
        child: Center(
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading('Aprender com decisões explicáveis',
                          'Learn explainable decisions'),
                      paragraph(
                          'Este guia acompanha o código 0.3.0 e sua extensão de laboratório em Unreleased. Use dados sintéticos, confira os cálculos e reproduza cenários pelo JSON.',
                          'This guide follows source 0.3.0 and its Unreleased laboratory extension. Use synthetic data, inspect calculations and reproduce scenarios through JSON.'),
                      heading(
                          '1. Fundamentos: critérios, alternativas e elegibilidade',
                          '1. Foundations: criteria, alternatives and eligibility'),
                      paragraph(
                          'Um critério define preferência por valores maiores ou menores e um peso relativo. Cada alternativa fornece todos os valores finitos. Restrições são limites obrigatórios inclusivos, aplicados antes da normalização: uma alternativa barata pode ser inelegível.',
                          'A criterion defines a preference for higher or lower values and a relative weight. Each alternative supplies all finite values. Constraints are inclusive hard bounds applied before normalization: a cheap alternative can still be ineligible.'),
                      paragraph(
                          'wⱼ = pⱼ / Σp. Exemplo: pesos 3 e 1 viram 0,75 e 0,25. Pelo menos um peso deve ser positivo. Empates compartilham posição; a primeira alternativa exibida não representa necessariamente um vencedor único.',
                          'wⱼ = pⱼ / Σp. Example: weights 3 and 1 become 0.75 and 0.25. At least one weight must be positive. Ties share a rank; the first displayed alternative is not necessarily a unique winner.'),
                      heading('2. Soma ponderada', '2. Weighted sum'),
                      paragraph(
                          'Maximizar: u=(x−mín)/(máx−mín). Minimizar: u=(máx−x)/(máx−mín). Nota Sᵢ=Σwⱼuᵢⱼ. Os extremos usam apenas alternativas elegíveis; colunas constantes contribuem igualmente. Alterar o conjunto elegível pode mudar todas as notas.',
                          'Maximize: u=(x−min)/(max−min). Minimize: u=(max−x)/(max−min). Score Sᵢ=Σwⱼuᵢⱼ. Extremes use eligible alternatives only; constant columns contribute equally. Changing eligibility can change every score.'),
                      paragraph(
                          'No exemplo, Atlas soma 0,2333 + 0,1500 + 0,2222 = 0,6056. Vega obtém 0,6500. A tabela de memória mostra cada utilidade normalizada e sua parcela ponderada.',
                          'In the sample, Atlas sums 0.2333 + 0.1500 + 0.2222 = 0.6056. Vega scores 0.6500. The trace table shows each normalized utility and weighted contribution.'),
                      heading('3. TOPSIS', '3. TOPSIS'),
                      paragraph(
                          'rᵢⱼ=xᵢⱼ/√Σxₖⱼ²; vᵢⱼ=wⱼrᵢⱼ. A direção escolhe os ideais positivo e negativo. Calcule as distâncias euclidianas d⁺ e d⁻; a nota é d⁻/(d⁺+d⁻). Alternativas indistinguíveis recebem 0,5. Coordenadas ponderadas não são parcelas aditivas dessa nota.',
                          'rᵢⱼ=xᵢⱼ/√Σxₖⱼ²; vᵢⱼ=wⱼrᵢⱼ. Direction determines positive and negative ideals. Compute Euclidean distances d⁺ and d⁻; the score is d⁻/(d⁺+d⁻). Indistinguishable alternatives receive 0.5. Weighted coordinates are not additive score contributions.'),
                      paragraph(
                          'O mesmo cenário favorece Atlas no TOPSIS (0,6232) e Vega na soma ponderada. Compare a ordem dentro de cada método, não notas entre métodos. Notas não são probabilidades.',
                          'The same scenario favors Atlas under TOPSIS (0.6232) and Vega under weighted sum. Compare ordering within each method, not scores across methods. Scores are not probabilities.'),
                      heading('4. AHP: importância e consistência',
                          '4. AHP: importance and consistency'),
                      paragraph(
                          'Aᵢⱼ compara a importância de i com j; Aⱼᵢ=1/Aᵢⱼ e Aᵢᵢ=1. O núcleo aceita 1–10 critérios e razões entre 1/9 e 9. O autovetor principal normalizado fornece pesos, sem mudar as direções dos critérios.',
                          'Aᵢⱼ compares the importance of i with j; Aⱼᵢ=1/Aᵢⱼ and Aᵢᵢ=1. The core accepts 1–10 criteria and ratios from 1/9 to 9. The normalized principal eigenvector supplies weights without changing criterion directions.'),
                      paragraph(
                          'CI=(λ−n)/(n−1), CR=CI/RI. O laboratório permite aplicar somente CR bruto ≤0,10. Para n≤2, CI e CR são zero por convenção. Consistência não prova que preferências são válidas. Isto é ponderação de critérios, não uma hierarquia AHP completa.',
                          'CI=(λ−n)/(n−1), CR=CI/RI. The lab only applies raw CR ≤0.10. For n≤2, CI and CR are zero by convention. Consistency does not prove preferences are valid. This is criterion weighting, not a full AHP hierarchy.'),
                      paragraph(
                          'Revisar inconsistências prioriza o desacordo logarítmico entre tríades. A prévia mostra o CR completo antes/depois sem mudar o cenário. Use o ajuste no rascunho e revise novamente antes de aplicar pesos. A sugestão não prova qual preferência está errada nem garante correção completa.',
                          'Review inconsistencies prioritizes log disagreement among triads. The preview shows full CR before/after without changing the scenario. Stage the adjustment and review again before applying weights. Suggestions do not prove which preference is wrong or guarantee a complete repair.'),
                      heading('5. Sensibilidade amostrada e limites',
                          '5. Sampled sensitivity and limits'),
                      paragraph(
                          'Uma varredura testa 21 pesos entre 0 e 1 e preserva as proporções dos demais. Ela compara conjuntos completos de vencedores. Os intervalos entre mudanças são amostrados: não são fronteiras exatas nem garantia de estabilidade contínua. A fração de estabilidade não é probabilidade.',
                          'A sweep tests 21 weights from 0 to 1 while retaining other weight proportions. It compares complete winner sets. Transition brackets are sampled: they are not exact boundaries or a continuous-stability guarantee. The stability fraction is not a probability.'),
                      paragraph(
                          'O núcleo é Dart puro, sem rede, IO ou dependências de execução. A UI limita cenários a 12 critérios e 30 alternativas; o AHP limita a dez critérios. Todos os cálculos são locais e imediatos. Não há tarefa contínua para pausar.',
                          'The core is pure Dart, with no network, IO or runtime dependencies. The UI bounds scenarios to 12 criteria and 30 alternatives; AHP is limited to ten criteria. Calculations are local and immediate. There is no continuous task to pause.'),
                      heading('Referências e exemplos executáveis',
                          'References and runnable examples'),
                      Wrap(spacing: 12, runSpacing: 8, children: [
                        TextButton(
                            onPressed: () =>
                                onLink(sourceUrl(context, 'methods')),
                            child: Text(copy(context, 'Métodos e equações',
                                'Methods and equations'))),
                        TextButton(
                            onPressed: () => onLink(sourceUrl(context, 'ahp')),
                            child: const Text('AHP')),
                        TextButton(
                            onPressed: () =>
                                onLink(sourceUrl(context, 'sensitivity')),
                            child: Text(
                                copy(context, 'Sensibilidade', 'Sensitivity'))),
                        FilledButton(
                            key: const Key('learn-example'),
                            onPressed: () => onPreset('baseline'),
                            child: Text(copy(
                                context,
                                'Abrir exemplo no laboratório',
                                'Open example in laboratory'))),
                      ]),
                      paragraph(
                          'Código e dados sintéticos: MIT, Kleber Andrade. Flutter e fontes conservam suas próprias licenças. A referência de RI e a política numérica estão documentadas no guia AHP.',
                          'Code and synthetic data: MIT, Kleber Andrade. Flutter and fonts retain their own licenses. The RI reference and numerical policy are documented in the AHP guide.'),
                      heading('Cinco exercícios práticos',
                          'Five practical exercises'),
                      for (final exercise in [
                        (
                          'Reproduzir: abra o exemplo básico e confira Vega=0,6500 na soma ponderada. Conclua quando exportar/reimportar JSON sem mudar as notas.',
                          'Reproduce: open the baseline and verify Vega=0.6500 under weighted sum. Finish by exporting/reimporting JSON without changing scores.'
                        ),
                        (
                          'Orçamento: abra o exemplo de limite de custo. Conclua quando Vega for rejeitada pelo custo e Nova pela disponibilidade, com motivos visíveis.',
                          'Budget: open the cost-bound example. Finish when Vega is excluded by cost and Nova by availability, with reasons visible.'
                        ),
                        (
                          'AHP: abra os pesos consistentes e depois edite as células para 9, 1/9 e 9. Revise e confira o CR da prévia. Conclua quando CR ainda alto bloquear a aplicação e descartar a prévia preservar os valores.',
                          'AHP: open consistent weights, then edit cells to 9, 1/9 and 9. Review and inspect preview CR. Finish when a still-high CR blocks application and discarding the preview preserves values.'
                        ),
                        (
                          'Sensibilidade: varra custo no cenário básico. Conclua identificando os intervalos 35–40% e 60–65% e explicando por que não são cruzamentos exatos.',
                          'Sensitivity: sweep cost in the baseline. Finish by identifying the 35–40% and 60–65% brackets and explaining why they are not exact crossings.'
                        ),
                        (
                          'Nova dimensão: acrescente suporte pelo editor visual, com valores para todas as alternativas. Conclua quando os dois rankings e a coluna ponderada renderizarem e a troca de idioma conservar os dados.',
                          'New dimension: add support using the visual editor, with values for every alternative. Finish when both rankings and the weighted column render and a language switch preserves data.'
                        ),
                      ].indexed)
                        paragraph('${exercise.$1 + 1}. ${exercise.$2.$1}',
                            '${exercise.$1 + 1}. ${exercise.$2.$2}'),
                    ]))));
  }
}

class ExampleView extends StatelessWidget {
  const ExampleView({super.key, required this.onPreset});
  final ValueChanged<String> onPreset;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
      key: const Key('examples-view'),
      padding: const EdgeInsets.all(24),
      child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                        copy(context, 'Exemplos reproduzíveis',
                            'Reproducible examples'),
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold)),
                    Text(copy(
                        context,
                        'Abrir um exemplo substitui o cenário atual. Exporte seu JSON antes de trocar.',
                        'Opening an example replaces the current scenario. Export your JSON before switching.')),
                    for (final e in [
                      (
                        'baseline',
                        'Escolha de provedor',
                        'Provider selection',
                        'Vega vence a soma ponderada; Atlas vence TOPSIS.',
                        'Vega wins weighted sum; Atlas wins TOPSIS.'
                      ),
                      (
                        'budget',
                        'Orçamento obrigatório',
                        'Hard budget',
                        'Custo ≤1200 e disponibilidade ≥99,9.',
                        'Cost ≤1200 and availability ≥99.9.'
                      ),
                      (
                        'availability',
                        'Nenhum elegível',
                        'No eligible options',
                        'Disponibilidade mínima 100: confira todas as exclusões.',
                        'Minimum availability 100: inspect all exclusions.'
                      ),
                      (
                        'ahp',
                        'Pesos AHP consistentes',
                        'Consistent AHP weights',
                        'Custo/latência/disponibilidade: 30/10/60, CR≈0.',
                        'Cost/latency/availability: 30/10/60, CR≈0.'
                      ),
                    ])
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(copy(context, e.$2, e.$3),
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                    Text(copy(context, e.$4, e.$5)),
                                    FilledButton(
                                        key: Key('preset-${e.$1}'),
                                        onPressed: () => onPreset(e.$1),
                                        child: Text(copy(
                                            context,
                                            'Abrir no laboratório',
                                            'Open in laboratory'))),
                                  ]))),
                  ]))));
}
