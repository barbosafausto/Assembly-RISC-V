# --------- SEGMENTO DE DADOS ---------- #
						.data				


# --------- Textos e Frases


						# strings pode sem armazenadas com quaisquer alinhamentos.
						.align 0												
			
# Mensagem de boas vindas 
hola:   				.asciz "Tchoo Tchoo! Tá na hora de montar uns trem bão por aí >:D\n\n"				

# Instruções de como jogar [para o usuário]
instrucoes: 
						.ascii "Como jogar? Simples: o seu objetivo é gerenciar um trem de acordo com as 6 funções dispostas no menu de ações.\n\n"
						.ascii "Regras: \n"
						.ascii "1. Só é possível adicionar vagões no início do trem (ao lado da locomotiva) e no fim.\n"
						.ascii "2. Para remover ou buscar qualquer vagão (primeiro vagão) é necessário fornecer o ID do vagão a ser removido.\n"
						.ascii "3. É importante esclarecer que cada vagão é representado por um ID (código único) e um código de tipo (1 = locomotiva, 2 = carga, etc).\n"
						.asciz "4. A locomotiva possui ID = 0 e tipo = 1. Não é possível mexer na locomotiva existente ou inserir outras locomotivas no trem.\n\n"

# Menu de ações
# No final de cada função (exceto sair) há um jump que volta para o Menu
mostrarMenu:
						.ascii "\n"
						.ascii "Menu de ações:\n"
						.ascii "1 - Adicionar vagão no início.\n"
						.ascii "2 - Adicionar vagão no final.\n"
						.ascii "3 - Remover vagão por ID.\n"
						.ascii "4 - Listar trem.\n"
						.ascii "5 - Buscar vagão.\n"
						.asciz "6 - Sair.\n\n"


# Mensagens essenciais para recebimento de ID e Tipo
txt_ID:					.asciz "\nDigite o ID Único do novo vagão: "
txt_ID_error:  			.asciz "\nErro! Outro vagão possui o ID informado. Tente novamente.\n"
txt_ID_negativo:		.asciz "\nErro! O ID deve ser um número positivo. Tente novamente.\n"

txt_Tipo:				.asciz "\nDigite o Tipo do novo vagão: "
txt_type_error: 		.asciz "\nErro! Você não pode adicionar locomotivas. Tente novamente.\n"
txt_type_negativo:		.asciz "\nErro! O Tipo deve ser um número positivo. Tente novamente.\n"

# Mensagens que compõe a função 3: Remover vagão 
txt_ID_rem:				.asciz "\nDigite o ID do vagão que deseja remover: "
txt_nao_existe_rem:		.asciz "\nEsse vagão não pode ser removido, pois não existe no trem.\n"
txt_locomotiva_rem:		.asciz "\nEsse vagão não pode ser removido, pois é a locomotiva.\n" 
txt_fim_rem: 			.asciz "\nVagão removido com sucesso.\n"

# Mensagens que compõem a função 4: Listar trem	
txt_inicio: 			.asciz "\n--- COMPOSIÇÃO DO TREM ---\n"
txt_vagao:				.asciz "Vagão "
txt_id:     			.asciz " -> [ID: "
txt_tipo:   			.asciz " | Tipo: "
txt_fecha:  			.asciz "]\n"

# Mensagens que compõe a função 5: Buscar vagão
txt_ID_busca:			.asciz "\nDigite o ID do vagão que deseja buscar: "
txt_existe_busca:		.asciz "\nEsse vagão existe.\n"
txt_nao_existe_busca:	.asciz "\nEsse vagão não existe.\n" 

# Mensagem que será mostrada quando o jogador fechar o jogo.
seeya:					.asciz "Obrigado por jogar!\n"														



	
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


			# --- Registradores usados as funções 1 (adicionar vagão no início), 4 (listagem do trem) e <outra função possível>.
			
			# s3 -> iterador, usado em loops, percorre o trem desde a locomotiva até o último vagão
			# s4 -> guarda o ID do vagão novo/atual
			# s5 -> guarda o Tipo do vagão novo/atual
			# s6 -> ?
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
			
			# Lê inteiro e coloca o valor no registrador s1
			addi a7, zero, 5		
			ecall				
			mv s1, a0			

		# ------ Decisão do que fazer com base no input
branch_from_input:			

			# 1 - Adicionar no início
			addi t0, zero, 1			
			beq s1, t0, add_ini		# Se s1 == 1, pule para add_ini
			
			# 2 - Adicionar no final
			addi t0, zero, 2			
			beq s1, t0, add_fim		# Se s1 == 2, pule para add_fim
			
			# 3 - Remover por ID
			addi t0, zero, 3			
			beq s1, t0, rem_ID		# Se s1 == 3, pule para rem_ID
			
			# 4 - Listar Trem
			addi t0, zero, 4			
			beq s1, t0, listar		# Se s1 == 4, pule para listar
			
			# 5 - Buscar Vagão
			addi t0, zero, 5			
			beq s1, t0, buscar		# Se s1 == 5, pule para buscar
			
			# 6 - Sair
			addi t0, zero, 6			
			beq s1, t0, exit		# Se s1 == 6 [...]
			
			# Se a entrada for qualquer outro número, faz o menu aparecer de novo e recebe a entrada de novo
			j interface


# ----------- FUNÇÕES AUXILIARES -------------- #		

	# ------ Função: verifica se um vagão de determinado ID está no trem
		# Parâmetros: a0 = ID a ser buscado
		# Retorno: a1 = 0, se não encontrado; a0 = 1, se encontrado
		# Usa os registradores:
			# s3 - Iterador sobre o trem
			# t0 - ID do vagão da iteração atual 
		
		# ---- Inicializações
busca_ID:		
			
			# Passando o endereço da locomotiva para s3, pois iremos iterar sobre o trem
			add s3, zero, s0
		
		# ---- Buscando ID
	loop_busca_ID:	
	
				# Pegando ID do vagão
				lw t0, 0(s3)
				
				# Comparando o ID do vagão com o parâmetro passado
				beq t0, a0, existe_busca_ID
				
				# Caso não seja o ID desejado, passa-se para o próximo vagão -> s3 recebe para onde o ponteiro do vagão atual
				lw s3, 8(s3)
				
				# Verificando se o trem acabou
				bne s3, zero, loop_busca_ID
				
			# ---- Retorno no caso em que não existe vagão com aquele ID
				addi a1, zero, 0
				
				# Voltando a instrução seguinte em relação a onde ocorreu a chamada
				jr ra 
	
		# ---- Retorno no caso em que existe vagão com aquele ID
	existe_busca_ID:
				
				addi a1, zero, 1
				
				# Voltando a instrução seguinte em relação a onde ocorreu a chamada
				jr ra
		# ----- Fim da função busca_ID	



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
			# Como iremos empilhar só ra, que é um endereço (4 bytes), iremos mover o topo 4 posições na memória
			addi sp, sp, -4
			# Armazenando ra na memória
			sw ra, 0(sp)
			
			
		# ---- Inicializações e lendo ID
		
	ini_get_ID:	# Impressão do texto que pede ID
				addi a7, zero, 4
				la a0, txt_ID
				ecall

				# Leitura do ID do vagão
				addi a7, zero, 5
				ecall
				
				# Se o ID for negativo, não é válido
				blt a0, zero, ID_negativo		
				
				# Salvando valor lido
				mv t1, a0
			
			# ---- Buscando ID
				# Parâmetro já está em a0
				jal busca_ID
			
			# ---- Verificando retorno
				
				# Se a1 == 0, não existe vagão com aquele ID, então é válido
				beq a1, zero, sair_get_ID 					
		
			# ----- Imprimindo que ID é inválido e voltando ao input do ID

				addi a7, zero, 4
				la a0, txt_ID_error
				ecall

				j ini_get_ID
				
			# ---- Imprimindo que ID deve ser positivo e voltando ao input do ID
	ID_negativo:

				la a0, txt_ID_negativo
				addi a7, zero, 4
				ecall
				
				j ini_get_ID
			
		# ---- Saindo com ID válido
	sair_get_ID:	

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
			la a0, txt_Tipo
			ecall

			# Leitura do tipo
			addi a7, zero, 5
			ecall
			
			# Se o tipo é negativo, não é válido
			blt a0, zero, type_negativo

			# Guarda o tipo em t1
			mv t1, a0

		# ---- Verificação do tipo

			# Se o tipo informado for igual a 1, então temos um erro, pois tipo = 1 é a locomotiva.
			addi t0, zero, 1
			beq t1, t0, type_error

		# ---- Saindo com tipo válido
			mv a1, t1
		
			# Se não temos erros, voltamos para quem chamou a função
			jr ra

		# ----  Imprimindo que tipo é inválido e voltando ao input do ID 
	type_error:

				addi a7, zero, 4
				la a0, txt_type_error
				ecall

				j get_type
			
		# ---- Imprimindo que type deve ser positivo e voltando ao input do ID
	type_negativo:
				
				addi a7, zero, 4
				la a0, txt_type_negativo
				ecall
				
				j get_type

	# ----- Fim da função get_type


# ------------ FUNÇÕES DO MENU ------------- #

# ------- Adição no Início ---------- #


		# ------ Ponto de partida
add_ini:	
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
			
			# Carrego o endereço do próximo vagão em t1
			lw t1, 8(s0)

			# Salvo esse endereço no offset 8 do novo vagão
			sw t1, 8(a0)

			# Salvo o endereço do novo vagão no offset 8 da locomotiva
			sw a0, 8(s0)
			
			j interface


# ----- Fim adição no início --------- #


# ----- Adicão no fim --------- #

add_fim:	
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
			
	loop_insercao:
			# -------- Condição de parada
				# Se o valor de s3 é nulo, s7 está atualmente no último vagão.
				beq s3, zero, add_fim_2
				
				# s7 = auxiliador que guarda a posição anterior de s3
				mv s7, s3
				
				# Vagão atual = (vagão atual)->próximo.
				lw s3, 8(s3)
				
				# Continua no loop até encontrar o fim do trem.
				j loop_insercao
			
	add_fim_2:		
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
		# Imprimind solicitação de ID
		la a0, txt_ID_rem			
		addi a7, zero, 4
		ecall
		
		# Recebendo ID (não precisamos verifica o ID com get_ID, pois já iremos fazer um loop para procurar o vagão)
		addi a7, zero, 5
		ecall
		
		# Salvando ID lido
		mv s6, a0
		
		# Preparando para impressão de string de resposta
		addi a7, zero, 4
		
		# Não é possível remover a locomotiva
		beq s6, zero, locomotiva_error_rem
		
	# ---- Inicializações para o loop
		
		# O iterador começa no vagão após a locomotiva
		lw s3, 8(s0)
		
		# Se s3 = 0, só há um vagão no trem (a locomotiva), então não é possível realizar nenhuma remoção  
		beq s3, zero, nao_existe_rem
		
		# Ponteiro auxiliar que aponta para o vagão anterior ao indicado pelo iterador
		mv s7, s0
		
	# ---- Procurando vagão
	 	
	loop_rem_ID:
		# Recuperando o ID do vagão atual
		lw s4, 0(s3)
		
		# Se ID for o desejado, começa o processo de remoção
		beq s4, s6, removendo
		
		# Senão, tentamos o próximo vagão
		mv s7, s3
		lw s3, 8(s3)
		
		# Se o trem acabou, não existe vagão com o ID desejado
		beq s3, zero, nao_existe_rem 
		
		j loop_rem_ID
	
	# ---- Removendo vagão
		
	removendo:
		# Para remover um vagão, basta ligar o anterior ao posterior dele, assim ele se "desvincula" do trem
		#Esse algoritmo trata tanto o caso de remoção no meio, quanto de remoção no fim, em anterior irá começar apontar para NULL (ponteiro = 0) 
		# Carregando o endereço do posterior ao que será removido
		lw t0, 8(s3)
		
		# Colocando endereço do posterior no ponteiro do anterior
		sw t0, 8(s7)
		
		# Imprimindo que a remoção ocorreu corretamente
		la a0, txt_fim_rem
		ecall
		
		j interface
		
	# ---- Resposta no caso do vagão não existir
		
	nao_existe_rem:
		# Imprimindo que o vagão não foi encontrado para remoção
		la a0, txt_nao_existe_rem
		ecall
		
		j interface
		
	# ---- Resposta no caso de tentativa de remover a locomotiva
		
	locomotiva_error_rem:
		# Imprimindo que o vagão escolhido para remoção é a locomotiva
		la a0, txt_locomotiva_rem
		ecall

		j interface


# ------- Listagem do Trem -------- #

	# ---- Apresentação do título e inicialização
listar:	
			# Chama serviço de imprimir texto pra imprimir o cabeçalho da função
			la a0, txt_inicio		
			addi a7, zero, 4
			ecall


			# s3 = ponteiro (iterador) que vai percorrer o trem, começando na cabeça.
			mv s3, s0	
			
			# Inicializa o registrador s8 como 1, que servirá como contador das posições dos vagões
			addi s8, zero, 1		

	# ---- Percorrendo trem
	loop_listar:

			# -------- Condição de parada
			# Se o valor do iterador é nulo, encerramos e voltamos à interface.
			beq s3, zero, interface		
			

			#  ------- Leitura do vagão atual
			# Damos load do valor de offset(s3) em s4 e s5.
			lw s4, 0(s3)			# s4 = ID, offset 0
			lw s5, 4(s3)			# s5 = tipo, offset 4
			
			# -------- Impressão de Texto
			# Chamada e impressão do texto: "Vagão "
			la a0, txt_vagao
			addi a7, zero, 4
			ecall
			
			# Chamada e impressão da posição do vagão
			add a0, zero, s8
			addi a7, zero, 1
			ecall
			
			# Itera o valor de s8
			addi s8, s8, 1
			
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


# ------- Buscar Vagão ------ #

buscar:		#-------- Recebendo o ID
			
			# Imprimindo solitação do ID
			la a0, txt_ID_busca
			addi a7, zero, 4
			ecall
			
			# Lendo ID (inteiro) -> retorno estará em a0
			addi a7, zero, 5
			ecall
			 
		# ------- Buscando ID
			# Parâmetro já está no a0
			jal busca_ID
			
		# ------ Verificando retorno
			
			# Preparando para imprimir string na próxima chamada de sistema
			addi a7, zero, 4
			
			# Desviando a depender do retorno da função
			beq a1, zero, print_nao_existe
			
		# ----- Resposta no caso de não existir vagão com aquele ID 
		
			la a0, txt_existe_busca
			ecall
			
			j interface
			
		# ----- Resposta no caso de existir vagão com aquele ID 
		
	print_nao_existe:

			la a0, txt_nao_existe_busca
			ecall
			
			j interface

# ----- Fim do Buscar Vagão ----- #

# ----- Saída do Jogo ----- #
exit:	

		la a0, seeya			# Carrega mensagem de despedida 

		addi a7, zero, 4		# Imprime a mensagem de despedida
		ecall
		
		addi a7, zero, 10		# Encerra o programa na próxima chamada do sistema
		ecall
