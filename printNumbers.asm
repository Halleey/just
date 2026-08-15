default rel

section .bss

    ; Reserve 1 byte = 8 bits.
    ;
    ; one_byte:
    ;
    ;     8 bits
    ;     ↓
    ;   ┌────────┐
    ;   │xxxxxxxx│
    ;   └────────┘
    ;
    one_byte resb 1


    ; Reserve 21 bytes.
    ;
    ; This will be our temporary buffer for the
    ; ASCII representation of the number.
    ;
    ; 21 bytes is enough for the decimal representation
    ; of a 64-bit unsigned integer plus some room.
    ;
    buffer resb 21


section .text

global _start

_start:

    ; Put a number into our 8-bit variable.

    mov byte [one_byte], 123


    ; RSI will contain the ADDRESS of one_byte.

    lea rsi, [rel one_byte]


    ; Call our function.
    ;
    ; RSI = address of an 8-bit number.

    call print_byte


    ; Put newline character '\n' into buffer.
    
    ; ASCII:
    
    ;     '\n' = 10

    mov byte [buffer], 10


    ; Linux syscall:
    
    ;     RAX = 1  -> write
    ;     RDI = 1  -> stdout
    ;     RSI = address of buffer
    ;     RDX = number of bytes

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel buffer]
    mov rdx, 1

    syscall


    ; Linux syscall:
    
    ;     RAX = 60 -> exit
    ;     RDI = exit status

    mov rax, 60
    xor rdi, rdi

    syscall


; print_byte


; Input:

;     RSI = address of an unsigned 8-bit number

; Example:

;     [RSI] = 123

; The function converts:

;     123

; into:

;     '1' '2' '3'

; and writes it to stdout.


print_byte:

    ; RSI currently points to our number.
    
    ; Read the 8-bit value into AL.

    ; AL = LOWEST 8 BITS of RAX.
    
    ; RAX is 64 bits:
    
    ;     RAX
    ;     |————————————————————————————————————————————————|
    ;     |                                                |
    ;     │                    56 bits                     │
    ;     │                                                │
    ;     ├────────────────────────────────────────────────┤
    ;     │                    AL                          │
    ;     │                   8 bits                       │
    ;     |────────────────────────────────────────────────|
    ;
    ; More precisely:
    ;
    ;     RAX
    ;      │
    ;      └── EAX = lower 32 bits
    ;              │
    ;              └── AX = lower 16 bits
    ;                    │
    ;                    ├── AH = bits 8-15
    ;                    │
    ;                    └── AL = bits 0-7
    
    ; Therefore:
    
    ;     AL = LOW 8 BITS
    

    mov al, [rsi]


    ; We need AX to contain our number.

    ; AX is 16 bits:
    ;             16 bits
    ;     ┌──────────────────┐
    ;     │ AH       │ AL    │
    ;     │ 8 bits   │ 8 bits│
    ;     └──────────────────┘
    ; AL contains our number.

    ; AH might contain garbage.

    ; Therefore we clear AH.

    ; After this:

    ;     AH = 0
    ;     AL = number

    ; Example:

    ;     AL = 01111011
    ;     AH = 00000000

    ;     AX = 00000000 01111011
    ;

    xor ah, ah


    ; BL will contain our divisor: 10.
    
    ; BL is the LOWEST 8 bits of RBX.

    ; Similar structure:
    
    ;     RBX
    ;      │
    ;      └── EBX = lower 32 bits
    ;              │
    ;              └── BX = lower 16 bits
    ;                    │
    ;                    ├── BH = bits 8-15
    ;                    │
    ;                    └── BL = bits 0-7
    ;
    ; So BL is another 8-bit LOW register portion.
    
    mov bl, 10

    ; RSI points to the END of the buffer.
    ;
    ; buffer has 21 bytes:
    
    ;     buffer + 0
    ;     buffer + 1
    ;     ...
    ;     buffer + 20
    
    ; buffer + 21 points one byte after the buffer.
    
    ; We will move RSI backwards as we write
    ; each ASCII digit.

    lea rsi, [rel buffer + 21]


.convert:

    ; DIV BL
    
    ; For an 8-bit DIV:
    
    ;     AX / BL
    
    ; The CPU produces:
    
    ;     AL = quotient
    ;     AH = remainder
    
    ; Example:
    
    ;     AX = 123
    ;     BL = 10
    
    ;     123 / 10
    
    ;     AL = 12
    ;     AH = 3
    
    ; This is different from:
    
    ;     div rbx
    
    ; where the CPU uses RDX:RAX.

    div bl


    ; AH now contains the remainder.
    
    ; Example:
    ;
    ;     AH = 3
    
    ; We need ASCII:
    ;
    ;     3 -> '3'
    
    ; ASCII:
    
    ;     '0' = 48
    ;     '1' = 49
    ;     '2' = 50
    ;     '3' = 51
    
    ; Therefore:
    
    ;     3 + '0' = '3'

    add ah, '0'


    ; Move RSI one byte backwards.
    
    ; The digits are generated backwards.
    
    ; For 123:
    
    ;     first remainder  = 3
    ;     second remainder = 2
    ;     third remainder  = 1
    ;
    ; Therefore we store them from right to left.
    ;
    ;     | ? | ? | ... | 1 | 2 | 3 |
    ;                       ^
    ;                       |
    ;                      RSI

    dec rsi


    ; Store the ASCII digit.
    
    ; AH contains the character.
    ;
    ; Example:
    
    ;     AH = '3'
    
    ;     [RSI] = '3'

    mov [rsi], ah


    ; We need to continue with the quotient.
    ;
    ; AL currently contains the quotient.
    
    ; Example:
    
    ;     123 / 10
    
    ;     AL = 12
    ;     AH = '3'
    
    ; But AH now contains ASCII '3'.
    
    ; We need to turn AX back into:
    
    ;     AX = 12
    
    ; Therefore clear AH.

    xor ah, ah


    ; Check whether the quotient is zero.
    
    ; AL = quotient.
    
    ; TEST AL, AL performs:
    
    ;     AL AND AL
    
    ; It doesn't change AL.
    
    ; It only updates FLAGS.
    ;
    ; If AL == 0:
    
    ;     ZF = 1
    
    ; If AL != 0:
    
    ;     ZF = 0

    test al, al


    ; If AL != 0, continue converting.

    jnz .convert


    ; At this point RSI points to the first digit.
    ;
    ; For 123:
    
    ;     buffer:
    
    ;     | ? | ? | ... | '1' | '2' | '3' |
    ;                       ^
    ;                       |
    ;                      RSI
    
    ; Now we need to calculate:
    ;
    ;     number of bytes = buffer_end - RSI


    ; RAX = syscall number.
    
    ; Linux:
    
    ;     syscall 1 = write

    mov rax, 1


    ; RDI = file descriptor.
    
    ;     0 = stdin
    ;     1 = stdout
    ;     2 = stderr
    
    ; We want stdout.

    mov rdi, 1


    ; RDX = number of bytes.
    
    ; buffer + 21 = end of buffer.
    
    ; Example:
    
    ;     buffer + 21 = 21
    ;     RSI         = 18

    ;     21 - 18 = 3
    
    ; Therefore:
    
    ;     RDX = 3

    lea rdx, [rel buffer + 21]

    sub rdx, rsi


    ; Linux write syscall:
    
    ;     RAX = 1
    ;     RDI = stdout
    ;     RSI = address of first character
    ;     RDX = number of bytes

    ; write(stdout, buffer, length)

    syscall


    ret