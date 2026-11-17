# Concluir a primeira publicação

Estado: 0.1.0 publicada, publisher transferido e verificado, release v0.1.0 criada.
A sincronização inicial por Git já foi concluída. Não repita o script inicial nem
republique a 0.1.0; o procedimento abaixo fica como histórico. Falta enviar as
atualizações de documentação por Git em um terminal com acesso à rede.

O código está pronto para continuar a validação fora das restrições de rede e
socket desta sessão. Estes scripts não publicam pacotes nem criam tags.

## 1. Sincronizar usando Git normal

No seu terminal, execute:

```sh
bash /Users/kleber/Projects/decision_engine/tool/sync_initial_repository.sh
```

O script exige os dois worktrees limpos, busca o remoto e confirma que `origin/main`
ainda é exatamente o commit inicial `04e990a2eb69406623d3081baa00d53b4996b1f6`.
Se o GitHub tiver recebido qualquer outro commit, interrompe antes de conciliar
históricos, para permitir a inspeção dessas mudanças.

Para o commit inicial conhecido, cria um merge que mantém o código local completo
e registra o histórico inicial do GitHub. Depois reaplica a branch local do AHP
sobre `main` e envia as duas branches em um push atômico, sem force push. Nenhum
arquivo remoto é enviado pelo navegador. `--check` verifica somente pré-condições
locais, sem acessar a rede ou modificar o Git.

Em caso de falha depois do merge local, os commits continuam preservados; inspecione
`git status` e `git log` antes de tentar novamente. O script é específico para a
primeira sincronização, não um substituto para o fluxo Git cotidiano.

## 2. Executar as validações pendentes

```sh
bash /Users/kleber/Projects/decision_engine/tool/verify_initial_release.sh
```

O script valida exclusivamente a 0.1.0 no worktree `decision_engine_release`:
formatação, análise, testes Dart, exemplos, JavaScript/Node, consumidor Flutter e
dry-run de publicação. Interrompe no primeiro erro. Também confira os jobs do SDK
mínimo, Dart estável e Flutter em [GitHub Actions](https://github.com/kleberandrade/decision-engine/actions).

## 3. Publicar após todas as verificações

```sh
cd /Users/kleber/Projects/decision_engine_release
dart pub publish
```

Conclua a autenticação solicitada pelo Dart, se houver. Após confirmar a versão
hospedada 0.1.0, transfira o pacote para `kleberandrade.dev` pela administração no
pub.dev e confira o publisher mostrado. Nenhuma dessas ações foi realizada ainda.
A branch `feat/ahp` contém a 0.2.0-dev.1 e permanece separada da primeira publicação.
