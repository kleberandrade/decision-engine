# Cenários e limites do laboratório

[English: complete guide](SCENARIOS.md)

Abra **Editor visual** para editar com campos identificados: nomes e valores das
alternativas, critérios, pesos relativos e preferência por valores menores ou
maiores. Use **Adicionar critério**, **Adicionar alternativa** e os botões de
remoção. Remover um critério também remove seus valores e restrições. Pelo menos
um critério e uma alternativa são mantidos; novos critérios começam com valor
zero em todas as alternativas, que você pode ajustar antes de aplicar.

Em **Restrições obrigatórias**, escolha o critério e informe mínimo e/ou máximo
inclusivos; deixe vazio o limite que não se aplica. Remova a linha para eliminar
uma restrição. Os campos aceitam ponto ou vírgula decimal. **Aplicar cenário**
valida tudo e recalcula o ranking; **Cancelar** ou Escape descarta o rascunho.
A interface mantém pesos atuais, método e varredura, inclusive permitindo
corrigir um rascunho com todos os pesos zerados.

Abra **Importar / exportar JSON** para importar, copiar ou editar um cenário.
O JSON continua permitindo adicionar/remover alternativas e critérios,
alterar direções (`minimize`/`maximize`), pesos e restrições inclusivas (`minimum`
e `maximum`). Cada alternativa deve conter todos os critérios. Use ponto decimal,
nomes/IDs únicos e pelo menos um peso positivo. O JSON também guarda método e
critério da varredura. Copie-o e salve localmente para reproduzir a configuração;
não há persistência automática nem envio dos dados a um servidor.

**Cancelar** ou Escape descarta edições. Uma entrada inválida preserva o cenário
anterior. **Restaurar** retorna aos pesos importados; **Reiniciar laboratório**
restaura todos os dados originais. As avaliações são imediatas, sem execução
contínua que exija pausar.

No cenário inicial, Nova é excluída por disponibilidade <99,9%. A soma ponderada
favorece Vega (0,6500); TOPSIS favorece Atlas (0,6232). Para Atlas na soma
ponderada: (2/3 × 0,35) + (0,6 × 0,25) + (5/9 × 0,4) = 0,6056. No TOPSIS,
as coordenadas ponderadas entram nas distâncias aos ideais; não são parcelas
aditivas da nota. Compare ordens, não notas de métodos diferentes.

Experimente disponibilidade mínima 100: não haverá vencedor, e todas as razões
de exclusão aparecem. Remova a restrição para incluir Nova. Para novo critério,
acrescente seu valor em todas as alternativas e ajuste as restrições associadas.
Pesos representam compensações; limites representam elegibilidade obrigatória.

A varredura avalia 21 amostras, preservando a proporção dos demais pesos. Requer
peso positivo em outro critério. Os intervalos não são fronteiras exatas e a
estabilidade não é probabilidade. **Amostras em texto** oferece os resultados sem
depender do gráfico.

## Editor da matriz AHP

Abra **Editor AHP** para comparar a importância dos critérios atuais (1–10).
Edite acima da diagonal com números ou frações entre 1/9 e 9, como `3`, `0,5`
ou `1/3`. O inverso é automático e a diagonal vale 1. A comparação considera a
importância da linha em relação à coluna; não muda a direção minimizar/maximizar.
Uma nova matriz começa com comparações iguais. A tabela tem rolagem horizontal,
e CR e ações permanecem fixos. Acima de dez critérios, use pesos manuais.

Os pesos vêm do autovetor principal calculado pelo núcleo. A interface mostra
pesos, λ, CI e RI. CI=(λ−n)/(n−1); CR=CI/RI. Para um ou dois critérios, CI e CR
são zero por convenção. A aplicação exige **CR bruto ≤0,10**; o valor detalhado
acompanha o indicador arredondado. Entradas inválidas apagam resultados calculados
e bloqueiam a aplicação. Uma matriz inconsistente pode ser inspecionada, mas não
aplicada. Consistência não prova validade das preferências; não se trata de uma
hierarquia AHP completa nem de comparações entre alternativas.

**Aplicar pesos** recalcula o cenário preservando alternativas, direções,
restrições, método e varredura. **Cancelar** descarta o rascunho. **Comparações
iguais** repõe todos os valores em 1. No cenário original, **Carregar exemplo**
preenche os pesos 0,3/0,1/0,6 na ordem custo/latência/disponibilidade. As células
editáveis são 3, 1/2 e 1/6. Experimente 9, 1/9 e 9 para observar inconsistência.

O JSON mantém a matriz aplicada em `ahp.criterionIds` e `ahp.comparisons`.
A importação recalcula tudo e exige pesos normalizados correspondentes, com
tolerância de 1e-8. Cenários antigos continuam válidos. O editor reabre a matriz
aplicada enquanto os pesos corresponderem a ela. Mudanças manuais nos pesos
removem evidência desatualizada da exportação. Alterar nomes, valores ou limites
pelo editor visual conserva a evidência quando IDs e pesos permanecem iguais.
**Restaurar** volta aos pesos de referência anteriores ao AHP; reiniciar restaura
o cenário completo original.

Limites da UI: 1–12 critérios, 1–30 alternativas, 100.000 caracteres JSON e
magnitude numérica até 1e12. Pesos maiores que um são reescalados sem alterar
proporções; sliders têm passos relativos de 0,01. Nomes têm até 80 caracteres.
Tabelas largas têm rolagem horizontal; painéis se empilham em telas estreitas.
Use Tab/Shift+Tab e setas. Consulte as [validações reais](../../doc/lab_validation.md).

## Referências e créditos

[Equações](../../doc/methods.pt-BR.md) · [AHP](../../doc/ahp.pt-BR.md) ·
[Sensibilidade](../../doc/sensitivity.pt-BR.md). Código e dados sintéticos sob MIT;
Flutter e fontes conservam suas licenças nos avisos do aplicativo compilado.

## Cinco exercícios práticos

1. **Reproduzir a referência.** Exporte e reimporte o JSON. Conclua quando ordens
   e notas dos dois métodos forem idênticas antes e depois.
2. **Modelar orçamento obrigatório.** Acrescente custo máximo de 1200. Conclua
   quando Vega e Nova forem excluídas, cada uma com seus motivos visíveis.
3. **Adicionar critério.** Crie `support`, direção `maximize`, peso positivo e
   valores para todos os provedores. Conclua quando ambos os rankings e a coluna
   da memória de cálculo forem exibidos.
4. **Inspecionar transição amostrada.** Varra custo com os pesos originais. Conclua
   identificando o intervalo 35–40%, conferindo as amostras textuais e explicando
   por que ele não representa uma fronteira exata.
5. **Editar e conferir AHP.** Na ordem original, informe 3, 1/2 e 1/6, confira
   CR≈0 e aplique os pesos 30/10/60. Exporte/reimporte o JSON e depois tente
   9, 1/9 e 9. Conclua quando a evidência consistente for reproduzida e a matriz
   cíclica bloquear a aplicação sem alterar o cenário.
