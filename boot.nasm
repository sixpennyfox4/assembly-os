ORG 0x7C00 ; address loaded by BIOS
BITS 16

mov si, 0

print_booting_msg:
    mov ah, 0x0E ; char print interrupt
    mov al, [booting_msg + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [booting_msg + si], 0 ; if \0
    jne print_booting_msg ; if not loop next char

mov si, 0

start:
    cli ; disable interrupts
    xor ax, ax ; clear AX

    ; set all these to 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x9000 ; set stack pointer
    sti ; enable interrupts

    mov ah, 0x02 ; read sectors
    mov al, 4 ; 4 sectors
    mov ch, 0
    mov cl, 2 ; sector 2 (skip bootloader)
    mov dh, 0
    mov dl, 0x00 ; drive number (floppy)
    mov bx, 0x8000 ; kernel destination address
    int 0x13 ; trigger interrupt

    jc disk_error

    jmp 0x0000:0x8000 ; jump where kernel was loaded (e.g. 0x8000)

disk_error:
    mov ah, 0x0E ; char print interrupt
    mov al, [disk_error_msg + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [disk_error_msg + si], 0 ; if \0
    jne disk_error ; if not loop next char
    hlt

stop:
    jmp stop

booting_msg: db "Booting into Assembly OS kernel...", 0
disk_error_msg: db "Disk read error!", 0

times 510 - ($ - $$) db 0 ; filler
dw 0xAA55