; well, here we are going to learn about section .bss
; a simple example, so even a stupid person can learn this

section .bss

; resb = reserve bytes
; resw = reserve words
; resd = reserve double words
; resq = reserve quad words

message resb 8

; We reserved 8 bytes of memory for "message".
; Right now, "message" does NOT contain "I cried".
; We only have a place in memory where we can put something.
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
    ; | I |   | c | r | i | e | d | \n |
    ;
    ; We reserved the memory in .bss,
    ; and initialized it here in .text.
    ;
    ; With this, we've learned the basic way
    ; to move and display values one by one.
    ;
    ; Shortly, we'll see how to use a constant
    ; to hold the whole thing.
    ;
    ; But take it easy, you wretch.


    ; Print as we saw earlier.

    mov rax, 1              ; syscall: write
    mov rdi, 1              ; file descriptor: stdout
    mov rsi, message        ; address of our message
    mov rdx, 8              ; number of bytes
    syscall


    ; Okay, let's try something more advanced.
    ; So pay close attention.
    ;
    ; Hexadecimal:
    ; If you don't know what it is, leave,
    ; go study, and then come back.

    ; 49 20 63 72 69 65 64 0A
    ; I     c  r  i  e  d  \n

    ; 20 is literally an empty space.

    ; Because of little-endian, the bytes will be
    ; stored in memory in the reverse order of the
    ; hexadecimal representation of the value.


    ; Here we use RAX because x86-64 provides a MOV
    ; encoding that allows a 64-bit immediate value
    ; to be loaded directly into a 64-bit register.

    mov rax, 0x0A64656972632049

    ; The value above is written this way because
    ; the processor uses little-endian byte order.
    ; The value:
    ; 0A 64 65 69 72 63 20 49
    ; will be stored in memory as:
    ; 49 20 63 72 69 65 64 0A
    ; which represents:
    ; I     c  r  i  e  d  \n
    ; Now we move the 64-bit value from RAX
    ; into our 8-byte memory area.

    mov [message], rax

    ; Print the message again.

    mov rax, 1         
    mov rdi, 1            
    lea rsi, [rel message]  ; address of our message
    mov rdx, 8              
    syscall


    mov rax, 60             
    mov rdi, 0             
    syscall

