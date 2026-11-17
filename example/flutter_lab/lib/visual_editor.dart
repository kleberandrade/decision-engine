import 'dart:convert';
// Keep the lab's Flutter >=3.35 import path; 3.50 deprecates this re-export.
// ignore: deprecated_member_use
import 'package:flutter/material.dart' hide Text;
import 'localization.dart';
import 'configuration.dart';

/// Isolated form draft; the same JSON boundary validates both editors.
class VisualScenarioEditor extends StatefulWidget {
  const VisualScenarioEditor(
      {super.key, required this.configuration, this.relativeWeights});
  final LabConfiguration configuration;
  final Map<String, double>? relativeWeights;

  @override
  State<VisualScenarioEditor> createState() => _VisualScenarioEditorState();
}

class _CriterionDraft {
  _CriterionDraft(this.id, this.label, this.weight, this.direction);
  final String id;
  String label;
  String weight;
  String direction;
}

class _AlternativeDraft {
  _AlternativeDraft(this.key, this.name, this.values);
  final int key;
  String name;
  final Map<String, String> values;
}

class _BoundDraft {
  _BoundDraft(this.key, this.criterion, this.minimum, this.maximum);
  final int key;
  String criterion;
  String minimum;
  String maximum;
}

class _VisualScenarioEditorState extends State<VisualScenarioEditor> {
  final form = GlobalKey<FormState>();
  late final criteria = [
    for (final c in widget.configuration.criteria)
      _CriterionDraft(c.id, widget.configuration.labels[c.id]!,
          '${widget.relativeWeights?[c.id] ?? c.weight}', c.direction.name)
  ];
  late final alternatives = [
    for (var i = 0; i < widget.configuration.alternatives.length; i++)
      _AlternativeDraft(
          i,
          widget.configuration.alternatives[i].name,
          widget.configuration.alternatives[i].values
              .map((id, v) => MapEntry(id, '$v')))
  ];
  late final bounds = [
    for (var i = 0; i < widget.configuration.bounds.length; i++)
      _BoundDraft(
          i,
          widget.configuration.bounds[i]['criterion'] as String,
          '${widget.configuration.bounds[i]['minimum'] ?? ''}',
          '${widget.configuration.bounds[i]['maximum'] ?? ''}')
  ];
  int nextCriterion = 1;
  late int nextAlternative = alternatives.length;
  late int nextBound = bounds.length;
  String? error;

  double number(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || !parsed.isFinite || parsed.abs() > 1e12) {
      throw const FormatException(
          'Confira os números de todas as alternativas, pesos e limites.');
    }
    return parsed;
  }

  void apply() {
    if (!form.currentState!.validate()) {
      setState(() =>
          error = 'Revise os campos destacados em vermelho antes de aplicar.');
      return;
    }
    try {
      final sweep = criteria.any((c) => c.id == widget.configuration.sweepId)
          ? widget.configuration.sweepId
          : criteria.first.id;
      final draftWeights = {for (final c in criteria) c.id: number(c.weight)};
      final ahp = widget.configuration.ahpResult;
      final retainAhp = ahp != null &&
          criteria.length == widget.configuration.criteria.length &&
          criteria
              .every((c) => widget.configuration.labels.containsKey(c.id)) &&
          widget.configuration.matchesAhp(draftWeights);
      final result = LabConfiguration.parse(jsonEncode({
        'method': widget.configuration.methodName,
        'sweep': sweep,
        'criteria': [
          for (final c in criteria)
            {
              'id': c.id,
              'label': c.label.trim(),
              'weight': draftWeights[c.id],
              'direction': c.direction
            }
        ],
        'alternatives': [
          for (final a in alternatives)
            {
              'name': a.name.trim(),
              'values': a.values.map((id, v) => MapEntry(id, number(v)))
            }
        ],
        if (retainAhp)
          'ahp': {
            'criterionIds': ahp.criterionIds,
            'comparisons': ahp.comparisons
          },
        'constraints': [
          for (final b in bounds)
            {
              'criterion': b.criterion,
              if (b.minimum.trim().isNotEmpty) 'minimum': number(b.minimum),
              if (b.maximum.trim().isNotEmpty) 'maximum': number(b.maximum)
            }
        ],
      }));
      Navigator.pop(context, result);
    } on FormatException catch (e) {
      setState(() => error = 'Não foi possível aplicar. ${e.message}');
    }
  }

  void addCriterion() => setState(() {
        String id;
        do {
          id = 'criterion${nextCriterion++}';
        } while (criteria.any((c) => c.id == id));
        criteria.add(
            _CriterionDraft(id, tr(context, 'Novo critério'), '1', 'maximize'));
        for (final a in alternatives) {
          a.values[id] = '0';
        }
      });

  void removeCriterion(_CriterionDraft c) => setState(() {
        criteria.remove(c);
        for (final a in alternatives) {
          a.values.remove(c.id);
        }
        bounds.removeWhere((b) => b.criterion == c.id);
        error = null;
      });

  Widget field(
          String key, String label, String value, ValueChanged<String> change,
          {bool numeric = false,
          bool optional = false,
          bool nonnegative = false}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: TextFormField(
            key: ValueKey(key),
            initialValue: value,
            onChanged: change,
            keyboardType: numeric
                ? const TextInputType.numberWithOptions(
                    decimal: true, signed: true)
                : TextInputType.text,
            decoration: InputDecoration(
                labelText: tr(context, label),
                border: const OutlineInputBorder()),
            validator: (text) {
              final v = text?.trim() ?? '';
              if (optional && v.isEmpty) return null;
              if (!numeric) {
                return v.isEmpty || v.length > 80
                    ? tr(context, 'Use de 1 a 80 caracteres.')
                    : null;
              }
              final n = double.tryParse(v.replaceAll(',', '.'));
              return n == null ||
                      !n.isFinite ||
                      n.abs() > 1e12 ||
                      (nonnegative && n < 0)
                  ? nonnegative
                      ? tr(context, 'Use um número finito entre 0 e 1e12.')
                      : tr(context, 'Use um número finito entre −1e12 e 1e12.')
                  : null;
            },
          ));

  Widget remove(String key, String label, VoidCallback? action) => IconButton(
      key: ValueKey(key),
      tooltip: tr(context, label),
      onPressed: action,
      icon: const Icon(Icons.delete_outline));

  Widget card(String key, String title, Widget action, List<Widget> children) =>
      Card(
          key: ValueKey(key),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))),
                      action
                    ]),
                    ...children,
                  ])));

  @override
  Widget build(BuildContext context) => Dialog(
      insetPadding: const EdgeInsets.all(12),
      child: SizedBox(
          width: 920,
          height: MediaQuery.sizeOf(context).height * 0.88,
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Editor visual de cenário',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text(
                        'Altere os campos e aplique para recalcular. Cancelar descarta as edições. Ponto ou vírgula decimal são aceitos.'),
                    const SizedBox(height: 8),
                    Expanded(
                        child: SingleChildScrollView(
                            child: Form(
                                key: form,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text('Critérios e pesos',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const Text(
                                          'Pesos são relativos; pelo menos um deve ser positivo. São normalizados ao calcular. Remover um critério também remove seus valores e restrições.'),
                                      for (var i = 0; i < criteria.length; i++)
                                        criterionCard(criteria[i], i),
                                      OutlinedButton.icon(
                                          key: const Key('add-criterion'),
                                          onPressed: criteria.length < 12
                                              ? addCriterion
                                              : null,
                                          icon: const Icon(Icons.add),
                                          label:
                                              const Text('Adicionar critério')),
                                      const SizedBox(height: 20),
                                      const Text('Alternativas e valores',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      for (final a in alternatives)
                                        alternativeCard(a),
                                      OutlinedButton.icon(
                                          key: const Key('add-alternative'),
                                          onPressed: alternatives.length < 30
                                              ? () => setState(() {
                                                    final index =
                                                        nextAlternative++;
                                                    alternatives.add(
                                                        _AlternativeDraft(
                                                            index,
                                                            tr(context,
                                                                'Alternativa ${index + 1}'),
                                                            {
                                                          for (final c
                                                              in criteria)
                                                            c.id: '0'
                                                        }));
                                                  })
                                              : null,
                                          icon: const Icon(Icons.add),
                                          label: const Text(
                                              'Adicionar alternativa')),
                                      const SizedBox(height: 20),
                                      const Text('Restrições obrigatórias',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      const Text(
                                          'Limites inclusivos: mínimo e/ou máximo. Deixe em branco o limite que não se aplica. Alternativas que falham são excluídas antes do ranking.'),
                                      for (final b in bounds) boundCard(b),
                                      OutlinedButton.icon(
                                          key: const Key('add-bound'),
                                          onPressed: () => setState(() =>
                                              bounds.add(_BoundDraft(
                                                  nextBound++,
                                                  criteria.first.id,
                                                  '0',
                                                  ''))),
                                          icon: const Icon(Icons.add),
                                          label: const Text(
                                              'Adicionar restrição')),
                                    ])))),
                    if (error != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Semantics(
                              liveRegion: true,
                              child: Text(error!,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error)))),
                    Wrap(alignment: WrapAlignment.end, spacing: 12, children: [
                      TextButton(
                          key: const Key('visual-cancel'),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar')),
                      FilledButton(
                          key: const Key('visual-apply'),
                          onPressed: apply,
                          child: const Text('Aplicar cenário')),
                    ]),
                  ]))));

  Widget criterionCard(_CriterionDraft c, int index) => card(
          'criterion-${c.id}',
          'Critério ${index + 1}',
          remove('remove-criterion-${c.id}', 'Remover critério ${c.label}',
              criteria.length > 1 ? () => removeCriterion(c) : null),
          [
            field('criterion-label-${c.id}', 'Nome do critério', c.label,
                (v) => setState(() => c.label = v)),
            DropdownButtonFormField<String>(
                key: ValueKey('direction-${c.id}'),
                initialValue: c.direction,
                isExpanded: true,
                decoration: InputDecoration(
                    labelText: tr(context, 'Preferência'),
                    border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                      value: 'minimize', child: Text('Menor é melhor')),
                  DropdownMenuItem(
                      value: 'maximize', child: Text('Maior é melhor'))
                ],
                onChanged: (v) => c.direction = v!),
            field('criterion-weight-${c.id}', 'Peso relativo', c.weight,
                (v) => c.weight = v,
                numeric: true, nonnegative: true),
          ]);

  Widget alternativeCard(_AlternativeDraft a) => Card(
      key: ValueKey('alternative-${a.key}'),
      child: ExpansionTile(
          initiallyExpanded: true,
          title: Text('Alternativa ${a.key + 1}'),
          trailing: remove(
              'remove-alternative-${a.key}',
              'Remover alternativa ${a.name}',
              alternatives.length > 1
                  ? () => setState(() => alternatives.remove(a))
                  : null),
          children: [
            Padding(
                padding: const EdgeInsets.all(12),
                child: Column(children: [
                  field('alternative-name-${a.key}', 'Nome da alternativa',
                      a.name, (v) => a.name = v),
                  for (final c in criteria)
                    field('value-${a.key}-${c.id}', c.label, a.values[c.id]!,
                        (v) => a.values[c.id] = v,
                        numeric: true),
                ]))
          ]));

  Widget boundCard(_BoundDraft b) => card(
          'bound-${b.key}',
          'Restrição ${b.key + 1}',
          remove('remove-bound-${b.key}', 'Remover restrição ${b.key + 1}',
              () => setState(() => bounds.remove(b))),
          [
            DropdownButtonFormField<String>(
                key: ValueKey('bound-criterion-${b.key}'),
                initialValue: b.criterion,
                isExpanded: true,
                decoration: InputDecoration(
                    labelText: tr(context, 'Critério'),
                    border: OutlineInputBorder()),
                items: [
                  for (final c in criteria)
                    DropdownMenuItem(
                        value: c.id,
                        child: Text(c.label,
                            maxLines: 1, overflow: TextOverflow.ellipsis))
                ],
                onChanged: (v) => b.criterion = v!),
            field('bound-min-${b.key}', 'Mínimo (opcional)', b.minimum,
                (v) => b.minimum = v,
                numeric: true, optional: true),
            field('bound-max-${b.key}', 'Máximo (opcional)', b.maximum,
                (v) => b.maximum = v,
                numeric: true, optional: true),
          ]);
}
