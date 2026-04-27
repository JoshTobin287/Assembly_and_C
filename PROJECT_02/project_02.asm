;-----------------------------------------------------------
; Title        : Converting 68k assembly to x86_64
; Written by   : Josh Tobin
; Date Created : 
; Description  : A loop based code project that prompt a user to enter a number twice 3 times,
;                with a sum after each prompt which then results in a final sum that adds all prompt
;                numbers togther. The user cannot enter more than 4 numbers.
;-----------------------------------------------------------

global _start           ;program entry point 
extern printf, scanf    ;library C functions

section .text

_start:
    mov qword   [counter],  3       ;set loop counter to 3
    mov rbx,    0                   ;set running total to 0

    lea rdi,    [LIMIT]             ;load address of LIMIT message into rdi
    xor rax,    rax                 ;clears rax fo calling printf
    call        printf              ;print the LIMIT message

GAME_LOOP:
; Inputting two numbers and add them using REGISTER_ADDER subroutine

    ;number 1
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
    cmp rax,    0           ;chek if number is less than 0
    jl  INVALID_INPUT       ;if number is less than 0 jmp to error
;-------------------------------------------------------------------------------------
    ;number 2
    lea rdi,    [PROMPT]    ;load prompt string
    xor rax,    rax         ;clears rax fo calling printf
    call        printf      ;prints the prompt message

    lea rdi,    [FORMAT]    ;format string with "%ld"
    lea rsi,    [number2]   ;address where input will be stored
    xor rax,    rax         ;
    call    scanf           ;read input into number1

    mov     rdx, [number2]   ;load first number into rax

    cmp rdx,    9999        ;check if number is greater than 9999
    jg  INVALID_INPUT       ;if number is greater than 9999, then jump to OVER_LIMIT error
    cmp rdx,    0           ;chek if number is less than 0
    jl  INVALID_INPUT       ;if number is less than 0 jmp to error

;----------------------------------------------------------------------------------------
    ;add
    mov rdi,    rax             ;first number to rdi
    mov rsi,    rdx             ;second number to rsi
    call        REGISTER_ADDER  ;returns result in rax
    
    add rbx,    rax             ;add result to running total

    lea rdi,    [RESULT]        ;load result
    mov rsi,    rax             ;value to print
    xor rax,    rax             ;clears rax fo calling printf
    call        printf          ;prints result message

    ;loop
    dec qword   [counter]       ;decrease the loop counter
    jnz GAME_LOOP               ;repeat if not zero
    jmp FINAL_SUM               ;otherwise go to final sum
    

INVALID_INPUT:
    lea rdi,    [OVER_LIMIT]    ;load error message
    xor rax,    rax             ;clears rax fo calling printf
    call        printf          ;print error message
    jmp         GAME_LOOP       ;restart loop

FINAL_SUM:
    lea rdi,    [FINAL_RESULT]  ;load final result message
    mov rsi,    rbx             ;the total sum of numbers
    xor rax,    rax             ;clears rax fo calling printf
    call        printf          ;prints final result message

EXIT: 
    mov rax, 60     ;syscall number for exit 
    xor rdi, rdi    ;return code 0 
    syscall         ;exit program

REGISTER_ADDER:
    mov rax,    rdi ;move first number into rax
    add rax,    rsi ;add second number 
    ret             ;return result in rax

;-------------------------------------------------------------------
section .bss

number1 resq 1      ;reserve 8 bytes for first number
number2 resq 1      ;reserve 8 bytes for second number
counter resq 1      ;reserve 8 bytes for loop counter

section .data

LIMIT db "Do no enter more than 4 numbers per prompt",10,0  ;message shown at START
OVER_LIMIT db "You went over limit try again",10,0          ;OVER LIMIT message
PROMPT db "Enter number: ",0                                ;input prompt message
RESULT db "The sum is: %ld",10,0                          ;result of sums message
FINAL_RESULT db "Final sum is: %ld",10,0                    ;final result of sums total
FORMAT db "%ld",0                                           ;scanf format for integers

