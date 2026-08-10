; well, here we are going to learn about section .bss
; a simple example, so even a stupid person can learn this

section .bss

; resb = reserve bytes
; resw = reserve words
; resd = reserve double words
; resq = reserve quad words

message resb 8

; We reserved 8 bytes of memory for "message".
;
; Right now, "message" does NOT contain "I cried".
; We only have a place in memory where we can put something.
;
; We can initialize it later during the program.


section .text
global _start

_start:

    ; Let's put "I cried" inside our reserved memory.

    mov byte [message],     'I'
    mov byte [message + 1], ' '
    mov byte [message + 2], 'c'
    mov byte [message + 3], 'r'
    mov byte [message + 4], 'i'
    mov byte [message + 5], 'e'
    mov byte [message + 6], 'd'
    mov byte [message + 7], 10      ; newline


    ; Now our memory looks like this:
    ; | I  |    | c  | r  | i  | e  | d  | \n |
    ; We reserved the memory in .bss,
    ; and initialized it here in .text.
    ; With this, we’ve learned the basic version of how to move
    ; and display values ​​one by one; shortly, we’ll see how to use
    ; a constant to hold the whole thing. But take it easy, you wretch.

    ; print as we saw earlier 
    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    mov rsi, message        ; address of our message
    mov rdx, 8              ; number of bytes
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
