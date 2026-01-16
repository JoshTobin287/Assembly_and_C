*-----------------------------------------------------------
* Title      : part2.X68
* Written by : Josh Tobin
* Date       : 15/01/2026
* Description: Assembly
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    MOVE.L  #$00000111, D1     ; Load immediate value into D1
    MOVE.B  D1, D2             ; Copy byte from D1 to D2
    MOVE.B  D1, $2000          ; Store byte from D1 to memory $2000
    MOVE.B  $2000, D2          ; Load byte from memory $2000 into D2
    MOVE.B  $2000, $3000       ; Copy byte from $2000 to memory $3000
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
