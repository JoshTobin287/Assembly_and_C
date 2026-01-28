*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:      
    LEA     PLAYER_HEALTH, A0
    LEA     PLAYER_POINTS, A1
    LEA     PLAYER_X, A2
    LEA     PLAYER_Y, A3
    LEA     BOSS_HEALTH, A4
    LEA     BOSS_X, A5
  
    MOVE.B  #$64, (A0)
    MOVE.W  #100, (A1)
    MOVE.W  #50,  (A2)
    MOVE.W  #30,  (A3)
    MOVE.B  #$64, (A4)
    MOVE.W  #200, (A5)
    MOVE.L  #1000, (A1)

        SIMHALT

PLAYER_HEALTH   dc.b 0
PLAYER_POINTS   dc.b 0,0,0,0
PLAYER_X        dc.b 0,0
PLAYER_Y        dc.b 0,0
BOSS_HEALTH     dc.b 0
BOSS_X          dc.b 0,0
BOSS_Y          dc.b 0,0         
      
    END    START        
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
