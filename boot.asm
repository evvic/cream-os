ORG 0               ; origin
BITS 16             ; ensure assmebler will only assemble instructions into 16-bit code

_start:
    jmp short start ; jumps to start label
    nop             ; no operation required for BIOS block

times 33 db 0       ; after the short jump fill in 33 bytes to cover the BIOS parameter block

start:
    jmp 0x7c0:step2 ; replace the code segment register with 0x7c0

step2:
    cli             ; clear (disable) interrupts durign critical operations
    mov ax, 0x7c0   ; must put 0x7c0 into ax first (processor requirement)
    mov ds, ax      ; data segment
    mov es, ax      ; extra segment
    mov ax, 0x00    ; stack segment grows down, start ax at 0 for stack assignment
    mov ss, ax      ; set the stack segment to 0
    mov sp, 0x7c00  ; stack pointer to 0x7c00
    sti             ; enables interrupts
    mov si, message ; move the address of the message label into si register
    call print      ; calls print sub-routine
    jmp $

print:
    mov bx, 0       ; set bx register to 0 (for the page number)
.loop:              ; .loop subroutine to print a char
    lodsb           ; load the character that si is pointing to into al register, then incrememnt si
    cmp al, 0       ; compare is al == 0 (0 = string null terminator)
    je .done        ; if above is true, jump to .done
    call print_char ; else continue and call print_char
    jmp .loop       ; jump back to .loop

.done:              ; this is called when the str null-terminator has been reached
    ret             ; return from sub-routine

print_char:
    mov ah, 0eh     ; sets ah to 0eh (0eh is the BIOS function for outputting to the screen)
    int 0x10        ; call interrupt 0x10 which will invoke the BIOS (which will see the 0eh) to print the char
    ret

message: db 'Hello World!', 0

times 510- ($ - $$) db 0
dw 0xAA55
