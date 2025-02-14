;; PRATICA 3 - DEMONSTRACAO DE LEITURA DE NUMERO

org 100h


; Imprime mensagem pedindo os lados do triangulo  
SPRINT msg1

; Pula Linha:
putc 0Dh
putc 0Ah

; scan X
call scan_num
mov num_x, cx

; Pula Linha:
putc 0Dh
putc 0Ah 

;compara se x > 1
mov ax, num_x
cmp ax, 1
jl menor_1

; Scan Y
call scan_num
mov num_y, cx  

; Pula Linha:
putc 0Dh
putc 0Ah    

;compara se y > 1
mov ax, num_y
cmp ax, 1
jl menor_1 

; scan Z
call scan_num
mov num_z, cx  

; Pula Linha: 
putc 0Dh
putc 0Ah    

;compara se z > 1
comp_z:
mov ax, num_z
cmp ax, 1
jl menor_1  
       

jmp maior_1  ;Pula o print de erro de uma variavel ser menor que 1 

 
menor_1:     
sprint msg2  ;printa que deu erro

ret 

maior_1:
; Parametros para o procedimento FormaTriangulo
mov bp, num_x    
mov dx, num_y
mov di, num_z
; chama o procedimento que salva em AX 1(True) ou 0(False) 
call FormaTriangulo

cmp ax, 1 
jne false
 
 
; Se chegou aqui printa que e triangulo
SPRINT msg3 
mov ax, num_x
call PRINT_NUM_UNS 
 
SPRINT msg4
mov ax, num_y
call PRINT_NUM_UNS

SPRINT msg5
mov ax, num_z
call PRINT_NUM_UNS

SPRINT msg6

jmp fim


false:
; Printa que nao e um triangulo
SPRINT msg7 
mov ax, num_x
call PRINT_NUM_UNS
 
SPRINT msg8
mov ax, num_y
call PRINT_NUM_UNS

SPRINT msg9
mov ax, num_z
call PRINT_NUM_UNS

SPRINT msg10

    
fim:

ret


; Prints:
msg1 db 'Digite os 3 lados do tri',131, 'ngulo (os valores devem ser >= 1) $'   

msg2 db 'ERRO. Os valores devem ser maiores ou iguais a 1! $'
msgO db 'ERRO de overflow!$' 

msg3 db 'Os valores $'
msg4 db ', $'
msg5 db ' e $'
msg6 db ' formam um tri',131,'ngulo $' 

msg7 db 'Os valores $'
msg8 db ', $'
msg9 db ' e $'
msg10 db ' n',198,'o formam um tri',131,'ngulo $'
 

; Variaveis
num_x dw ?
num_y dw ?
num_z dw ?


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

FormaTriangulo  PROC    NEAR                     
        ;Soma Valores do Triangulo
        
        
        soma__xy:
        mov ax, bp
        add ax, dx
        jo overflow  ; Checa se deu overflow
        mov bx, ax
        
        
        mov ax, bp
        add ax, di 
        jo overflow  ; Checa se deu overflow
        mov cx, ax
        
        
        mov ax, dx
        add ax, di
        jo overflow  ; Checa se deu overflow
        mov si, ax
        
        
        
        jmp sem_erro ; Separa o teste de overflow do processamento
        
        overflow:    ; ERRO de overflow
        
        ; input \n:
        putc 0Dh
        putc 0Ah 
        sprint msgO  ;printa na tela se deu erro e logo acaba o programa
        
        sem_erro:
        
        ;Compara a soma com o lado restante
        
        mov ax, bx
        cmp ax, di
        jle  nao_formatriangulo
        
        
        mov ax, cx
        cmp ax, dx
        jle  nao_formatriangulo
        
        
        mov ax, si
        cmp ax, bp
        jle  nao_formatriangulo

        
        ; Se chegou aqui e triangulo
        MOV AX, 1
        RET
        
        
        nao_formatriangulo:
        ; Printa que nao e um triangulo    
        
        MOV AX, 0
        RET
        
FormaTriangulo ENDP        
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