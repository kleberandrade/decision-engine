# decision_engine

**Decisão multicritério explicável em Dart puro**, para aplicativos Flutter e
serviços Dart. Compare alternativas com critérios, pesos e requisitos obrigatórios.
O núcleo não tem dependências de execução, imports de Flutter, IO ou acesso à rede.

[English](README.md) · [Guia](doc/getting_started.pt-BR.md) ·
[Métodos e equações](doc/methods.pt-BR.md) · [Arquitetura](doc/architecture.pt-BR.md) ·
[Extensões](doc/extending.pt-BR.md) · [Roadmap](doc/roadmap.pt-BR.md)

## Estado e instalação

A versão **0.1.0 está publicada no [pub.dev](https://pub.dev/packages/decision_engine)**,
vinculada ao publisher verificado [kleberandrade.dev](https://pub.dev/publishers/kleberandrade.dev),
com **160 pontos** na análise. Requer Dart >=3.3.0 <4.0.0 e pode ser usada no Flutter.

```yaml
dependencies:
  decision_engine: ^0.1.0
```

Execute `dart pub add decision_engine` ou `flutter pub add decision_engine`.
A [release v0.1.0](https://github.com/kleberandrade/decision-engine/releases/tag/v0.1.0)
aponta para o commit `fcc0a86`, aprovado na CI. O AHP está na branch `feat/ahp`,
previsto para a 0.2.0; não faz parte da API publicada na 0.1.0.

## Como funciona

1. Defina critérios e a direção: minimizar custo, maximizar disponibilidade.
2. Atribua pesos relativos; o motor os normaliza para somarem um.
3. Informe alternativas com um valor numérico finito para cada critério.
4. Aplique requisitos como `MinimumValue('availability', 99.9)`.
5. Escolha `const WeightedSum()` ou `const Topsis()` e execute `evaluate`.
6. Inspecione ranking, exclusões, pesos e memória de cálculo.

```dart
import 'package:decision_engine/decision_engine.dart';

void main() {
  final engine = DecisionEngine(
    criteria: [
      Criterion.maximize('quality', weight: 3),
      Criterion.minimize('price', weight: 1),
    ],
    method: const WeightedSum(),
  );
  final result = engine.evaluate([
    Alternative('Básico', values: {'quality': 10, 'price': 100}),
    Alternative('Premium', values: {'quality': 20, 'price': 200}),
  ]);
  print(result.best?.name); // Premium
  print(result.ranking.first.score); // 0.75
}
```

## Métodos disponíveis

| Método | Cálculo | Uso |
| --- | --- | --- |
| `WeightedSum` | Normalização min-max orientada à preferência e soma ponderada | Trocas aditivas e explicação por contribuição |
| `Topsis` | Normalização vetorial e distâncias euclidianas aos ideais | Comparação pela proximidade da solução ideal |

Valores negativos e zero são aceitos. Pesos devem ser finitos e não negativos,
com pelo menos um positivo. Peso zero remove a influência no ranking, mas não
anula restrições obrigatórias. Colunas constantes não diferenciam alternativas.

## Resultados e limites

`ranking` contém alternativas, notas e posições. Empates exatos preservam a ordem
de entrada e recebem posições de competição: `1, 1, 3`. `best` retorna a primeira
alternativa empatada, sem afirmar que existe um vencedor único.

`excluded` contém todos os motivos de exclusão. `eligible` define a ordem das
linhas de `trace.normalized`, `trace.weighted` e dos diagnósticos do TOPSIS.
`criteria` e `weights` definem as colunas e os pesos normalizados. As coleções
são imutáveis, incluindo mapas e matrizes aninhados.

Sem alternativas elegíveis, `best` e `trace` são nulos. As notas não são
probabilidades e não devem ser comparadas entre métodos ou execuções com
conjuntos diferentes. Adicionar ou remover alternativas pode mudar o ranking.

Implemente `DecisionMethod` ou `DecisionConstraint` para estender por composição.
AHP, análise de sensibilidade e laboratório visual Flutter estão no roadmap;
não fazem parte desta implementação.

Execute `dart test`, `dart analyze --fatal-infos` e os exemplos em `example/`.
Consulte os comandos completos em [CONTRIBUTING.md](CONTRIBUTING.md).
