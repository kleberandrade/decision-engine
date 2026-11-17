# Contratos de extensão

[English](extending.md)

Implemente `DecisionMethod`: forneça `name` e `evaluate(DecisionMatrix)`.
A matriz é imutável, não vazia e validada, com pesos normalizados. Retorne
`MethodEvaluation` com uma nota finita por linha (maior é melhor), duas matrizes
com as dimensões originais e diagnósticos opcionais com um valor finito por linha.
A escala das notas customizadas é livre. A semântica matemática é responsabilidade
do autor; o motor verifica finitude e dimensões.

O [exemplo executável](../example/custom_method.dart) usa apenas o primeiro critério
para demonstrar o contrato. Não é um método multicritério geral. Não importe
`src/` nem herde do motor.

Implemente `DecisionConstraint` com `criterionId` existente e
`rejectionReason(double)`: nulo aprova, texto reprova. Todas as restrições rodam e
todos os motivos ficam no resultado. Estratégias devem ter comportamento estável;
o motor não clona o estado de implementações fornecidas pela aplicação.
