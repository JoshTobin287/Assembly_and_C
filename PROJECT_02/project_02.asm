*-----------------------------------------------------------
* Title        : Converting 68k assembly to x86_64
* Written by   : Josh Tobin
* Date Created : 
* Description  : 
*-----------------------------------------------------------

global _start           ;program entry point 
extern printf, scanf    ;library C functions

section .text
_start
_START:
    mov rcx,    3       ;set loop counter to 3
    mov rbx,    0       ;set running total to 0

    lea rdi,    [LIMIT] ;load address of LIMIT message into rdi
    xor rax,    rax     ;clears rax fo calling printf
    call        printf  ;print the LIMIT message

GAME_LOOP:
* Input two numbers and add them using REGISTER_ADDER subroutine
    lea rdi,    [PROMPT]    ;load prompt string
    xor rax,    rax         ;clears rax fo calling printf
    call        printf      ;prints the prompt message

    lea rdi,    [FORMAT]    ;format string with "%ld"
    lea rsi,    [number1]   ;address where input will be stored
    xor rax,    rax         ;
    call    scanf           ;read input into number1

    mov     rax, [number1]   ;load first number into rax

    cmp rax,    9999        ;check if number is greater than 9999
    jg  INVALID_INPUT       ;if number is greater than 9999, then jump to OVER_LIMIT error

EXIT: 
    mov rax, 60     ;syscall number for exit 
    xor rdi, rdi    ;return code 0 
    syscall         ;exit program




section .bss
number1 resq 1      ;reserve 8 bits for first number
number2 resq 1      ;reserve 8 bits for second number

section .data
LIMIT db "Do no enter more than 4 numbers per prompt",10,0  ;message shown at START
OVER_LIMIT db "You went over limit try again",10,0          ;OVER LIMIT message
PROMPT db "Enter number: ",0                                ;input prompt message
RESULT db "The sum is: " %ld",10,0                          ;result of sums message
FINAL_RESULT db "Final sum is: %ld",10,0                    ;final result of sums total
FORMAT db "%ld",0                                           ;scanf format for integers

