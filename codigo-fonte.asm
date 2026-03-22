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
	.asciz "Escolha uma das oções (1-6):\n"

# Menu de ações
# Dev note: Lembrar de no final de cada função (exceto sair) dar jump para cá novamente
mostrarMenu:
	.ascii "1 - Adicionar vagão no início.\n"
	.ascii "2 - Adicionar vagão no final.\n"
	.ascii "3 - Remover vagão por ID.\n"
	.ascii "4 - Listar trem.\n"
	.ascii "5 - Buscar vagão.\n"
	.asciz "6 - sair.\n\n"
	
	
	.align 2
	.text				# Segmento de Código
	.globl main
	
	
	
main:	# ---------- INICIALIZAÇÃO DAS VARIÁVEIS ----------
	addi s0, zero, 0	# Ponteiro da locomotiva começa como 0/NULL
	addi s1, zero, 1	# O jogo já começa com 1 vagão
	addi s2, zero, 0	# Menu começa zerado por default
	
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
add_ini:

add_fim:

rem_ID:

listar:

buscar:

exit:	la a0, seeya			# printa mensagem de despedida 
	addi a7, zero, 4		
	ecall
	
	addi a7, zero, 10		# Encerra o programa na próxima chamada do sistema
	ecall
