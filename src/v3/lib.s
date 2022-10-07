.equ setregoffset, 28           @ Offset do registrador de set do GPIO
.equ clrregoffset, 40           @ Offset do registrador de clear do GPIO
.equ nano_sleep, 162            @ Numero da syscall do nano sleep
.equ off, 0
.equ on, 1


.macro nanoSleep
    LDR R0,=timespecsec
    LDR R1,=timespecnano
    MOV R7, #nano_sleep
    SVC 0
.endm

.macro SetGpioValue pin, value

    MOV R1, \value
    LDR R3, =\pin

    MOV R2, R8
    CMP R1,#0
    ADDEQ R2, #clrregoffset
    CMP R1,#1
    ADDEQ R2, #setregoffset

    MOV R0, #1
    ADD R3, #8
    LDR R3, [R3]
    LSL R0, R3
    STR R0, [R2]
.endm

.macro GPIODirectionOut pin

    LDR R2, =\pin
    LDR R2, [R2]
    LDR R1, [R8, R2]
    LDR R3, =\pin
    ADD R3, #4
    LDR R3, [R3]
    MOV R0, #0b111
    LSL R0, R3
    BIC R1, R0
    MOV R0, #1
    LSL R0, R3
    ORR R1, R0
    STR R1, [R8, R2]
.endm

.macro FunctionSet

    SetGpioValue pinRS, #off
    SetGpioValue pinD7, #off
    SetGpioValue pinD6, #off
    SetGpioValue pinD5, #on
    SetGpioValue pinD4, #off

    SetEnable

.endm

.macro SetEnable

    SetGpioValue pinEN, #off
    nanoSleep
    SetGpioValue pinEN, #on
    nanoSleep
    SetGpioValue pinEN, #off

.endm

.macro SetPinsDisplayOut

    GPIODirectionOut pinEN
    GPIODirectionOut pinRS
    GPIODirectionOut pinD7
    GPIODirectionOut pinD6
    GPIODirectionOut pinD5
    GPIODirectionOut pinD4

.endm

.macro OnDisplay

    SetGpioValue pinRS, #off
    SetGpioValue pinD7, #off
    SetGpioValue pinD6, #off
    SetGpioValue pinD5, #off
    SetGpioValue pinD4, #off
    SetEnable

    SetGpioValue pinRS, #off
    SetGpioValue pinD7, #on
    SetGpioValue pinD6, #on
    SetGpioValue pinD5, #on
    SetGpioValue pinD4, #on
    SetEnable

.endm

.macro ClearDisplay

    SetGpioValue pinRS, #off
    SetGpioValue pinD7, #off
    SetGpioValue pinD6, #off
    SetGpioValue pinD5, #off
    SetGpioValue pinD4, #off
    SetEnable

    SetGpioValue pinRS, #off
    SetGpioValue pinD7, #off
    SetGpioValue pinD6, #off
    SetGpioValue pinD5, #off
    SetGpioValue pinD4, #on
    SetEnable

.endm

.macro EntrySetMode

    SetGpioValue pinRS, #off
    SetGpioValue pinD7, #off
    SetGpioValue pinD6, #off
    SetGpioValue pinD5, #off
    SetGpioValue pinD4, #off
    SetEnable

    SetGpioValue pinRS, #off
    SetGpioValue pinD7, #off
    SetGpioValue pinD6, #on
    SetGpioValue pinD5, #on
    SetGpioValue pinD4, #off
    SetEnable
    .ltorg

.endm

.macro SetUpperBitsDefaultNumber

    SetGpioValue pinRS, #on
    SetGpioValue pinD7, #off
    SetGpioValue pinD6, #off
    SetGpioValue pinD5, #on
    SetGpioValue pinD4, #on
    SetEnable

.endm

.macro writeDigit value

    SetUpperBitsDefaultNumber
    SetGpioValue pinRS, #on

    MOV R2,#1
    LSL R2,#3
    AND R1,R2,\value
    LSR R1,#3
    SetGpioValue pinD7, R1

    MOV R2,#1
    LSL R2,#2
    AND R1,R2,\value
    LSR R1,#2
    SetGpioValue pinD6, R1

    MOV R2,#1
    LSL R2,#1
    AND R1,R2,\value
    LSR R1,#1
    SetGpioValue pinD5, R1


    MOV R2,#1
    AND R1,R2,\value
    SetGpioValue pinD4, R1
    SetEnable
    .ltorg

.endm

.macro writeChar value


    SetGpioValue pinRS, #on

    MOV R2,#1
    LSL R2,#7
    AND R1,R2,\value
    LSR R1,#7
    SetGpioValue pinD7, R1

    MOV R2,#1
    LSL R2,#6
    AND R1,R2,\value
    LSR R1,#6
    SetGpioValue pinD6, R1

    MOV R2,#1
    LSL R2,#5
    AND R1,R2,\value
    LSR R1,#5
    SetGpioValue pinD5, R1


    MOV R2,#1
    LSL R2,#4
    AND R1,R2,\value
    LSR R1,#4
    SetGpioValue pinD4, R1

    SetEnable

    SetGpioValue pinRS, #on

    MOV R2,#1
    LSL R2,#3
    AND R1,R2,\value
    LSR R1,#3
    SetGpioValue pinD7, R1

    MOV R2,#1
    LSL R2,#2
    AND R1,R2,\value
    LSR R1,#2
    SetGpioValue pinD6, R1

    MOV R2,#1
    LSL R2,#1
    AND R1,R2,\value
    LSR R1,#1
    SetGpioValue pinD5, R1


    MOV R2,#1
    AND R1,R2,\value
    SetGpioValue pinD4, R1

    SetEnable
    .ltorg

.endm

.macro send_cmd value


    SetGpioValue pinRS, #off

    MOV R2,#1
    LSL R2,#7
    AND R1,R2,\value
    LSR R1,#7
    SetGpioValue pinD7, R1

    MOV R2,#1
    LSL R2,#6
    AND R1,R2,\value
    LSR R1,#6
    SetGpioValue pinD6, R1

    MOV R2,#1
    LSL R2,#5
    AND R1,R2,\value
    LSR R1,#5
    SetGpioValue pinD5, R1


    MOV R2,#1
    LSL R2,#4
    AND R1,R2,\value
    LSR R1,#4
    SetGpioValue pinD4, R1

    SetEnable

    SetGpioValue pinRS, #on

    MOV R2,#1
    LSL R2,#3
    AND R1,R2,\value
    LSR R1,#3
    SetGpioValue pinD7, R1

    MOV R2,#1
    LSL R2,#2
    AND R1,R2,\value
    LSR R1,#2
    SetGpioValue pinD6, R1

    MOV R2,#1
    LSL R2,#1
    AND R1,R2,\value
    LSR R1,#1
    SetGpioValue pinD5, R1


    MOV R2,#1
    AND R1,R2,\value
    SetGpioValue pinD4, R1

    SetEnable
    .ltorg

.endm

.macro InitDisplay
   SetPinsDisplayOut
   ClearDisplay
   FunctionSet
   FunctionSet
   FunctionSet
   OnDisplay
   EntrySetMode

.endm

.global write_digit
.global clear_display
.global write_char
.global init_display

@ Escreve um digito (numero 0-9) no display
@ Recebe em R0 o valor do endereço base da gpio
@ Recebe em R1 o valor do digito para exibir
@ Salva em r8 o endereço base recebido em r0
write_digit:
    push {R8}         @ Salva o valor atual de r8
    mov r8, r0        @ Salva em r8 o valor recebido em r0
    writeDigit r1     @ Escreve o digito recebido em r1
    pop {R8}          @ Restaura o valor de R8
    bx lr             @ Retorna

@ Apaga todos os caracteres no display
@ Recebe em R0 o valor do endereço base da gpio
@ Salva em r8 o endereço base recebido em r0
clear_display:
    push {R8}         @ Salva o valor atual de r8
    mov r8, r0        @ Salva em r8 o valor recebido em r0
    ClearDisplay      @ Limpa o display
    pop {R8}          @ Restaura o valor de R8
    bx lr             @ Retorna

@ Escreve um caractere no display
@ Recebe em R0 o valor do endereço base da gpio
@ Recebe em R1 o valor do caractere para exibir
@ Salva em r8 o endereço base recebido em r0
write_char:
    push {R8}         @ Salva o valor atual de r8
    mov r8, r0        @ Salva em r8 o valor recebido em r0
    writeChar r1      @ Escreve o caractere recebido em r1
    pop {R8}          @ Restaura o valor de R8
    bx lr             @ Retorna

@ Inicializa o display antes do uso
@ Recebe em R0 o valor do endereço base da gpio
@ Salva em r8 o endereço base recebido em r0
init_display:
    push {R8}         @ Salva o valor atual de r8
    mov r8, r0        @ Salva em r8 o valor recebido em r0
    InitDisplay       @ Inicializa o display
    pop {R8}          @ Restaura o valor de R8
    bx lr             @ Retorna

@ Posiciona cursor linha coluna 
@ Recebe em R0 o valor do endereço base da gpio
@ Recebe em r1 o numero da linha (1 ou 2)
@ Recebe em r2 o numero da coluna (1 a 16)
@ Salva em r8 o endereço base recebido em r0
position_cursor:
    push {R8}         @ Salva o valor atual de r8
    cmp r1, #2        @ Se o valor da linha for maior que 2
    bgt line_err      @ Retorna erro
    cmp r2, #16       @ Se o valor da coluna for maior que 16
    bgt column_err    @ Retorna erro

    cmp r1, #1        @ Se o valor da linha for menor que 1
    blt line_err      @ Retorna erro
    cmp r2, #1        @ Se o valor da coluna for menor que 1
    blt column_err    @ Retorna erro

    b change_position

line_err:
    mov r0, #1        @ Retorna erro
    b p_c_return

column_err:
    mov r0, #2        @ Retorna erro
    b p_c_return

change_position:
    cmp r1, #1        @ se o selecionado primeira linha
    beq first_line    @ Vá para a primeria linha
    b second_line     @ Do contrario, vá para a segunda

first_line:
    send_cmd #0x80    @ Coloca o cursor no inicio da primeira linha
    b set_column
second_line:
    send_cmd #0xC0    @ Coloca o cursor no inicio da segunda linha
    b set_column

set_column:
    sub r2, r2, #1
    cmp r2, #0        @ Se igual a zero, já esta na coluna desejada
    beq p_c_success   @ e retorna sucesso
                      @ Do contrario
    send_cmd #0x06    @ incrementa a posição do cursor em 1 para a direita
    b set_column      @ repete até encontrar a coluna certa

p_c_success:
    mov r0, #0        @ Retorna sucesso
p_c_return
    pop {R8}          @ Restaura o valor de R8
    bx lr


.data

timespecsec: .word 0              @ zero segundos
timespecnano: .word 015000000     @ 15


@ Pinos da GPIO conectados no display

pinD4:
    .word 4
    .word 6
    .word 12

pinD5:
    .word 4
    .word 18
    .word 16

pinD6:
    .word 8
    .word 0
    .word 20

pinD7:
    .word 8
    .word 3
    .word 21

pinRS:
    .word 8
    .word 15
    .word 25

pinEN:
    .word 0
    .word 3
    .word 1


pin6:
     .word 0
     .word 18
     .word 6

