ORG 0x7c00 ; origin
BITS 16    ; ensure assmebler will only assemble instructions into 16-bit code

start:
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
