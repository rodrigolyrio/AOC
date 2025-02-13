org 100h

     
sprint msg1

; Scan numero
call scan_num
mov kmx, cx    
        
; input \n:
putc 0Dh
putc 0Ah   
    
sprint msg2

; Scan numero
call scan_num
mov vx, cx

; input \n:
putc 0Dh
putc 0Ah    

sprint msg3

; Scan numero
call scan_num
mov kmy, cx    
        
; input \n:
putc 0Dh
putc 0Ah   
    
sprint msg4

; Scan numero
call scan_num
mov vy, cx 

; input \n:
putc 0Dh
putc 0Ah 

; input \n:
putc 0Dh
putc 0Ah 

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

cmp si, di
jae infinito

jmp hora_em_hora

Xatras:
mov bx, kmy
mov cx, kmx
mov si, vy
mov di, vx

cmp si, di   ;checa se vai ter ultrapassagem eventualmente
jae infinito



hora_em_hora: ;loop ate X utrapassar o Y
        
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
    lea dx, pos     
    mov ah, 9       
    int 21h         
ENDM
;================================================ 

;================================================
; this macro prints a char in AL and advances
; the current cursor position:
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM      
;================================================

;================================================
; gets the multi-digit SIGNED number from the keyboard,
; and stores the result in CX register:
SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0

next_digit:

        ; get char from keyboard
        ; into AL:
        MOV     AH, 00h
        INT     16h
        ; and print it:
        MOV     AH, 0Eh
        INT     10h

        ; check for MINUS:
        CMP     AL, '-'
        JE      set_minus

        ; check for ENTER key:
        CMP     AL, 0Dh  ; carriage return?
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                   ; 'BACKSPACE' pressed?
        JNE     backspace_checked
        MOV     DX, 0                   ; remove last digit by
        MOV     AX, CX                  ; division:
        DIV     CS:ten                  ; AX = DX:AX / 10 (DX-rem).
        MOV     CX, AX
        PUTC    ' '                     ; clear position.
        PUTC    8                       ; backspace again.
        JMP     next_digit
backspace_checked:


        ; allow only digits:
        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered not digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for next input.       
ok_digit:


        ; multiply CX by 10 (first time the result is zero)
        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten                  ; DX:AX = AX*10
        MOV     CX, AX
        POP     AX

        ; check if the number is too big
        ; (result should be 16 bits)
        CMP     DX, 0
        JNE     too_big

        ; convert from ASCII code:
        SUB     AL, 30h

        ; add AL to CX:
        MOV     AH, 0
        MOV     DX, CX      ; backup, in case the result will be too big.
        ADD     CX, AX
        JC      too_big2    ; jump if the number is too big.

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX      ; restore the backuped value before add.
        MOV     DX, 0       ; DX was zero before backup!
too_big:
        MOV     AX, CX
        DIV     CS:ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
        MOV     CX, AX
        PUTC    8       ; backspace.
        PUTC    ' '     ; clear last entered digit.
        PUTC    8       ; backspace again.        
        JMP     next_digit ; wait for Enter/Backspace.
        
        
stop_input:
        ; check flag:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?       ; used as a flag.
SCAN_NUM        ENDP                                

;================================================

;================================================
; this procedure prints out an unsigned
; number in AX (not just a single digit)
; allowed values are from 0 to 65535 (FFFF)
PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        ; flag to prevent printing zeros before number:
        MOV     CX, 1

        ; (result of "/ 10000" is always less or equal to 9).
        MOV     BX, 10000       ; 2710h - divider.

        ; AX is zero?
        CMP     AX, 0
        JZ      print_zero

begin_print:

        ; check divider (if zero go to end_print):
        CMP     BX,0
        JZ      end_print

        ; avoid printing zeros before number:
        CMP     CX, 0
        JE      calc
        ; if AX<BX then result of DIV will be zero:
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0   ; set flag.

        MOV     DX, 0
        DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

        ; print last digit
        ; AH is always ZERO, so it's ignored
        ADD     AL, 30h    ; convert to ASCII code.
        PUTC    AL


        MOV     AX, DX  ; get remainder from last div.

skip:
        ; calculate BX=BX/10
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PRINT_NUM_UNS   ENDP  
;================================================
      
; used as multiplier/divider by SCAN_NUM & PRINT_NUM_UNS.
ten             DW      10