BITS 16
org 0x7C00

start:
    ; Cambiar a modo gráfico 13h (320x200, 256 colores)
    mov ax, 0x0013
    int 0x10

    ; Pantalla de inicio
    call show_start_screen

    ; Esperar cualquier tecla
    call wait_for_key

    ; Limpiar pantalla
    call clear_screen

    ; Mostrar el nombre "Juan" en una posición aleatoria
    call random_position
    mov si, bitmap_Juan
    call draw_bitmap

main_loop:
    ; Leer tecla
    call get_key
    cmp al, 'w'
    je rotate_up
    cmp al, 'a'
    je rotate_left
    cmp al, 's'
    je rotate_down
    cmp al, 'd'
    je rotate_right
    cmp al, 'r'
    je restart
    cmp al, 'q'
    je exit
    jmp main_loop

rotate_left:
    call clear_screen
    call random_position
    mov si, bitmap_Juan_left
    call draw_bitmap
    jmp main_loop

rotate_right:
    call clear_screen
    call random_position
    mov si, bitmap_Juan_right
    call draw_bitmap
    jmp main_loop

rotate_up:
    call clear_screen
    call random_position
    mov si, bitmap_Juan_up
    call draw_bitmap
    jmp main_loop

rotate_down:
    call clear_screen
    call random_position
    mov si, bitmap_Juan_down
    call draw_bitmap
    jmp main_loop

restart:
    ; Reiniciar el sistema (especificar el vector de reinicio del sistema)
    mov ax, 0xFFFF
    mov ds, ax
    mov es, ax
    jmp 0xFFFF:0x0000

exit:
    ; Salir del bootloader (esto puede necesitar soporte adicional del sistema)
    ; No siempre se puede salir del bootloader, pero podrías intentar detener la ejecución
    hlt

show_start_screen:
    ; Cambiar a modo texto 03h (80x25, 16 colores)
    mov ax, 0x0003
    int 0x10

    ; Mostrar "Presiona cualquier tecla para continuar"
    mov si, welcome_msg
    call print_string

    ; Esperar cualquier tecla
    call wait_for_key

    ; Cambiar de nuevo a modo gráfico 13h (320x200, 256 colores)
    mov ax, 0x0013
    int 0x10
    ret

clear_screen:
    ; Limpiar la pantalla completa
    xor di, di
    mov ax, 0xA000
    mov es, ax
    mov al, 0x00
    mov cx, 320 * 200
    rep stosb
    ret

draw_bitmap:
    ; Dibujar el bitmap de 8x8 en la posición almacenada en (cx, dx)
    ; Cada letra ocupa 8x8 píxeles
    mov di, dx           ; Y inicial en la pantalla
    mov ax, 0xA000       ; Dirección base de la memoria de video
    mov es, ax
    push cx              ; Guardar la coordenada X
    push dx              ; Guardar la coordenada Y
    mov bx, di           ; Guardar Y inicial en bx
    mov al, 8            ; Altura de 8 píxeles por letra
.draw_char:
    lodsb                ; Leer fila del bitmap (1 byte = 8 bits)
    push cx              ; Guardar X inicial
    mov cx, 8            ; 8 bits por cada fila
    mov di, bx           ; Restaurar la posición de Y
    add di, dx           ; Sumar coordenada X para avanzar en la fila
    .draw_pixel:
        test al, 128     ; Verificar si el bit más alto es 1
        jz .skip_pixel   ; Si no, no dibujar
        mov [es:di], bl  ; Escribir el píxel en la memoria de video (usar bl como color)
    .skip_pixel:
        shl al, 1        ; Desplazar el siguiente bit a la izquierda
        inc di           ; Moverse a la siguiente posición horizontal
        loop .draw_pixel ; Dibujar los 8 píxeles de la fila
    pop cx               ; Restaurar X inicial
    add bx, 320          ; Pasar a la siguiente fila en la pantalla (320 bytes por fila)
    dec al               ; Altura de la letra
    jnz .draw_char       ; Repetir hasta completar las 8 filas
    pop dx               ; Restaurar Y
    pop cx               ; Restaurar X
    ret
wait_for_key:
    ; Esperar a que se presione una tecla
    mov ah, 0x00
    int 0x16
    ret

get_key:
    ; Leer una tecla del teclado
    mov ah, 0x00
    int 0x16
    ret

random_position:
    ; Generar posición aleatoria para dibujar el bitmap
    mov ah, 0x00
    int 0x1A         ; Llamar a la BIOS para obtener la hora del sistema
    xor cx, cx
    xor dx, dx
    mov al, ch       ; Usar parte de los segundos (ch) para la coordenada Y
    and al, 0xC8     ; Limitar a 0-200 (altura de la pantalla)
    mov dh, al       ; Fila aleatoria
    mov al, cl       ; Usar parte de los minutos (cl) para la coordenada X
    and al, 0xA0     ; Limitar a 0-160 (ancho de la pantalla)
    mov dl, al       ; Columna aleatoria
    ret

print_string:
    ; Imprimir una cadena de caracteres en la pantalla
    mov ah, 0x0E
.next_char:
    lodsb            ; Cargar siguiente byte desde [si]
    cmp al, 0        ; ¿Final de la cadena?
    je .done
    int 0x10         ; Imprimir carácter
    jmp .next_char
.done:
    ret

bitmap_Juan:
    ; Bitmap para la palabra "Juan", cada letra de 8x8 píxeles
    db 0b11111111, 0b10000001, 0b10000001, 0b11111111, 0b10000001, 0b10000001, 0b10000001, 0b11111111  ; J
    db 0b11111111, 0b10000001, 0b10000001, 0b10000001, 0b10000001, 0b10000001, 0b10000001, 0b01111110  ; U
    db 0b00111100, 0b01000010, 0b10000001, 0b10000001, 0b11111111, 0b10000001, 0b10000001, 0b10000001  ; A
    db 0b11111110, 0b10000001, 0b10000001, 0b11111110, 0b10000001, 0b10000001, 0b10000001, 0b11111110  ; N

bitmap_Juan_left:
    ; Bitmap rotado a la izquierda (90°)
    db 0b11111111, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b10000001, 0b10000001, 0b01111110  ; J
    db 0b01111110, 0b01000010, 0b01000010, 0b01000010, 0b01000010, 0b01000010, 0b01000010, 0b01111110  ; U
    db 0b11111111, 0b00010001, 0b00010001, 0b00010001, 0b00010001, 0b00010001, 0b00010001, 0b01111110  ; A
    db 0b01111111, 0b01000001, 0b01000001, 0b01111111, 0b01000001, 0b01000001, 0b01000001, 0b01111111  ; N

bitmap_Juan_right:
    ; Bitmap rotado a la derecha (90°)
    db 0b01111110, 0b10000001, 0b10000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b11111111  ; J
    db 0b01111110, 0b01000010, 0b01000010, 0b01000010, 0b01000010, 0b01000010, 0b01000010, 0b01111110  ; U
    db 0b01111110, 0b10001000, 0b10001000, 0b10001000, 0b10001000, 0b10001000, 0b10001000, 0b01111110  ; A
    db 0b11111111, 0b10000001, 0b10000001, 0b11111111, 0b10000001, 0b10000001, 0b10000001, 0b11111111  ; N

bitmap_Juan_up:
    ; Bitmap rotado hacia arriba (original)
    db 0b11111111, 0b10000001, 0b10000001, 0b11111111, 0b10000001, 0b10000001, 0b10000001, 0b11111111  ; J
    db 0b11111111, 0b10000001, 0b10000001, 0b10000001, 0b10000001, 0b10000001, 0b10000001, 0b01111110  ; U
    db 0b00111100, 0b01000010, 0b10000001, 0b10000001, 0b11111111, 0b10000001, 0b10000001, 0b10000001  ; A
    db 0b11111110, 0b10000001, 0b10000001, 0b11111110, 0b10000001, 0b10000001, 0b10000001, 0b11111110  ; N

bitmap_Juan_down:
    ; Bitmap rotado hacia abajo (180°)
    db 0b01111110, 0b10000001, 0b10000001, 0b00000001, 0b00000001, 0b00000001, 0b00000001, 0b11111111  ; J
    db 0b01111110, 0b01000010, 0b01000010, 0b01000010, 0b01000010, 0b01000010, 0b01000010, 0b01111110  ; U
    db 0b01111110, 0b10001000, 0b10001000, 0b10001000, 0b10001000, 0b10001000, 0b10001000, 0b01111110  ; A
    db 0b11111111, 0b10000001, 0b10000001, 0b11111111, 0b10000001, 0b10000001, 0b10000001, 0b11111111  ; N

welcome_msg db "Presiona cualquier tecla para continuar", 0

times 510-($-$$) db 0  ; Rellenar con ceros hasta 510 bytes
dw 0xAA55              ; Firma de arranque
