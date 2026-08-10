; This section is just for constant values in read-only memory. Don't make the 
;mistake of putting
; a fuckin' value without initialization. .bss is meant for that.

section .rodata
message db "Can someone help me ?", 10
length equ $ - message

message2 db "I hate this, but let's talk about this crap, right? ", 10
length2 equ $ - message2



;I think I'll explain the rest more later
section .text
global _start

_start:
; You could use a different register here, just to hold a reference.
; Yeah, you... but the syscall itself requires
; rsi and rdx. Let's look at an example shortly.

mov rax, 1          ; ID da syscall sys_write
    mov rdi, 1          ; fd 1 = stdout
    mov rsi, message   ; Ponteiro para os dados na .rodata
    mov rdx, length    ; Quantidade de bytes a escrever
    syscall

; Second message
mov rax, 1
mov rdi, 1

mov rbx, message
mov rcx, length

mov rsi, rbx
mov rdx, rcx
syscall

; Third message
mov rax, 1
mov rdi, 1

mov rbx, message2
mov rcx, length2

mov rsi, rbx
mov rdx, rcx
syscall

mov rax, 60
xor rdi, rdi
syscall
