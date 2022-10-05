<h1 align="center">Aplicativo de Temporização</h1> 

![GitHub Org's stars](https://img.shields.io/github/stars/DanielSRS?style=social)

O problema propõe desenvolver um aplicativo de temporização que apresente a contagem num display LCD



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

## Autores

| [<img src="https://avatars.githubusercontent.com/u/38389307?v=4" width=115><br><sub>Alexandre Silva Caribé</sub>](https://github.com/AlexandreCaribe) |  [<img src="https://avatars.githubusercontent.com/u/39845798?v=4" width=115><br><sub>Daniel Santa Rosa Santos</sub>](https://github.com/DanielSRS) |  [<img src="https://avatars.githubusercontent.com/u/88436328?v=4" width=115><br><sub>Joanderson Santos</sub>](https://github.com/Joanderson90) |
| :---: | :---: | :---: |