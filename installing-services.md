# Instalado os serviços

Para facilitar a construção do ambiente completo, disponibilizados neste repositório um script para fazer a configuração dos serviços.


Será necessário um ambiente Linux (testado com Ubuntu 20.04), com os seguintes programas instalados:
    - git
    - docker
    - docker-compose
    - perl
    - sudo

Execute os seguintes comandos:

    git clone https://github.com/revistaazmina/chatbot-penha.git penhas_project
    cd penhas_project/scripts;

Crie uma pasta para manter os projetos, por exemplo:

    mkdir /home/seu-usuario/penha_chatbot

Depois, execute o script abaixo, que irá pedir para você informar este diretório base para o projeto.

O script clone-projects.sh irá clonar os 3 repositórios e fazer o build das imagens, vai criar um arquivo de $BASE_DIR/.env parcialmente preenchido para o docker-compose.

Para executar o script, não é necessário usuário root, porem, o usuário precisa ter permissão para executar o comando `docker` e também ter permissão para trocar o chown de algumas pastas.

    ./clone-projects.sh


