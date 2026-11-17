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
                                                              OutlineInputBorder()),
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
                                (result?.isConsistent == true
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
                          onPressed: result?.isConsistent == true
                              ? () => Navigator.pop(context, result)
                              : null,
                          child: const Text('Aplicar pesos')),
                    ]),
                  ]))));
}
