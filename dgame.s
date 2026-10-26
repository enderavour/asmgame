.intel_syntax noprefix

.extern _putchar
.extern _exit
.extern _usleep
.extern _getc
.extern _set_term_game_state
.extern _restore_term_state

.globl _start

_start:
    mov r14, rsp
    and rsp, -16

    lea rsi, [rip + map]
    call _fill_map
    mov r13, rax

    mov rax, 0x3E8
    mov rbp, 0x14
    div rbp
    mov rbp, rax
    call _set_term_game_state
.gameLoop:
    lea rdi, [rip + clearSeq]
    call _printf
    mov rsi, r13
    call _print_map
    mov rdi, rbp
    call _usleep
    xor rdi, rdi
    call _getchar
    cmp rax, 0x65 # 'e'
    je .gameCleanup
    mov rdi, rax
    lea rsi, [rip + map]
    call _move_player
    je .gameCleanup
    jmp .gameLoop

.gameCleanup:
    mov rsp, r14
    call _restore_term_state
    xor rdi, rdi
    call _exit

.macro map_at ptr, y, x
    mov rax, \y
    imul rax, 20
    add rax, \x
    lea rcx, [\ptr + rax]
.endm

_fill_map:
    push r12
    push rbx

    xor rbx, rbx
    mov rdx, 0xA

    mov r12, rsi

    mov rdi, rsi
    mov al, 0x20
    mov rcx, 0x190
    rep stosb

    xor ebx, ebx
1:
    map_at r12, rbx, 0
    mov byte ptr [rcx], 0x23
    map_at r12, rbx, 19
    mov byte ptr [rcx], 0x23
    inc rbx
    cmp rbx, 20
    je .cols
    jmp 1b


.cols:
    xor rbx, rbx
2:
    map_at r12, 0, rbx
    mov byte ptr [rcx], 0x23
    map_at r12, 19, rbx
    mov byte ptr [rcx], 0x23
    inc rbx
    cmp rbx, 20
    je 3f
    jmp 2b

3:
    movzx rdx, word ptr [rip + playerPosX]
    movzx r9,  word ptr [rip + playerPosY]

    map_at r12, rdx, r9
    mov byte ptr [rcx], 0x40

    mov rax, r12
    pop rbx
    pop r12
    ret

_print_map:
    push rbx
    push r12
    push r13

    mov r12, rsi
    xor r13d, r13d
1:
    cmp r13, 20
    jae 3f

    xor ebx, ebx
2:
    cmp rbx, 20
    jae .innerDone

    map_at r12, r13, rbx
    movzx edi, byte ptr [rcx]
    call _putchar

    inc rbx
    jmp 2b
.innerDone:
    mov edi, 10
    call _putchar

    inc r13
    jmp 1b

3:
    pop r13
    pop r12
    pop rbx
    ret


_move_player:
    push rbx
    push r12
    push r13

    # r12 = X, r13 = Y
    movzx r12, word ptr [rip + playerPosX]
    movzx r13, word ptr [rip + playerPosY]

    mov r8, r12
    mov r9, r13

    cmp edi, 0x77
    je .up
    cmp edi, 0x73
    je .down
    cmp edi, 0x61
    je .left
    cmp edi, 0x64
    je .right
    jmp .done

.up:
    cmp r13, 1
    jle .done
    dec r13
    jmp .update

.down:
    cmp r13, 18
    jge .done
    inc r13
    jmp .update

.left:
    cmp r12, 1
    jle .done
    dec r12
    jmp .update

.right:
    cmp r12, 18
    jge .done
    inc r12
    jmp .update

.update:
    map_at rsi, r9, r8
    mov byte ptr [rcx], 0x20

    map_at rsi, r13, r12
    mov byte ptr [rcx], 0x40

    mov word ptr [rip + playerPosX], r12w
    mov word ptr [rip + playerPosY], r13w

.done:
    pop r13
    pop r12
    pop rbx
    ret


.data
clearSeq: .asciz "\x1b[H\x1b[J"
playerPosX: .short 10
playerPosY: .short 10


.bss
.lcomm map, 0x190
