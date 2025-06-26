ORG 0x8000 ; address loaded by bootloader
BITS 16

%macro print_new_line 0
    mov ah, 0x0E ; char print interrupt
    mov al, 0x0D ; carriage return
    int 0x10 ; trigger interrupt

    mov ah, 0x0E ; char print interrupt
    mov al, 0x0A ; line feed
    int 0x10 ; trigger interrupt
%endmacro

; row, col
%macro set_cursor_pos 2
    mov ah, 0x02 ; set cursor position interrupt
    mov bh, 0x00 ; display page #0
    mov dh, %1 ; row
    mov dl, %2 ; col
    int 0x10 ; trigger interrupt
%endmacro

; i dont really understand the clear_screen thing but if it works it works
%macro clear_screen 0
    mov ah, 0x06
    mov al, 0 ; clear entire window
    mov bh, 0x07
    mov cx, 0x0000
    mov dx, 0x184F
    int 0x10 ; trigger interrupt

    set_cursor_pos 0x00, 0x00
%endmacro

clear_screen

; set background color (out of screen isnt colored)
;mov ah, 0x09 ; char print & attribute
;mov al, ' ' ; pass char
;mov bh, 0x00 ; display page
;mov bl, 0x1F ; attribute: BG blue (1 << 4), FG white (0xF)
;mov cx, 2000 ; number of times to write (entire screen)
;int 0x10 ; trigger interrupt

mov si, 0 ; char counter for printing

; print welcome_msg1
mov bx, welcome_msg1
call print_string

mov si, 0 ; reset counter

; print welcome message
print_welcome_msg_assembly:
    mov al, [welcome_msg_assembly + si] ; pass char
    cmp byte al, 0 ; if \0
    je print_welcome_msg2

    cmp al, 0x0A ; if newline
    je print_default_char

    cmp al, 0x0D ; if carriage return
    je print_default_char

    mov ah, 0x09
    mov bh, 0x00
    mov bl, 0x06 ; brown
    mov cx, 1
    int 0x10

    ; move cursor forward
    mov ah, 0x03
    mov bh, 0x00
    int 0x10

    inc dl
    mov ah, 0x02
    mov bh, 0x00
    int 0x10

    add si, 1
    jmp print_welcome_msg_assembly

print_default_char:
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10

    add si, 1
    jmp print_welcome_msg_assembly

print_welcome_msg2:
    mov si, 0 ; reset counter

    mov bx, welcome_msg2
    call print_string

mov si, 0 ; reset counter

print_new_line
print_new_line

%include "features/cli.nasm"

print_string:
    ; bx is string
    mov ah, 0x0E ; char print interrupt
    mov al, [bx + si] ; pass char
    int 0x10 ; trigger interrupt

    inc si ; increase counter

    cmp byte [bx + si], 0 ; if \0
    jne print_string ; if not loop next char

    ret

welcome_msg1:
    db "###################", 0xD, 0xA
    db "#   ", 0

welcome_msg_assembly:
    db "ASSEMBLY", 0

welcome_msg2:
    db " OS   #", 0xD, 0xA
    db "###################", 0xD, 0xA, 0xD, 0xA

    db "Creator: sixpennyfox4 (https://github.com/sixpennyfox4)", 0xD, 0xA
    db "Inspired By: MikeOS (https://mikeos.sourceforge.net/)", 0xD, 0xA, 0xD, 0xA

    db "Type 'help' to get started!", 0