# =-=-=-=-=-=-=-=-=-=-=-=-= TRABALHO PRÁTICO I =-=-=-=-=-=-=-=-=-=-=-=-=-=-= #
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #
	# João Pedro Conde Gomes Alves - 16816271 #
	# Eduardo Benedini Bueno - 16862551 #
	# José Fausto Vital Barbosa - 15512767 #
	# Erik Min Soo Chung - 15450334 #
# =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-= #

# --------- SEGMENTO DE DADOS ---------- #
				.data				


# --------- Textos e Frases


				# strings pode sem armazenadas com quaisquer alinhamentos.
				.align 0												
			
# Mensagem de boas vindas 
txt_hello:   			.asciz "Tchoo Tchoo! Tá na hora de montar uns trem bão por aí >:D\n\n"				

# Instruções de como jogar [para o usuário]
txt_instructions: 
				.ascii "Como jogar? Simples: o seu objetivo é gerenciar um trem de acordo com as 6 funções dispostas no menu de ações.\n\n"
				.ascii "Regras: \n"
				.ascii "1. Só é possível adicionar vagões no início do trem (ao lado da locomotiva) e no fim.\n"
				.ascii "2. Para remover ou buscar qualquer vagão (primeiro vagão) é necessário fornecer o ID do vagão a ser removido.\n"
				.ascii "3. É importante esclarecer que cada vagão é representado por um ID (código único) e um código de tipo (1 = locomotiva, 2 = carga, etc).\n"
				.asciz "4. A locomotiva possui ID = 0 e tipo = 1. Não é possível mexer na locomotiva existente ou inserir outras locomotivas no trem.\n\n"

# Menu de ações
# No final de cada função (exceto sair) há um jump que volta para o Menu
txt_menu:
				.ascii "\n"
				.ascii "Menu de ações:\n"
				.ascii "1 - Adicionar vagão no início.\n"
				.ascii "2 - Adicionar vagão no final.\n"
				.ascii "3 - Remover vagão por ID.\n"
				.ascii "4 - Listar trem.\n"
				.ascii "5 - Buscar vagão.\n"
				.asciz "6 - Sair.\n\n"


# Mensagens essenciais para recebimento de ID e Tipo
txt_ID:				.asciz "\nDigite o ID Único do novo vagão (lembrando que ID = 0 está reservado!): "
					
txt_ID_error:  			.asciz "\nErro! Outro vagão possui o ID informado. Tente novamente.\n"
txt_ID_negative:		.asciz "\nErro! O ID deve ser um número positivo. Tente novamente.\n"

txt_type:			.ascii "\nDigite o Tipo do novo vagão (2 = carga, 3 = passageiro e 4 = combustível):\n"
				.asciz "(Lembrando que pode existir apenas uma locomotiva!)\n"
txt_type_error: 		.asciz "\nErro! Você não pode adicionar locomotivas. Tente novamente.\n"
txt_type_limitExceed:		.asciz "\nErro! Tipo inexistente de vagão.\n"

# Mensagens que compõe a função 3: Remover vagão 
txt_ID_rem:			.asciz "\nDigite o ID do vagão que deseja remover: "
txt_not_exist_rem:		.asciz "\nEsse vagão não pode ser removido, pois não existe no trem.\n"
txt_locomotive_rem:		.asciz "\nEsse vagão não pode ser removido, pois é a locomotiva.\n" 
txt_end_rem: 			.asciz "\nVagão removido com sucesso.\n"

# Mensagens que compõem a função 4: Listar trem	
txt_begin_list: 			.asciz "\n--- COMPOSIÇÃO DO TREM ---\n"
txt_wagon_list:			.asciz "Vagão "
txt_id_list:     			.asciz " -> [ID: "
txt_type_list:   			.asciz " | Tipo: "
txt_close_list:  			.asciz "]\n"

# Mensagens que compõe a função 5: Buscar vagão
txt_ID_search:			.asciz "\nDigite o ID do vagão que deseja buscar: "
txt_exist_search:		.asciz "\nEsse vagão existe.\n"
txt_not_exist_search:		.asciz "\nEsse vagão não existe.\n" 

# Mensagem que será mostrada quando o jogador fechar o jogo.
txt_bye:					.asciz "Obrigado por jogar!\n"														



	
	# ------------ SEGMENTO DE CÓDIGO --------- #

		.text	

		# Todas as instruções são de 32 bits									
		.align 2 
		.globl main
	
main:	
			
			# ---------- Dicionário de registradores e variáveis

			
			# --- Registradores gerais

			# s0 -> Guarda ponteiro da locomotiva. Não podemos mudar o seu valor.
			# s1 -> Guarda entrada do usuário no menu de ações


			# --- Registradores usados nas funções separadamente.
			
			# s3 -> iterador, usado em loops, percorre o trem desde a locomotiva até o último vagão
			# s4 -> guarda o ID do vagão novo/atual
			# s5 -> guarda o Tipo do vagão novo/atual
			# s6 -> contador para apresentar os vagões (usado na função de listar)
			# s7 -> indica o endereço do vagão anterior ao indicado pelo iterador (usado na função de remover e inserção no fim)

			
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

			addi s1, zero, 0	# Entrada para o menu começa zerada
			
		# --------- Início do Jogo
			
			# Muda o valor de a0 para o endereço do primeiro byte da string de rótulo "txt_hello"
			la a0, txt_hello			

			# Imprime a string encontrada em a0 na próxima chamada do sistema, que é a mensagem de boas vindas
			addi a7, zero, 4		
			ecall

			# Aqui, o processo é análogo, porém com a string "txt_instructions"
			la a0, txt_instructions		
			addi a7, zero, 4
			ecall


		# ------ Apresentação das instruções do jogo
interface:	
			# Printa o menu de ações	
			la a0, txt_menu	
			addi a7, zero, 4
			ecall

		# ------ Recebimento do input do usuário (get_input)
			
			# Lê inteiro e coloca o valor no registrador s1
			addi a7, zero, 5		
			ecall				
			mv s1, a0			

		# ------ Decisão do que fazer com base no input (branch_from_input)

			# 1 - Adicionar no início
			addi t0, zero, 1			
			beq s1, t0, add_begin		# Se s1 == 1, pule para add_begin
			
			# 2 - Adicionar no final
			addi t0, zero, 2			
			beq s1, t0, add_end		# Se s1 == 2, pule para add_end
			
			# 3 - Remover por ID
			addi t0, zero, 3			
			beq s1, t0, rem_ID		# Se s1 == 3, pule para rem_ID
			
			# 4 - Listar Trem
			addi t0, zero, 4			
			beq s1, t0, list		# Se s1 == 4, pule para list
			
			# 5 - Buscar Vagão
			addi t0, zero, 5			
			beq s1, t0, search		# Se s1 == 5, pule para search
			
			# 6 - Sair
			addi t0, zero, 6			
			beq s1, t0, exit		# Se s1 == 6 [...]
			
			# Se a entrada for qualquer outro número, faz o menu aparecer de novo e recebe a entrada de novo
			j interface


# ----------- FUNÇÕES AUXILIARES -------------- #		

	# ------ Função: verifica se um vagão de determinado ID está no trem
		# Parâmetros: a0 = ID a ser buscado
		# Retorno: a1 = 0, se não encontrado; a1 = 1, se encontrado
		# Usa os registradores:
			# s3 - Iterador sobre o trem
			# t0 - ID do vagão da iteração atual 
		
		# ---- Inicializações
search_ID:		
			# Vamos empilhar s3 para seguir as boas práticas, pois iremos alterá-lo
			addi sp, sp, -4
			sw s3, 0(sp)
			
			# Passando o endereço da locomotiva para s3, pois iremos iterar sobre o trem
			add s3, zero, s0
		
		# ---- Buscando ID
	loop_search_ID:	
	
				# Pegando ID do vagão
				lw t0, 0(s3)
				
				# Comparando o ID do vagão com o parâmetro passado
				beq t0, a0, exist_search_ID
				
				# Caso não seja o ID desejado, passa-se para o próximo vagão -> s3 recebe para onde o ponteiro do vagão atual
				lw s3, 8(s3)
				
				# Verificando se o trem acabou
				bne s3, zero, loop_search_ID
				
			# ---- Retorno no caso em que não existe vagão com aquele ID
				addi a1, zero, 0

				# Vamos desempilhar s3: terminamos de usá-lo
				lw s3, 0(sp)
				addi sp, sp, 4
				
				# Voltando a instrução seguinte em relação a onde ocorreu a chamada
				jr ra 
	
		# ---- Retorno no caso em que existe vagão com aquele ID
	exist_search_ID:
				
				addi a1, zero, 1

				# Vamos desempilhar s3: terminamos de usá-lo
				lw s3, 0(sp)
				addi sp, sp, 4
				
				# Voltando a instrução seguinte em relação a onde ocorreu a chamada
				jr ra
	# ----- Fim da função search_ID	



	# ----- Função: lê o ID e o valida
		# Parâmetros: nenhum (A leitura do ID é feita dentro da função)
		# Retorno: a1 = ID válido
		# Usa os registradores:
			# t1 - ID lido
			# a7 - Opção de ecall
			# a0 - Endereço de string e retorno de ecall
			# s3, t0 - Busca_ID
		
get_ID:
		# ---- Empilhando (dentro dessa função, outra será chamada)
			# Como iremos empilhar só ra, que é um endereço (4 bytes), iremos mover o topo 4 posições na memória (pilha cresce ao contrário)
			addi sp, sp, -4
			# Armazenando ra na memória
			sw ra, 0(sp)
			
			
		# ---- Inicializações e lendo ID
		
	ini_get_ID:		# Impressão do texto que pede ID
				addi a7, zero, 4
				la a0, txt_ID
				ecall

				# Leitura do ID do vagão
				addi a7, zero, 5
				ecall
				
				# Se o ID for negativo, não é válido
				blt a0, zero, ID_negative		
				
				# Salvando valor lido
				mv t1, a0
			
			# ---- Buscando ID
				# Parâmetro já está em a0
				jal search_ID
			
			# ---- Verificando retorno
				
				# Se a1 == 0, não existe vagão com aquele ID, então é válido
				beq a1, zero, exit_get_ID 					
		
			# ----- Imprimindo que ID é inválido e voltando ao input do ID

				addi a7, zero, 4
				la a0, txt_ID_error
				ecall

				j ini_get_ID
				
			# ---- Imprimindo que ID deve ser positivo e voltando ao input do ID
	ID_negative:

				la a0, txt_ID_negative
				addi a7, zero, 4
				ecall
				
				j ini_get_ID
			
		# ---- Saindo com ID válido
	exit_get_ID:	

				# Colocando resultado no registrador de retorno da função (a1)
				mv a1, t1
				
				# Desempilhando endereço de retorno
				lw ra, 0(sp)
				addi sp, sp, 4
				
				jr ra

	# ------ Fim da função get_ID

		
	# ------ Função: lê o tipo e o valida
		# Parâmetros: nenhum (o valor é lido dentro da função)
		# Retorno: a1 = Tipo válido
		# Usa os registradores t1, a0, a7 e t0
			# t0 - Valor 1 para comparação 
			# t1 - Tipo lido
			# a7 - Opção de ecall
			# a0 - Endereço de string e retorno de ecall
				
		# ---- Inicializações e lendo tipo
get_type:
			# Texto que pede o tipo
			addi a7, zero, 4
			la a0, txt_type
			ecall

			# Leitura do tipo
			addi a7, zero, 5
			ecall
			
			# Guarda o tipo em t1
			mv t1, a0

		# ---- Verificação do tipo
			
			# Por logística de implementação, tipo = 0 não pode existir.
			ble t1, zero, type_limitExceed
			
			# Se o tipo informado for igual a 1, então temos um erro, pois tipo = 1 é a locomotiva.
			addi t0, zero, 1
			beq t1, t0, type_error
			
			# Se o tipo informado for maior que 4, então temos um erro, por existem no máximo 4 tipos.
			addi t0, zero, 4
			bgt t1, t0, type_limitExceed 
			
			
		# ---- Saindo com tipo válido
			mv a1, t1
		
			# Se não temos erros, voltamos para quem chamou a função
			jr ra

		# ----  Imprimindo que tipo é inválido e voltando ao input do tipo
	type_error:

				addi a7, zero, 4
				la a0, txt_type_error
				ecall

				j get_type
				
		# ----  Imprimindo que é tipo inválido e voltando ao input do tipo
	type_limitExceed:
				addi a7, zero, 4
				la a0, txt_type_limitExceed
				ecall
				
				j get_type
			
	# ----- Fim da função get_type


# ------------ FUNÇÕES DO MENU ------------- #

# ------- Adição no Início ---------- #


		# ------ Lendo ID e Tipo do novo vagão (validando-os por funções auxiliares)
add_begin:	
			jal get_ID
			mv s4, a1
			jal get_type
			mv s5, a1

		# ----- Alocação do novo vagão (12 bytes)

			addi a7, zero, 9
			addi a0, zero, 12
			ecall

			
		# ----- Preenchimento dos valores do novo vagão
		
			sw s4, 0(a0)	
			sw s5, 4(a0)


		# ------ Organização de ponteiros
			
			# Carrego o endereço do vagão depois da locomotiva em t1
			lw t1, 8(s0)

			# Salvo esse endereço no offset 8 do novo vagão
			sw t1, 8(a0)

			# Salvo o endereço do novo vagão no offset 8 da locomotiva
			sw a0, 8(s0)
			
			j interface


# ----- Fim adição no início --------- #


# ----- Adicão no fim --------- #

add_end:	
		# ----- Recebe valores do usuário
			jal get_ID
			mv s4, a1
			jal get_type
			mv s5, a1

		# ----- Alocação do novo vagão (12 bytes)

			addi a7, zero, 9
			addi a0, zero, 12
			ecall

			
		# ----- Preenchimento dos valores do novo vagão
		
			sw s4, 0(a0)	
			sw s5, 4(a0)
	
			# s3 = ponteiro (iterador) que vai percorrer o trem, começando na cabeça.
			mv s3, s0
			
	loop_add_end:
			# -------- Condição de parada
				# Se o valor de s3 é nulo, s7 está atualmente no último vagão.
				beq s3, zero, add_end_2
				
				# s7 = auxiliador que guarda a posição anterior de s3
				mv s7, s3
				
				# Vagão atual = (vagão atual)->próximo.
				lw s3, 8(s3)
				
				# Continua no loop até encontrar o fim do trem.
				j loop_add_end
			
	add_end_2:		
			# ------ Organização de ponteiros
				
				# Carrego um novo "ponteiro nulo" (endereço 0) nos últimos 4 bytes do novo vagão
				sw zero, 8(a0)

				# Salvo o endereço do novo vagão no offset 8 do último vagão
				sw a0, 8(s7)
				
				j interface

# ----- Fim da Adição no Fim ------ #

# ------ Remoção por ID ------ #

	# ---- Lendo ID
rem_ID:	
		# Imprimindo solicitação de ID
		la a0, txt_ID_rem			
		addi a7, zero, 4
		ecall
		
		# Recebendo ID (não precisamos verifica o ID com get_ID, pois já iremos fazer um loop para procurar o vagão)
		addi a7, zero, 5
		ecall
		
		# Salvando ID lido
		mv s4, a0
		
		# Preparando para impressão de string de resposta
		addi a7, zero, 4
		
		# Não é possível remover a locomotiva
		beq s4, zero, locomotive_erro_rem
	
		# Não há ID negativo no trem
		blt s4, zero, not_exist_rem
		
	# ---- Inicializações para o loop
		
		# O iterador começa no vagão após a locomotiva
		lw s3, 8(s0)
		
		# Se s3 = 0, só há um vagão no trem (a locomotiva), então não é possível realizar nenhuma remoção  
		beq s3, zero, not_exist_rem
		
		# Ponteiro auxiliar que aponta para o vagão anterior ao indicado pelo iterador
		mv s7, s0
		
	# ---- Procurando vagão
	 	
	loop_rem_ID:
		# Recuperando o ID do vagão atual
		lw t0, 0(s3)
		
		# Se ID for o desejado, começa o processo de remoção
		beq t0, s4, removing
		
		# Senão, tentamos o próximo vagão
		mv s7, s3
		lw s3, 8(s3)
		
		# Se o trem acabou, não existe vagão com o ID desejado
		beq s3, zero, not_exist_rem 
		
		j loop_rem_ID
	
	# ---- Removendo vagão
		
	removing:
		# Para remover um vagão, basta ligar o anterior ao posterior dele, assim ele se "desvincula" do trem (não precisamos desalocar memória)
		# Esse algoritmo trata tanto o caso de remoção no meio, quanto de remoção no fim, em que o anterior irá começar apontar para NULL (ponteiro = 0) 
		# Carregando o endereço do posterior ao que será removido
		lw t1, 8(s3)
		
		# Colocando endereço do posterior no ponteiro do anterior
		sw t1, 8(s7)
		
		# Imprimindo que a remoção ocorreu corretamente
		la a0, txt_end_rem
		ecall
		
		j interface
		
	# ---- Resposta no caso do vagão não existir
		
	not_exist_rem:
		# Imprimindo que o vagão não foi encontrado para remoção
		la a0, txt_not_exist_rem
		ecall
		
		j interface
		
	# ---- Resposta no caso de tentativa de remover a locomotiva
		
	locomotive_erro_rem:
		# Imprimindo que o vagão escolhido para remoção é a locomotiva
		la a0, txt_locomotive_rem
		ecall

		j interface


# ------- Listagem do Trem -------- #

	# ---- Apresentação do título e inicialização
list:	
			# Chama serviço de imprimir texto pra imprimir o cabeçalho da função
			la a0, txt_begin_list		
			addi a7, zero, 4
			ecall


			# s3 = ponteiro (iterador) que vai percorrer o trem, começando na cabeça.
			mv s3, s0	
			
			# Inicializa o registrador s8 como 1, que servirá como contador das posições dos vagões
			addi s6, zero, 1		

	# ---- Percorrendo trem
	loop_list:

		# -------- Condição de parada
			# Se o valor do iterador é nulo, encerramos e voltamos à interface (acabou o trem).
			beq s3, zero, interface		
			

		#  ------- Leitura do vagão atual
			# Damos load do valor de offset(s3) em s4 e s5.
			lw s4, 0(s3)			# s4 = ID, offset 0
			lw s5, 4(s3)			# s5 = tipo, offset 4
			
		# -------- Impressão de Texto
			# Chamada e impressão do texto: "Vagão "
			la a0, txt_wagon_list
			addi a7, zero, 4
			ecall
			
			# Chamada e impressão da posição do vagão
			add a0, zero, s6
			addi a7, zero, 1
			ecall
			
			# Itera o valor de s6
			addi s6, s6, 1
			
		# -------- Impressão de Texto
			# Chamada e impressão do texto: " -> [ID : "
			la a0, txt_id_list
			addi a7, zero, 4
			ecall	

		# -------- Impressão do ID (Inteiro)
			mv a0, s4			
			addi a7, zero, 1		
			ecall
			
		# --------  Mais impressão de texto
			# Texto que será impresso: " | Tipo: "
			la a0, txt_type_list
			addi a7, zero, 4
			ecall
			
		# -------- Impressão do Tipo (Inteiro)
			mv a0, s5			
			addi a7, zero, 1		
			ecall
			
		# -------- Mais impressão de texto
			# Texto que será impresso:  "]\n" (fechamento e quebra de linha)
			la a0, txt_close_list
			addi a7, zero, 4
			ecall
			
		#--------- Atualização do ponteiro 
			# Essencialmente, estamos fazendo isso: vagão atual = (vagão atual)->proximo
			lw s3, 8(s3)
			
			# Continua no loop até a parada, que ocorre ao alcançar o fim do trem, cujo ponteiro é nulo.
			j loop_list

# ------- Fim da Listagem do Trem ------ #


# ------- Buscar Vagão ------ #

search:		#-------- Recebendo o ID
			
			# Imprimindo solitação do ID
			la a0, txt_ID_search
			addi a7, zero, 4
			ecall
			
			# Lendo ID (inteiro) -> retorno estará em a0
			addi a7, zero, 5
			ecall
			 
		# ------- Buscando ID
			# Parâmetro já está no a0
			jal search_ID
			
		# ------ Verificando retorno
			
			# Preparando para imprimir string na próxima chamada de sistema
			addi a7, zero, 4
			
			# Desviando a depender do retorno da função
			beq a1, zero, not_exist_search
			
		# ----- Resposta no caso de não existir vagão com aquele ID 
		
			la a0, txt_exist_search
			ecall
			
			j interface
			
		# ----- Resposta no caso de existir vagão com aquele ID 
		
	not_exist_search:

			la a0, txt_not_exist_search
			ecall
			
			j interface

# ----- Fim do Buscar Vagão ----- #

# ----- Saída do Jogo ----- #
exit:	
		# Carrega mensagem de despedida 
		la a0, txt_bye			

		# Imprime a mensagem de despedida
		addi a7, zero, 4		
		ecall
		
		# Encerra o programa na próxima chamada do sistema
		addi a7, zero, 10		
		ecall
