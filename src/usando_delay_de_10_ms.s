.equ pagelen, 4096
.equ setregoffset, 28
.equ clrregoffset, 40
.equ prot_read, 1
.equ prot_write, 2
.equ map_shared, 1
.equ sys_open, 5
.equ sys_map, 192
.equ nano_sleep, 162
.equ level, 52
.equ off, 0
.equ on, 1

.global _start


.macro nanoSleep
        LDR R0,=timespecsec
        LDR R1,=timespecnano
        MOV R7, #nano_sleep
        SVC 0
.endm



.macro nanoSleep2 time
        LDR R0, =\time
        LDR R1, =\time
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



.macro WriteNumber number

        push {R9}

        MOV R9, \number

        SetUpperBitsDefaultNumber

        SetGpioValue pinRS, #on

        MOV R2, R9
        LSR R2, R2, #3
        AND R1, R2, #1
        SetGpioValue pinD7, R1

        MOV R2, R9
        LSR R2, R2, #2
        AND R1, R2, #1
        SetGpioValue pinD6,  R1

        MOV R2, R9
        LSR R2, R2, #1
        AND R1, R2, #1
        SetGpioValue pinD5,  R1

        MOV R2, R9
        AND R1, R2, #1
        SetGpioValue pinD4, R2

        SetEnable

        pop {R9}
        .ltorg

.endm



@ escreve um digito na tela
@ usa os regs r2, r1, 
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

@ mapeia os endereço base da GPIO usando os registradores:
@ r0, r1, r2, r7, r4, r5 e salva o valor em r8
.macro MapAddressGPIO

        @ push {r0, r1, r2, r4, r5, r7}

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

        @ push {r0, r1, r2, r4, r5, r7, r8}
        .ltorg

.endm


.macro InitDisplay

       MapAddressGPIO
       SetPinsDisplayOut
       ClearDisplay
       FunctionSet
       FunctionSet
       FunctionSet
       OnDisplay
       EntrySetMode

.endm

@ Contador usando os seguintes registradores:
@
@ R12 Valor do contador
@ R8 endereço base da gpio
@ R9 
_start:
        InitDisplay
        MOV R12, #9
        MOV R9, #0    @ Tempo passado em ms. vai de zero a 1000ms


        .ltorg


@ Aguarda o botão ser pressiondado para iniciar contagem
@ Usando os seguintes registradores: r0, r1, r8
wait_button:

        LDR R0, [R8, #level]
        MOV R1, #1
        LSL R1, #5
        AND R1, R1, R0
        cmp R1, #0
        bne wait_button

        b loop

@ Loop do contador e exibição em tela.
@ Usando os registradores R12
loop:
        ClearDisplay          @ Limpa o display
        writeDigit R12        @ Escreve o caractere na tela
        @  nanoSleep2 time1s  // ja tem um delay de 10 ms na leitura do botão

        CMP, R9, #1000        @ Verifica se já passou 1 segundo
        BEQ next_second
        B increment_passed_time

increment_passed_time:
        ADD R9, R9, #10       @ Incrementa 10ms ao tempo passado, pois é o tempo da
                              @ leitura do botão
        B verifica_button

next_second:
        MOV R9, #10           @ "Reseta" o valor de tempo passado já adicionando
                              @ os 10ms da leitura do botão que sera feito em seguida

        SUB R12, R12, #1      @ Decrementa o contador em 1 segundo
        CMP R12, #0           @ Se zero:

        BLT end               @ Termina o programa
                              @ Se não zero:
        bl verifica_button    @ Verifica se há um botão pressionado

@ Le o se há um botão pressionado:
@ Usa os registradores: r0, r1, r2 e r8
verifica_button:
        @nanoSleep2 time500ms
        LDR R0, [R8, #level]
        MOV R1, #1
        LSL R1, #5
        AND R1, R1, R0

        nanoSleep2 time10ms
        LDR R0, [R8, #level]
        MOV R2, #1
        LSL R2, #5
        AND R2, R2, R0

        cmp R1, R2
        bgt loop
        blt loop

        cmp R1, #0

        bne loop

        b verifica_button2

@ Le o se o botão NÂO FOI PRESSIONADO por no minimo 10ms:
@ Usa os registradores: r0, r1, r2 e r8
verifica_button2:
        @nanoSleep2 time500ms
        LDR R0, [R8, #level]
        MOV R1, #1
        LSL R1, #5
        AND R1, R1, R0

        nanoSleep2 time10ms
        LDR R0, [R8, #level]
        MOV R2, #1
        LSL R2, #5
        AND R2, R2, R0

        cmp R1, R2
        bgt verifica_button2
        blt verifica_button2

        cmp R1, #0

        bne verifica_button2

        b verifica_button

end:
        MOV R7, #1
        SVC 0


.data

time1s:
        .word 1
        .word 000000000

timespecsec: .word 0
timespecnano: .word 015000000


fileName: .asciz "/dev/mem"
gpioaddr: .word 0x20200


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
        .word 0  @ offset para selecionar o registrador
        .word 18 @ bit offset no registrador selecionado
        .word 6  @ bit offset no registrador set & clr


time500ms:
        .word 0 @ Tempo em segundos
        .word 500000000 @ Tempo em nanossegundos

time10ms:
        .word 0 @ Tempo em segundos
        .word 010000000 @ Tempo em nanossegundos
