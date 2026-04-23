*-----------------------------------------------------------
* Title        : Parameter Passing Example for Easy68k
* Written by   : Josh Tobin
* Date Created : 
* Description  : Demonstrates passing parameters using registers
*                and stack, performing arithmetic operations,
*                and running a loop to keep a running sum.
*                Highlights security vulnerabilities related to
*                stack handling, input validation, and memory access.
*-----------------------------------------------------------

START   ORG     $1000

        CLR.L   D3              ; Running sum initialized to 0
        MOVE.W  #3, D4          ; Loop counter set to 3
        MOVE.B  #14, D0
        LEA     LIMIT,  A1
        TRAP    #15
        
        BSR     NEW_LINE

GAME_LOOP:
* Input two numbers and add them using REGISTER_ADDER subroutine
        MOVE.B  #14, D0         ; Task 14: Display string
        LEA     PROMPT, A1      ; Load address of prompt string
        TRAP    #15             ; System call (No input validation - Vulnerable!)

        MOVE.B  #4, D0          ; Task 4: Read integer input (No input validation - Vulnerable!)
        TRAP    #15             ; Execute system call
        
        CMP.L   #9999, D1       ; max 4 digits
        BGT     INVALID_INPUT
        CMP.L   #0, D1          ;prevents negatives
        BLT     INVALID_INPUT
        
        MOVE.L  D1, D2          ; Store first number in D2

        MOVE.B  #14, D0
        LEA     PROMPT, A1
        TRAP    #15             ; Display prompt again (No validation - Vulnerable!)

        MOVE.B  #4, D0
        TRAP    #15             ; Read second number into D1 (No validation - Vulnerable!)
        
        CMP.L   #9999, D1       ; max 4 digits
        BGT     INVALID_INPUT
        CMP.L   #0, D1          ;prevents negatives
        BLT     INVALID_INPUT

        BSR     REGISTER_ADDER  ; Call subroutine (D1 = D1 + D2)
        ADD.L   D1, D3          ; Add result to running sum

        MOVE.B  #14, D0
        LEA     RESULT, A1
        TRAP    #15
        MOVE.B  #3, D0
        TRAP    #15

        BSR     NEW_LINE

* Decrement loop counter and repeat if not zero
        SUBQ.W  #1, D4
        BNE     GAME_LOOP
        BRA     FINAL_SUM
INVALID_INPUT:
        MOVE.B  #14,    D0
        LEA     OVER_LIMIT, A1 
        TRAP    #15
        
        BSR     NEW_LINE
        BRA     GAME_LOOP

* Display final sum
FINAL_SUM:
        MOVE.B  #14, D0
        LEA     FINAL_RESULT, A1
        TRAP    #15
        
        MOVE.L  D3, D1
        MOVE.B  #3, D0
        TRAP    #15

        SIMHALT

*-----------------------------------------------------------
* Add numbers using register parameters
REGISTER_ADDER:
        ADD.L   D2, D1          ; Add D2 to D1 (No bounds checking - Vulnerable!)
        RTS                     ; Return from subroutine

*-----------------------------------------------------------
* Subroutine to display Carriage Return and Line Feed
NEW_LINE:
        MOVE.B  #14, D0
        LEA     CRLF, A1
        TRAP    #15
        RTS

*-----------------------------------------------------------
* Strings
LIMIT          DC.B    'Do no enter more than 4 numbers per prompt!',0
OVER_LIMIT     DC.B    'You have went over limit try again',0
PROMPT         DC.B    'Enter number: ',0
RESULT         DC.B    'The sum is: ',0
FINAL_RESULT   DC.B    'Final sum is: ',0
CRLF           DC.B    $D,$A,0

        END     START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
