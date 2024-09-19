BITS 16

org 0x7C00  ; dirección donde se carga el bootloader

start:
    ; Limpieza de pantalla
    mov ax, 0x0600   ; Función BIOS para limpiar pantalla
    mov bh, 0x07     ; Atributo de texto: fondo negro, texto gris claro
    mov cx, 0x0000   ; Coordenada inicial (superior izquierda)
    mov dx, 0x184F   ; Coordenada final (inferior derecha)
    int 0x10         ; Llamada BIOS para manipulación de video

    ; Mostrar el mensaje de bienvenida
    mov si, welcome_msg
    call print_string

    ; Esperar confirmación del usuario (pulsar cualquier tecla)
    call wait_for_key

    ; Limpiar pantalla nuevamente
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10

    ; Mostrar el nombre en una posición aleatoria
    call random_position
    mov si, student_name
    call print_string

main_loop:
    ; Esperar entrada del teclado
    call get_key

    ; Comprobar si es una flecha
    cmp al, 'a'  ; Flecha izquierda
    je rotate_left
    cmp al, 'd'  ; Flecha derecha
    je rotate_right
    cmp al, 's'  ; Flecha abajo
    je rotate_down
    cmp al, 'w'  ; Flecha arriba
    je rotate_up
    cmp al, 'r'  ; Comparar con 'R' para reiniciar
    je restart
    cmp al, 'q'  ; Comparar con 'Q' para salir
    je quit

    jmp main_loop

rotate_left:
    ; Limpiar la pantalla y rotar el texto a la izquierda
    call clear_screen
    call random_position
    mov si, rotated_name_left
    call print_string
    jmp main_loop

rotate_right:
    ; Limpiar la pantalla y rotar el texto a la derecha
    call clear_screen
    call random_position
    mov si, rotated_name_right
    call print_string
    jmp main_loop

rotate_down:
    ; Limpiar la pantalla y rotar el texto hacia abajo
    call clear_screen
    call random_position
    mov si, rotated_name_down
    call print_string
    jmp main_loop

rotate_up:
    ; Limpiar la pantalla y rotar el texto hacia arriba
    call clear_screen
    call random_position
    mov si, rotated_name_up
    call print_string
    jmp main_loop

restart:
    ; Reiniciar el bootloader volviendo al inicio del código
    jmp start

quit:
    ; Reiniciar el sistema
    mov ax, 0x4C00
    int 0x21

wait_for_key:
    ; Esperar a que se presione una tecla
    mov ah, 0x00
    int 0x16
    ret

get_key:
    ; Obtener la tecla presionada
    mov ah, 0x00
    int 0x16
    ret

random_position:
    ; Obtener una semilla del reloj del sistema para generar una posición aleatoria
    mov ah, 0x00
    int 0x1A        ; Interrupción del reloj del sistema
    mov al, ch       ; Obtener la parte de los segundos (ch)
    and al, 0x1F     ; Limitar a un rango de 32 para filas (0-24)
    mov dh, al       ; Fila aleatoria

    mov al, cl       ; Obtener la parte de los minutos (cl)
    and al, 0x3F     ; Limitar a un rango de 64 para columnas (0-79)
    mov dl, al       ; Columna aleatoria

    mov ah, 0x02     ; Función para mover el cursor
    mov bh, 0x00     ; Página 0
    int 0x10
    ret

print_string:
    ; Imprimir cadena de caracteres
    mov ah, 0x0E
.next_char:
    lodsb             ; Cargar siguiente byte desde [si]
    cmp al, 0         ; ¿Final de la cadena?
    je .done
    int 0x10          ; Imprimir carácter
    jmp .next_char
.done:
    ret

clear_screen:
    ; Limpiar la pantalla completa
    mov ax, 0x0600   ; Función BIOS para limpiar pantalla
    mov bh, 0x07     ; Atributo de texto: fondo negro, texto gris claro
    mov cx, 0x0000   ; Coordenada inicial (superior izquierda)
    mov dx, 0x184F   ; Coordenada final (inferior derecha)
    int 0x10
    ret

print_rotated_left:
    ; Imprimir el nombre rotado a la izquierda
    mov si, rotated_name_left
    call print_string
    ret

print_rotated_right:
    ; Imprimir el nombre rotado a la derecha
    mov si, rotated_name_right
    call print_string
    ret

print_rotated_down:
    ; Imprimir el nombre rotado hacia abajo
    mov si, rotated_name_down
    call print_string
    ret

print_rotated_up:
    ; Imprimir el nombre rotado hacia arriba
    mov si, rotated_name_up
    call print_string
    ret

student_name db "Juan", 0   ; Nombre del estudiante
rotated_name_left db "nauJ", 0
rotated_name_right db "Juan", 0
rotated_name_down db "ʌnauJ", 0  ; Esto es solo un ejemplo, usar letras invertidas
rotated_name_up db "uʌanJ", 0    ; Similar al anterior

welcome_msg db "Welcome to My Name!", 0

times 510-($-$$) db 0  ; Llenar con ceros hasta 510 bytes
dw 0xAA55              ; Firma de arranque
