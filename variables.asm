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

default rel             ; avoid warning about absolute address in x86-64

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

;temporary buffer to convert number into ascii 
buffer resb 21


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


    ; well, print a ascii is very simple, right ? see

    mov rax, 1         
    mov rdi, 1          
    mov rsi, one_byte   
    mov rdx, 1    
    syscall


    ;we will  talk about LEA in the future 
    mov al, [one_byte]          ; Copy the CONTENT of 'one_byte' ('A') into the AL register
    mov [buffer], al            ; Copy the 'A' character from AL into the first position of the buffer
    mov byte [buffer + 1], 10   ; Put a newline (\n) in the second position of the buffer

    ;fuck, we already know what this does.
    mov rax, 1                 
    mov rdi, 1                  

; HOW THE FUCK DOES LEA WORK?
; The 'sys_write' syscall expects RSI to contain the ADDRESS
; of the memory where the message starts.

; It does NOT want the actual contents of the buffer.

; So if we did:

;     mov rsi, [buffer]

; the CPU would READ the contents stored inside 'buffer'.

; Our buffer currently contains:

;     'A' + '\n'

; In memory, that's basically:

;     41 0A

; So RSI would end up containing something like 0x0A41
; instead of the fucking address of the buffer.

; Then sys_write would treat 0x0A41 as a memory address
; and try to read from there.

; And guess what?
; nuclear bomb. Segmentation fault
;
; This is where LEA (Load Effective Address) becomes useful.
;
; LEA evaluates the memory expression [buffer], but DOES NOT
; read the data stored there.
;
; Instead, it calculates the ADDRESS of 'buffer' and puts
; that address into RSI.
;
; In other words:
;
;     mov rsi, [buffer]   -> "Give me what's INSIDE buffer."
;
;     lea rsi, [buffer]   -> "Give me WHERE buffer IS."
;
; That's the important difference:
;
;     [] with MOV  -> access the CONTENT
;     LEA          -> calculate the ADDRESS
;
; So RSI now contains a pointer to the beginning of our buffer.

    lea rsi, [buffer]           ; Load the ADDRESS of buffer into RSI

    mov rdx, 2                  
    syscall                                


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

