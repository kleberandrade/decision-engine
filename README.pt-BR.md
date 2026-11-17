# decision_engine

**Decisão multicritério explicável em Dart puro**, para aplicativos Flutter e
serviços Dart. Compare alternativas com critérios, pesos e requisitos obrigatórios.
O núcleo não tem dependências de execução, imports de Flutter, IO ou acesso à rede.

[English](README.md) · [Guia](doc/getting_started.pt-BR.md) ·
[Métodos e equações](doc/methods.pt-BR.md) · [Arquitetura](doc/architecture.pt-BR.md) ·
[Sensibilidade](doc/sensitivity.pt-BR.md) · [Laboratório Flutter](example/flutter_lab/README.md) ·
[Pesos AHP](doc/ahp.pt-BR.md) · [Extensões](doc/extending.pt-BR.md) · [Roadmap](doc/roadmap.pt-BR.md)

## Estado e instalação

A versão estável **0.3.0** está publicada sob o publisher verificado
[kleberandrade.dev](https://pub.dev/publishers/kleberandrade.dev), com **160/160 pontos**
(verificado em 17/11/2026). Inclui AHP e sensibilidade amostrada. O laboratório
Flutter separado consome o código deste checkout. O núcleo permanece em Dart
puro, compatível com Dart >=3.3.0 <4.0.0.

```yaml
dependencies:
  decision_engine: ^0.3.0
```

Execute `dart pub add decision_engine` ou `flutter pub add decision_engine`.
AHP requer **0.2.0 ou superior**; sensibilidade exige **0.3.0 ou superior**.
Confira a [lista de versões](https://pub.dev/packages/decision_engine/versions).
Alterações em Unreleased não são publicadas automaticamente no pub.dev.

[Laboratório online](https://kleberandrade.github.io/decision-engine/) ·
[Guia de cenários e limites](example/flutter_lab/SCENARIOS.pt-BR.md)

Use o editor visual para alternativas, critérios, pesos e restrições inclusivas, compare métodos e
inspecione cálculos. Copie o JSON para reproduzir o cenário.

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
Pesos por AHP estão na 0.2.0. Esta branch acrescenta sensibilidade amostrada e
um laboratório Flutter separado. Consulte [o guia AHP](doc/ahp.pt-BR.md)
para pesos, validação de reciprocidade e índice/razão de consistência.

Execute `dart test`, `dart analyze --fatal-infos` e os exemplos em `example/`.
Consulte os comandos completos em [CONTRIBUTING.md](CONTRIBUTING.md).

## Usar o AHP da 0.2.0

O guia de AHP e `example/ahp.dart` descrevem a API da **0.2.0**.
O recurso não faz parte da versão 0.1.0 hospedada.

## Sensibilidade e laboratório (0.3.0)

`SensitivityAnalyzer(engine: engine).sweep(alternatives, criterionId: 'cost',
weights: [0, 0.25, 0.5, 0.75, 1])` varia um peso e preserva as proporções dos demais.
Use `WeightScenario` com `analyze` para conjuntos completos de pesos.
O resultado compara todos os vencedores, inclusive empates, e as posições de cada
alternativa. Intervalos amostrados não são fronteiras exatas; estabilidade não é
probabilidade. Veja o [guia completo](doc/sensitivity.pt-BR.md).

O [laboratório Flutter](example/flutter_lab/README.md) tem controles de pesos,
AHP, comparação de métodos, curvas amostradas e matriz ponderada. Execute
`flutter run -d chrome` no diretório do exemplo. Ele requer Flutter >=3.35.0 e
não acrescenta nenhuma dependência Flutter ao núcleo.
