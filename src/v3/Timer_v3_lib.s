.equ pagelen, 4096              @ Tamanho da pagina de memoria paginada
.equ prot_read, 1
.equ prot_write, 2
.equ map_shared, 1
.equ sys_open, 5                @ Numero da syscall para abrir arquivo
.equ sys_map, 192               @
.equ nano_sleep, 162            @ Numero da syscall para nanosleep
.equ level, 52                  @ Offset para o registrador de niveis da GPIO


.global _start

.macro nanoSleep2 time
    LDR R0, =\time
    LDR R1, =\time
    MOV R7, #nano_sleep
    SVC 0
.endm

@ Limpa todo o conteúdo do display
.macro ClearDisplay
    mov r0, r8
    bl clear_display
.endm

@ Escreve um digito (0-9) no display
.macro writeDigit value

    mov r0, r8
    mov r1, \value
    bl write_digit

.endm

@ Escreve um caractere no display
.macro writeChar value

    mov r0, r8              @ primeiro argumento é o endereço base da GPIO
    mov r1, \value          @ Segundo argumento é o caractere
    bl write_char

.endm

@ Mapeia o endereço do registrador base da GPIO
@ Salva em r8 o endereço base da GPIO
.macro MapAddressGPIO

    @ opening the file
    LDR R0, = fileName
    MOV R1, #0x1b0
    ORR R1, #0x006
    MOV R2, R1
    MOV R7, #sys_open
    SVC 0
    MOVS R4, R0

    @ preparing the mapping
    LDR R5, =gpioaddr
    LDR R5, [R5]
    MOV R1, #pagelen
    MOV R2, #(prot_read + prot_write)
    MOV R3, #map_shared
    MOV R0, #0
    MOV R7, #sys_map
    SVC 0
    MOVS R8, R0
    .ltorg

.endm

@ Inicializa o display 16x2
.macro InitDisplay
    mov r0, r8
    bl init_display
.endm


_start:
    MapAddressGPIO          @ Mapeia o endereço base da GPIO
    InitDisplay             @ Inicializa o display
    InitDisplay

    @ Inicia o timer em 99 segundos
    MOV R12, #9             @ Digito da dezena
    MOV R4, #9              @ Digito da unidade

    @ Exibe uma mensagem inicial
    
    writeChar #65   @A
    writeChar #112  @p
    writeChar #101  @e
    writeChar #114  @r
    writeChar #116  @t
    writeChar #101  @e
    writeChar #32   @

    writeChar #111  @o
    writeChar #32   @

    writeChar #66   @B
    writeChar #111  @o
    writeChar #116  @t
    writeChar #97   @ã
    writeChar #111  @o



    .ltorg


wait_button_start:
    LDR R9, [R8, #level]
    MOV R11, #1
    LSL R11, #5
    AND R10, R11, R9
    cmp R10, #0

    bne wait_button_start
    nanoSleep2 time100ms
    b wait_button_up_start

restart:

        MOV R12, #9
        MOV R4,  #9

wait_button_up_start:
    LDR R9, [R8, #level]
    MOV R11, #1
    LSL R11, #5
    AND R10, R11, R9
    cmp R10, #0
    beq wait_button_up_start
    b loop

wait_button_up_pause:
    LDR R9, [R8, #level]
    MOV R11, #1
    LSL R11, #5
    AND R10, R11, R9
    cmp R10, #0
    beq wait_button_up_pause
    b wait_button_start


loop:
    ClearDisplay            @ Limpa o conteúdo do display
    writeDigit R12          @ Escreve o digito de dezena
    writeDigit R4           @ Escreve o digito de unidade



    MOV R6, #13             @ Tempo passado em grupos de 100ms
verifica_button:
    LDR R9, [R8, #level]    @ Leitura dos niveis dos pinos da GPIO

    MOV R11, #1             @ Mascara o bit referente ao
    LSL R11, #5             @ botão de start/pause

    MOV R5, #1              @ Mascara o bit referente ao
    LSL R5, #26             @ botão de restart

    AND R10, R5, R9         @ Descarta o valores não relevantes
    cmp R10, #0             @ verifica se o nivel do botão de restart é 0 (pressionado)
    beq restart             @ Se pressionado, reinicia timer

    AND R10, R11, R9        @ Descarta o valores não relevantes
    CMP R10, #0             @ verifica se o nivel do botão de start/pause é 0 (pressionado)
    bleq wait_button_up_pause   @ Se pressionado, pausa o timer

    @ Se nenhum botão foi pressionado, continua contagem do timer
    nanoSleep2 time100ms    @ Aguarda 100ms
    SUB R6, R6, #1          @ Decrementa 100ms do tempo passado
    CMP R6, #0              @ Verifica se já se passou 1 segundo (1000ms)
    BNE verifica_button     @ Se ainda não passou, continua contagem

    @ Se ja se passou 1 segundo, decrementa unidade de segundos do timer
    SUB R4, R4, #1
    CMP R4, #0              @ Verifica se a unidade de segundos foi zerada

    BGE loop                @ Se falso volta para inicio do loop e atualiza
                            @ as informações exibidas

    SUB R12, R12, #1        @ Se verdadeiro, decrementa 1s do digito de dezena
    CMP R12, #0             @ Verifica se contagem do timer terminou

    BLT restart             @ Se terminado, reinicia contador

    MOV R4, #9              @ Se não, reseta o digito de unidade para 9 segundos
    b loop                  @ e continua contagem

end:
    MOV R7, #1
    SVC 0


.data

fileName: .asciz "/dev/mem"
gpioaddr: .word 0x20200            @ Endereço base (fisico) da GPIO

@ Struct timespec argumento do nanosleep
time100ms:
    .word 0
    .word 100000000
