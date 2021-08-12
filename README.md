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

[Requisitar acesso à API e criar um aplicativo no Twitter](twitter-app.md)
[Configuração dos serviços](installing-services.md)

# Arquitetura

