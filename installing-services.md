# Instalado os serviços

Para facilitar a construção do ambiente completo, disponibilizados neste repositório um script para fazer a configuração dos serviços.


Será necessário um ambiente Linux (testado com Ubuntu 20.04), com os seguintes programas instalados:

- git - baixar os repositórios
- docker - executar os containers
- docker-compose - gerenciar os containers
- perl - trocar de textos no arquivo .env
- sudo - trocar permissões de usuários
- curl - para testar os serviços
- ngrok - opcional, para exportar um endpoint https para o twitter.

Execute os seguintes comandos:

    git clone https://github.com/revistaazmina/chatbot-penha.git penhas_project
    cd penhas_project/scripts;

Crie uma pasta para manter os projetos, por exemplo:

    mkdir /home/seu-usuario/penha_chatbot

Depois, execute o script abaixo, que irá pedir para você informar este diretório base para o projeto.

O script clone-projects.sh irá clonar os 3 repositórios e fazer o build das imagens, vai criar um arquivo de $BASE_DIR/.env parcialmente preenchido para o docker-compose.

Para executar o script, não é necessário usuário root, porem, o usuário precisa ter permissão para executar o comando `docker` e também ter permissão para trocar o chown de algumas pastas.

O script também irá pedir para informar um nome para o banco de dados. Para este manual, vou usar o valor "prefix_for_db"

    ./clone-projects.sh

Vá até a pasta escolhida, e execute o comando:

    docker-compose up quiz_api

Isso deve subir 3 containers, `quiz_api_db`, `penhas_redis_1` e `quiz_api` e fazer o start-up do banco de dados. Se tudo ocorrer corretamente, você deverá ver na tela o resultado:

    ```Redirecting STDERR/STDOUT to /data/log//quiz-api.YYYY-MM-DD.log```

Abra um novo terminal, e continue com os passos:

Após subir estes containers, você poderá executar o seguinte comando para entrar no banco do quiz:

    docker exec -it quiz_api_db psql -U pguser prefix_for_db_quiz

Execute o comando a seguir para receber o valor que será necessário atualizar no arquivo .env: PENHAS_API_TOKEN

    docker exec -it quiz_api_db psql -U pguser prefix_for_db_quiz -c "select value from penhas_config where name='ANON_QUIZ_SECRET'"

Copie esta chave e atualize no arquivo .env o onde estava o valor "get-from-penhas_config-on-database"

Aproveite para atualizar também as variáveis que recebeu do processo do twitter, e também as variáveis do SMTP para que o directus consiga enviar os emails de nova conta e esqueci minha senha.

Você pode modificar as outras variáveis, porém, você deverá atualizar os próximos comandos para refletir a atualização.

Após atualizar o arquivo .env, volte para o terminal anterior e aperte Ctrl+C para encerrar o processo do *docker-compose* com apenas a api, e rode novamente

    docker-compose up

Isso irá subir todos os containers do projeto, com as seguintes configurações de nome/portas:

    IMAGE                           PORTS                        NAMES
    penhas_webhook_server           172.17.0.1:8021->8080/tcp    azmina_chatbot_webhook
    directus/directus:v9.0.0-rc.69  172.17.0.1:8020->8055/tcp    penhas_directus_1
    azminas/quiz_api                8080/tcp                     quiz_api
    penhas_analytics_server         2049/tcp                     azmina_chatbot_analytics
    postgres:13.3                   5432/tcp                     twitter_chatbot_db
    postgres:13.3                   5432/tcp                     quiz_api_db
    bitnami/redis:6.2               6379/tcp                     penhas_redis_1


* Você poderá acessar o directus usando o endereço http://172.17.0.1:8020 e usar o usuário e senha `admin@example.com`
* Você poderá acessar a API de webhook usando o endereço http://172.17.0.1:8021/



⚠️ Caso você esteja executando os comandos num VPS, você pode conectar utilizando tunnels do ssh:

    ssh -4 -NL 127.0.0.1:8020:172.17.0.1:8020 -NL 127.0.0.1:8021:172.17.0.1:8021 user@seu-vps

> E então utilizar o 127.0.0.1 como IP. também será necessário atualizar a url em DIRECTUS_PUBLIC_URL no arquivo .env e reiniciar o container do directus.

Para o ambiente de produção você irá precisar configurar o nginx para fazer o proxy reverso com SSl.

Vamos configurar um fluxo de bem vindo, que leva para o primeiro questionário:

Acesse http://172.17.0.1:8020/admin/collections/twitter_bot_config e coloque no campo:

    {
        "nodes": [
            {
                "code": "node_tos",
                "type": "text_message",
                "input_type": "quick_reply",
                "messages": [
                    "Olá! Você concorda com os termos?"
                ],
                "quick_replies": [
                    {
                        "label": "👍 Sim",
                        "metadata": "node_tos_accepted"
                    },
                    {
                        "label": "👎 Não",
                        "metadata": "node_tos_refused"
                    }
                ],
                "children": [
                    "node_tos_accepted",
                    "node_tos_refused"
                ]
            },
            {
                "code": "node_welcome_back",
                "type": "text_message",
                "input_type": "quick_reply",
                "messages": [
                    "Bem-vinda de volta! Aperte no botão abaixo para começar novamente"
                ],
                "quick_replies": [
                    {
                        "label": "🔃 Começar novamente",
                        "metadata": "node_tos_accepted"
                    }
                ],
                "children": [
                    "node_tos_accepted"
                ]
            },
            {
                "code": "node_tos_refused",
                "type": "text_message",
                "input_type": "quick_reply",
                "messages": [
                    "Infelizmente não podemos continuar a nossa conversa por aqui."
                ],
                "quick_replies": [
                    {
                        "label": "🔙 Voltar",
                        "metadata": "node_tos"
                    }
                ],
                "children": [
                    "node_tos"
                ]
            },
            {
                "code": "node_tos_accepted",
                "type": "questionnaire",
                "questionnaire_id": "2",
                "is_conversation_end": true,
                "on_conversation_end": "restart",
                "parent": "node_1",
                "children": null
            }
        ],
        "tag_code_config": {
            "default": 0,
            "scenarios": [
                {
                    "tag_code_value": 1,
                    "check_code": "P3a_para_mim"
                },
                {
                    "tag_code_value": 2,
                    "check_code": "P3a_para_outra"
                },
                {
                    "tag_code_value": 3,
                    "check_code": "P2b"
                }
            ]
        },
        "timeout_seconds": 86400,
        "timeout_message": "Vamos nos falar mais tarde!",
        "error_msg": "Não entendi! Utilize os botões abaixo"
    }


Após salvar, é necessário enviar o comando para que o serviço de webhook recarregue as configurações, para isso, vá para um novo terminal e execute:

    curl -X POST 172.17.0.1:8021/config

Se o setup da chave anterior (PENHAS_API_TOKEN) estiver correta, você deverá receber o retorno `{"message":"OK"}`, isso significa que a configuração foi recarregada com sucesso. Caso a chave esteja errada ou algum problema na configuração do docker-compose, confira a saida do log do container azmina_chatbot_webhook.


