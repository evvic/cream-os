# cream-os
Handmade Linux Kernel

## Build Real Mode Boot
```bash
nasm -f bin ./boot.asm -o ./boot.bin
```

## Run Boot Emulator
```bash
qemu-system-x86_64 -hda ./boot.bin
```

### Check the built binary
```bash
ndisasm ./boot.bin 
00000000  B40E              mov ah,0xe
00000002  B041              mov al,0x41
00000004  BB0000            mov bx,0x0
00000007  CD10              int 0x10
00000009  EBFE              jmp short 0x9
0000000B  0000              add [bx+si],al
...
```

# References

# Setup
- Running on Linux x86 system
- In this case I am using WSL

```bash
sudo apt-get upgrade
sudo apt install make
sudo apt install nasm
sudo apt install qemu-system-x86
```
