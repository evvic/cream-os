all:
	nasm -f bin ./boot.asm -o ./boot.bin
	dd if=./message.txt >> ./boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./boot.bin

# Append the string in messages.txt to boot.bin then pad that data sector to be 512 bytes
