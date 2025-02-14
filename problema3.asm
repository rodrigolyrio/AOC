;; PRATICA 3 - DEMONSTRACAO DE LEITURA DE NUMERO

org 100h
   
;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Leitura dos dados  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;


; Imprime mensagem do primeiro numero   
mov dx, offset msg1
mov ah, 9
int 21h

; scan primeiro numero
call scan_num
mov num_x, cx
mov bp, num_x

; Pula Linha:
putc 0Dh
putc 0Ah 

; Imprime mensagem do segundo numero    
mov dx, offset msg3
mov ah, 9
int 21h

; Scan do segundo numero
call scan_num
mov num_y, cx
mov si, num_y

; Pula Linha:
putc 0Dh
putc 0Ah    

; Imprime mensagem do terceiro numero   
mov dx, offset msg5
mov ah, 9
int 21h

; scan terceiro numero
call scan_num
mov num_z, cx
mov di , num_z  
putc 0Dh
putc 0Ah    
      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Impressao dos dados  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
; Imprime mensagem com o primeiro numero  
  
mov dx, offset msg2
mov ah, 9
int 21h 

; Reimprime numero
mov ax, num_x
call print_num
  
                                  
; Pula Linha:
putc 0Dh
putc 0Ah  

; Imprime mensagem com o segundo numero    
mov dx, offset msg4
mov ah, 9
int 21h        


; Reimprime numero
mov ax, num_y
call print_num      


; Pula Linha:
putc 0Dh
putc 0Ah      
 
; Imprime mensagem com o terceiro numero  
mov dx, offset msg6
mov ah, 9
int 21h

; Reimprime numero
mov ax, num_z
call print_num 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Verifica valores >= 1 ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Pula Linha
putc 0Dh
putc 0Ah

;compara se x > 1
mov ax, [num_x]
cmp ax, [one]
jg comp_y
je comp_y
jl menor_1


;compara se y > 1
comp_y:
mov ax, [num_y]
cmp ax, [one]
jg comp_z 
je comp_z
jl menor_1

;compara se z > 1
comp_z:
mov ax, [num_z]
cmp ax, [one]
jg comp_xy_z
jl menor_1
je comp_xy_z

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Soma Valores do Triangulo ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;
soma__xy:
mov ax, [num_x]
add ax, [num_y]
mov [soma_xy], ax
jmp soma__xz

;
soma__xz:
mov ax, [num_x]
add ax, [num_z]
mov [soma_xz], ax
jmp soma__yz

;
soma__yz:
mov ax, [num_y]
add ax, [num_z]
mov [soma_yz], ax
jmp comp_xy_z


;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Forma Triangulo ? ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

comp_xy_z:
mov ax, [soma_xy]
cmp ax, [num_z]
jg  comp_xz_y
jle  nao_formatriangulo

;
comp_xz_y:
mov ax, [soma_xz]
cmp ax, [num_y]
jg  comp_yz_x
jle  nao_formatriangulo


;
comp_yz_x:
mov ax, [soma_yz]
cmp ax, [num_x]
jg  formatriangulo
jle  nao_formatriangulo

;;;;;;;;;;;;;;;;;;;;;;;
;;;        Fim      ;;;
;;;;;;;;;;;;;;;;;;;;;;;

menor_1:
mov dx, offset msg7
mov ah, 9
int 21h
jmp fim

formatriangulo:
mov dx, offset msg8
mov ah, 9
int 21h
jmp fim

nao_formatriangulo:
mov dx, offset msg9
mov ah, 9
int 21h
jmp fim
    
fim:
mov dx, offset msg10
mov ah, 9
int 21h

ret


; Prints:
msg1 db "Digite um numero: $"
msg2 db "primeiro numero digitado: $"  
msg3 db "Digite outro numero: $"  
msg4 db "segundo numero digitado: $"  
msg5 db "Digite mais um numero: $"  
msg6 db "terceiro numero digitado: $"
msg7 db "ERRO, numero menor que 1 $"
msg8 db "Forma um triangulo $"
msg9 db "Nao forma um triangulo $" 
msg10 db "PROGRAMA ENCERRADO $"

; Variaveis
num_x dw ?
num_y dw ?
num_z dw ?
one dw 1
soma_xy dw ?
soma_xz dw ?
soma_yz dw ?

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; these functions are copied from emu8086.inc ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this macro prints a char in AL and advances
; the current cursor position:
PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

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

; this procedure prints number in AX,
; used with PRINT_NUM_UNS to print signed numbers:
PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTC    '0'
        JMP     printed

not_zero:
        ; the check SIGN of AX,
        ; make absolute if it's negative:
        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP

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



ten             DW      10      ; used as multiplier/divider by SCAN_NUM & PRINT_NUM_UNS.
