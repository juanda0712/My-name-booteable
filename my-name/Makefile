# Makefile para el bootloader en ensamblador x86

# Archivo de salida
OUTPUT = boot.bin

# Compilador de ensamblador
AS = nasm
ASFLAGS = -f bin

# Emulador
EMU = qemu-system-x86_64

# Reglas de construcción
all: $(OUTPUT)

$(OUTPUT): boot.asm
	$(AS) $(ASFLAGS) -o $(OUTPUT) boot.asm

run: $(OUTPUT)
	$(EMU) -drive file=$(OUTPUT),format=raw

clean:
	rm -f $(OUTPUT)

# Regla para limpiar todos los archivos generados
distclean: clean
	rm -f *~
	rm -f *.o
	rm -f *.map

.PHONY: all run clean distclean
