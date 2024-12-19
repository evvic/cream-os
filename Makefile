all:
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

clean:
	rm -rf ./bin/boot.bin

# Append the string in messages.txt to boot.bin then pad that data sector to be 512 bytes
