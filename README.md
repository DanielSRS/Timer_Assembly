<h1 align="center">Aplicativo de Temporização</h1> 

![GitHub Org's stars](https://img.shields.io/github/stars/DanielSRS?style=social)

O problema propõe desenvolver um aplicativo de temporização para um processador ARMV6L que apresente a contagem num display LCD 16x2, esse display exibirá o tempo em segundos que é pré-definido no código, além disso o app deve ser capaz de aceitar a entrada de 2 botões que tem como papel Start/Pause e Restart que reseta a contagem para o tempo pré-definido. Também é pedido que o código seja modelado pensando em funcionar como uma biblioteca para os problemas futuros, tendo como principais funçoes: 1- Escrever Carácter, 2- Limpar Display e 3- Posicionar cursor linha e coluna.



## :hammer: Compilar e executar 

#### Assemblar um arquivo

```http
  as -o arquivo.o arquivo.s
```

#### Linkar um objeto compilado ou arquivo compactado

```http
  ld -o arquivo arquivo.o
```
#### Executar código

```http
  ./arquivo
```
#### Buildar Makefile

```http
  cd src/
  make all
```

#### Executar Makefile

```http
  cd src/
  make run
```

## :heavy_check_mark: Softwares Utilizados

- Linux

- Nano

- Visual Studio Code

- GCC (GNU Compiler Collection)

- Git

## :computer: Arquitetura do Computador

Sistema Operacional: Raspbian

Arquitetura:  ARMV6L

Ordem de armazenamento de byte: Little Endian (menor para o MSB)

CPU: 1

VID: ARM

Modelo: 7

Nome do Modelo: ARM1176


## :pencil: Instruções utilizadas
CMP reg,#val -  compara o valor em reg com o número val

LDR reg,=val -  coloca o número val no registrador chamado reg.

MOV reg,#val -  coloca o número val no registrador chamado reg.

SVC cond -  instrução causa uma exceção. Isso significa que o modo do processador muda para Supervisor, o CPSR é salvo no modo Supervisor SPSR e a execução ramifica para o vetor SVC.

ADDEQ reg, #val

ADD reg,#val -  adiciona o número val ao conteúdo do registro reg.

STR reg,[dest,#val] - armazena o número em reg no endereço dado por dest + val.

BIC reg1, reg - executa uma operação AND nos bits com os complementos dos bits correspondentes no valor de reg

ORR reg1, reg - executa operações OR bit a bit nos valores em reg

PUSH {reg1,reg2,...} -  copia os registradores da lista reg1,reg2,... no topo da pilha. Apenas registradores de uso geral e lr podem ser enviados.

LSR dst,src,#val -  desloca a representação binária do número em src para a direita por val, mas armazena o resultado em dst.

AND reg,#val -  calcula o booleano e a função do número em reg com val.

POP {reg1,reg2,...} - copia os valores do topo da pilha para a lista de registradores reg1,reg2,.... Somente registradores de uso geral e pc podem ser exibidos.

.LTORG

LSL reg,#val -  desloca a representação binária do número em reg por val lugares para a esquerda.

MOVS reg1, reg - 

BNE cond -  

B cond -  muda o ramo para cond

SUB reg,#val -  subtrai o número val do valor em reg.

BEQ cond -  

BLT cond -  

BGT cond -  

## Testes
1- Contagem do valor pré-definido até 0
Resultado: O Aplicativo funciona perfeitamente e ao chegar ao 0 reseta para o estado de espera do botão Start/Pause

2- Usando Reset
Resultado: O Aplicativo inicia a contagem e ao pressionar o botão Reset age como o esperado chegando no estado de espera do botão Start/Pause

3- Usando Pause/Start
Resultado: O Aplicativo inicia a contagem e ao pressionar o botão Pause/Start ele pausa a contagem e ao clicar novamente retorna a contagem, no entanto, em alguns momentos a depender da velocidade do clique a função pode não funcionar perfeitamente.

4- Usando Reset enquanto pausado
Resultado: O Aplicativo faz a contagem, pausa e ao tentar resetar não funciona exatamente como o programado.

5- Usando Start/Pause e Reset ao mesmo tempo
Resultado: Ao pressionar os 2 botões ao mesmo tempo ele reseta como esperado pelo programa, pois o reset tem prioridade.

## Autores

| [<img src="https://avatars.githubusercontent.com/u/38389307?v=4" width=115><br><sub>Alexandre Silva Caribé</sub>](https://github.com/AlexandreCaribe) |  [<img src="https://avatars.githubusercontent.com/u/39845798?v=4" width=115><br><sub>Daniel Santa Rosa Santos</sub>](https://github.com/DanielSRS) |  [<img src="https://avatars.githubusercontent.com/u/88436328?v=4" width=115><br><sub>Joanderson Santos</sub>](https://github.com/Joanderson90) |
| :---: | :---: | :---: |
