org 100h

;printa a mensagem que pede para inserir kmx     
sprint msg1

; Scan da distancia kmx
call scan_num
mov kmx, cx    
        
; input \n:
putc 0Dh
putc 0Ah   

;printa a mensagem que pede para inserir vx         
sprint msg2

; Scan da velocidade vx
call scan_num
mov vx, cx

; input \n:
putc 0Dh
putc 0Ah    

;printa a mensagem que pede para inserir kmy     
sprint msg3

; Scan da distancia kmy
call scan_num
mov kmy, cx    
        
; input \n:
putc 0Dh
putc 0Ah   

;printa a mensagem que pede para inserir vy         
sprint msg4

; Scan da velocidad vy
call scan_num
mov vy, cx 

; input \n:
putc 0Dh
putc 0Ah 

; input \n:
putc 0Dh
putc 0Ah 

; imprimindo mensagem por partes por causa das variaveis 
sprint msg5

; Imprime kmx
mov ax, kmx
call print_num_uns

sprint msg6

; Imprime vx
mov ax, vx
call print_num_uns

sprint msg7

; Imprime kmy
mov ax, kmy
call print_num_uns

sprint msg8

; Imprime vy
mov ax, vy
call print_num_uns



;Se o carro Y estiver a frente pula pra Xatras
mov cx, kmx       
cmp kmy, cx
ja Xatras 
 
;else
mov bx, kmx
mov cx, kmy
mov si, vx 
mov di, vy 

cmp si, di     ;checa se vai ter ultrapassagem eventualmente
jae infinito

jmp hora_em_hora

Xatras:        ;Esse jump e para associar os dados de quem esta atras
mov bx, kmy    ;para registradores especificos e os dados de quem esta 
mov cx, kmx    ;a frente para outros registradores para facilitar o loop
mov si, vy     
mov di, vx

cmp si, di     ;checa se vai ter ultrapassagem eventualmente
jae infinito



hora_em_hora:  ;loop ate a ultrapassagem
        
; input \n:
putc 0Dh
putc 0Ah

sprint msghora

; Imprime hora
mov ax, hora
call print_num_uns
    
sprint posicao1
        
; Imprime posicao x
mov ax, kmx
call print_num_uns
    
sprint posicao2

; Imprime posicao y
mov ax, kmy
call print_num_uns 

;Adicoes
add hora, 1

mov ax, vy
add kmy, ax 
jo overflow     ; Se houve overflow, pula para "overflow"

mov ax, vx
add kmx, ax
jo overflow     ; Se houve overflow, pula para "overflow"

add cx, di
jo overflow     ; Se houve overflow, pula para "overflow"

add bx, si 
jo overflow     ; Se houve overflow, pula para "overflow"

; while bx > dx              
cmp bx, cx
jae hora_em_hora  

; input \n:
putc 0Dh
putc 0Ah

sprint msghora

; Imprime hora
mov ax, hora
call print_num_uns
    
sprint posicao1
        
; Imprime posicao x
mov ax, kmx
call print_num_uns
    
sprint posicao2

; Imprime posicao y
mov ax, kmy
call print_num_uns 
 
 
; input \n:
putc 0Dh
putc 0Ah

mov ax,vy
cmp vx,ax
jb y_ultrapassa

sprint msg9 

jmp y_naopassa 
y_ultrapassa:
sprint msg10

y_naopassa:
; Imprime numero
mov ax, hora
call print_num_uns

                   
sprint msg11

; Imprime numero
mov ax, bx
call print_num_uns



jmp sem_erro ; separa a parte do overflow do codigo

overflow:

; input \n:
putc 0Dh
putc 0Ah 
sprint msgO ;printa na tela se deu erro e logo acaba o programa 

  
  
jmp sem_erro ; Separa a parte do infinito do codigo

infinito:
sprint msgi


sem_erro:

ret  



; Prints:
msg1 db 'Digite a posi', 135, 198, 'o inicial do carro X (kmx): $'

msg2 db "Digite a velocidade do carro X (vx): $"
msg3 db 'Digite a posi', 135, 198, 'o inicial do carro Y (kmy): $'
msg4 db "Digite a velocidade do carro Y (vy): $" 

msg5 db "kmx = $"
msg6 db " | vx = $"
msg7 db " | kmy = $" 
msg8 db " | vy = $" 

msg9 db "Carro X ultrapassou o carro Y na hora $"
msg10 db "Carro Y ultrapassou o carro X na hora $"
msg11 db " apos o KM $"

msgi db 'Nunca haver', 160,' ultrapassagem! $'
msgO db "Erro de overflow! $"

msghora db "Hora $"
posicao1 db ": Carro X em $"
posicao2 db " e Carro Y em $"   

; Variaveis:
hora dw 0
kmx dw ?
vx  dw ?                                         
kmy dw ?
vy  dw ?  
                         

;================================================
; coloca o print do int21h em um macro
SPRINT MACRO pos
    lea dx, pos      ;Pega o enderenco da string para fazer a interrupcao
    mov ah, 9        ;21h-9
    int 21h         
ENDM
;================================================ 

;================================================
; Macro que printa um caracter usando a interrupcao 10h
; Preciso para escrever o equivalente de '\n' 
PUTC    MACRO   caracter
        PUSH    AX
        MOV     AL, caracter
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM      
;================================================

;================================================
; Funcao base do emu8086.inc para ler como input um numero com sinal
; salva o numero no registrador CX:
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reseta a flag :
        MOV     CS:make_minus, 0

next_digit:

        ; pega um caracter digitado
        ; coloca no AL:
        MOV     AH, 00h
        INT     16h
        ; e imprime pro usuario ver o proprio digito:
        MOV     AH, 0Eh
        INT     10h

        ; checa se o caracter e de sinal negativo:
        CMP     AL, '-'
        JE      set_minus

        ; checa se o usuario deu enter:
        CMP     AL, 0Dh  
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                ; Detecta se 'backspace' foi apertado
        JNE     backspace_checked    ; Se nao for ele pula essa etapa
        MOV     DX, 0                ; Prepara DX para divisao
        MOV     AX, CX               ; Pega o caracter anterior
        DIV     CS:ten               ; E realizada uma divisao por 10 pois
        MOV     CX, AX               ; divisao por 10 remove o ultimo numero
        PUTC    ' '                  ; Limpa a area do caracter anterior
        PUTC    8                    ; Backspace
        JMP     next_digit           ; Espera o proximo digito
backspace_checked:


        ; analisa se o caracter e um numero:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit  ;se nao for um numero ele e removido
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace
        PUTC    ' '     ; limpa o caracter que nao e um numero
        PUTC    8       ; backspace        
        JMP     next_digit ; Espera o proximo digito       
ok_digit:


        ; Multiplica CX por 10 (a primeira vez que o resultado for 0)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  
        MOV     CX, AX
        POP     AX

        ; Checa se for muito grande o numero
        ; pois o resultado tem que ser 16 bits
        CMP     DX, 0
        JNE     too_big

        ; Converte de ASCII:
        SUB     AL, 30h


        MOV     AH, 0
        MOV     DX, CX      ; Salva antes se o numero ficar muito grande
        ADD     CX, AX
        JC      too_big2    ; Checa se o numero for muito grande

        JMP     next_digit  ; Espera o proximo digito

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit  ; Espera o proximo digito

too_big2:
        MOV     CX, DX      ; Restaura para o numero salva antes de ser 
        MOV     DX, 0       ; muito grande e limpa o save
too_big:
        MOV     AX, CX
        DIV     CS:ten      ; Reverte o processo de multiplicar por 10
        MOV     CX, AX
        PUTC    8           ; Backspace
        PUTC    ' '         ; Limpa o digito que deixou grande de mais
        PUTC    8           ; backspace        
        JMP     next_digit  ; Espera o proximo digito
        
        
stop_input:
        ; Checa a flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?   ; usado de flag.
SCAN_NUM        ENDP                                

;================================================

;================================================
; Printa um numero em AX sem sinal 
; valores aceitos de 0 a 65535 (FFFF)
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag para impedir printar 0 a esquerda
        MOV     CX, 1

        ; recebe o valorr 10000 para fazer a divisao de cada casa decimal
        MOV     BX, 10000       

        ; Se AX for 0
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; Checa se ja passou por todas as casas decimais
        CMP     BX,0
        JZ      end_print

        ; Evita printar 0 a esquerda
        CMP     CX, 0
        JE      calc
        ; Se AX<BX o resultado da divisao vai ser 0
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; Declara a flag.

        MOV     DX, 0
        DIV     BX      ; AX recebe a divisao e DX recebe o resto.

        
        ; AH sempre e 0 nesse caso
        ADD     AL, 30h    ; Converte pra ASCII.
        PUTC    AL         ; Printa o ultimo digito


        MOV     AX, DX  ; Salva o resto da ultima divisao

skip:
        ; Vai para a proxima casa decimal ao dividir BX por 10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  
        MOV     BX, AX
        POP     AX

        JMP     begin_print ;vai para o proximo digito a ser printado
        
print_zero:
        PUTC    '0' ; Serve apenas para se o numero recebido for 0
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_NUM_UNS   ENDP  
;================================================
      

ten             DW      10 ;usado por SCAN_NUM e PRINT_NUM_UNS como divisor