all: boot.bin

boot.bin: boot.asm
    nasm -f bin -o boot.bin boot.asm

run: boot.bin
    qemu-system-x86_64 -drive file=boot.bin,format=raw

clean:
    rm -f boot.bin
