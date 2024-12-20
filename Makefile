# -g : adds debugging symbols
FILES = ./build/kernel.asm.o

# setup sets the bash environment variables (for the cross-compiler)
.PHONY: setup
setup:
	/bin/bash -c 'source ./build.sh'

# TODO: make cross-compiler

all: setup ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin of=./bin/os.bin
	dd if=./bin/kernel.bin of=./bin/os.bin
	dd if=/dev/zero bs=512 count=10 of=./bin/os.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./bin/boot.bin: ./src/boot/boot.asm
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

./build/kernel.asm.o: ./src/kernel.asm
	nasm -f elf -g ./src/kernel.asm -o ./build/kernel.asm.o

clean:
	rm -rf ./bin/boot.bin

##
## LEFT OFF AT 18:30/38:38
##
##
