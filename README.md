# cream-os
Handmade Linux Kernel

## Build OS
```bash
make clean all
```
- Created a `bin/os.bin` object 

## Run boot emulator
```bash
qemu-system-x86_64 -hda ./bin/os.bin
```

### Attach debugger to emulator
- First just type `gdb` to enter the debugger
- Then set the target
```bash
gdb
add-symbol-file ./build/kernelfull.o 0x100000
target remote | qemu-system-x86_64 -hda ./bin/os.bin -S -gdb stdio
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
- Running on Linux x86 Debian system
- In this case I am using WSL
```bash
sudo apt-get upgrade
```

- The table below is all the required packages and what they are for
    - Pick and choose what is needed

| Tool | Packages |
| ---- | -------- |
| Makefile | `sudo apt install make` |
| nasm (Assembly builder) | `sudo apt install nasm` |
| qemu (boot emulator) | `sudo apt install qemu-system-x86` |
| Bless (hex editor) | `sudo apt install bless` |
| GDB (debugger) | `sudo apt install gdb` |


## Cross-Compiler
- This project cannot use GCC to compile C code because this is a custom kernel (no Linux!)
- It will use [osdev opensource cross-compiler](https://wiki.osdev.org/GCC_Cross-Compiler) to compile C

### 1. Preparation
- The cross-compiler by default will create itself in `$HOME/src`
    - Create directory:
```bash
mkdir $HOME/src
```
- Also requires some exports:
```bash
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
```

### 2. Dependencies
```bash
sudo apt install build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libisl-dev
```

### 3. [Bin-utils](https://ftp.gnu.org/gnu/binutils/)
```bash
wget https://ftp.gnu.org/gnu/binutils/binutils-2.35.tar.xz
tar -xvf binutils-2.35.tar.xz -C $HOME/src
cd $HOME/src
mkdir build-binutils
cd build-binutils
../binutils-2.35/configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install
```
- Using version `2.35` for this compiler

### 4. GCC Source
- Find an [available mirror](https://www.gnu.org/software/gcc/mirrors.html) for `gcc-10.2.0.tar.gz`
```bash
wget https://bigsearcher.com/mirrors/gcc/releases/gcc-10.2.0/gcc-10.2.0.tar.gz
tar -xzvf gcc-10.2.0.tar.gz -C $HOME/src/
cd $HOME/src
```
- Using version `gcc-10.2.0`
- To be certain the `$TARGET` value is set, re-run the exports in step 1
```bash
cd $HOME/src
which -- $TARGET-as || echo $TARGET-as is not in the PATH
mkdir build-gcc
cd build-gcc
../gcc-10.2.0/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers --disable-hosted-libstdcxx
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
```

### 5. Use the new compiler
- Verify it is working with
```bash
$HOME/opt/cross/bin/$TARGET-gcc --version
```

- To use the new compiler simply by invoking `$TARGET-gcc`, add `$HOME/opt/cross/bin` to your `$PATH` by typing:
```bash
export PATH="$HOME/opt/cross/bin:$PATH"
```
- Beware there is no standard library



## Binaries
- Using the [Bless hex editor](https://www.thinkpenguin.com/gnu-linux/bless-hex-editor)
```bash
bless ./boot.bin
```
- Use Bless to inspect binaries!
