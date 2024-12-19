# cream-os
Handmade Linux Kernel

## Build real mode boot
```bash
nasm -f bin ./boot.asm -o ./boot.bin
```

## Run boot emulator
```bash
qemu-system-x86_64 -hda ./boot.bin
```

### Attach debugger to emulator
- First just type `gdb` to enter the debugger
- Then set the target
```bash
gdb
target remote | qemu-system-x86_64 -hda ./bin/boot.bin -S -gdb stdio
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
sudo apt install bless
sudo apt install gdb
```

- Using the [Bless hex editor](https://www.thinkpenguin.com/gnu-linux/bless-hex-editor)
```bash
bless ./boot.bin
```
- Use Bless to inspect binaries!
