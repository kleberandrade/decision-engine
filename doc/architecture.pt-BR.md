# Arquitetura

[English](architecture.md)

`DecisionEngine` valida entradas, aplica restrições, delega os cálculos e ordena o
resultado. Não importa métodos concretos. `DecisionMethod` controla normalização,
nota e diagnóstico; `DecisionConstraint` controla a elegibilidade.

| Diretório | Responsabilidade |
| --- | --- |
| `lib/src/domain/` | Critérios, alternativas, matriz validada, resultados e memória |
| `lib/src/contracts/` | Interfaces de métodos e restrições |
| `lib/src/methods/` | Soma ponderada e TOPSIS |
| `lib/src/constraints/` | Limites inclusivos mínimo e máximo |
| `lib/src/engine/` | Orquestração sem dependência de métodos concretos |
| `test/` | Comportamento verificado apenas pela API pública |

Use apenas `package:decision_engine/decision_engine.dart`. Coleções são copiadas e
imutáveis, inclusive mapas e matrizes internos. Cada execução possui seu estado.
Estratégias customizadas devem evitar estado compartilhado. Restrições customizadas
são referenciadas, não clonadas; seu comportamento deve permanecer estável.

Linhas da memória seguem `result.eligible`; colunas seguem `result.criteria`.
O ranking possui ordenação própria. A saída de extensões é validada quanto a
finitude e dimensões, sem comprovar a correção matemática do algoritmo externo.

O núcleo não possui Flutter, HTTP, persistência, isolates ou integração obrigatória
com outros engines. Aplicações controlam esses recursos. Os métodos usam tempo e
memória O(linhas × colunas); a ordenação acrescenta O(linhas × log(linhas)).
