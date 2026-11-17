# Primeiros passos

[English](getting_started.md)

1. Instale pelo Git seguindo o [README](../README.pt-BR.md).
2. Defina IDs únicos, pesos relativos e direções para cada critério.
3. Informe alternativas com nomes únicos e exatamente as chaves dos critérios.
4. Componha `DecisionEngine` com `WeightedSum` ou `Topsis`.
5. Aplique `MinimumValue` e/ou `MaximumValue` para exigências inclusivas.
6. Execute `evaluate` e inspecione ranking, exclusões, pesos e memória de cálculo.

Execute os exemplos `example/weighted_sum.dart`, `example/decision_engine_example.dart`
e `example/custom_method.dart` com `dart run`.

No Flutter, importe a mesma biblioteca Dart. Não há widgets nem execução automática
em segundo plano. Trate `best == null`. As linhas da memória seguem `eligible`,
não a posição no ranking. Consulte os [métodos](methods.pt-BR.md) antes de
interpretar notas ou comparar conjuntos de candidatos diferentes.
