; si is 0

; print command prompt
print_cmd_prompt:
    ; clear cmd_buffer
    mov di, cmd_buffer
    mov cx, 128

.clear_cmd_buffer_loop:
    mov byte [di], 0
    inc di
    dec cx
    cmp cx, 0
    jne .clear_cmd_buffer_loop

    mov si, 0

    mov bx, cmd_prompt
    call print_string

mov si, 0

; main loop
cmd_loop:
    mov ah, 0x00 ; wait for keystroke
    int 0x16 ; return ASCII in AL

    cmp al, 0x08 ; if backspace is pressed
    je handle_backspace

    cmp al, 0x0D ; if enter is pressed
    je check_cmd

    ; if its 127 chars then it wont detect key
    cmp si, 127
    je cmd_loop

    mov [cmd_buffer + si], al ; store char
    ;mov byte [cmd_buffer + si + 1], 0 ; add null terminator

    mov ah, 0x0E ; char print interrupt
    int 0x10 ; trigger interrupt

    inc si ; increase counter
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

    jz do_help_cmd

    lea si, [cmd_buffer]

    ; version cmd
    lea di, [cmd_version_str]
    mov cx, cmd_version_len
    cld
    repe cmpsb

    jz do_version_cmd

    lea si, [cmd_buffer]

    ; credits cmd
    lea di, [cmd_credits_str]
    mov cx, cmd_credits_len
    cld
    repe cmpsb

    jz do_credits_cmd

    lea si, [cmd_buffer]

    ; clear cmd
    lea di, [cmd_clear_str]
    mov cx, cmd_clear_len
    cld
    repe cmpsb

    jz do_clear_cmd

    lea si, [cmd_buffer]

    ; echo cmd
    lea di, [cmd_echo_str]
    mov cx, cmd_echo_len
    cld
    repe cmpsb

    jz do_echo_cmd

    lea si, [cmd_buffer]

    ; add cmd
    lea di, [cmd_add_str]
    mov cx, cmd_add_len
    cld
    repe cmpsb

    jz do_add_cmd

    lea si, [cmd_buffer]

    ; rick cmd
    lea di, [cmd_rick_str]
    mov cx, cmd_rick_len
    cld
    repe cmpsb

    jz do_rick_cmd

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

do_rick_cmd:
    mov si, 0

    mov bx, cmd_rick_output
    call print_string

    jmp print_cmd_prompt

do_credits_cmd:
    mov si, 0

    mov bx, cmd_credits_output
    call print_string

    jmp print_cmd_prompt


do_version_cmd:
    mov si, 0

    mov bx, cmd_version_output
    call print_string

    jmp print_cmd_prompt

do_help_cmd:
    mov si, 0

    mov bx, cmd_help_output
    call print_string

    jmp print_cmd_prompt

do_clear_cmd:
    clear_screen
    ;print_new_line

    jmp print_cmd_prompt

do_echo_cmd:
    mov si, cmd_echo_len ; skip "echo"

echo_skip_spaces:
    mov al, [cmd_buffer + si]
    cmp al, ' ' ; if empty space

    jne print_echo

    inc si
    jmp echo_skip_spaces

print_echo:
    mov bx, cmd_buffer
    call print_string

    print_new_line
    print_new_line

    jmp print_cmd_prompt

do_add_cmd:
    mov si, cmd_add_len ; skip "add"

; first param
add_get_param_f:
.param_f_loop:
    mov al, [cmd_buffer + si]
    cmp al, ' '

    jne .param_f_save

    inc si
    jmp .param_f_loop

.param_f_save:
    mov dl, [cmd_buffer + si]
    sub dl, '0' ; convert to number

inc si

; second param
add_get_param_s:
.param_s_loop:
    mov al, [cmd_buffer + si]
    cmp al, ' '

    jne .param_s_save

    inc si
    jmp .param_s_loop

.param_s_save:
    mov bl, [cmd_buffer + si]
    sub bl, '0' ; convert to number

add dl, bl

cmp dl, 9
jbe add_single_digit ; if less or equal

; if 2 digit
mov ax, 0
mov al, dl
mov bl, 10
mov dx, 0
div bl

add al, '0'
mov [cmd_add_result], al
add ah, '0'
mov [cmd_add_result + 1], ah
mov byte [cmd_add_result + 2], 0

mov si, 0
mov bx, cmd_add_result
call print_string

print_new_line
print_new_line
jmp print_cmd_prompt

add_single_digit:
    mov al, dl
    add al, '0'
    mov [cmd_add_result], al
    mov byte [cmd_add_result + 1], 0

    mov si, 0
    mov bx, cmd_add_result
    call print_string

    print_new_line
    print_new_line
    jmp print_cmd_prompt

unknown_cmd:
    mov si, 0

    mov bx, unknown_cmd_output1
    call print_string

    mov si, 0

    mov bx, cmd_buffer
    call print_string

    mov si, 0

    mov bx, unknown_cmd_output2
    call print_string

    print_new_line
    print_new_line
    jmp print_cmd_prompt

cmd_prompt: db "> ", 0
cmd_buffer: times 128 db 0

; cmd shit
unknown_cmd_output1: db "Unknown command '", 0
unknown_cmd_output2: db "'.", 0

cmd_add_result: times 2 db 0

cmd_help_output:
    db "Available commands:", 0xD, 0xA
    db "--------------------------------------", 0xD, 0xA
    db "help - print this message", 0xD, 0xA
    db "version - print current OS version", 0xD, 0xA
    db "credits - print credits", 0xD, 0xA
    db "clear - clear the screen", 0xD, 0xA
    db "echo [TEXT] - prints [TEXT]", 0xD, 0xA
    db "add [NUM1] [NUM2] - prints the sum of [NUM1] and [NUM2] (the inputs should be 1 digit)", 0xD, 0xA
    db "rick - ???", 0xD, 0xA
    db "reboot - reboot OS", 0xD, 0xA, 0xD, 0xA, 0

cmd_version_output:
    db "Assembly OS v0.3", 0xD, 0xA
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

cmd_echo_str: db "echo", 0
cmd_echo_len: equ $ - cmd_echo_str - 1 ; without null terminator

cmd_add_str: db "add", 0
cmd_add_len: equ $ - cmd_add_str - 1 ; without null terminator

cmd_version_str: db "version", 0
cmd_version_len: equ $ - cmd_version_str - 1 ; without null terminator

cmd_credits_str: db "credits", 0
cmd_credits_len: equ $ - cmd_credits_str - 1 ; without null terminator

cmd_rick_str: db "rick", 0
cmd_rick_len: equ $ - cmd_rick_str - 1 ; without null terminator

cmd_reboot_str: db "reboot", 0
cmd_reboot_len: equ $ - cmd_reboot_str - 1 ; without null terminator