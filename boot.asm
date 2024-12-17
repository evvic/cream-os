ORG 0x7c00 ; origin
BITS 16    ; ensure assmebler will only assemble instructions into 16-bit code

start:
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0
    int 0x10

    jmp $

times 510- ($ - $$) db 0
dw 0xAA55
