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

   MapAddressGPIO
   SetPinsDisplayOut
   ClearDisplay
   FunctionSet
   FunctionSet
   FunctionSet
   OnDisplay
   EntrySetMode

.endm


_start:
    InitDisplay
    InitDisplay

restart:
    ClearDisplay
    MOV R12, #3
    MOV R4, #0

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
     .word 0
     .word 18
     .word 6


time500ms:
    .word 0
    .word 500000000



time100ms:
    .word 0
    .word 100000000
