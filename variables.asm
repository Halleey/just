; In the previous example, we reserved 8 bytes and then
; manually placed each character into memory.

; This time, we will reserve different types of data:

;   resb = reserve bytes      (1 byte)
;   resw = reserve words      (2 bytes)
;   resd = reserve double     (4 bytes)
;   resq = reserve quad       (8 bytes)

; The important thing to understand is:
; .bss reserves MEMORY.

; It does not give that memory an initial value.

section .bss

; Reserve one byte.

one_byte resb 1

; Reserve two bytes.

two_bytes resw 1

; Reserve four bytes.

four_bytes resd 1

; Reserve eight bytes.

eight_bytes resq 1

; We can also reserve several elements at once.
;
; This reserves 6 bytes:
;
; | ? | ? | ? | ? | ? | ? |
;
; The question marks simply mean:
; "We have memory here, but we have not initialized it."

array resb 6

section .text

global _start

_start:

    ;ONE BYTE
    ; We can put a single character into one_byte.


    mov byte [one_byte], 'A'

    ; TWO BYTES
    ; A WORD is 2 bytes.
    ; Here we store the number 500.

    mov word [two_bytes], 500

    ;four BYTES

    ; A DWORD is 4 bytes
    ; Here we store the number 100000

    mov dword [four_bytes], 100000


    ;eight bytes
    ; A QWORD is 8 bytes.
    ; Here we store a much larger number.

    mov qword [eight_bytes], 123456789


    ;  AN ARRAY
    ; Remember:
    ;     array resb 6
    ; means:
    ;     |   |   |   |   |   |   |
    ;       0   1   2   3   4   5
    ;
    ; We can access each byte using an offset.
    ;

    mov byte [rel array + 0], 'H'
    mov byte [rel array + 1], 'e'
    mov byte [rel array + 2], 'l'
    mov byte [rel array + 3], 'l'
    mov byte [rel array + 4], 'o'
    mov byte [rel array + 5], 10

    mov byte [rel array], 'Y'

    mov al, [rel array]
    mov al, [rel array + 1]

    mov [rel one_byte], al


    ; What does [array + 2] mean?
    ; array
    ;   |
    ;   v
    ; | H | e | l | l | o | \n |
    ;   0   1   2   3   4    5
    ; [array + 0] -> H
    ; [array + 1] -> e
    ; [array + 2] -> l
    ; [array + 3] -> l
    ; [array + 4] -> o
    ; [array + 5] -> \n
    ; The number after '+' is an OFFSET.
    ; Because each element here is one byte,
    ; increasing the offset by 1 moves one byte forward.


    ; Let's change the array.
    ; Replace the first character.

    mov byte [rel array], 'Y'

    ; Now the array contains:
    ; | Y | e | l | l | o | \n |
    ; "Yello"


    ; We can also READ memory.
    ; MOV can work in both directions:
    ;     register -> memory
    ; or
    ;     memory -> register
    ; Let's read the first byte of the array.
    mov al, [rel array]

    ; AL now contains:
    ; 'Y'
    ; AL is the lower 8 bits of RAX.


    ; We can also copy one memory value to another
    ; through a register.
    ; We cannot generally do:
    ;     mov [one_byte], [array]
    ; because MOV does not allow two memory operands
    ; in this form.
    ;
    ; Instead:
    ;
    ;     memory -> register -> memory
    ;

    mov al, [rel array + 1]

    mov [rel one_byte], al

    ; one_byte now contains:
    ;
    ; 'e'



    ; MEMORY LAYOUT

    ; At this point, conceptually:
    ; one_byte
    ; | e |

    ; two_bytes:

    ; | lower byte | higher byte |

    ; four_bytes:
    ; | byte | byte | byte | byte |

    ; eight_bytes:

    ; | byte | byte | byte | byte | byte | byte | byte | byte |


    ; The exact byte order of multi-byte integers is affected
    ; by the CPU's endianness.
    ;
    ; x86-64 uses LITTLE-ENDIAN.


    ; Print the array


    mov rax, 1              ; syscall write
    mov rdi, 1              ; stdout 
    lea rsi, [rel array]    ; address of our message
    mov rdx, 6              ; number of bytes
    syscall



    mov rax, 60            
    mov rdi, 0           
    syscall

