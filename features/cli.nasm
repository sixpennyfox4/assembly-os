; si is 0

; print command prompt
print_cmd_prompt:
    mov ah, 0x0E ; char print interrupt
    mov al, [cmd_prompt + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [cmd_prompt + si], 0 ; if \0
    jne print_cmd_prompt

mov si, 0

; main loop
cmd_loop:
    mov ah, 0x00 ; wait for keystroke
    int 0x16 ; return ASCII in AL

    cmp al, 0x08 ; if backspace is pressed
    je handle_backspace

    cmp al, 0x0D ; if enter is pressed
    je check_cmd

    mov [cmd_buffer + si], al ; store char
    ;mov byte [cmd_buffer + si + 1], 0 ; add null terminator

    mov ah, 0x0E ; char print interrupt
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter
    jmp cmd_loop

; handle backspace
handle_backspace:
    cmp si, 0 ; if at buffer start
    je cmd_loop

    dec si ; go 1 char back
    mov byte [cmd_buffer + si], 0 ; set deleted char to \0

    ; remove char from screen
    mov ah, 0x0E
    mov al, 0x08 ; move cursor to left
    int 0x10

    mov ah, 0x0E
    mov al, ' ' ; overwrite with space
    int 0x10

    mov ah, 0x0E
    mov al, 0x08 ; move cursor to left
    int 0x10

    jmp cmd_loop

; check command
check_cmd:
    mov byte [cmd_buffer + si], 0
    print_new_line

    cmp byte [cmd_buffer], 0 ; if cmd_buffer is empty ...
    je print_cmd_prompt ; just loop again

    lea si, [cmd_buffer]

    ; help cmd
    lea di, [cmd_help_str]
    mov cx, cmd_help_len
    cld
    repe cmpsb

    jz help_cmd_start

    lea si, [cmd_buffer]

    ; version cmd
    lea di, [cmd_version_str]
    mov cx, cmd_version_len
    cld
    repe cmpsb

    jz version_cmd_start

    lea si, [cmd_buffer]

    ; credits cmd
    lea di, [cmd_credits_str]
    mov cx, cmd_credits_len
    cld
    repe cmpsb

    jz credits_cmd_start

    lea si, [cmd_buffer]

    ; clear cmd
    lea di, [cmd_clear_str]
    mov cx, cmd_clear_len
    cld
    repe cmpsb

    jz do_clear_cmd

    lea si, [cmd_buffer]

    ; rick cmd
    lea di, [cmd_rick_str]
    mov cx, cmd_rick_len
    cld
    repe cmpsb

    jz rick_cmd_start

    lea si, [cmd_buffer]

    ; reboot cmd
    lea di, [cmd_reboot_str]
    mov cx, cmd_reboot_len
    cld
    repe cmpsb

    jz do_reboot_cmd

    jmp unknown_cmd ; if didnt match any cmds

do_reboot_cmd:
    int 0x19 ; soft reboot

rick_cmd_start:
    mov si, 0

do_rick_cmd:
    mov ah, 0x0E ; char print interrupt
    mov al, [cmd_rick_output + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [cmd_rick_output + si], 0 ; if \0
    jne do_rick_cmd

    mov si, 0
    jmp print_cmd_prompt

credits_cmd_start:
    mov si, 0

do_credits_cmd:
    mov ah, 0x0E ; char print interrupt
    mov al, [cmd_credits_output + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [cmd_credits_output + si], 0 ; if \0
    jne do_credits_cmd

    mov si, 0
    jmp print_cmd_prompt

version_cmd_start:
    mov si, 0

do_version_cmd:
    mov ah, 0x0E ; char print interrupt
    mov al, [cmd_version_output + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [cmd_version_output + si], 0 ; if \0
    jne do_version_cmd

    mov si, 0
    jmp print_cmd_prompt

help_cmd_start:
    mov si, 0

do_help_cmd:
    mov ah, 0x0E ; char print interrupt
    mov al, [cmd_help_output + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [cmd_help_output + si], 0 ; if \0
    jne do_help_cmd

    mov si, 0
    jmp print_cmd_prompt

do_clear_cmd:
    clear_screen
    ;print_new_line

    mov si, 0
    jmp print_cmd_prompt

unknown_cmd:
    mov si, 0

print_unknown_cmd1:
    mov ah, 0x0E ; char print interrupt
    mov al, [unknown_cmd_output1 + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [unknown_cmd_output1 + si], 0 ; if \0
    jne print_unknown_cmd1

mov si, 0

; print the unknown cmd
print_unknown_cmd_cmd:
    mov ah, 0x0E ; char print interrupt
    mov al, [cmd_buffer + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [cmd_buffer + si], 0 ; if \0
    jne print_unknown_cmd_cmd

mov si, 0

print_unknown_cmd2:
    mov ah, 0x0E ; char print interrupt
    mov al, [unknown_cmd_output2 + si] ; pass char
    int 0x10 ; trigger interrupt

    add si, 1 ; increase counter

    cmp byte [unknown_cmd_output2 + si], 0 ; if \0
    jne print_unknown_cmd2

    mov si, 0

    print_new_line
    print_new_line
    jmp print_cmd_prompt

cmd_prompt: db "> ", 0
cmd_buffer: times 128 db 0

; cmd shit
unknown_cmd_output1: db "Unknown command '", 0
unknown_cmd_output2: db "'.", 0

cmd_help_output:
    db "Available commands:", 0xD, 0xA
    db "--------------------------------------", 0xD, 0xA
    db "help - print this message", 0xD, 0xA
    db "version - print current OS version", 0xD, 0xA
    db "credits - print credits", 0xD, 0xA
    db "clear - clear the screen", 0xD, 0xA
    db "rick - ???", 0xD, 0xA
    db "reboot - reboot OS", 0xD, 0xA, 0xD, 0xA, 0

cmd_version_output:
    db "Assembly OS v0.1", 0xD, 0xA
    db "Built entirely in assembly.", 0xD, 0xA, 0xD, 0xA, 0

cmd_credits_output:
    db "Creator: sixpennyfox4 (https://github.com/sixpennyfox4)", 0xD, 0xA
    db "Inspired By: MikeOS (https://mikeos.sourceforge.net/)", 0xD, 0xA, 0xD, 0xA, 0

cmd_rick_output:
    db "never gonna give you up, never gonna let you down, never gonna run around and desert you..", 0xD, 0xA
    db "never gonna make you cry.. never gonna saay goodbyee, never gonna tell a liee and huurt youu", 0xD, 0xA, 0xD, 0xA, 0

cmd_help_str: db "help", 0
cmd_help_len: equ $ - cmd_help_str - 1 ; without null terminator

cmd_clear_str: db "clear", 0
cmd_clear_len: equ $ - cmd_clear_str - 1 ; without null terminator

cmd_version_str: db "version", 0
cmd_version_len: equ $ - cmd_version_str - 1 ; without null terminator

cmd_credits_str: db "credits", 0
cmd_credits_len: equ $ - cmd_credits_str - 1 ; without null terminator

cmd_rick_str: db "rick", 0
cmd_rick_len: equ $ - cmd_rick_str - 1 ; without null terminator

cmd_reboot_str: db "reboot", 0
cmd_reboot_len: equ $ - cmd_reboot_str - 1 ; without null terminator