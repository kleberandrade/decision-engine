# Cenários e limites do laboratório

[English: complete guide](SCENARIOS.md)

Abra **Editar / copiar cenário** para adicionar/remover alternativas e critérios,
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
depender do gráfico. AHP demonstra uma matriz fixa e consistente somente para
os três IDs originais, com pesos 0,6/0,3/0,1 e CR=0; não inclui editor arbitrário
de comparações. Consistência não prova validade das preferências.

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
5. **Explicar AHP e recuperar estado.** Aplique o exemplo, confira CR=0 e pesos
   60/30/10 e reinicie. Conclua quando disponibilidade/custo/latência retornarem
   a 40/35/25 e Vega vencer novamente na soma ponderada.
