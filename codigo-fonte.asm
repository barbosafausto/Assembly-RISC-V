	.data				# Segmento de dados
	
	# --------- TEXTOS E FRASES ------------
	
	.align 0
seeya:	.asciz "Obrigado por jogar!"	# Mensagem que será mostrada quando o jogador fechar o jogo.

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

	.text				# Segmento de Código
	.align 2
	.globl main
	
main:	la a0, hola			# printa Texto de boas vindas
	addi a7, zero, 4
	ecall
	
	la a0, instrucoes		# printa ao usuário como jogar
	addi a7, zero, 4
	ecall
	
	la a0, mostrarMenu		# printa o meno de ações
	addi a7, zero, 4
	ecall

exit:	la a0, seeya			# Muda o valor de a0 para o endereço do primeiro byte do string de rótulo "seeya"
	addi a7, zero, 4		# Imprime o string encontrado em a0 na próxima chamada do sistema
	ecall
	
	addi a7, zero, 10		# Encerra o programa na próxima chamada do sistema
	ecall
