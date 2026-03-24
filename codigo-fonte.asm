# --------- SEGMENTO DE DADOS ---------- #
			.data				


# --------- Textos e Frases


			# strings pode sem armazenadas com quaisquer alinhamentos.
			.align 0												
			
# Mensagem de boas vindas 
hola:   	.asciz "Tchoo Tchoo! Tá na hora de montar uns trem bão por aí >:D\n\n"				

# Instruções de como jogar [para o usuário]
instrucoes: 
			.ascii "Como jogar? Simples: o seu objetivo é gerenciar um trem, podendo adicionar e remover vagões (mas não a cabeça, que é a locomotiva!), "
			.ascii "além de listar o trem e buscar por vagões. Mas com algumas regras fixas: Só é possível adicionar vagões no início (depois da locomotiva) e no fim, "
			.ascii "remover qualquer vagão que não seja a locomotiva (primeiro vagão), mas para isso é necessário fornecer o ID do vagão a ser removido.\n"
			.ascii "Você pode também listar todos os vagões (e mostrar o ID de cada) e buscar por um vagão através do ID também. Veja o menu de ações:\n\n"
			.asciz "Escolha uma das oções (1-6):"

# Menu de ações
# No final de cada função (exceto sair) há um jump que volta para o Menu
mostrarMenu:
			.ascii "\n"
			.ascii "1 - Adicionar vagão no início.\n"
			.ascii "2 - Adicionar vagão no final.\n"
			.ascii "3 - Remover vagão por ID.\n"
			.ascii "4 - Listar trem.\n"
			.ascii "5 - Buscar vagão.\n"
			.asciz "6 - Sair.\n\n"

# Mensagens que compõem a função 4: Listar trem	
txt_inicio: .asciz "\n--- COMPOSIÇÃO DO TREM ---\n"
txt_id:     .asciz " -> [ID: "
txt_tipo:   .asciz " | Tipo: "
txt_fecha:  .asciz "]\n"

# Mensagens que compõem a função 1: Adicionar vagão no início e <outra função possível>
txt_ID:			.asciz "\nDigite o ID Único do novo vagão: "
txt_Tipo:		.asciz "\nDigite o Tipo do novo vagão: "
txt_ID_error:  	.asciz "\nErro! Outro vagão possui o ID informado. Tente novamente.\n"
txt_type_error: .asciz "\nErro! Você não pode adicionar locomotivas. Tente novamente.\n"
	
# Mensagem que será mostrada quando o jogador fechar o jogo.
seeya:		.asciz "Obrigado por jogar!\n"														



	
	# ------------ SEGMENTO DE CÓDIGO --------- #

			.text	

			
			# Todas as instruções são de 32 bits	
			.align 2 									
			.globl main
	
main:	
			
			# ---------- Dicionário de registradores e variáveis

			
			# --- Registradores gerais

			# s0 -> Guarda ponteiro da locomotiva. Não podemos mudar o seu valor.
			# s1 -> Quantidade de vagões do trem (talvez seja inútil; se for o caso, vamos removê-lo no fim do projeto)
			# s2 -> Guarda entrada do usuário no menu de ações


			# --- Registradores usados as funções 1 (adicionar vagão no início), 4 (listagem do trem) e <outra função possível>.
			
			# s3 -> iterador, usado em loops, percorre o trem desde a locomotiva até o último vagão
			# s4 -> guarda o ID do vagão novo/atual
			# s5 -> guarda o Tipo do vagão novo/atual

			
			# --- DEV NOTE

			# Pessoal, tentem manter esse padrão, na medida do possível: sempre que forem guardar as informações
			# de um vagão novo ou de um vagão atual em um loop, coloquem em s4 e s5. 

			# --- FIM DEV NOTE

			
			# --- IDs e Tipos

			# ID da cabeça = 0, Tipo da Cabeça = 1 (locomativa)
			# Os demais vagões terão ID e Tipo informados pelo usuário.
			# Exemplos de tipos: 1 = locomotiva, 2 = carga, 3 = passageiro, 4 = combustível, etc.




			# ---------- Alocação da Lomocomativa (vagão cabeça)

			
			# Alocar memória para a cabeça
			# Serviço 9 -> alocação de memória heap
			addi a7, zero, 9	

			# Instrução de quantidade: 12 bytes de espaço (4 ID, 4 TIPO, 4 PONTEIRO)
			addi a0, zero, 12	

			# Chamada de sistema para o endereço ser alocado e guardado no registrador a0
			ecall			

			# Agora, o endereço da cabeça está guardado em s0. Isso não pode ser mudado.
			mv s0, a0		




			# ---------- Preenchimento dos dados no espaço alocado
			
			# ID da locomotiva = 0
			addi t1, zero, 0 		

			# Tipo da locomativa = 1
			addi t2, zero, 1		

			# Guarda o valor de t1 (ID) no offset 0 do registrador s0 
			sw t1, 0(s0)		
			
			# Guarda o valor de t2 (Tipo) no offset 4 
			sw t2, 4(s0)		

			# Guarda o valor do ponteiro no offset 8. Como só tem a locomotiva, o ponteiro é NULL (zero)
			# Sistema de 32 bits -> 4 bytes. Por isso, o valor do ponteiro tem 4 bytes reservados.
			sw zero, 8(s0)		




			# --------- Preparo para o Jogo

			addi s1, zero, 1	# O jogo começa com 1 vagão (locomativa)
			addi s2, zero, 0	# Entrada para o menu começa zerada


			
			# --------- Início do Jogo


			# Muda o valor de a0 para o endereço do primeiro byte da string de rótulo "hola"
			la a0, hola			

			# Imprime a string encontrada em a0 na próxima chamada do sistema, que é a mensagem de boas vindas
			addi a7, zero, 4		
			ecall

			# Aqui, o processo é análogo, porém com a string "instrucoes"
			la a0, instrucoes		
			addi a7, zero, 4
			ecall




			# ------ Apresentação das instruções do jogo
interface:	

			# Printa o menu de ações	
			la a0, mostrarMenu	
			addi a7, zero, 4
			ecall


			


			# ------ Recebimento do input do usuário
get_input:
			
			# Lê inteiro e coloca o valor no registrador s2
			addi a7, zero, 5		
			ecall				
			mv s2, a0			





			# ------ Decisão do que fazer com base no input
branch_from_input:			

			# 1 - Adicionar no início
			addi t0, zero, 1			
			beq s2, t0, add_ini		# Se s2 == 1, pule jump pro add_ini
			
			# 2 - Adicionar no final
			addi t0, zero, 2			
			beq s2, t0, add_fim		# Se s2 == 2, pule para add_fim
			
			# 3 - Remover por ID
			addi t0, zero, 3			
			beq s2, t0, rem_ID		# Se s2 == 3, [...]
			
			# 4 - Listar Trem
			addi t0, zero, 4			
			beq s2, t0, listar		# Se s2 == 4, pule para a função 4: listar
			
			# 5 - Buscar Vagão
			addi t0, zero, 5			
			beq s2, t0, buscar		# Se s2 == 5, [...]
			
			# 6 - Sair
			addi t0, zero, 6			
			beq s2, t0, exit		# Se s2 == 6 [...]
			
			# Se a entrada for qualquer outro número, faz o menu aparecer de novo e recebe a entrada de novo
			j interface

			


# ------------ FUNÇÕES DO MENU ------------- #

# ------- Funções Auxiliares


			# ----- Função: lê o ID e o valida
get_ID:
			
			# Impressão do texto que pede ID
			addi a7, zero, 4
			la a0, txt_ID
			ecall

			# Leitura do ID do vagão e armazenamento em s4
			addi a7, zero, 5
			ecall
			mv s4, a0

			# Inicialização do iterador para validar o ID
			mv s3, s0


			# ------ Loop de validação do ID
loop_valida_ID:


			# Se o iterador for NULL, saio da função
			beq s3, zero sair

			# Se o ID já existir, peço novamente
			lw t1, 0(s3)
			beq s4, t1 ID_error

			# Senão, tento o próximo vagão até ver todos
			lw s3, 8(s3)

			j loop_valida_ID
	
ID_error:

			addi a7, zero, 4
			la a0, txt_ID_error
			ecall

			j get_ID

sair:
			jr ra

		# ------ Fim da função get_ID

		
		# ------ Função: lê o tipo e o valida
get_type:

			# Texto que pede o tipo
			addi a7, zero, 4
			la a0, txt_Tipo
			ecall

			# Leitura do tipo
			addi a7, zero, 5
			ecall

			# Guardo o tipo em s5
			mv s5, a0

			# Se o tipo informado for igual a 1, então temos um erro
			addi t0, zero, 1
			beq s5, t0, type_error

			# Se não temos erros, voltamos para quem chamou a função
			jr ra

type_error:

			addi a7, zero, 4
			la a0, txt_type_error
			ecall

			j get_type
	

# ------- Adição no Início ---------- #


		# ------ Ponto de partida
add_ini:	
			jal get_ID
			jal get_type

			# ------ Alocação do novo vagão (12 bytes)

			addi a7, zero, 9
			addi a0, zero, 12
			ecall

			
			# ----- Preenchimento dos valores do novo vagão
			sw s4, 0(a0)	
			sw s5, 4(a0)


			# ------ Organização de ponteiros
			
			# Carrego o endereço do próximo vagão em t1
			lw t1, 8(s0)

			# Salvo esse endereço no offset 8 do novo vagão
			sw t1, 8(a0)

			# Salvo o endereço do novo vagão no offset 8 da locomotiva
			sw a0, 8(s0)

			# Incremento o número de vagões
			addi s1, s1, 1 
			
			j interface


# ----- Fim adição no início ---------


# ----- Adicão no fim ---------

add_fim:	j interface

rem_ID:		j interface




# ------- Listagem do Trem -------- #

listar:	
			
			# Chama serviço de imprimir texto pra imprimir o cabeçalho da função
			la a0, txt_inicio		
			addi a7, zero, 4
			ecall


			# s3 = ponteiro (iterador) que vai percorrer o trem, começando na cabeça.
			mv s3, s0			


loop_listar:

			# -------- Condição de parada
			# Se o valor do iterador é nulo, encerramos e voltamos à interface.
			beq s3, zero, interface		
			

			#  ------- Leitura do vagão atual
			# Damos load do valor de offset(s3) em s4 e s5.
			lw s4, 0(s3)			# s4 = ID, offset 0
			lw s5, 4(s3)			# s5 = tipo, offset 4
			
			# -------- Impressão de Texto
			# Chamada e impressão do texto: " -> [ID : "
			la a0, txt_id
			addi a7, zero, 4
			ecall	

			# -------- Impressão do ID (Inteiro)
			mv a0, s4			
			addi a7, zero, 1		
			ecall
			
			# --------  Mais impressão de texto
			# Texto que será impresso: " | Tipo: "
			la a0, txt_tipo
			addi a7, zero, 4
			ecall
			
			# -------- Impressão do Tipo (Inteiro)
			mv a0, s5			
			addi a7, zero, 1		
			ecall
			
			# -------- Mais impressão de texto
			# Texto que será impresso:  "]\n" (fechamento e quebra de linha)
			la a0, txt_fecha
			addi a7, zero, 4
			ecall
			
			#--------- Atualização do ponteiro 
			# Essencialmente, estamos fazendo isso: vagão atual = (vagão atual)->proximo
			lw s3, 8(s3)
			
			# Continua no loop até a parada, que ocorre ao alcançar o fim do trem, cujo ponteiro é nulo.
			j loop_listar

# ------- Fim da Listagem do Trem ------ #


buscar:	j interface



# ----- Saída do Jogo ----- #
exit:	

		la a0, seeya			# printa mensagem de despedida 

		addi a7, zero, 4		
		ecall
		
		addi a7, zero, 10		# Encerra o programa na próxima chamada do sistema
		ecall
