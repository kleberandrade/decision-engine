# Sensibilidade dos pesos

[English](sensitivity.md) · [Exemplo CLI](../example/sensitivity.dart) ·
[Laboratório Flutter](../example/flutter_lab/README.md)

`SensitivityAnalyzer` recebe um `DecisionEngine`, calcula o resultado original e
repete a avaliação com outros pesos. Preserva método, valores observados, direções
e restrições. O núcleo continua em Dart puro, sem Flutter, IO ou rede.

## Cenários completos

```dart
final report = SensitivityAnalyzer(engine: engine).analyze(alternatives,
  scenarios: [
    WeightScenario('economia', weights: {'quality': 1, 'cost': 3}),
    WeightScenario('qualidade', weights: {'quality': 3, 'cost': 1}),
  ],
);
```

Cada cenário exige nome único não vazio e exatamente uma chave por critério.
Pesos devem ser finitos e não negativos, com pelo menos um positivo. Todos os
cenários são validados antes do primeiro cálculo. O motor normaliza os pesos.
Restrições continuam ativas mesmo quando o critério recebe peso zero.

## Varredura de um critério

```dart
final report = SensitivityAnalyzer(engine: engine).sweep(alternatives,
  criterionId: 'quality', weights: [0, 0.25, 0.5, 0.75, 1],
);
```

A grade deve ser não vazia, finita, crescente (permitindo valores repetidos) e
estar em [0,1]. O critério escolhido recebe o peso normalizado solicitado. Os
demais dividem a massa restante nas proporções originais:
novoOutro = antigoOutro / somaDosOutros × (1 - alvo).

Se todos os outros pesos forem zero, só é permitido alvo=1; isso inclui motores
com um único critério. Não há distribuição uniforme implícita. Um alvo de peso
original zero pode variar se houver outros critérios positivos. A normalização
usa os pesos seguros do motor, sem somar valores relativos brutos enormes.

## Resultado

| Campo | Significado |
| --- | --- |
| `baseline` | Resultado original completo |
| `baselineWinners` | Todos os nomes empatados em primeiro |
| `scenarios` | Avaliações na ordem solicitada |
| `winners` | Conjunto completo de primeiros do cenário |
| `winnerSetChanged` | Diferença do conjunto vencedor em relação ao original |
| `rankChanges` | Posição original menos nova posição; positivo indica melhora |
| `maxWeightChange` | Maior variação absoluta de peso normalizado |
| `winnerStability` | Fração das amostras que preserva todo o conjunto vencedor original |
| `transitions` | Pares de amostras adjacentes com conjuntos vencedores diferentes |

Com benefícios [10,20], custos [100,200] e pesos originais [3,1], Premium vence
pela soma ponderada. Na grade [0,0.25,0.5,0.75,1], Basic vence nas duas primeiras,
ambos empatam em 0.5 e Premium vence nas duas últimas. A estabilidade é 2/5: o
empate altera o conjunto vencedor. Os intervalos de mudança são 0.25–0.5 e
0.5–0.75; os testes verificam esse cálculo independente.

## Limites

Os intervalos **não são fronteiras exatas**. A grade pode perder mudanças entre
amostras; a estabilidade não é probabilidade, confiança ou garantia contínua de
robustez. Nos cenários explícitos, adjacência indica apenas a ordem de entrada.
Sem cenários ou alternativas elegíveis, a estabilidade é nula. Notas de métodos
diferentes não devem ser comparadas diretamente.

Critérios gerados por AHP são aceitos. Alterar seus pesos na varredura não gera
uma nova matriz AHP consistente. Para mudar julgamentos, execute o AHP novamente
e forneça os pesos resultantes como um cenário completo.

Métodos e restrições devem ter comportamento estável entre chamadas. Mudança de
elegibilidade causa `StateError`. Coleções e matrizes são imutáveis. A memória
retida é O(amostras × alternativas × critérios), pois cada cenário guarda sua
memória de cálculo completa. Isolates e execução em segundo plano ficam com a
aplicação; o analisador é síncrono.
