section .rodata
    message db "Routine",10
    length equ $ - message

section .text
    global _start


_start: 

    call simple_routine


    mov rax, 60
    xor rdi, rdi
    syscall



;this is called 'routine' think of this as the equivalent of a function in
;high level lang.
; We will need to learn about this to 
;create hexadecimal cconversion functions for printing numbers         


;and you can call name your routine whatever you want 
simple_routine: 
    mov rax, 1
    mov rdi, 1
    mov rsi, message
    mov rdx, length
    syscall

    ret