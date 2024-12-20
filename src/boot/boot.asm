ORG 0x7c00          ; origin, offset is 0x7c0
[BITS 16]           ; ensure assmebler will only assemble instructions into 16-bit code

; Calculate 0x8 and 0x10 offsets
CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

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
    jmp $

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

[BITS 32]
load32:             ; load kernel into memory and jump to it
    mov eax, 1      ; starting sector to load the kernel from (sector 0 has the bootloader)
    mov ecx, 100    ; size of kernel (number of sectors)
    mov edi, 0x0100000  ; the address we want to load kernel into
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:       ; simple driver
    mov ebx, eax    ; backup the LBA

    ; send the highest 8 bits of the LBA  to hard disk controller
    shr eax, 24     ; shift eax register 24 bits to the right (eax will then contain the highest 8 bits)
    or eax, 0xE0    ; select the master drive (magic number)
    mov dx, 0x1F6   ; port expected to write the 8 bits to
    out dx, al

    ; send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al

    ; send more bits of the LBA to the controller
    mov eax, ebx    ; restoring the backup LBA
    mov dx, 0x1F3
    out dx, al

    ; send a few more bits to the controller
    mov dx, 0x1F4
    mov eax, ebx    ; restore the backup of LBA
    shr eax, 8
    out dx, al

    ; send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16     ; shift eax register to the right by 16 bits
    out dx, al

    mov dx, 0x1F7
    mov al, 0x20
    out dx, al

    ; read all sectors into memory
.next_sector:
    push ecx        ; push ecx to stack

; checking if we need to read
.try_again:
    mov dx, 0x1F7
    in al, dx
    test al, 8      ; magic number
    jz .try_again   ; try again until it doesn't fail

    ; need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0   ; move the port address (magic number) into dx
    rep insw        ; reads a word from the io port specified in DX into memory location specified in ES:DI (edi)
    pop ecx         ; restore sector number (from push)
    loop .next_sector
    ; end of reading sectors from memory

    ret


times 510- ($ - $$) db 0
dw 0xAA55

