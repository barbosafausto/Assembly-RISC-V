	.data				# Segmento de dados
	.align 0
seeya:	.asciz "Obrigado por jogar!"	# Mensagem que será mostrada quando o jogador fechar o jogo.

	.text				# Segmento de Código
	.align 2
	.globl main
	
main:

exit:	la a0, seeya			# Muda o valor de a0 para o endereço do primeiro byte do string de rótulo "seeya"
	addi a7, zero, 4		# Imprime o string encontrado em a0 na próxima chamada do sistema
	ecall
	
	addi a7, zero, 10		# Encerra o programa na próxima chamada do sistema
	ecall