# Métodos e convenções

[English](methods.md)

As linhas representam alternativas e as colunas representam critérios. Todos os
valores devem ser finitos. Pesos relativos são normalizados para somarem um; pelo
menos um deve ser positivo. IDs, nomes e chaves são validados antes das exclusões.
Restrições obrigatórias rodam antes da normalização; todos os motivos são retidos.

## Soma ponderada

Para maximizar: u = (x - mínimo) / (máximo - mínimo).
Para minimizar: u = (máximo - x) / (máximo - mínimo).
Uma coluna constante recebe utilidade 1 em todas as alternativas.
A nota é a soma de peso normalizado multiplicado pela utilidade.

Com benefícios [10,20,15], custos [100,200,125] e pesos [3,1], os pesos normalizados
são [0.75,0.25]. As utilidades são [[0,1],[1,0],[0.5,0.75]] e as notas são
[0.25,0.75,0.5625]. A segunda alternativa vence. Os pesos expressam trocas entre
amplitudes normalizadas, e não entre unidades originais.

## TOPSIS

Normalize cada coluna pela sua norma euclidiana: r = x / raiz(soma(x²)).
Colunas inteiramente zero recebem zero. Multiplique cada coluna pelo peso.
Para maximizar, o ideal positivo é o maior valor ponderado e o negativo é o menor;
para minimizar, inverta. Calcule as distâncias euclidianas dPositivo e dNegativo.
A nota é dNegativo / (dPositivo + dNegativo).

Se as duas distâncias forem zero, a nota é 0.5: alternativas indistinguíveis,
conjunto unitário ou diferenças apenas em critérios de peso zero. Com benefício
[1,2], custo [1,3] e pesos iguais, as notas são aproximadamente [0.585786,0.414214].
Os testes verificam as distâncias calculadas independentemente.

## Interpretação e limites

Notas maiores são preferidas. Empates exatos compartilham posição (1,1,3) e
preservam a ordem original de exibição. Não há tolerância de empate aproximado.
Valores negativos são aceitos; a direção do critério determina os ideais.

O cálculo escala colunas e pesos para evitar overflow, mas continua sujeito ao
arredondamento e underflow de ponto flutuante. Não há precisão arbitrária.
Critérios podem compensar uns aos outros; exigências obrigatórias devem ser
restrições. Notas não são probabilidades e não são comparáveis entre métodos,
pesos ou conjuntos diferentes. Alterar o conjunto pode mudar o ranking, inclusive
por reversão de ranking no TOPSIS. Análise de sensibilidade ainda exige reavaliação
explícita e está prevista no roadmap.
