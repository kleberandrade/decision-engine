// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:decision_engine/decision_engine.dart';
import 'score_chart.dart';
import 'configuration.dart';
import 'package:flutter/services.dart';

void main() => runApp(const DecisionLabApp());

class DecisionLabApp extends StatelessWidget {
  const DecisionLabApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Decision Engine Lab',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF5DE4C7),
            scaffoldBackgroundColor: const Color(0xFF09121E)),
        home: const DecisionDashboard(),
      );
}

class DecisionDashboard extends StatefulWidget {
  const DecisionDashboard({super.key});
  @override
  State<DecisionDashboard> createState() => _DecisionDashboardState();
}

class _DecisionDashboardState extends State<DecisionDashboard> {
  LabConfiguration configuration = LabConfiguration.sample();
  Map<String, String> get labels => configuration.labels;
  List<Alternative> get providers => configuration.alternatives;
  late Map<String, double> weights = configuration.sliderWeights;
  int revision = 0;
  String methodName = 'weighted_sum';
  String sweepId = 'cost';
  String? ahpStatus;

  void applyAhp() {
    final ahp = AhpWeighting().evaluate(
      criterionIds: ['availability', 'cost', 'latency'],
      comparisons: [
        [1, 2, 6],
        [1 / 2, 1, 3],
        [1 / 6, 1 / 3, 1]
      ],
    );
    setState(() {
      weights = Map.of(ahp.weights);
      ahpStatus =
          'Pesos AHP aplicados • CR ${ahp.consistencyRatio.toStringAsFixed(4)}';
    });
  }

  DecisionEngine makeEngine() => configuration.engine(
      methodName == 'weighted_sum' ? const WeightedSum() : const Topsis(),
      weights);

  Future<void> editScenario() async {
    final controller = TextEditingController(
        text: configuration.encode(weights, methodName, sweepId));
    String? error;
    final route = DialogRoute<LabConfiguration>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, update) => AlertDialog(
                  title: const Text('Configurar cenário'),
                  content: SizedBox(
                      width: 720,
                      child: SingleChildScrollView(
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Text(
                                'Edite critérios (minimize/maximize), pesos, alternativas e limites inclusivos. Use ponto decimal. Copie o JSON para reproduzir o cenário. Até 12 critérios e 30 alternativas.'),
                            const SizedBox(height: 12),
                            TextField(
                                key: const Key('scenario-json'),
                                controller: controller,
                                maxLines: 16,
                                decoration: const InputDecoration(
                                    labelText: 'Cenário JSON',
                                    border: OutlineInputBorder())),
                            if (error != null)
                              Semantics(
                                  liveRegion: true,
                                  child: Text(error!,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error))),
                          ]))),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          await Clipboard.setData(
                              ClipboardData(text: controller.text));
                        },
                        child: const Text('Copiar JSON')),
                    TextButton(
                        key: const Key('scenario-cancel'),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar')),
                    FilledButton(
                        key: const Key('scenario-apply'),
                        onPressed: () {
                          try {
                            Navigator.pop(context,
                                LabConfiguration.parse(controller.text));
                          } on FormatException catch (e) {
                            update(() => error = e.message);
                          }
                        },
                        child: const Text('Validar e aplicar')),
                  ],
                )));
    final next = await Navigator.of(context).push(route);
    await route.completed;
    controller.dispose();
    if (next != null && mounted) {
      setState(() {
        configuration = next;
        weights = next.sliderWeights;
        sweepId = next.sweepId;
        methodName = next.methodName;
        ahpStatus = null;
        revision++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = weights.values.fold(0.0, (a, b) => a + b);
    final engine = total == 0 ? null : makeEngine();
    final baseline = engine?.evaluate(providers);
    SensitivityReport? report;
    if (engine != null &&
        weights.entries.any((e) => e.key != sweepId && e.value > 0)) {
      report = SensitivityAnalyzer(engine: engine).sweep(providers,
          criterionId: sweepId, weights: List.generate(21, (i) => i / 20));
    }
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF163B3C),
                        borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.explore_outlined,
                        color: Color(0xFF5DE4C7), size: 30)),
                const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DECISION ENGINE',
                          style: TextStyle(
                              color: Color(0xFF5DE4C7),
                              fontSize: 11,
                              letterSpacing: 3)),
                      Text('Laboratório de decisões',
                          style: TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w700)),
                    ]),
                const Chip(
                    avatar: Icon(Icons.offline_bolt_outlined, size: 16),
                    label: Text('Local • Dart puro')),
              ]),
          const SizedBox(height: 12),
          const Text(
              'Explore como os pesos mudam uma escolha. Compare métodos, inspecione os cálculos e teste a estabilidade do ranking.',
              style: TextStyle(
                  color: Color(0xFFA9B8CB), fontSize: 15, height: 1.5)),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, bounds) {
            final controls =
                panel('01', 'Critérios e método', controlsBody(total));
            final ranking = panel('02', 'Ranking atual', rankingBody(baseline));
            if (bounds.maxWidth < 760) {
              return Column(
                  children: [controls, const SizedBox(height: 16), ranking]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: controls),
              const SizedBox(width: 16),
              Expanded(child: ranking),
            ]);
          }),
          const SizedBox(height: 16),
          panel('03', 'Dados e comparação', comparisonBody(total)),
          const SizedBox(height: 16),
          panel('04', 'Sensibilidade dos pesos', sensitivityBody(report)),
          const SizedBox(height: 16),
          panel('05', 'Memória de cálculo', traceBody(baseline)),
          const SizedBox(height: 16),
          const Text(
              'Cenário local • Resultados são relativos às alternativas elegíveis. Edite e copie o cenário para reproduzir os cálculos.',
              style: TextStyle(color: Color(0xFF94A5BA), height: 1.5)),
          const SizedBox(height: 16),
        ]),
      )),
    )));
  }

  Widget panel(String number, String title, Widget body) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
            color: const Color(0xFF111E2D),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF26374A))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(number,
                style: const TextStyle(
                    color: Color(0xFF5DE4C7), fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)))
          ]),
          const SizedBox(height: 20),
          body,
        ]),
      );

  Widget controlsBody(double total) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownButtonFormField<String>(
            key: revision == 0
                ? const Key('method-selector')
                : ValueKey('method-selector-$revision'),
            isExpanded: true,
            initialValue: methodName,
            decoration: const InputDecoration(
                labelText: 'Método de ranking', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(
                  value: 'weighted_sum',
                  child: Text('Soma ponderada',
                      maxLines: 1, overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(value: 'topsis', child: Text('TOPSIS'))
            ],
            onChanged: (value) => setState(() => methodName = value!)),
        const SizedBox(height: 16),
        for (final id in labels.keys) ...[
          Row(children: [
            Expanded(
                child: Text(
                    '${labels[id]} • ${total == 0 ? 0 : (weights[id]! / total * 100).round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(
                configuration.criteria
                            .firstWhere((c) => c.id == id)
                            .direction ==
                        CriterionDirection.maximize
                    ? 'maximizar'
                    : 'minimizar',
                style: const TextStyle(color: Color(0xFF94A5BA), fontSize: 12))
          ]),
          Slider(
              key: Key('weight-$id'),
              value: weights[id]!,
              min: 0,
              max: 1,
              divisions: 100,
              semanticFormatterCallback: (v) =>
                  '${labels[id]}: ${(v * 100).round()} de 100',
              label: 'Peso relativo ${weights[id]!.toStringAsFixed(2)}',
              onChanged: (value) => setState(() {
                    weights[id] = value;
                    ahpStatus = null;
                  })),
        ],
        const Text('Pesos relativos são normalizados automaticamente.',
            style: TextStyle(color: Color(0xFF94A5BA), fontSize: 12)),
        const SizedBox(height: 12),
        Wrap(spacing: 10, runSpacing: 8, children: [
          OutlinedButton.icon(
              key: const Key('apply-ahp'),
              onPressed: labels.keys
                          .toSet()
                          .containsAll(['cost', 'latency', 'availability']) &&
                      labels.length == 3
                  ? applyAhp
                  : null,
              icon: const Icon(Icons.account_tree_outlined, size: 18),
              label: const Text('Usar pesos AHP')),
          TextButton(
              key: const Key('weights-reset'),
              onPressed: () => setState(() {
                    weights = configuration.sliderWeights;
                    ahpStatus = null;
                  }),
              child: const Text('Restaurar')),
        ]),
        const Text(
            'AHP demonstrativo: disponibilidade/custo/latência; matriz [1,2,6; ½,1,3; ⅙,⅓,1]. Apenas estes três IDs. CR indica consistência, não validade das preferências.',
            style: TextStyle(color: Color(0xFF94A5BA), height: 1.4)),
        if (ahpStatus != null)
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(ahpStatus!,
                  style: const TextStyle(color: Color(0xFF5DE4C7)))),
      ]);

  Widget rankingBody(DecisionResult? result) {
    if (result == null) {
      return const Text('Atribua peso positivo a pelo menos um critério.');
    }
    final winners = result.ranking
        .where((r) => r.rank == 1)
        .map((r) => r.alternative.name)
        .join(' + ');
    return Column(
        key: const Key('ranking'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MELHOR CONJUNTO ATUAL',
              style: TextStyle(
                  color: Color(0xFF94A5BA), fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 8),
          Text(winners.isEmpty ? 'Sem vencedor' : winners,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5DE4C7))),
          const SizedBox(height: 8),
          Text(
              '${result.eligible.length} elegíveis • ${result.excluded.length} excluída'),
          const SizedBox(height: 18),
          for (final entry in result.ranking)
            Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(children: [
                  Row(children: [
                    Text('${entry.rank.toString().padLeft(2, '0')}  ',
                        style: const TextStyle(color: Color(0xFF94A5BA))),
                    Expanded(child: Text(entry.alternative.name)),
                    Text(entry.score.toStringAsFixed(4),
                        style: const TextStyle(
                            fontFeatures: [FontFeature.tabularFigures()]))
                  ]),
                  const SizedBox(height: 7),
                  LinearProgressIndicator(
                      value: entry.score.clamp(0.0, 1.0), minHeight: 5),
                ])),
          if (result.ranking.isEmpty)
            const Text(
                'Nenhuma alternativa elegível. Revise os limites no cenário.'),
          for (final excluded in result.excluded)
            Text('${excluded.alternative.name}: ${excluded.reasons.join('; ')}',
                style: const TextStyle(color: Color(0xFFFFC770), fontSize: 12)),
          const SizedBox(height: 12),
          Text(
              methodName == 'weighted_sum'
                  ? 'Soma de utilidades ponderadas. Colunas constantes contribuem igualmente.'
                  : 'Proximidade do ideal por distâncias euclidianas. Nota não é uma probabilidade.',
              style: const TextStyle(color: Color(0xFF94A5BA), height: 1.4)),
        ]);
  }

  Widget sensitivityBody(SensitivityReport? report) {
    final selector = DropdownButtonFormField<String>(
        key: revision == 0
            ? const Key('criterion-selector')
            : ValueKey('criterion-selector-$revision'),
        isExpanded: true,
        initialValue: sweepId,
        decoration: const InputDecoration(
            labelText: 'Critério da varredura', border: OutlineInputBorder()),
        items: labels.entries
            .map((e) => DropdownMenuItem(
                value: e.key,
                child: Text(e.value,
                    maxLines: 1, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: (value) => setState(() => sweepId = value!));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
          spacing: 24,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(width: 260, child: selector),
            if (report != null)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    '${((report.winnerStability ?? 0) * 100).round()}% dos cenários preservam o vencedor',
                    style: const TextStyle(
                        color: Color(0xFF5DE4C7), fontWeight: FontWeight.bold)),
                Text(
                    '21 cenários • ${report.transitions.length} mudanças amostradas',
                    style: const TextStyle(color: Color(0xFF94A5BA))),
              ]),
          ]),
      const SizedBox(height: 16),
      const Text(
          'O peso escolhido varia de 0% a 100%. Os demais preservam suas proporções. A fração de estabilidade não é uma probabilidade.',
          style: TextStyle(color: Color(0xFF94A5BA), height: 1.4)),
      if (report == null)
        const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
                'Mantenha peso positivo em outro critério para gerar a varredura.')),
      if (report != null) ...[
        const SizedBox(height: 12),
        ScoreChart(
            key: const Key('score-chart'),
            report: report,
            criterionId: sweepId),
        Wrap(spacing: 18, runSpacing: 8, children: [
          for (var i = 0; i < report.baseline.eligible.length; i++)
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                      color: seriesColors[i % seriesColors.length],
                      shape: BoxShape.circle)),
              const SizedBox(width: 7),
              Text(report.baseline.eligible[i].name),
            ])
        ]),
        ExpansionTile(title: const Text('Amostras em texto'), children: [
          for (final scenario in report.scenarios)
            ListTile(
                title: Text(
                    '${percent(scenario.result)}: ${scenario.winners.join(' + ')}'),
                subtitle: Text(scenario.result.ranking
                    .map((r) =>
                        '${r.alternative.name}: ${r.score.toStringAsFixed(4)}')
                    .join(' • '))),
        ]),
        const SizedBox(height: 18),
        if (report.transitions.isEmpty)
          const Text(
              'Nenhuma mudança no conjunto vencedor nas amostras selecionadas.'),
        for (final transition in report.transitions)
          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                  '${percent(transition.from.result)} → ${percent(transition.to.result)}: ${transition.from.winners.join(' + ')} → ${transition.to.winners.join(' + ')}',
                  style: const TextStyle(color: Color(0xFFFFC770)))),
        const SizedBox(height: 8),
        const Text(
            'Linhas unem amostras. Os intervalos acima não são limites exatos e não garantem estabilidade entre os pontos.',
            style:
                TextStyle(color: Color(0xFF94A5BA), fontSize: 12, height: 1.4)),
      ],
    ]);
  }

  Widget comparisonBody(double total) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(spacing: 12, runSpacing: 8, children: [
          FilledButton.icon(
              key: const Key('scenario-edit'),
              onPressed: editScenario,
              icon: const Icon(Icons.edit_note),
              label: const Text('Editar / copiar cenário')),
          TextButton(
              key: const Key('scenario-reset'),
              onPressed: () => setState(() {
                    configuration = LabConfiguration.sample();
                    weights = configuration.sliderWeights;
                    sweepId = 'cost';
                    methodName = 'weighted_sum';
                    ahpStatus = null;
                    revision++;
                  }),
              child: const Text('Reiniciar laboratório')),
        ]),
        const SizedBox(height: 12),
        const Text(
            'Valores originais • as restrições são aplicadas antes da normalização.'),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                const DataColumn(label: Text('Alternativa')),
                for (final id in labels.keys)
                  DataColumn(label: Text(labels[id]!))
              ],
              rows: [
                for (final a in providers)
                  DataRow(cells: [
                    DataCell(Text(a.name)),
                    for (final id in labels.keys)
                      DataCell(Text('${a.values[id]}'))
                  ])
              ],
            )),
        Text(configuration.bounds.isEmpty
            ? 'Sem restrições.'
            : 'Limites inclusivos: ${configuration.bounds}'),
        const SizedBox(height: 12),
        if (total > 0)
          for (final method in [const WeightedSum(), const Topsis()])
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                    '${method.name}: ${configuration.engine(method, weights).evaluate(providers).ranking.map((r) => '${r.rank}. ${r.alternative.name} (${r.score.toStringAsFixed(4)})').join(' • ')}')),
        const Text(
            'Compare a ordem, não as notas entre métodos. Soma ponderada: utilidade min–max × peso, somada por linha. TOPSIS: normalização vetorial × peso; nota = distância ao anti-ideal / soma das duas distâncias.',
            style: TextStyle(color: Color(0xFF94A5BA), height: 1.4)),
      ]);

  String percent(DecisionResult result) {
    final index = result.criteria.indexWhere((c) => c.id == sweepId);
    return '${(result.weights[index] * 100).round()}%';
  }

  Widget traceBody(DecisionResult? result) {
    if (result?.trace == null) {
      return const Text('Sem resultado para inspecionar.');
    }
    final value = result!;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text(
          'Matriz normalizada e ponderada • linhas na ordem original das alternativas elegíveis.',
          style: TextStyle(color: Color(0xFF94A5BA))),
      const SizedBox(height: 12),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              const DataColumn(label: Text('Alternativa')),
              for (final c in value.criteria)
                DataColumn(
                    label: Text('${labels[c.id]}: normalizado → ponderado'))
            ],
            rows: [
              for (var i = 0; i < value.eligible.length; i++)
                DataRow(cells: [
                  DataCell(Text(value.eligible[i].name)),
                  for (var j = 0; j < value.criteria.length; j++)
                    DataCell(Text(
                        '${value.trace!.normalized[i][j].toStringAsFixed(4)} → ${value.trace!.weighted[i][j].toStringAsFixed(4)}')),
                ])
            ],
          )),
      for (final diagnostic in value.trace!.diagnostics.entries)
        Text(
            '${diagnostic.key}: ${diagnostic.value.map((v) => v.toStringAsFixed(6)).join(', ')} (ordem das linhas)'),
      const SizedBox(height: 10),
      Text(
          methodName == 'weighted_sum'
              ? 'A soma de cada linha produz a nota da soma ponderada.'
              : 'No TOPSIS, estas coordenadas ponderadas entram no cálculo das distâncias aos ideais.',
          style: const TextStyle(
              color: Color(0xFF94A5BA), fontSize: 12, height: 1.4)),
    ]);
  }
}
