import 'package:decision_engine/decision_engine.dart';
// Retain the declared Flutter >=3.35 import path on Flutter 3.50.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' hide Text;
import 'localization.dart';

/// Pairwise importance judgments; all AHP calculations belong to the core.
class AhpMatrixEditor extends StatefulWidget {
  const AhpMatrixEditor(
      {super.key,
      required this.criteria,
      required this.labels,
      this.initialResult});
  final List<Criterion> criteria;
  final Map<String, String> labels;
  final AhpResult? initialResult;
  @override
  State<AhpMatrixEditor> createState() => _AhpMatrixEditorState();
}

class _AhpMatrixEditorState extends State<AhpMatrixEditor> {
  final inputs = <(int, int), TextEditingController>{};
  AhpResult? result;
  String? error;
  AhpConsistencyReview? diagnosis;
  AhpComparisonReview? selectedReview;
  final previewAnchor = GlobalKey();
  List<String> get ids => widget.criteria.map((c) => c.id).toList();
  String label(int i) => widget.labels[ids[i]] ?? ids[i];

  @override
  void initState() {
    super.initState();
    final previous = widget.initialResult;
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final oldI = previous?.criterionIds.indexOf(ids[i]) ?? -1;
        final oldJ = previous?.criterionIds.indexOf(ids[j]) ?? -1;
        final value =
            oldI >= 0 && oldJ >= 0 ? previous!.comparisons[oldI][oldJ] : 1.0;
        inputs[(i, j)] = TextEditingController(text: '$value');
      }
    }
    calculate();
  }

  @override
  void dispose() {
    for (final controller in inputs.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double ratio(String text) {
    final parts = text.trim().replaceAll(',', '.').split('/');
    final numerator = double.tryParse(parts.first.trim());
    final denominator = parts.length == 1
        ? 1.0
        : parts.length == 2
            ? double.tryParse(parts.last.trim())
            : null;
    if (numerator == null ||
        denominator == null ||
        !numerator.isFinite ||
        !denominator.isFinite ||
        denominator == 0) {
      throw const FormatException(
          'Use números ou frações entre 1/9 e 9 (por exemplo, 3 ou 1/3).');
    }
    final value = numerator / denominator;
    if (!value.isFinite || value < 1 / 9 || value > 9) {
      throw const FormatException('Cada comparação deve estar entre 1/9 e 9.');
    }
    return value;
  }

  void calculate() {
    result = null;
    error = null;
    diagnosis = null;
    selectedReview = null;
    try {
      final matrix =
          List.generate(ids.length, (_) => List.filled(ids.length, 1.0));
      for (final entry in inputs.entries) {
        final (i, j) = entry.key;
        final value = ratio(entry.value.text);
        matrix[i][j] = value;
        matrix[j][i] = 1 / value;
      }
      result = AhpWeighting().evaluate(criterionIds: ids, comparisons: matrix);
    } on FormatException catch (e) {
      error = e.message;
    } on ArgumentError {
      error =
          'AHP aceita de 1 a 10 critérios e comparações recíprocas entre 1/9 e 9.';
    } on StateError {
      error =
          'O cálculo não convergiu. Revise as comparações; nenhum peso foi aplicado.';
    }
  }

  String displayRatio(double value) {
    if (value == value.roundToDouble()) return '${value.toInt()}';
    final inverse = 1 / value;
    if (inverse == inverse.roundToDouble()) return '1/${inverse.toInt()}';
    return '$value';
  }

  void load(Map<String, double>? weights) => setState(() {
        for (final entry in inputs.entries) {
          final (i, j) = entry.key;
          entry.value.text = weights == null
              ? '1'
              : displayRatio(weights[ids[i]]! / weights[ids[j]]!);
        }
        calculate();
      });

  void diagnose() => setState(() {
        selectedReview = null;
        try {
          diagnosis = const AhpConsistencyAdvisor().review(result!);
        } on ArgumentError {
          error = 'Não foi possível revisar esta matriz. Confira os valores.';
        } on StateError {
          error = 'Não foi possível revisar esta matriz. Confira os valores.';
        }
      });

  int? priority(int i, int j) {
    final index = diagnosis?.comparisons
            .take(3)
            .toList()
            .indexWhere((p) => p.row == i && p.column == j) ??
        -1;
    return index < 0 ? null : index + 1;
  }

  void showPreview(AhpComparisonReview pair) {
    setState(() => selectedReview = pair);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = previewAnchor.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(target,
            alignment: .1,
            duration: MediaQuery.of(context).disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 180));
      }
    });
  }

  Widget reviewBody() => Column(
          key: const Key('ahp-review'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Comparações prioritárias para revisão',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text(
                'Prioridade = desvio log absoluto médio das relações indiretas Aik × Akj. Tríades em desacordo não provam qual julgamento está errado. Marcadores #1–#3 destacam prioridades; empates são possíveis.'),
            if (diagnosis!.comparisons.isEmpty)
              const Text('Nenhum desacordo de tríade acima da tolerância.'),
            for (final entry in diagnosis!.comparisons.take(5).indexed)
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '#${entry.$1 + 1} • ${label(entry.$2.row)} / ${label(entry.$2.column)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(
                                'Desvio log absoluto médio: ${entry.$2.meanLogDeviation.toStringAsPrecision(6)} • Tríades: ${entry.$2.triadCount}'),
                            Text(
                                'Maior desacordo via: ${label(entry.$2.witness)}'),
                            if (entry.$2.adjustment != null) ...[
                              Text(
                                  'Comparação atual: ${result!.comparisons[entry.$2.row][entry.$2.column].toStringAsPrecision(6)} • Sugestão: ${entry.$2.adjustment!.value.toStringAsPrecision(6)}'),
                              Text(
                                  'CR da prévia: ${entry.$2.adjustment!.evaluation.consistencyRatio.toStringAsPrecision(8)}'),
                              OutlinedButton(
                                  key: Key(
                                      'ahp-preview-${entry.$2.row}-${entry.$2.column}'),
                                  onPressed: () => showPreview(entry.$2),
                                  child: const Text(
                                      'Ver impacto antes de ajustar')),
                            ] else
                              const Text(
                                  'Nenhum ajuste testado reduziu o CR para este par.'),
                          ]))),
            if (diagnosis!.comparisons.length > 5)
              Text(
                  'Exibindo as 5 maiores prioridades de ${diagnosis!.comparisons.length} pares.'),
            if (selectedReview != null)
              Container(key: previewAnchor, child: previewBody()),
            const Text(
                'Sugestões são heurísticas: média geométrica dos caminhos indiretos e três passos intermediários, limitados a 1/9–9. Cada prévia muda só um par e recalcula o CR no núcleo. Não há garantia de solução global ou de que a preferência sugerida seja correta.'),
          ]);

  Widget previewBody() {
    final pair = selectedReview!;
    final adjustment = pair.adjustment!;
    final after = adjustment.evaluation;
    final before = diagnosis!.baseline.consistencyRatio;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
                key: const Key('ahp-preview-impact'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prévia de ajuste — cenário ainda inalterado',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                      '${label(pair.row)} / ${label(pair.column)}: ${result!.comparisons[pair.row][pair.column].toStringAsPrecision(6)} → ${adjustment.value.toStringAsPrecision(6)}'),
                  Text('CR antes: ${before.toStringAsPrecision(8)}'),
                  Text(
                      'CR depois: ${after.consistencyRatio.toStringAsPrecision(8)}'),
                  Text(
                      'Redução absoluta do CR: ${(before - after.consistencyRatio).toStringAsPrecision(6)}'),
                  Text(after.isConsistent
                      ? 'A prévia atende CR ≤ 0,10.'
                      : 'A prévia ainda supera CR 0,10; serão necessárias outras revisões.'),
                  if (adjustment.targetWasClamped)
                    const Text(
                        'O alvo indireto excede a escala; a sugestão foi limitada a 1/9–9.'),
                  const Text('Pesos da prévia'),
                  for (final c in widget.criteria)
                    Text(
                        '${widget.labels[c.id] ?? c.id}: ${(after.weights[c.id]! * 100).toStringAsFixed(2)}%'),
                  const Text(
                      'Usar no rascunho altera apenas esta comparação e seu inverso. O cenário só recebe pesos ao clicar Aplicar pesos.'),
                  Wrap(spacing: 12, runSpacing: 8, children: [
                    OutlinedButton(
                        key: const Key('ahp-preview-cancel'),
                        onPressed: () => setState(() => selectedReview = null),
                        child: const Text('Descartar prévia')),
                    FilledButton(
                        key: const Key('ahp-stage-adjustment'),
                        onPressed: () {
                          inputs[(pair.row, pair.column)]!.text =
                              '${adjustment.value}';
                          setState(calculate);
                        },
                        child: const Text('Usar ajuste no rascunho')),
                  ]),
                ])));
  }

  @override
  Widget build(BuildContext context) => Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
          width: 1100,
          height: MediaQuery.sizeOf(context).height * .90,
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Matriz de comparações AHP',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Expanded(
                        child: SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                          const Text(
                              'Cada célula compara a importância da linha com a coluna, não seus valores observados. Edite acima da diagonal: 1 = igual; 3 = três vezes; 1/3 = um terço. O inverso é preenchido automaticamente e a diagonal vale 1.'),
                          const SizedBox(height: 12),
                          Wrap(spacing: 12, runSpacing: 8, children: [
                            OutlinedButton(
                                key: const Key('ahp-equal'),
                                onPressed: () => load(null),
                                child: const Text('Comparações iguais')),
                            if (ids.length == 3 &&
                                ids.toSet().containsAll(
                                    ['cost', 'latency', 'availability']))
                              OutlinedButton(
                                  key: const Key('ahp-demo'),
                                  onPressed: () => load({
                                        'cost': 3,
                                        'latency': 1,
                                        'availability': 6
                                      }),
                                  child: const Text('Carregar exemplo')),
                          ]),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                key: const Key('ahp-matrix'),
                                headingRowHeight: 72,
                                dataRowMinHeight: 64,
                                dataRowMaxHeight: 80,
                                columnSpacing: 16,
                                columns: [
                                  const DataColumn(
                                      label: Text('Linha / coluna')),
                                  for (var j = 0; j < ids.length; j++)
                                    DataColumn(
                                        label: Tooltip(
                                            message: tr(context, label(j)),
                                            child: SizedBox(
                                                width: 112,
                                                child: Text(label(j),
                                                    maxLines: 2,
                                                    overflow: TextOverflow
                                                        .ellipsis))))
                                ],
                                rows: [
                                  for (var i = 0; i < ids.length; i++)
                                    DataRow(cells: [
                                      DataCell(SizedBox(
                                          width: 140,
                                          child: Tooltip(
                                              message: tr(context, label(i)),
                                              child: Text(label(i),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis)))),
                                      for (var j = 0; j < ids.length; j++)
                                        DataCell(i < j
                                            ? SizedBox(
                                                width: 112,
                                                child: Semantics(
                                                    label: tr(context,
                                                        'Importância de ${label(i)} em relação a ${label(j)}'),
                                                    child: TextField(
                                                      key: Key('ahp-$i-$j'),
                                                      controller:
                                                          inputs[(i, j)],
                                                      keyboardType:
                                                          TextInputType.text,
                                                      decoration: InputDecoration(
                                                          border:
                                                              const OutlineInputBorder(),
                                                          labelText: priority(
                                                                      i, j) ==
                                                                  null
                                                              ? null
                                                              : '#${priority(i, j)}',
                                                          enabledBorder: priority(
                                                                      i, j) ==
                                                                  null
                                                              ? null
                                                              : const OutlineInputBorder(
                                                                  borderSide: BorderSide(
                                                                      color: Color(
                                                                          0xFFFFC770),
                                                                      width:
                                                                          2))),
                                                      onChanged: (_) =>
                                                          setState(calculate),
                                                    )))
                                            : Semantics(
                                                label: tr(context,
                                                    '${label(i)} / ${label(j)}: ${i == j ? '1 (fixo)' : result?.comparisons[i][j].toStringAsPrecision(5) ?? 'inválido'}'),
                                                child: Text(i == j
                                                    ? '1'
                                                    : result?.comparisons[i][j]
                                                            .toStringAsPrecision(
                                                                5) ??
                                                        '—'))),
                                    ])
                                ],
                              )),
                          const SizedBox(height: 16),
                          if (result != null) ...[
                            Text(
                                result!.isConsistent
                                    ? 'Consistente: CR ≤ 0,10. Pesos disponíveis para aplicar.'
                                    : 'Inconsistente: CR > 0,10. Revise as comparações antes de aplicar.',
                                key: const Key('ahp-consistency')),
                            Text(
                                'CR usado na validação: ${result!.consistencyRatio.toStringAsPrecision(12)}. λ máximo ${result!.lambdaMax.toStringAsFixed(6)} • CI ${result!.consistencyIndex.toStringAsFixed(6)} • RI ${result!.randomIndex}'),
                            if (ids.length <= 2)
                              const Text(
                                  'Para 1 ou 2 critérios, CI e CR são zero por convenção; isso não valida as preferências.'),
                            const SizedBox(height: 8),
                            for (final c in widget.criteria)
                              Text(
                                  '${widget.labels[c.id] ?? c.id}: ${(result!.weights[c.id]! * 100).toStringAsFixed(2)}%',
                                  key: Key('ahp-weight-${c.id}')),
                          ],
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                              key: const Key('ahp-diagnose'),
                              onPressed: result != null && ids.length >= 3
                                  ? diagnose
                                  : null,
                              icon: const Icon(Icons.troubleshoot),
                              label: const Text('Revisar inconsistências')),
                          if (ids.length < 3)
                            const Text(
                                'São necessários pelo menos 3 critérios para revisar tríades.'),
                          if (diagnosis != null) reviewBody(),
                          const SizedBox(height: 12),
                          const Text(
                              'Pesos calculados pelo autovetor principal. CI = (λ − n)/(n − 1); CR = CI/RI. O limite inclusivo é 0,10. Consistência não prova que as preferências são corretas. AHP aqui pondera critérios; não compara alternativas diretamente. Arraste a tabela para os lados em telas menores.'),
                        ]))),
                    const SizedBox(height: 8),
                    if (result != null)
                      Text('CR ${result!.consistencyRatio.toStringAsFixed(4)}',
                          key: const Key('ahp-cr'),
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('Limite de consistência: CR ≤ 0,10'),
                    Semantics(
                        liveRegion: true,
                        child: Text(
                            error ??
                                (selectedReview != null
                                    ? 'Prévia ativa: use ou descarte o ajuste antes de aplicar pesos.'
                                    : result?.isConsistent == true
                                        ? 'Pronto para aplicar os pesos ao cenário.'
                                        : 'Revise a matriz: aplicação bloqueada.'),
                            key: const Key('ahp-status'))),
                    Wrap(alignment: WrapAlignment.end, spacing: 12, children: [
                      TextButton(
                          key: const Key('ahp-cancel'),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar')),
                      FilledButton(
                          key: const Key('ahp-apply'),
                          onPressed: result?.isConsistent == true &&
                                  selectedReview == null
                              ? () => Navigator.pop(context, result)
                              : null,
                          child: const Text('Aplicar pesos')),
                    ]),
                  ]))));
}
