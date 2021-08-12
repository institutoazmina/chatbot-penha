# 1. Configuração da conta do Twitter

## Requisitar acesso à API

Link para referência do Twitter:: https://developer.twitter.com/en/docs/developer-portal/overview

O primeiro passo para criar um chatbot no Twitter é receber permissão para a utilização da API. Este processo requer uma conta com e-mail validado no Twitter.

Para requisitar acesso à API:

1. Acesse o link: https://developer.twitter.com/en/apply-for-access
2. Aperte no botão “Apply for a developer account”:
2. Ao apertar neste botão, será feito o encaminhamento para outra página, onde será necessário responder perguntas sobre o caso de uso;
2. Um representante do Twitter entrará em contato após o preenchimento dos dados, para dar encaminhamento ao processo de aprovação da conta de desenvolvedor.

## 2. Criar um aplicativo

Link para referência do Twitter: https://developer.twitter.com/en/docs/apps/overview

Após adquirir acesso ao painel de desenvolvedor do Twitter, é necessário criar um aplicativo para o chatbot.

Para criar um aplicativo:

1. Acessar menu “Projects & Apps”, e criar um App na seção “Standalone Apps”;
1. Assinalar a opção “Read, Write and Access direct messages” na página de permissões do seu App;
1. Gerar e salvar chaves na página “Keys and Token” do seu App.


## 3. Setup da API de webhooks

Link para referência do Twitter: https://developer.twitter.com/en/docs/twitter-api/premium/account-activity-api/overview

Após a criação e configuração do aplicativo, é necessário adquirir, e configurar, o acesso à API de webhooks.

Para configurar o webhook:

1. Acesse a página de ambientes de desenvolvimento (https://developer.twitter.com/en/account/environments);
1. Crie um ambiente para a “Account Activity API” utilizando o app criado no passo anterior.
> OBS: Para criar o ambiente será pedido um nome, este nome irá ser utilizado em requisições que serão descritas posteriormente neste guia.

## 4. Inscrição do webhook

Link para referência do Twitter: https://developer.twitter.com/en/docs/twitter-api/premium/account-activity-api/guides/managing-webhooks-and-subscriptions

O último passo é o de “subscribe” do webhook. Caso a conta utilizada para a criação da conta de desenvolvedor seja a mesma que irá abrigar o chatbot, você pode utilizar as chaves geradas no próprio painel. Caso contrário, siga os passos abaixo:

1. Instale o (Twurl)[https://github.com/twitter/twurl] (ferramenta para facilitar requisições feitas para a API do Twitter), pode ser em qualquer computador, não precisa ser no servidor da aplicação.
1. Execute `twurl authorize --consumer-key ${CONSUMER_KEY_ADQUIRIDA_NO_PAINEL} --consumer-secret ${CONSUMER_SECRET_ADQUIRIDO_NO_PAINEL}`
1. O comando acima irá retornar uma URL, que te levará ao Twitter para que seja feita a autenticação da página que irá hospedar o chatbot
1. Após o processo de autenticação, **guarde o token e o secret gerados pelo Twurl**, pois eles serão utilizados no arquivo de variáveis de ambiente da API de webhook.
É possível encontrá-los utilizando o seguinte comando:
`cat ~/.twurlrc`;

Agora você já tem em mãos as chaves que serão utilizadas para os seguintes processos:

1. Cadastro de um webhook com a sua URL;
1. Inscrição de uma página no webhook cadastrado.

### Cadastro do webhook:

1. Utilize o seguinte endpoint: POST account_activity/all/:env_name/webhooks (https://developer.twitter.com/en/docs/twitter-api/premium/account-activity-api/api-reference/aaa-premium#post-account-activity-all-env-name-webhooks), substituindo “:env_name”, pelo nome do ambiente criado no painel do twitter.

### Inscrição da página no webhook:

Link para referência: https://developer.twitter.com/en/docs/twitter-api/premium/account-activity-api/api-reference/aaa-premium#post-account-activity-all-env-name-subscriptions

1. Utilizando as chaves da página que irá hospedar o chatbot, utilize o seguinte endpoint: `POST account_activity/all/:env_name/subscriptions`

Após esta última requisição a URL cadastrada para o no passo anterior, irá passar a receber chamadas vindas do Twitter para os eventos de DM.


