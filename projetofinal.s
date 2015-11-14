@Atividade final: programa que lê uma entrada e uma chave do teclado, transoforma as entradas em ASCII
@A seguir, a mensagem recebida é criptografada e depois descriptografada
@A mensagem criptografada e descriptografada são mostradas no console e no LCD

INICIO:

@saida ou chave
mov r8, #0

@Interface do Teclado é apresentada ao usuário através do display LCD

@Linha 1 do LCD
mov r0, #0
mov r1, #0
ldr r2, =TECLADO1
swi 0x204

@Linha 2 do LCD
mov r1, #2
ldr r2, =TECLADO2
swi 0x204

@Linha 3 do LCD
mov r1, #3
ldr r2, =TECLADO3
swi 0x204

@Linha 4 do LCD
mov r1, #4
ldr r2, =TECLADO4
swi 0x204

@Linha 5
mov r1, #5
ldr r2, =TECLADO5
swi 0x204

@Linha 6
mov r1, #6
ldr r2, =TECLADO6
swi 0x204

INICIO_LEITURA:

@r4 irá conter o número de caracteres lidos
mov r4, #0

@Espera uma tecla ser pressionada
VERIFICA_TECLADO:

swi 0x203
cmp r0, #0
beq VERIFICA_TECLADO @Teclado ainda não foi pressionado

@Teclado foi pressionado
@r3 irá armazenar o valor retornado por swi (relativo ao botão pressionado)
mov r3, r0

@Limpa o LCD
swi 0x206

@registrador utilizado para armazenar o valor (em hexadecimal) do caractere lido
mov r1, #0

swi 0x202
cmp r0, #1 @Troca os botões do teclado
bne CONTINUA

@Teclado 2: incrementa r1 em 16 pois o teclado está no segundo modo de operação
add r1, r1, #16

CONTINUA:

@r5 irá conter a posição relativa do botão pressionado
mov r5, #0

@Loop que incrementa r5 para cada vez que o bit do registrador r3 for deslocado para a direita
TRATA_INPUT_INICIO:

cmp r3, #1
beq TRATA_INPUT_FIM

mov r3, r3, lsr #1
add r5, r5, #1

b TRATA_INPUT_INICIO

@Calcula o valor real (em hexadecimal - ASCII) do caractere lido, e coloca em r5
TRATA_INPUT_FIM:

add r5, r5, #65
add r5, r5, r1

@Converte para o caractere de espaço
TESTE1:
cmp r5, #91
bne TESTE2
mov r5, #32

@Testa se a tecla de "Fim" foi pressionada
TESTE2:
cmp r5, #96
beq FIM

@Armazena o caractere ASCII na memória

cmp r8, #0
bne NCHAVE

ldr r6, =SAIDA
add r6, r6, r4
strb r5, [r6]
b FIM_ARMAZENAMENTO

NCHAVE:
ldr r6, =CHAVE
add r6, r6, r4
strb r5, [r6]

FIM_ARMAZENAMENTO:
add r4, r4, #1

@Output

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #0

cmp r8, #0
bne PALAVRA2

@Conteúdo do LCD
ldr r2, =SAIDA
swi 0x204

@Imprime uma mensagem auxiliar e depois o caractere lido (em Hexadecimal - ASCII) no Console
ldr r0, =MENSAGEM
swi 0x02

ldr r0, =SAIDA
swi 0x02

ldr r0, =AUX
swi 0x02


b PALAVRA1

PALAVRA2:
@Conteúdo do LCD
ldr r2, =CHAVE
swi 0x204

@Imprime uma mensagem auxiliar e depois o caractere lido (em Hexadecimal - ASCII) no Console
ldr r0, =MENSAGEM
swi 0x02

ldr r0, =CHAVE
swi 0x02

ldr r0, =AUX
swi 0x02

PALAVRA1:


@Zera os registradores auxiliares para a proxima iteracao
mov r0, #0
mov r1, #1

b VERIFICA_TECLADO

FIM:
add r8, r8, #1

cmp r8, #1
bne TERMINOU_LEITURA

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #0

@Conteúdo do LCD
ldr r2, =MSGCHAVE

@Mostra o resultado no display LCD
swi 0x204

ldr r0, =MSGCHAVE
swi 0x02

b INICIO_LEITURA

TERMINOU_LEITURA:
mov r8, r4
@algoritmo de criptografia One-Time Pad

START:

@r0, r1 e r2 armazenam os endereços das mensagens na memória
ldr r0, =SAIDA
ldr r1, =CHAVE
ldr r2, =MSGCRIPTOGRAFADA

@r5 contém o número de bits da mensagem recebida
mov r5, #0

LEITURA:

@testa se a leitura da mensagem recebida já terminou
ldrb r3, [r0]
cmp r3, #0

beq FIM_LEITURA
@leitura ainda não terminou

ldrb r4, [r1]

@realiza a criptografia da mensagem recebida utilizando um XOR bit a bit
eor r3, r3, r4

@armazena o resultado na memória
strb r3, [r2]

@avança em 1 o endereço do próximo bit da mensagem
add r0, r0, #1
add r1, r1, #1
add r2, r2, #1

@avança em 1 o número de bits
add r5, r5, #1
b LEITURA

@terminou a criptografia da mensagem recebida
FIM_LEITURA:


ldr r0, =CHAVE
ldr r1, =MSGCRIPTOGRAFADA
ldr r2, =MSGFINAL

LOOP:

@testa se todos os bits já foram lidos
cmp r5, #0

beq FIM2

ldrb r3, [r0]
ldrb r4, [r1]

@realiza a descriptografia da mensagem cifrada utilizando um XOR bit a bit
eor r3, r3, r4

@armazena o resultado na memória
strb r3, [r2]

@avança em 1 o endereço do próximo bit da mensagem
add r0, r0, #1
add r1, r1, #1
add r2, r2, #1

@diminui em 1 o número de bits que ainda não foram lidos
sub r5, r5, #1
b LOOP

@imprime as mensagens console

FIM2:

@imprime a mensagem recebida
ldr r0, = MESSAGE1
swi 0x02

ldr r0, = SAIDA
swi 0x02

@imprime a mensagem cifrada
ldr r0, = MESSAGE2
swi 0x02

ldr r0, = MSGCRIPTOGRAFADA
swi 0x02

@imprime a mensagem decifrada
ldr r0, = MESSAGE3
swi 0x02

ldr r0, = MSGFINAL
swi 0x02

@OUTPUT DO LCD

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #0

@Conteúdo do LCD
ldr r2, =MSG1
swi 0x204

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #1

@Conteúdo do LCD
ldr r2, =SAIDA
swi 0x204

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #3

@Conteúdo do LCD
ldr r2, =MSG2
swi 0x204

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #4

@Conteúdo do LCD
ldr r2, =CHAVE
swi 0x204

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #6

@Conteúdo do LCD
ldr r2, =MSG3
swi 0x204

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #7

@Conteúdo do LCD
ldr r2, =MSGCRIPTOGRAFADA
swi 0x204

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #9

@Conteúdo do LCD
ldr r2, =MSG4
swi 0x204

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, #10

@Conteúdo do LCD
ldr r3, =MSGCRIPTOGRAFADA

@numero 1

OUTRO_LOOP:
cmp r8, #0
beq FIM_OUTRO_LOOP

ldrb r2, [r3]
and r2, r2, #240
mov r2, r2, lsr #4

cmp r2, #10
blt EH_NUMERO1

add r2, r2, #55
b FIM_TRATAMENTO_HEXA1

EH_NUMERO1:
add r2, r2, #48

FIM_TRATAMENTO_HEXA1:
swi 0x207

add r0, r0, #1

@numero 2

ldrb r2, [r3]
and r2, r2, #15

cmp r2, #10
blt EH_NUMERO2

add r2, r2, #55
b FIM_TRATAMENTO_HEXA2

EH_NUMERO2:
add r2, r2, #48

FIM_TRATAMENTO_HEXA2:
swi 0x207

add r0, r0, #1

ldr r2, =ESP
swi 0x204

add r0, r0, #1

sub r8, r8, #1
add r3, r3, #1

cmp r0, #36
blt OUTRO_LOOP

add r1, r1, #1
mov r0, #0

b OUTRO_LOOP

FIM_OUTRO_LOOP:

add r1, r1, #2

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, r1

@Conteúdo do LCD
ldr r2, =MSG5
swi 0x204

add r1, r1, #1

@Posição X do LCD
mov r0, #0

@Posição Y do LCD
mov r1, r1

@Conteúdo do LCD
ldr r2, =MSGFINAL
swi 0x204


@Memoria
TECLADO1: .ASCIZ "ENTRE COM A MENSAGEM:"
TECLADO2: .ASCIZ "TECLADO 1      TECLADO 2"
TECLADO3: .ASCIZ " A B C D        Q R S T"
TECLADO4: .ASCIZ " E F G H        U V W X"
TECLADO5: .ASCIZ " I J K L        Y Z ESP \\"
TECLADO6: .ASCIZ " M N O P        ] ^ _ FIM"

MESSAGE1: .ASCIZ "MENSAGEM RECEBIDA:\n"
MESSAGE2: .ASCIZ "\n----------\nMENSAGEM CIFRADA:\n"
MESSAGE3: .ASCIZ "\n----------\nMENSAGEM DECIFRADA:\n"

MSGCHAVE: .ASCIZ "ENTRE COM A CHAVE:\n"
MENSAGEM: .ASCIZ "MENSAGEM DIGITADA:\n"

MSG1: .ASCIZ "MENSAGEM RECEBIDA:"
MSG2: .ASCIZ "CHAVE RECEBIDA:"
MSG3: .ASCIZ "MENSAGEM CIFRADA (ASCII):"
MSG4: .ASCIZ "MENSAGEM CIFRADA (HEXA):"
MSG5: .ASCIZ "MENSAGEM DECIFRADA:"
ESP: .ASCIZ " "

SAIDA: .ASCIZ "                      "
CHAVE: .ASCIZ "                      "
MSGCRIPTOGRAFADA: .ASCIZ "                      "
MSGFINAL: .ASCIZ "                      "
AUX: .ASCIZ "\n-----------------\n"
