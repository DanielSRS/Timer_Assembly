@Timer regressivo que começa com o valor inicial 30 e exibe a contagem no display.
@Este código foi testado em uma Raspberry pi zero W e um display LCD HD44780U.
@Autores : Joanderson Santos, Daniel Santa Rosa e Alexandre Silva Caribé 


@Definição das constantes
.equ pagelen, 4096              @ Tamanho da pagina de memoria paginada
.equ setregoffset, 28 
.equ clrregoffset, 40 
.equ prot_read, 1  
.equ prot_write, 2  
.equ map_shared, 1  
.equ sys_open, 5                @ Numero da syscall para abrir arquivo
.equ sys_map, 192  
.equ nano_sleep, 162						@ Numero da syscall para nanosleep 
.equ level, 52                  @ Offset para o registrador de niveis da GPIO
.equ off, 0
.equ on, 1

.global _start

@Faz a chamada para o serviço de nanosleep do Linux
@Passa a referência para o timespec nos registradores r0 e r1.
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


@Faz o mapeamento da memória referente ao endereço base da GPIO
@e move esse valor mapeado para o R8.
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


@Seta um valor para um determinado pino da Gpio
.macro SetGpioValue pin, value

	@Obtém os valores passados por parâmetro

  MOV R1, \value
  LDR R3, =\pin

	@Verifica se o valor a ser enviado para o pino é 0 ou 1
	@Se for zero utiliza o clrregoffset para selecionar o registrador clear (GPCLR0)
	@Caso contrário utiliza o setregoffset para selecionar o registrador set (GPSET0)

  MOV R2, R8    
  CMP R1,#0    
  ADDEQ R2, #clrregoffset 
  CMP R1,#1    
  ADDEQ R2, #setregoffset 

	@Manda o valor do pino no seu bit correspondente para o registrador selecionado acima.

  MOV R0, #1    
  ADD R3, #8    
  LDR R3, [R3]   
  LSL R0, R3    
  STR R0, [R2]   
.endm

@Seta um determinado pino da Gpio como output
.macro GPIODirectionOut pin

  LDR R2, =\pin      @Armazena o endereço referente ao pino que foi passado por parâmetro em R2
  LDR R2, [R2]       @Armazena o valor do pino citado acima
  LDR R1, [R8, R2]   @Armazena em R1 o endereço da GPIO base + offset referente ao pino
  LDR R3, =\pin 	   @Armazena o endereço referente ao pino que foi passado por parâmetro em R3 
  ADD R3, #4  	   
  LDR R3, [R3]        
  MOV R0, #0b111    @Move para R0 o valor b111 para realizar o mascaramento de bits
  LSL R0, R3  
  BIC R1, R0        @Faz o clear de 3 bits
  MOV R0, #1  
  LSL R0, R3      
  ORR R1, R0   
  STR R1, [R8, R2]  @Armazena o valor de R1 com o valor do bit correspondente ao número do pino no endereço base 
.endm                 @da GPIO

@Seta os pinos referentes ao display como output
.macro SetPinsDisplayOut

  GPIODirectionOut pinEN
  GPIODirectionOut pinRS
  GPIODirectionOut pinD7
  GPIODirectionOut pinD6
  GPIODirectionOut pinD5
  GPIODirectionOut pinD4
  
.endm



@Seta o display para operar em modo de 4 bits
.macro FunctionSet

  SetGpioValue pinRS, #off
  SetGpioValue pinD7, #off
  SetGpioValue pinD6, #off
  SetGpioValue pinD5, #on
  SetGpioValue pinD4, #off
 
  SetEnable
 
.endm

@Realiza um pulso de clock para o pino referente ao enable do display
.macro SetEnable

  SetGpioValue pinEN, #off
  nanoSleep 
  SetGpioValue pinEN, #on
  nanoSleep 
  SetGpioValue pinEN, #off
  
.endm

@Liga o display e pisca o cursor
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



@Limpa todos os caracteres do display
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


@Seta o display em mode de entrada
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

@Seta os 4 primeiros bits mais significativos referente a um número
@com base na tabela ASCII
@0011
.macro SetUpperBitsDefaultNumber

  SetGpioValue pinRS, #on
  SetGpioValue pinD7, #off
  SetGpioValue pinD6, #off
  SetGpioValue pinD5, #on
  SetGpioValue pinD4, #on
  SetEnable
  
.endm

@Escreve um determinado número no display
.macro writeDigit value

  SetUpperBitsDefaultNumber
  SetGpioValue pinRS, #on   @Manda nível lógico alto para o pino RS referente ao display
							  @indicando que ele irá receber um caractere


	@O código a seguir obtém os 4 bits menos significativos do valor numérico a ser
	@exibido no display, e seta cada bit referente ao pino correspondente do display

	@Ex: Obtendo o 4º bit menos significativo do valor 9
	@MOV R2,#1 -> 0000..., 0001
  @LSL R2,#3 -> 0000..., 1000
  @AND R1,R2,\value
	@0000..., 1000
	@0000..., 1001
	@0000..., 1000

  @LSR R1,#3 ->0000..., 0001
  @SetGpioValue pinD7, R1 -> pinD7 = 1



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

@Escreve um caractere qualquer no display, dado seu valor, este referente a tabela ASCII
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

@Inicia o display
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
  @ Inicializa o display
  InitDisplay
	InitDisplay

@Faz o reinício da contagem
restart:
	ClearDisplay

	@ Inicia o timer em 30 segundos
  MOV R12, #3             @ Digito da dezena
  MOV R4, #0              @ Digito da unidade

	@ Exibe uma mensagem inicial

  writeChar #65 @A
  writeChar #112 @p
  writeChar #101 @e
  writeChar #114 @r
  writeChar #116 @t 
  writeChar #101 @e
  writeChar #32 @

  writeChar #111 @o
  writeChar #32 @

  writeChar #66 @B
  writeChar #111 @o
  writeChar #116 @t
  writeChar #97  @a 
  writeChar #111 @o

  .ltorg


@Espera o botão ser pressionado para iniciar o timer
wait_button_start:
  LDR R9, [R8, #level]
  MOV R11, #1
  LSL R11, #5
  AND R10, R11, R9
  cmp R10, #0

  bne wait_button_start
  nanoSleep2 time100ms 
  b wait_button_up_start

@Espera o botão sair de nível lógico baixo após ser pressionado para iniciar a contagem
wait_button_up_start:
  LDR R9, [R8, #level]
  MOV R11, #1
  LSL R11, #5
  AND R10, R11, R9
  cmp R10, #0
  beq wait_button_up_start
  b loop

@Espera o botão sair de nível lógico baixo após ser pressionado para pausar a contagem
wait_button_up_pause:
  LDR R9, [R8, #level]
  MOV R11, #1
  LSL R11, #5
  AND R10, R11, R9
  cmp R10, #0
  beq wait_button_up_pause
  b wait_button_start

@Loop para realizar a contagem e escrever no display   
loop:
  ClearDisplay            @ Limpa o conteúdo do display
  writeDigit R12          @ Escreve o digito de dezena
  writeDigit R4           @ Escreve o digito de unidade

  

	@O código a seguir faz a leitura dos botões de reinício da contagem e de pausa
	@isso a cada 100ms, 13 vezes seguidas, totalizando 1s e 300ms

  MOV R6, #13
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


	@Subtrai o valor da unidade e verificar se é maior ou igual a zero, se sim
	@continua a contagem
  SUB R4, R4, #1
  CMP R4, #0								@ Verifica se a unidade de segundos foi zerada
  
  BGE loop                	@ Se falso volta para inicio do loop e atualiza
                            @ as informações exibidas

	@Subtrai o valor da dezena e verifica se é menor que zero, se sim reinicia a contagem
	@caso contrário adiciona 9 a unidade e continua a contagem

  SUB R12, R12, #1
  CMP R12, #0

  BLT restart               @ Se terminado, reinicia contador

  MOV R4, #9                @ Se não, reseta o digito de unidade para 9 segundos
  b loop                    @ e continua contagem




@ Definição das variáveis
.data

@Definição dos valores referentes aos times
time1s:
  .word 1
  .word 000000000

time100ms:
  .word 0
  .word 100000000

timespecsec: .word 0
timespecnano: .word 015000000

@Definição do nome do arquivo para realizar o mapeamento da memória
@e o endereço base da GPIO
fileName: .asciz "/dev/mem"
gpioaddr: .word 0x20200

@Definição dos valores dos pinos referentes ao display

pinD4:       @Valor do pino na GPIO -> 12
  .word 4  @Offset para selecionar o registrador de função (GPFSEL1)
  .word 6  @Bit offset referente ao pino no registrador selecionado
  .word 12 @Bit offset referente ao pino no registrador set e clr (GPSET0) e (GPCLR0)

pinD5: @Valor do pino na GPIO -> 16
  .word 4 
  .word 18 
  .word 16 

pinD6: @Valor do pino na GPIO -> 20
  .word 8 
  .word 0 
  .word 20 

pinD7: @Valor do pino na GPIO -> 21
  .word 8 
  .word 3 
  .word 21 

pinRS: @Valor do pino na GPIO -> 25
  .word 8 
  .word 15 
  .word 25

pinEN: @Valor do pino na GPIO -> 1
  .word 0 
  .word 3 
  .word 1
