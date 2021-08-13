# Chatbot Penha

Contém documentação para configuração do chatbot Penha (combate à violência contra a mulher) em um perfil do Twitter.

# Procedimentos

- Requisitar acesso à API e criar um aplicativo no Twitter - Requer um Perfil com e-mail validado no Twitter
- Configuração do ambiente do webhook, analytics e arvore de decisão
- Opcional: configuração do metabase para acompanhar a utilização.

Para fazer a configuração dos sistemas, é necessário familiaridade com Docker e docker-compose em ambiente Linux.

Para hospedar os serviços, é necessário um host com pelo menos 2GB de RAM, 2 vCPU e 25GB de disco (recomendado SSD).
Para a API de webhook, será necessário um endpoint HTTPS com o certificado funcionando.


# Manuais

* [Requisitar acesso à API e criar um aplicativo no Twitter](twitter-app.md)
* [Configuração dos serviços](installing-services.md)

# Arquitetura

<img src="https://raw.githubusercontent.com/revistaazmina/chatbot-penha/main/docs-res/penhas-containers.svg">

<img src="https://raw.githubusercontent.com/revistaazmina/chatbot-penha/main/docs-res/wsd-chatbot-penha.png">

* **Twitter**: Interface de DM dos twitter
* **Webhook**: API que gerencia o estado da conversa, tomando decisões de quando deve ser iniciado um novo questionário, reiniciar o fluxo, encerrar conversas por tempo (timeout)
* **QuizAPI**: API para execução do questionário, gerencia as respostas e quais a próximas perguntas
* **Analytics**: API Proxy para o as tabelas de analytics, atualmente salvando em banco PostgreSQL


## Webhook

Código fonte: https://github.com/revistaazmina/penha_webhook_twitter


Contém um webserver com os seguintes endpoints:

* `POST /config` - Recarrega as configurações da arvore de decisão
* `GET /health-check` - Responde 200 quando está com o serviço online
* `GET /twitter-webhook` - Responde com o desafio para fazer a autorização com o twitter
* `POST /twitter-webhook` - Recebe o texto da DM+opções do quick-reply quando existir. Dispara o processamento do texto para gerar mais DMs.

E um script conversation_timeout.js que deve ser executado a cada hora para expirar as conversas que não responderam a tempo.

Uma conversa pode ter vários estados que são controlado por algoritmos diferentes. A primeira delas é o estado *DURING_DECISION_TREE*, que é controlada por uma simples configuração em JSON, e as respostas não são armazenadas, e a outra é *DURING_QUESTIONNAIRE*, que acontece depois que a conversa iniciou um questionário, e cada resposta é armazenada no banco de dados do QuizAPI, e o fluxo pode se basear nas respostas anteriores para mudar de direção.

Ao iniciar o webserver de webhook, uma consulta é feita na QuizAPI para baixar a configuração do bot, para a parte que não é um questionário.

Depois da mensagem de boas vindas, que é configurada na interface do twitter, qualquer mensagem enviada pelo usuário é recebida e se não existir na memoria uma conversa para aquela pessoa, o fluxo é iniciado com o primeiro nó da configuração.


## QuizAPI

Código fonte: https://github.com/revistaazmina/penha_arvore_decisao

Contém um webserver com os seguintes endpoints:

* `GET /anon-questionnaires/config` - Responde com a configuração para a webhook executar o *DURING_DECISION_TREE*
* `GET /anon-questionnaires` - Lista todos os questionários disponíveis para serem respondidos
* `GET /anon-questionnaires/history` - Lista todas as respostas de uma session
* `POST /anon-questionnaires` - Cria uma nova session para responder um questionário e retorna a primeira pergunta
* `POST /anon-questionnaires/process` - Recebe uma resposta e responde com a próxima pergunta


### Tabelas

Ao fazer deploy deste projeto, o banco será populado com as tabelas do directus já preparadas, e também um questionário de exemplo.

O usuário e senha do directus é `admin@example.com`

#### penhas_config

Tabela Chave/Valor para configurações de ambiente (chave para o google-maps ou here api, por exemplo)

Ao iniciar o banco, ANON_QUIZ_SECRET e PONTO_APOIO_SECRET são iniciadas utilizando a função uuid_generate_v4().

    -[ RECORD 1 ]------------------------------------
    id         | 1
    name       | ANON_QUIZ_SECRET
    value      | fa04fe7f-e1ea-4ce0-a330-a8dab3bea773
    valid_from | 2021-08-03 17:52:28.383229
    valid_to   | infinity
    -[ RECORD 2 ]------------------------------------
    id         | 2
    name       | PONTO_APOIO_SECRET
    value      | 977d6330-86b7-4d83-bb2f-9967f6d8035d
    valid_from | 2021-08-03 17:52:28.383229
    valid_to   | infinity

Apos alterações nessa tabela, é necessário reiniciar o serviço (ver no manual de deploy)
#### questionnaires

Tabela para configuração dos questionários. Vem com um exemplo populado para os testes.

    -[ RECORD 1 ]--------------+-------------------------------------
    id                         | 2
    created_on                 | 2021-05-31 15:31:21.186-03
    modified_on                | 2021-07-09 23:49:49.379455-03
    active                     | t
    name                       | anon-test
    condition                  | 0
    end_screen                 | home
    owner                      |
    modified_by                | 8bc23069-7341-4c75-9c35-e1ab182ea526
    penhas_start_automatically | f
    penhas_cliente_required    | f

#### quiz_config

Guarda configurações sobre cada pergunta do questionário.

    -[ RECORD 1 ]----+--------------------------------------------------------------------
    id               | 29
    status           | published
    sort             | 0
    modified_on      | 2021-05-31 15:41:12.801-03
    type             | onlychoice
    code             | chooseone
    question         | choose one
    questionnaire_id | 2
    yesnogroup       | []
    intro            | []
    relevance        | 1
    button_label     |
    modified_by      | 8bc23069-7341-4c75-9c35-e1ab182ea526
    options          | [{"value":"a","label":"option a"},{"value":"b","label":"option b"}]
    -[ RECORD 2 ]----+--------------------------------------------------------------------
    id               | 39
    status           | published
    sort             | 4
    modified_on      | 2021-07-09 23:49:49.379-03
    type             | cep_address_lookup
    code             | cep_01
    question         | digite seu cep
    questionnaire_id | 2
    yesnogroup       | []
    intro            | []
    relevance        | _self=='cep_01'
    button_label     |
    modified_by      | 04729ae2-61a4-4b02-b56b-f10928faf6fb
    options          | []
    -[ RECORD 3 ]----+--------------------------------------------------------------------
    id               | 30
    status           | published
    sort             | 999
    modified_on      | 2021-07-09 23:37:12.322-03
    type             | botao_fim
    code             | botao_fim
    question         | Obrigado por responder. Você também pode ligar para 190 ou XXX.
    questionnaire_id | 2
    yesnogroup       | []
    intro            | [{"text":"olá"}]
    relevance        | _self=='botao_fim'
    button_label     | Finalizar
    modified_by      | 04729ae2-61a4-4b02-b56b-f10928faf6fb
    options          | []


Durante a execução do questionário, as perguntas são examinadas de acordo com a coluna `sort` e `relevance`. A primeira pergunta com relevância será exibida para o usuário.

Essa tabela deve ser atualizada pela interface do Directus, para facilitar o cadastro e atualização dos campos.

Para o chatbot do twitter, apenas os tipos `onlychoice`, `botao_fim` e `cep_address_lookup` são suportados.

Todas mensagens no campo `intro` são enviadas antes da mensagem principal (pergunta)


Para utilizar o `cep_address_lookup` é necessário ter configurado uma chave de api para consulta do cep no serviço do Google ou Here.com. Para consultar consumir os resultados da api do pontos de apoios, também é necessário uma chave, entre em contato caso o seu chatbot também precise da consulta do ponto de apoio.

#### twitter_bot_config

Guarda a configuração em JSON do fluxo de questionários para a parte do *DURING_DECISION_TREE*

#### anonymous_quiz_session

Guarda todas as informações necessárias para execução do quiz (memoria e respostas)



## Analytics

Código fonte: https://github.com/revistaazmina/penha_analytics

Contém um webserver com os seguintes endpoints:

* `GET /health-check` - Responde 200 quando está com o serviço online
* `POST /conversa` - Grava um novo evento de conversa, e retorna um ID para que os eventos sejam agrupados
* `POST /analytics` - Grava os eventos de uma conversa e retorna um ID para este evento
* `POST /timeout` - Atualiza o evento para o state QUESTIONNAIRE_TIMEOUT

### Tabelas

#### tag_code

Serve para segmentar conversas em diferentes grupos. Por padrão, são criado 4 valores:

* 0 - Sem categoria
* 1 - Em busca de info. sobre relacionamento abusivo para ela
* 2 - Em busca de info. sobre relacionamento abusivo para outra pessoa
* 3 - Está em relacionamento abusivo

Estes valores podem ser removidos, exceto o primeiro com ID 0, que sempre deve existir.


#### step_code

Referencia com o nome para cada código de resposta.

Exemplo:
    `ID=1, Code=node_tos, questionnaire_id=Null`


#### conversa

Guarda o horário e com qual @ a conversa aconteceu, para que seja possível contar quantas conversas e com quantas pessoas diferentes elas aconteceram.

Exemplo:
    `ID=1, handle_hashed=(hash do valor da conta do twitter), started_at=Y-M-D H:M:S`

#### analytics

Guarda os eventos de uma conversa.

* Coluna `conversa_id` é sobre qual a conversa.
* Coluna `step_code_id` é sobre qual nó o evento se refere.
* Coluna `previous_step_code_id` é qual o nó anterior da conversa (origem)
* Coluna `state` é um ENUM com os seguintes valores:

    * `DURING_DECISION_TREE` - step_code_id faz parte do json de configuração
    * `DURING_QUESTIONNAIRE` - step_code_id faz parte do questionário
    * `QUESTIONNAIRE_FINISHED` - questionário chegou ao final (no "sucesso" do fluxo, essa é última mensagem de uma conversa), só deve ocorrer uma vez por conversa_id
    * `QUESTIONNAIRE_TIMEOUT` - Quando o questionário não foi respondido a tempo, o ultimo nó que era *DURING_QUESTIONNAIRE* deve virar *QUESTIONNAIRE_TIMEOUT* para marcar os locais que as pessoas pararam de conversar com o bot.
    * `QUESTIONNAIRE_GAVE_UP` - Marca o step_code_id que pessoa desistiu da conversa (comandos "reiniciar" ou botão "Sair")

* Coluna `tag_code` - Marca qual o categoria do evento atual
* Coluna `created_at` - Quando foi enviado essa mensagem
* Coluna `first_msg_tz` - Contém o horário da primeira mensagem, para facilitar os relatórios.
* Coluna `timeout_at` - Contém o horário da que o timeout foi executado

Você pode encontrar algumas queries prontas [neste arquivo](analytics.sql)
