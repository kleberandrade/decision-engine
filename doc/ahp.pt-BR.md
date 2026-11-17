# Pesos de critérios com AHP

[English](ahp.md)

`AhpWeighting` calcula pesos relativos antes do ranking. Não implementa uma
hierarquia completa nem comparações pareadas de alternativas. Use os critérios
gerados com `WeightedSum` ou `Topsis`.

## Convenção de entrada

Informe IDs únicos ordenados e uma matriz quadrada. A[i][j] representa a importância
do critério i em relação ao j: 1 indica igualdade, 3 indica importância tripla e
1/3 a relação inversa. Importância é diferente de direção: custo pode ser muito
importante e continuar sendo um critério a minimizar.

São aceitos de 1 a 10 critérios e valores finitos no intervalo [1/9,9], inclusive
razões contínuas. A diagonal deve ser um, e A[i][j] × A[j][i] deve ser um dentro
da tolerância absoluta `reciprocityTolerance`, padrão 1e-8. Ruído aceito é mantido;
a biblioteca não corrige a matriz. Dados incompletos são rejeitados.

## Cálculo e diagnóstico

A iteração de potência parte de pesos uniformes, multiplica pela matriz e
normaliza a soma. Para convergir, tanto a maior alteração absoluta de peso quanto
o resíduo relativo max(abs(A*w - lambda*w))/lambda devem ser <= `tolerance`, padrão
1e-10. A estimativa de lambda é a média de (A*w)[i]/w[i]. O limite padrão é de
10000 iterações; sem convergência, ocorre `StateError`, sem pesos provisórios.

CI = max(0,(lambdaMax - n)/(n - 1)); CR = CI/RI. Para ordens 1 e 2, CI e CR são
zero por convenção. CI negativo por arredondamento é limitado a zero. O resultado
imutável contém pesos, matriz, autovalor estimado, CI, RI, CR, iterações e resíduo.

| Ordem | RI |
| --- | --- |
| 1 | 0 |
| 2 | 0 |
| 3 | 0.58 |
| 4 | 0.90 |
| 5 | 1.12 |
| 6 | 1.24 |
| 7 | 1.32 |
| 8 | 1.41 |
| 9 | 1.45 |
| 10 | 1.49 |

A tabela usa a convenção de Saaty reproduzida na Tabela 1 de
[Ishizaka e Labib (2009)](https://pure.port.ac.uk/ws/files/42847/ORI-preprint-AIshizaka.pdf).
Existem outras tabelas publicadas; estes valores fazem parte da política numérica
da biblioteca.

## Política de consistência

Convergência numérica e aceitação dos julgamentos são verificações distintas.
Uma matriz convergente e inconsistente retorna `isConsistent == false` para
inspeção. A política da biblioteca é inclusiva: CR <= `consistencyThreshold`,
padrão 0.10; o artigo citado usa a convenção de menos de 10%. O limiar configurável
deve ser finito em [0,1). CR baixo não comprova a qualidade dos julgamentos.

`toCriteria(directions)` exige uma direção para cada ID, preserva a ordem e
rejeita resultados inconsistentes por padrão. Após inspecionar os diagnósticos,
é possível adotar esses pesos explicitamente com `requireConsistency: false`.
A leitura de `weights` mantém os resultados disponíveis para análise.

Execute `dart run example/ahp.dart`. A matriz consistente [[1,2,6],[1/2,1,3],
[1/6,1/3,1]] gera pesos [0.6,0.3,0.1], verificados independentemente nos testes.
O custo é O(iterações × n²), com memória O(n²). A aplicação controla execução
e revisão dos julgamentos.


## Revisão de inconsistências (API fonte Unreleased)

`AhpConsistencyAdvisor` está neste checkout, ainda não no pacote hospedado 0.3.0.
Execute `dart run example/ahp_review.dart`. A API recebe um `AhpResult` e retorna
`baseline` e `comparisons`. Cada par contém `row`, `column`, `meanLogDeviation`,
`triadCount`, `witness` e `adjustment` opcional; a prévia oferece `value`,
`evaluation` (CR e pesos completos) e `targetWasClamped`.

Para cada par i<j, a prioridade é
`média_k |ln(Aij) - ln(Aik) - ln(Akj)|`, com k diferente de i,j.
O relatório informa a tríade de maior desacordo; empates seguem linha/coluna.
Isso prioriza revisão, sem provar qual julgamento está errado. Ordens 1/2 não
possuem tríades; desvios <=1e-10 são tratados como ruído numérico.

O alvo é a média geométrica das razões indiretas Aik×Akj, limitada a [1/9,9].
São testados quatro passos logarítmicos (100%, 75%, 50%, 25%) até o alvo.
Cada candidato altera somente Aij e seu inverso, recalculando autovetor e CR
completos. Só é oferecido o melhor candidato convergente que reduza o CR em mais
de 1e-12. Pode não existir melhora entre os candidatos. A heurística não garante
ótimo global nem correção completa da matriz.

A referência é reavaliada com convergência e reciprocidade padrão, preservando
o limiar de consistência. Matrizes aceitas apenas com tolerância de reciprocidade
mais frouxa são rejeitadas nessa fronteira. Relatórios e matrizes são imutáveis;
criar a prévia não aplica pesos. No laboratório, usar o ajuste altera o rascunho;
aplicar pesos ao cenário ainda exige CR bruto <=0,10.

Com razões editáveis cíclicas 9,1/9,9, um ajuste limitado reduz CR de 6,1302682
para 0,48347731: a aplicação continua bloqueada. Com quatro critérios e matriz
de uns, exceto A01=9 e seu recíproco, esse par é a prioridade única; sugerir 1
restaura CR≈0 e pesos iguais. Nenhum exemplo prova que a sugestão representa
uma preferência adequada à decisão real.
