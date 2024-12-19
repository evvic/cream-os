ORG 0x7c00          ; origin, offset is 0x7c0
BITS 16             ; ensure assmebler will only assemble instructions into 16-bit code

; Calculate 0x8 and 0x10 offsets
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_code - gdt_start

_start:
    jmp short start ; jumps to start label
    nop             ; no operation required for BIOS block

times 33 db 0       ; after the short jump fill in 33 bytes to cover the BIOS parameter block

start:
    jmp 0:step2     ; the code segment will change to 0 from the jump

step2:
    ; Initalize segment values
    cli             ; clear (disable) interrupts durign critical operations
    mov ax, 0x00    ; must put 0x00 into ax first (processor requirement)
    mov ds, ax      ; data segment
    mov es, ax      ; extra segment
    mov ss, ax      ; set the stack segment to 0
    mov sp, 0x7c00  ; stack pointer to 0x7c00
    sti             ; enables interrupts

.load_protected:    ; pause inte3rrupts and Load Global Descriptor Table
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32

; GDT
gdt_start:

gdt_null:
    dd 0x0
    dd 0x0

; offset 0x8
gdt_code:           ; CS should point to this
    dw 0xffff       ; segment limit first 0-15 bits
    dw 0            ; base first 0-15 bits 
    db 0            ; base 16-23 bits
    db 0x9a         ; access byte
    db 11001111b    ; high 4 bit flags and low 4 bit flags
    db 0            ; base 24-31 bits

; offset 0x10
gdt_data:           ; link to DS, SS, ES, FS, GS
    dw 0xffff       ; segment limit first 0-15 bits
    dw 0            ; base first 0-15 bits 
    db 0            ; base 16-23 bits
    db 0x92         ; access byte
    db 11001111b    ; high 4 bit flags and low 4 bit flags
    db 0 

gdt_end:

gdt_descriptor:     ; give the size of the descriptor
    dw gdt_end - gdt_start-1
    dd gdt_start    ; offset

[BITS 32]           ; all code after this is seen as 32-bit code
                    ; can no longer access the BIOS once in protected mode
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp    ; set the step pointer to the abse pointer
    jmp $

times 510- ($ - $$) db 0
dw 0xAA55

