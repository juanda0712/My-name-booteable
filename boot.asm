; boot.asm
[ORG 0x7C00]        ; Dirección donde se carga el bootloader en memoria

; Mostrar un mensaje en pantalla
mov ah, 0x0E        ; Función para mostrar carácter en modo texto
mov al, 'H'         ; Carácter a mostrar
int 0x10            ; Interrupción de video

mov al, 'e'
int 0x10

mov al, 'l'
int 0x10

mov al, 'l'
int 0x10

mov al, 'o'
int 0x10

; Bucle infinito
jmp $

; Asegúrate de que el tamaño del bootloader es 512 bytes
times 510 - ($ - $$) db 0
dw 0xAA55           ; Firma de arranque (boot signature)
