org 100h

mov dx, offset msg1
mov ah, 9
int 21h 
;call ler_valor / achar a funcao de ler num
;mov [a] registradorx / por o registrador usado na funcao

mov dx, offset msg2
mov ah, 9
int 21h
;call ler_valor / achar a funcao de ler num
;mov [b] registradorx / por o registrador usado na funcao

mov dx, offset msg3
mov ah, 9
int 21h
;call ler_valor / achar a funcao de ler num
;mov [c] registradorx / por o registrador usado na funcao

ret

msg1 dw "digite o valor de a: $"
msg2 dw "digite o valor de b: $"
msg3 dw "digite o valor de c: $"
msg4 dw "soma dos dois maiores: $" 

; variaveis

a dw ?
b dw ?
c dw ?
