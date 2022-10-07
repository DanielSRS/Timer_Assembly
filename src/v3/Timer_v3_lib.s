.equ pagelen, 4096
.equ prot_read, 1
.equ prot_write, 2
.equ map_shared, 1
.equ sys_open, 5
.equ sys_map, 192
.equ nano_sleep, 162
.equ level, 52


.global _start

.macro nanoSleep2 time
    LDR R0, =\time
    LDR R1, =\time
    MOV R7, #nano_sleep
    SVC 0
.endm

.macro ClearDisplay
    mov r0, r8
    bl clear_display
.endm

.macro writeDigit value

    mov r0, r8
    mov r1, \value
    bl write_digit

.endm

.macro writeChar value

    mov r0, r8              @ primeiro argumento é o endereço base da GPIO
    mov r1, \value          @ Segundo argumento é o caractere
    bl write_char

.endm

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

.macro InitDisplay
    mov r0, r8
    bl init_display
.endm


_start:
    MapAddressGPIO          @ Mapeia o endereço base da GPIO
    InitDisplay             @ Inicializa o display
    InitDisplay
    MOV R12, #9
    MOV R4, #9

    @ Exibe uma mensagem inicial
    
    writeChar #65  @A
    writeChar #112 @p
    writeChar #101 @e
    writeChar #114 @r
    writeChar #116 @t
    writeChar #101 @e
    writeChar #32  @

    writeChar #111 @o
    writeChar #32  @

    writeChar #66  @B
    writeChar #111 @o
    writeChar #116 @t
    writeChar #97 @ã
    writeChar #111 @o



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
    ClearDisplay
    writeDigit R12
    writeDigit R4



    MOV R6, #13
    verifica_button:
        LDR R9, [R8, #level]

        MOV R11, #1
        LSL R11, #5
        MOV R5, #1
        LSL R5, #26

        AND R10, R5, R9
        cmp R10, #0
        beq restart

        AND R10, R11, R9
        CMP R10, #0
        bleq wait_button_up_pause

        nanoSleep2 time100ms
        SUB R6, R6, #1
        CMP R6, #0
        BNE verifica_button



    SUB R4, R4, #1
    CMP R4, #0

    BGE loop


    SUB R12, R12, #1
    CMP R12, #0

    BLT restart

    MOV R4, #9
    b loop

end:
    MOV R7, #1
    SVC 0


.data

fileName: .asciz "/dev/mem"
gpioaddr: .word 0x20200

time100ms:
    .word 0
    .word 100000000
