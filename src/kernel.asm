[BITS 32]           ; all code after this is seen as 32-bit code
                    ; can no longer access the BIOS once in protected mode
global _start

CODE_SEG equ 0x08
DATA_SEG equ 0x10

_start:
    ; setup segment registers
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp    ; set the step pointer to the abse pointer

    ; enable the A20 gate
    in al, 0x92
    or al, 2        ; bitwise OR on al register with 0b00000010
    out 0x92, al

    jmp $

times 512- ($ - $$) db 0
