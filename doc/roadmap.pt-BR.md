# Roadmap

[English](roadmap.md)

## 0.1.0 — base inicial

Núcleo Dart puro, interfaces, modelos imutáveis, soma ponderada, TOPSIS, restrições
inclusivas, exclusões explicadas, empates determinísticos, memória de cálculo,
exemplos executáveis, testes, CI e documentação em inglês e português.

## 0.2.0 — publicada, com 160/160 pontos

AHP para gerar pesos por comparações pareadas, validar reciprocidade e calcular
índice e razão de consistência. Documentar tabela de índices aleatórios, tamanhos
suportados e política de aceitação. Usar os pesos com os dois métodos existentes.

Implementação com iteração de potência, de 1 a 10 critérios e conversão para
critérios com direções explícitas. Veja [AHP](ahp.pt-BR.md). Integração na main, publicação hospedada e
release v0.2.0 estão verificadas.

## 0.3.0 — preparação da release

Cenários completos e varreduras de pesos; comparação de todos os vencedores;
mudanças de posição; estabilidade amostrada; intervalos de transição; resultados
imutáveis e laboratório Flutter separado. Exemplos CLI/JavaScript e documentação
bilíngue. A versão 0.3 ainda não está publicada; a nova CI precisa ser verificada.

## Propostas posteriores

Produto ponderado com domínio positivo e
cálculo logarítmico; VIKOR com regras de compromisso;
persistência JSON versionada; exemplos integrados com outros engines.
Estes itens ainda não estão implementados nem representam prazo contratado.

Antes de publicar: concluir CI nos SDKs mínimo e estável, revisar dry-run e arquivos,
e verificar disponibilidade do nome no pub.dev. Criar o GitHub não publica nem
reserva o nome no pub.dev.
