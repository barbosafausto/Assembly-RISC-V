# 🚂 Assembly-RISC-V

Este projeto tem como objetivo implementar uma lista encadeada usando apenas Assembly, de modo a simular a montagem de um trem composto por uma locomotiva e diversos vagões. Cada nó da lista possui 12 bytes: 4 para o ID, 4 para o Tipo e 4 para o ponteiro do próximo vagão.

# 💾 Segmento de Dados
Este segmento armazena todas as strings utilizadas para a interação com o usuário através de chamadas de sistema (ecall).

## 📜 Boas Vindas, Instruções e Menu
Contém as mensagens iniciais (`hola`, `instrucoes`) e o texto do menu principal de ações (`mostrarMenu`) que guia o fluxo do programa.

## 🆔 Tipo e ID
Guarda os textos de solicitação de input (`txt_ID`, `txt_Tipo`) e as mensagens de tratamento de erro para valores inválidos, negativos, ou IDs duplicados.

## 👁️ Listar Trem
Armazena as strings de formatação (cabeçalho, setas, colchetes) usadas para imprimir a composição do trem de forma visualmente agradável.

## 🔍 Busca
Contém as mensagens de feedback informando se o vagão procurado pelo ID existe ou não no trem.

## 🛑 Fechamento do Jogo
Guarda a mensagem de despedida ("Obrigado por jogar!") exibida antes de encerrar a execução.


# ⚙️ Segmento de Código
Contém toda a lógica de execução, manipulação de registradores e controle de memória da lista encadeada.

## 🚀 main
Ponto de entrada do programa. É responsável por alocar os 12 bytes iniciais na Heap para a locomotiva (ID = 0, Tipo = 1, Ponteiro = NULL) e fixar seu endereço base no registrador `s0`.

## 🎮 Setup do Jogo
Blocos responsáveis pelo laço principal de interação com o usuário.

### 🖥️ interface
Imprime o menu de opções na tela.

### ⌨️ get_input
Lê o número inteiro digitado pelo usuário e o salva no registrador `s1`.

### 🔀 branch_from_input
Atua como um bloco `switch-case`, redirecionando a execução (usando `beq`) para a função correspondente (1 a 6) de acordo com a entrada do usuário.

## 🛠️ Funções auxiliares
Sub-rotinas para modularizar a validação de dados e evitar repetição de código.

### 🔎 `busca_ID`
Itera pela lista encadeada comparando o ID fornecido (`a0`) com os IDs existentes. Retorna `a1 = 1` se existir, ou `a1 = 0` se não existir.

### 🔢 `get_ID`
Solicita e valida o ID do novo vagão. Garante que o valor seja positivo e utiliza a função `busca_ID` para impedir a inserção de IDs duplicados. Utiliza a Pilha (Stack) para preservar o registrador `ra`.

### 🏷️ `get_type`
Solicita e valida o Tipo do novo vagão. Garante que o valor seja positivo, menor que 5, e impede a criação de novas locomotivas (Tipo 1).

## 📦 Funções Principais
Implementam as operações fundamentais da lista encadeada.

### 1️⃣ Adição no Início (`add_ini`)
Aloca um novo vagão, salva seu ID e Tipo, aponta seu ponteiro para o antigo primeiro vagão (após a locomotiva), e atualiza o ponteiro da locomotiva para apontar para ele.

### 2️⃣ Adição no Fim (`add_fim`)
Itera a lista a partir da locomotiva até encontrar o ponteiro NULL. Aloca o novo vagão, preenche os dados, atualiza o ponteiro do antigo último vagão para este novo endereço, e define o ponteiro do novo vagão como NULL.

### 3️⃣ Remoção por ID (`rem_ID`)
Lê um ID, varre a lista usando um ponteiro atual e um auxiliar para o vagão anterior. Ao encontrar o nó, desvincula-o fazendo o ponteiro do vagão anterior apontar diretamente para o vagão posterior. Possui bloqueio contra a remoção da locomotiva.

### 4️⃣ Listar Trem (`listar`)
Percorre todos os nós da lista sequencialmente, realizando impressões sucessivas para formatar e exibir no console a posição, o ID e o Tipo de cada vagão.

### 5️⃣ Buscar Vagão por ID (`buscar`)
Recebe um ID do usuário, chama a sub-rotina `busca_ID` e imprime uma mensagem correspondente ao retorno, confirmando a existência ou não do vagão.

### 6️⃣ Sair do Jogo (`exit`)
Imprime a mensagem de fechamento e realiza a chamada de sistema (`ecall 10`) para encerrar o programa de forma limpa.

# 🚧 Desafios Enfrentados e Soluções
* **Gerenciamento de Ponteiros:** Demoramos um pouco para entender a diferença entre o conteúdo de um registrador e o conteúdo do endereço armazenado neste registrador:

```mips
# Vamos supor que s0 guarda um endereço.

# Carrega o endereço de s0 em a0
addi a0, s0, s0 

# Carrega em a0 o valor guardado nos 4 primeiros bytes do endereço contido em s0 
lw a0, 0(s0)    

# Salva o valor de a0 nos 4 primeiros bytes do endereço contido em s0
sw a0, 0(s0)
```

 Com o prática e vários usos de *load* e *store*, essa dificuldade se tornou algo mais natural.


* **Sobrescrita do Endereço de Retorno (`ra`):** Ao fazer chamadas de função aninhadas (ex: `add_ini` chamando `get_ID`, que chama `busca_ID`), o registrador `ra` era perdido. A solução foi implementar o uso da Pilha (`sp`) para preservar os endereços de retorno.

# 🧠 Lições Aprendidas
* Compreensão prática da alocação dinâmica de memória (Heap) através da chamada de sistema `ecall 9`.
* Fixação dos conceitos de estrutura de dados (Lista Encadeada) traduzidos para o nível de hardware.
* Entendimento da importância das convenções de registradores no RISC-V para a modularização de código (separação de responsabilidades entre registradores "s", "t" e "a").