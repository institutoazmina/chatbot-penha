# Configuração do quiz

A configuração do fluxo da conversa está dividida em 2 sistemas diferentes. Ambos podem ser configurados pela interface do directus.

A primeira configuração, fica na tabela "Twitter Bot Config" e permite configurar textos e encaminhar para outros fluxos dependendo da resposta, porém, nenhuma resposta fica registrada.

A segunda configuração, chamamos de questionários, e fica dividida em duas tabelas, "Questionários" e "Perguntas dos questionários".

Para cada pergunta cadastrada nesse questionário, as respostas ficam salvas na tabela anonymous_quiz_session.

## Twitter Bot Config

Acessando pelo directus http://172.17.0.1:8020/admin/collections/twitter_bot_config

Existe apenas um campo, que é um JSON.

Veja o exemplo abaixo:

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


Dentro da chave `nodes` deve existir um objeto, e cada objeto *precisa* das seguintes chaves:

    "code": texto - código único para este nó,
    "type": texto "text_message" ou "questionnaire"

Quando a `type` for `text_message` as seguintes chaves são obrigatórias:

    "messages": [
        texto que deve ser enviado para o twitter quando entrar neste nó
    ],
    "children": [
        cada item deve ser o código dos nós que são os filhos
    ]
    "parent": texto - código do nó pai
    "input_type": "quick_reply", atualmente só suportamos esse input-type no tipo `text_message`,
                                 e por consequência também é necessário configurar a chave quick_replies
    "quick_replies": [
        objetos com as chaves `label` e `metadata`
    ],


Quando a `type` for `questionnaire` as seguintes chaves são obrigatórias:


    "questionnaire_id": ID do questionário que deve ser carregado,
    "is_conversation_end": true - se esse nó é o fim da conversa, marcar como "true"
    "on_conversation_end": "restart" - o que deve acontecer ao chegar no final do fluxo (só suportamos "restart" que leva pro primeiro nó novamente)

Para criar um fluxo de conversa, no objeto `quick_replies` deve ser configurado no campo `metadata` qual é o código do nó que deve o usuário será direcionado ao escolher aquela resposta.

Quando deseja iniciar um questionário (quando as respostas são registradas) deve-se utilizar a opção `questionnaire` e escolher o ID correspondente.

Para listar quais IDs estão disponíveis, pode-se olhar no directus na tabela de questionários e filtrando os resultado por `active` = TRUE.

## Novo questionário

Para criar um novo questionário, acesse o http://172.17.0.1:8020/admin/collections/questionnaires e clique no "+"

Marque o campo "Active" como TRUE, digite um nome para representar este questionário no campo `Name`  e pronto. Os outros campos não são usados neste projeto.

<img src="https://github.com/institutoazmina/chatbot-penha/blob/main/docs-res/Screenshot%20from%202021-09-02%2017-08-46.png?raw=true">

### Criando perguntas para o questionário

Para o twitter, suportamos perguntas de texto livre e item numa lista de opções, que será exibido da mesma forma que o "Quick Reply".

Abra o link http://172.17.0.1:8020/admin/collections/quiz_config/ e clique no "+" para criar um novo item.

Será necessário escolher o questionário para esta pergunta.

<img src="https://github.com/institutoazmina/chatbot-penha/blob/main/docs-res/Screenshot%20from%202021-09-02%2017-14-44.png">

As perguntas são carregadas para ser exibidas de acordo com a ordem e relevância da pergunta.

Preencha o campo de ordem, opcionalmente pode-se colocar textos introdutórios e fazer a nova pergunta (ou texto final)

<img src="https://github.com/institutoazmina/chatbot-penha/blob/main/docs-res/Screenshot%20from%202021-09-02%2017-15-59.png?raw=true">

No campo "Type" escolha o tipo desta pergunta

<img src="https://github.com/institutoazmina/chatbot-penha/blob/main/docs-res/Screenshot%20from%202021-09-02%2017-17-05.png?raw=true">

- Lista de opção - é a opção mais usada, que cria as opções de resposta para o usuário escolher uma
- Texto livre - qualquer texto é aceito
- Apenas exibir texto - Use para exibir apenas a pergunta, sem fazer nenhuma pergunta
- Botão de finalizar - Use para criar um botão para finalizar a tarefa
- Busca de CEP - Pergunta um CEP para o usuário, e depois buscar na base do ponto de apoio - requer configuração extra na API para funcionar. Entre em contato caso deseje acesso a base.

Escolhendo a opção `Lista de opção` será necessário configurar o campo `Options`

Para adicionar uma opção, clique no botão "Nova opção" e depois digite o valor e o texto a ser exibido. O texto a ser exibido no twitter **não pode passar de 36 caracteres**.

<img src="https://github.com/institutoazmina/chatbot-penha/blob/main/docs-res/Screenshot%20from%202021-09-02%2017-20-38.png?raw=true">

O `valor` será usado para construir a expressão e também ficará salvo na tabela de respostas.

Escolhendo a opção `Botão de finalizar` você pode customizar o botão usando o campo `Button Label`


O `code` é usado para guardar as respostas e também para calcular a relevância de outros campos. É recomendado usar um valor único para o fluxo, embora não seja um requerimento.

Não deve ser utilizado acentos, nem espaços, nem começar com número.

Para o campo `relevance`, ele é o principal campo para controlar o fluxo. Caso deseje que a pergunta seja feita para todos os usuários, coloque o valor `1` no campo.

### Detalhes do campo `code` na implementação atual

Se o code começar com RESET_ a api de webhook irá reiniciar o chat e mandar para o analytics que o fluxo foi reiniciado.

Se o code começar com FIM_ a api de webhook irá terminar o chat (mesmo sem a pessoa clicar no botão) e mandar para o analytics que o fluxo foi finalizado.

### Detalhes do campo `relevance`

A expressão que for digitada dentro desse campo será computada durante a execução do quiz, e o resultado irá determinar se a pergunta deve aparecer.

Para uma pergunta sempre aparecer, use o valor '1' - para ela não aparecer, use o valor '0'

Não há nada de especial no valor '1', mas este valor tem significado 'verdadeiro' e com o '0' ou vazio tem significado falso.

Geralmente, será usado nesse campo expressões, como as seguintes:

    codigo_de_outra_pergunta == 'A'
        - pergunta só ira aparecer se a opção de resposta `codigo_de_outra_pergunta` for exatamente "A"

    codigo_de_outra_pergunta != 'A'
        - pergunta só ira aparecer se a opção de resposta `codigo_de_outra_pergunta` NÃO for exatamente "A"

    codigo_de_outra_pergunta > 10
        - pergunta só ira aparecer se a opção de resposta `codigo_de_outra_pergunta` for maior que 10. Lembrando que se a pessoa digitar um texto (sem ser número), a expressão não irá fazer sentido e pode resultar em verdadeiro ou falso de acordo com o texto.

    pergunta_1 && (pergunta_2 == "A" || pergunta_2 == "B")
        - pergunta ira aparecer SE existir alguma resposta para a pergunta pergunta_1 (qualquer resposta que for verdadeira) e a pergunta_2 for respondida com "A" ou "B"

    pergunta_1 == "C" || pergunta_2 == "A"
        - pergunta ira aparecer se pergunta_1 for "C" OU pergunta_2 for "A"

    pergunta_x == _self
        - _self é uma variável especial, e corresponde ao código da pergunta corrente.


Você pode conferir no arquivo https://github.com/institutoazmina/chatbot-penha/blob/main/docs-res/quiz_config%202021-09-02%20at%2020.51.41.csv todas as 86 perguntas do nosso questionário do Penha.
