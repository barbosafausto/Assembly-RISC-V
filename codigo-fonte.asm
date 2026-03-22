	.data				# Segmento de dados
	
	# --------- TEXTOS E FRASES ------------
	
	.align 0
seeya:	.asciz "Obrigado por jogar!\n"	# Mensagem que será mostrada quando o jogador fechar o jogo.

# Mensagem de boas vindas
hola:   .asciz "Tchoo Tchoo! tá na hora de montar uns trem bão por aí >:D\n\n" 

# Mostrar como jogar ao usuário
instrucoes: 
	.ascii "Como jogar? simples, seu objetivo é gerenciar um trem, podendo adicionar e remover vagões (mas não a cabeça, que é a locomotiva!), "
	.ascii "além de listar o trem e buscar por vagões. Mas com algumas regras fixas: Só é possível adicionar vagões no início (depois da locomotiva) e no fim, "
	.ascii "remover qualquer vagão que não seja a locomotiva (primeiro vagão), mas para isso é necessário fornecer o ID do vagão a ser removido.\n"
	.ascii "Você pode também listar todos os vagões (e mostrar o ID de cada) e buscar por um vagão através do ID também. Veja o menu de ações:\n\n"
	.asciz "Escolha uma das oções (1-6):"

# Menu de ações
# Dev note: Lembrar de no final de cada função (exceto sair) dar jump para cá novamente
mostrarMenu:
	.ascii "\n"
	.ascii "1 - Adicionar vagão no início.\n"
	.ascii "2 - Adicionar vagão no final.\n"
	.ascii "3 - Remover vagão por ID.\n"
	.ascii "4 - Listar trem.\n"
	.ascii "5 - Buscar vagão.\n"
	.asciz "6 - sair.\n\n"
	
txt_inicio: .asciz "\n--- COMPOSICAO DO TREM ---\n"
txt_id:     .asciz " -> [ID: "
txt_tipo:   .asciz " | Tipo: "
txt_fecha:  .asciz "]\n"
	
	
	.align 2
	.text				# Segmento de Código
	.globl main
	
main:	# ---------- DICIONÁRIO DE REGISTRADORES E VARIÁVEIS --------------
	# s0 -> guarda ponteiro da locomotiva cabeça (não mexer)
	# s1 -> quantidade de vagões (provavelmente inútil mas veremos)
	# s2 -> guarda entrada do usuário pro menu de ações
	
	# usado na listagem:
	# s3 -> iterador, percorre o trem desde a locomotiva até o último vagão
	# s4 -> guarda o ID do vagão atual
	# S5 -> guarda o tipo do vagão atal
	
	# ID da cabeça = 0, próximos vagões serão 1, 2, 3, etc
	# TIPOS: 1 = cabeça, 2 = carga, 3 = passageiro (exemplo)

	# ---------- ADIÇÃO DA LOCOMOTIVA (VAGÃO CABEÇA) ----------
	
	# alocar memória para cabeça
	addi a7, zero, 9	# serviço 9 -> alocação de memória
	addi a0, zero, 12	# instruir quantidade: 12 bytes de espaço (4 ID, 4 TIPO, 4 PONTEIRO)
	ecall			# endereço retornado no a0 também
	
	mv s0, a0		# agora o endereço da cabeça está guardado em s0, NÃO MUDAR!!!!
	
	# preenchimento dos dados na memória RAM no espaço alocado
	addi t1, zero, 0 		# ID DA LOCOMOTIVA (CABEÇA) = 0?
	addi t2, zero, 1		# TIPO: CABEÇA, PODE SER 1 ?
	
	sw t1, 0(s0)		# offset 0 (0-3) guarda ID
	sw t2, 4(s0)		# offset 4 (4-7) guarda tipo
	sw zero, 8(s0)		# offset 8 (8-11) guarda ponteiro, como só tem a locomotiva o ponteiro é NULL (zero)
				# sistema de 32 bits -> 4 bytes, portanto ponteiro tem 4 bytes de tamanho
	
	# ---------- TESTE - ALOCAÇÃO DE MEMÓRIA PARA SEGUNDO VAGÃO DE TESTE ----------
	
	# alocar memória para possível segund vagão
	addi a7, zero, 9	# serviço 9 -> Alocação de memória
	addi a0, zero, 12	# pede 12 bytes de espaço
	ecall			# endereço do novo vagão retorna em a0
	
	# preencher os dados do vagão 1 (pós locomotiva) (que está no endereço a0)
	addi t1, zero, 1	# ID 1
	addi t2, zero, 2	# TIPO: 2 (Carga)
	
	sw t1, 0(a0)		# offset 0 -> guarda o ID 1 
	sw t2, 4(a0)		# offset 4 -> guarda o Tipo 
	sw zero, 8(a0)		# offset 8 -> ponteiro é NULL, pois ele é o último da fila agora
	
	# ligação do ex-último vagão ao atual último vagão
	# a cabeça está no endereço s0. O offset 8 dela estava com 'zero'.
	# -> colocar o endereço do novo vagão (a0) lá dentro
	sw a0, 8(s0)		# locomotiva agora aponta para o próximo vagão

	# -----------------------------------------------------------

	# Atualizar contador e iniciar o jogo
	addi s1, zero, 2	# O jogo começa com 2 vagões (locomotiva + vagão teste)
	addi s2, zero, 0	# menu começa zerado
	
	# ------- INICIO DO JOGO ---------
	la a0, hola			# Muda o valor de a0 para o endereço do primeiro byte do string de rótulo "hola"
	addi a7, zero, 4		# Imprime o string encontrado em a0 na próxima chamada do sistema, que é a mensagem de boas vindas
	ecall
	
	la a0, instrucoes		# printa ao usuário como jogar
	addi a7, zero, 4
	ecall
	
interface:	
	la a0, mostrarMenu		# printa o meno de ações
	addi a7, zero, 4
	ecall
	
get_input:
	addi a7, zero, 5		# código de serviço ReadInt
	ecall				# resultado fica automaticamente em a0
	mv s2, a0			# ENTRADA FICA SALVA EM s2
	
branch_from_input:			# ve qual é a entrada e pula pra função correspondente

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
	beq s2, t0, listar		# Se s2 == 4, [...]
	
	# 5 - Buscar Vagão
	addi t0, zero, 5			
	beq s2, t0, buscar		# Se s2 == 5, [...]
	
	# 6 - Sair
	addi t0, zero, 6			
	beq s2, t0, exit		# Se s2 == 6 [...]
	
	# Se a entrada for qualquer outro número, faz o menu aparecer de novo e recebe a entrada de novo
	j interface

# ---------- FUNÇÕES DO MENU ----------
add_ini:	j interface

add_fim:	j interface

rem_ID:		j interface

listar:	
	la a0, txt_inicio		# chama serviço de imprimir texto pra imprimir o cabeçalho de enfeite
	addi a7, zero, 4
	ecall
	
	mv s3, s0			# s3 = PONTEIRO QUE VAI PERCORRER O TREM, COMEÇA NA CABEÇA, EX: ITERADOR
loop_listar:
	#CONDIÇÃO PARADA
	beq s3, zero, interface		# se o ponteiro for null, significa que não tem "Próximo vagão", acabou
	
	#LER VAGÃO ATUAL
	lw s4, 0(s3)			# s4 = ID, offset 0
	lw s5, 4(s3)			# s5 = tipo, offset 4
	
	# ----------------- IMPRESSAO -------------------------  (pqp como dá trabalho pra imprimir texto em assembly)
	# chamada e impressão de " -> [ID : "
	la a0, txt_id
	addi a7, zero, 4
	ecall	
	
	# chamada e impressão do ID
	mv a0, s4			# move o valor do ID armazenado em s4 para a0
	addi a7, zero, 1		# Serviço 1 -> imprime inteiro
	ecall
	
	# chamada e impressão de " | Tipo: "
	la a0, txt_tipo
	addi a7, zero, 4
	ecall
	
	# chamada e impressão do tipo
	mv a0, s5			# move o valor do tipo armazenado em s5 para a0
	addi a7, zero, 1		# Serviço 1 -> imprime inteiro
	ecall
	
	# chamada e impressão de "]\n" (fechar e pular linha só
	la a0, txt_fecha
	addi a7, zero, 4
	ecall
	
	#ATUALIZACAO DO PONTEIRO ex: atual = atual->proximo
	lw s3, 8(s3)
	
	#continua loop até parada (alcançar o fim do trem, cujo ponteiro é nulo), 
	j loop_listar

buscar:	j interface

exit:	la a0, seeya			# printa mensagem de despedida 
	addi a7, zero, 4		
	ecall
	
	addi a7, zero, 10		# Encerra o programa na próxima chamada do sistema
	ecall
