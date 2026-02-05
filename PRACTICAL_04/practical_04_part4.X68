*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:      
    ;PLAYER HEALTH
    MOVE.B  #100,   $3000
    LEA     $3000,  A1
    
    ;BOSS HEALTH
    MOVE.B  #200,   $3010
    LEA     $3010,  A2
    
    ;BOSS LOCATION
    MOVE.B  #$1,    D0      ;BOSS X POSTION
    MOVE.B  #10,    $3009   ;BOSS Y POSTION
    
    ;PLAYER LOCATION
    MOVE.B  #$2,    D3      ;PLAYER X POSITION
    MOVE.B  #10,    $3059   ;PLAYER Y POSITION


PLAYER_TURN:
    MOVE.B  #$2,    D1      ;PLAYER MOVES - X POSTION
    MOVE.B  #00,    D3      ;REVERTS TO DEFAULT
    MOVE.B  #10,    $3019   ;PLAYER MOVES - Y POSTION
    MOVE.B  #$FF,   $3059   ;REVERTS TO DEFAULT
    BSR     PLAYER_CLOSE_ATTACK     ;PLAYER TURN
    
PLAYER_TURN2:
    MOVE.B  #$2,    D3
    MOVE.B  #00,    D1
    MOVE.B  #10,    $3059
    MOVE.B  #$FF,   $3019
    BSR     PLAYER_RANGED_ATTACK
    

PLAYER_CLOSE_ATTACK:
    SUB.B   #80,    (A2)    ;PLAYER ATTACKS, BOSS LOSES HEALTH
    BSR     BOSS_TURN

PLAYER_RANGED_ATTACK:
    SUB.B   #120,   (A2)
    BSR     GAME_END 
    
    
BOSS_TURN:
    BSR     BOSS_ATTACK     ;BOSS TURN
    
BOSS_ATTACK:
    SUB.B   #90,    (A1)    ;BOSS ATTACKS, PLAYER LOSES HEALTH
    BSR     PLAYER_TURN2
    
GAME_END:
                
    SIMHALT            
    END    START       

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
