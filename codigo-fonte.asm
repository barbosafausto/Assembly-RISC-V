	# --------- SEGMENTO DE DADOS ---------- #
			.data				
	
	
	
	# --------- Textos e Frases


			# strings pode sem armazenadas com quaisquer alinhamentos.
			.align 0												
			
# Mensagem que será mostrada quando o jogador fechar o jogo.
seeya:		.asciz "Obrigado por jogar!\n"														

# Mensagem de boas vindas 
hola:   	.asciz "Tchoo Tchoo! tá na hora de montar uns trem bão por aí >:D\n\n"				


# Instruções de como jogar [para o usuário]
instrucoes: 
			.ascii "Como jogar? Simples: o seu objetivo é gerenciar um trem, podendo adicionar e remover vagões (mas não a cabeça, que é a locomotiva!), "
			.ascii "além de listar o trem e buscar por vagões. Mas com algumas regras fixas: Só é possível adicionar vagões no início (depois da locomotiva) e no fim, "
			.ascii "remover qualquer vagão que não seja a locomotiva (primeiro vagão), mas para isso é necessário fornecer o ID do vagão a ser removido.\n"
			.ascii "Você pode também listar todos os vagões (e mostrar o ID de cada) e buscar por um vagão através do ID também. Veja o menu de ações:\n\n"
			.asciz "Escolha uma das oções (1-6):"

# Menu de ações
# No final de cada função (exceto sair) há um jump para cá novamente
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


# Mensagens que compõem a função 1: Adicionar vagão no início 
txt_ID:		.asciz "\nDigite o ID do novo vagão: "
txt_Tipo:	.asciz "\nDigite o Tipo do novo vagão: "
txt_Erro: 	.asciz "\nErro! Já existe um vagão com o ID fornecido."
	
	

	
	# ------------ SEGMENTO DE CÓDIGO --------- #



	# Todas as instruções são de 32 bits	
			.align 2 									

			.text	
			.globl main
	
main:	
			
			# ---------- Dicionário de registradores e variáveis


			# s0 -> Guarda ponteiro da locomotiva. Não podemos mudar o seu valor.
			# s1 -> Quantidade de vagões do trem
			# s2 -> Guarda entrada do usuário pro menu de ações

			# Usados na função 4 (listagem do trem):
			# s3 -> iterador, percorre o trem desde a locomotiva até o último vagão
			# s4 -> guarda o ID do vagão atual
			# s5 -> guarda o tipo do vagão atual
			# s6 -> guarda o endereço do novo vagão alocado
			
			# ID da cabeça = 0. próximos vagões serão: 1, 2, 3, 4, 5, ... , n-1, n
			# Exemplos de tipos: 1 = locomotiva, 2 = carga, 3 = passageiro, 4 = combustível


			

			# ---------- Adição da Lomocomativa (vagão cabeça)


			# ----- Alocação de memória	

			
			# Alocar memória para a cabeça
			# Serviço 9 -> alocação de memória heap
			addi a7, zero, 9	

			# Instruir de quantidade: 12 bytes de espaço (4 ID, 4 TIPO, 4 PONTEIRO)
			addi a0, zero, 12	

			# Chamada de sistema para o endereço ser alocado e guardado no registrador a0
			ecall			

			# Agora o endereço da cabeça está guardado em s0. Isso não pode ser mudado.
			mv s0, a0		


			# ----- Preenchimento dos dados no espaço alocado

			
			# ID da locomotiva (cabeça) = 0
			addi t1, zero, 0 		

			# Tipo da locomativa (cabeça) = 1
			addi t2, zero, 1		

			# Guarda o valor de t1 (ID) no offset 0 do registrador s0 
			sw t1, 0(s0)		
			
			# Guarda o valor de t2 (Tipo) no offset 4 
			sw t2, 4(s0)		

			# Guarda o valor do ponteiro no offset 8. Como só tem a locomotiva, o ponteiro é NULL (zero)
			# Sistema de 32 bits -> 4 bytes. Por isso, o valor do ponteiro tem 4 bytes reservados.
			sw zero, 8(s0)		



			# Atualizar contador e iniciar o jogo
			addi s1, zero, 2	# O jogo começa com 2 vagões (locomotiva + vagão teste)
			addi s2, zero, 0	# menu começa zerado

			
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


			# ------ Mostra ao usuários as opções		
interface:	

			# Printa o menu de ações	
			la a0, mostrarMenu	
			addi a7, zero, 4
			ecall


			# ------ Armazena o input do usuário
	
get_input:
			
			# Lê inteiro e coloca o valor no registrador s2
			addi a7, zero, 5		
			ecall				
			mv s2, a0			


			# ----- Decide o que fazer com base no input
	
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

			
			# ---------- FUNÇÕES DO MENU ----------


add_ini:	

			# ------- Leitura dos dados do novo vagão

			# Lê o ID do novo vagão e coloca em s4
			addi a7, zero, 4
			la a0, txt_ID
			ecall

			addi a7, zero, 5
			ecall
			mv s4, a0

			# Lê o Tipo do novo vagão e coloca em s5
			addi a7, zero, 4
			la a0, txt_Tipo
			ecall

			addi a7, zero, 5
			ecall
			mv s5, a0

			# !!!!!!!!! Por enquanto está assim, mas é necessário validar o ID: IDs repetidos não fazem sentido


			# ------ Alocação do novo vagão (12 bytes)
			addi a7, zero, 9
			addi a0, zero, 12
			ecall

			# ----- Preenchimento dos valores do novo vagão
			# ID
			sw s4, 0(a0)	
			# Tipo
			sw s5, 4(a0)

			# ------ Organização de ponteiros
			# Carrego o endereço do próximo vagão em t2
			lw t1, 8(s0)
			
			# Salvo esse endereço no offset 8 do novo vagão
			sw t1, 8(a0)

			# Salvo o endereço do novo vagão em offset 8 da locomotiva
			sw a0, 8(s0)

			
			# Incremento o número de vagões
			addi s1, s1, 1
			
			j interface

add_fim:	j interface

rem_ID:		j interface


			# -------

listar:	
			
			# Chama serviço de imprimir texto pra imprimir o cabeçalho da função
			la a0, txt_inicio		
			addi a7, zero, 4
			ecall


			# s3 = Ponteiro (iterador) que vai percorrer o trem, começando na cabeça.
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

buscar:	j interface

exit:	la a0, seeya			# printa mensagem de despedida 
	addi a7, zero, 4		
	ecall
	
	addi a7, zero, 10		# Encerra o programa na próxima chamada do sistema
	ecall
