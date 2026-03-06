
*-----------------------------------------------------------
* Title      : ZOMBIE SPLATTER
* Written by : Josh Tobin
* Date       : 06/03/2026
* Description: ZOMBIE SPLATTER is a 2D side scrolling game where zombies move 
* across the screen from right to left. The player must react 
* quickly to avoide the large zombies before they damage your hull integrity.
* The player must kill small zombies to increas the kill counter to get as many 
* kills as possible. The player must be careful as fuel is quickly running out,
* so the player must pick up fuel drops that spawn on the screen.
* If you your fuel goes to zero or your hull integrity goes to zero you lose.
*
*
* This program handles the movement and resetting of zombies, 
* ensuring that when a zombie moves off the right side of the 
* screen, it respawns at their assigned X and Y coordinates.
* small and large zombies have separate reset routines to 
* manage their positions and activity.
* 
* This program also handles many collision factors between
* the player and the objects in its path, all occur and result
* in differnt ways. 
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
    BSR     START_MENU
    BSR     INITIALISE
    BSR     GAME
*-----------------------------------------------------------
* Section       : Trap Codes
* Description   : Trap Codes used throughout StarterKit
*-----------------------------------------------------------
* Trap CODES
TC_SCREEN   EQU         33          ; Screen size information trap code
TC_S_SIZE   EQU         00          ; Places 0 in D1.L to retrieve Screen width and height in D1.L
                                    ; First 16 bit Word is screen Width and Second 16 bits is screen Height
TC_KEYCODE  EQU         19          ; Check for pressed keys
TC_DBL_BUF  EQU         92          ; Double Buffer Screen Trap Code
TC_CURSR_P  EQU         11          ; Trap code cursor position

TC_EXIT     EQU         09          ; Exit Trapcode

*-----------------------------------------------------------
* Section       : Charater Setup
* Description   : Size of Player and Enemy and properties
* of these characters e.g Starting Positions and Sizes
*-----------------------------------------------------------
PLYR_W_INIT EQU         08          ; Players initial Width
PLYR_H_INIT EQU         08          ; Players initial Height

PLYR_DFLT_V EQU         00          ; Default Player Velocity
PLYR_JUMP_V EQU        -25         ; Player Jump Velocity
PLYR_DFLT_G EQU         02         ; Player Default Gravity

GND_TRUE    EQU         01          ; Player on Ground True
GND_FALSE   EQU         00          ; Player on Ground False

RUN_INDEX   EQU         00          ; Player Run Sound Index  
JMP_INDEX   EQU         01          ; Player Jump Sound Index  
OPPS_INDEX  EQU         02          ; Player Opps Sound Index
BACKGROUND_INDEX    EQU 03

SMALLZOMB_W_INIT EQU    08         ; Enemy initial Width
SMALLZOMB_H_INIT EQU    08          ; Enemy initial Height

LARGEZOMB_W_INIT EQU    16         ; Enemy initial Width
LARGEZOMB_H_INIT EQU    22         ; Enemy initial Height

BUILDING_W      EQU     50     ; width of building
BUILDING_H      EQU     200     ; height of building

ROAD_HEIGHT   EQU       1       ; height of the road in pixels

HULL_MAX    EQU         100

FUEL_W_INIT EQU         08          ;Fuel initail width
FUEL_H_INIT EQU         14          ;Fuel initial height
FUEL_MAX    EQU         100         ;max fuel

*-----------------------------------------------------------
* Section       : Keyboard Keys
* Description   : Spacebar and Escape or two functioning keys
* Spacebar to JUMP and Escape to Exit Game
*-----------------------------------------------------------
SPACEBAR    EQU         $20         ; Spacebar ASCII Keycode
ESCAPE      EQU         $1B         ; Escape ASCII Keycode
*-----------------------------------------------------------
* Subroutine : START_MENU
* Description: Display welcome screen and wait for SPACE to start
*-----------------------------------------------------------

START_MENU:
    ; Clear screen
    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  #$FF00, D1
    TRAP    #15

    ; Set starting row
    MOVE.W  #2, D0  ; row 2
    MOVE.W  #20, D1  ; column 20
    ; Display Game Title
    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  #$1402, D1   ; Row 2, Column 20
    TRAP    #15
    LEA     GAME_TITLE_MSG, A1
    MOVE    #13, D0
    TRAP    #15

    ; Display objectives, each 2 rows below previous
    MOVE.W  #4, D1   ; row 4
    MOVE.W  #20, D2  ; column 20
    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  D1, D1
    TRAP    #15
    LEA     OBJECTIVE_1, A1
    MOVE    #13, D0
    TRAP    #15

    MOVE.W  #6, D1   ; row 6
    MOVE.W  #20, D2
    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  D1, D1
    TRAP    #15
    LEA     OBJECTIVE_2, A1
    MOVE    #13, D0
    TRAP    #15

    MOVE.W  #8, D1   ; row 8
    MOVE.W  #20, D2
    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  D1, D1
    TRAP    #15
    LEA     OBJECTIVE_3, A1
    MOVE    #13, D0
    TRAP    #15
    
    ; Display "Press SPACE to start"
    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  #$1910, D1   ; Row 12, Column 20
    TRAP    #15
    LEA     START_MSG, A1
    MOVE    #13, D0
    TRAP    #15
WAIT_FOR_START:
    MOVE.B  #TC_KEYCODE, D0       ; Check key press
    TRAP    #15
    CMP.B   #SPACEBAR, D1          ; Did user press SPACE?
    BNE     WAIT_FOR_START          ; If not, loop again
    RTS                             ; Return to start game
    
*-----------------------------------------------------------
* Subroutine    : Initialise
* Description   : Initialise game data into memory such as 
* sounds and screen size
*-----------------------------------------------------------
INITIALISE:
    ; Initialise Sounds
    BSR     RUN_LOAD                ; Load Run Sound into Memory
    BSR     JUMP_LOAD               ; Load Jump Sound into Memory
    BSR     OPPS_LOAD               ; Load Opps (Collision) Sound into Memory
    BSR     BACKGROUND_LOAD         ; Load Background music into memory
    
    ; Initialize Kill Counter
    CLR.L   D1
    MOVE.L  D1, KILL_COUNT
    
    ; Intiailse Hull Integrity
    MOVE.L  #100,   HULL_INTEGRITY
    
    CLR.L   ZOMBIE_SOUND_ACTIVE    ; 0 = zombie sound not playing
    
    ; Screen Size
    MOVE.B  #TC_SCREEN, D0          ; access screen information
    MOVE.L  #TC_S_SIZE, D1          ; placing 0 in D1 triggers loading screen size information
    TRAP    #15                     ; interpret D0 and D1 for screen size
    MOVE.W  D1,         SCREEN_H    ; place screen height in memory location
    SWAP    D1                      ; Swap top and bottom word to retrive screen size
    MOVE.W  D1,         SCREEN_W    ; place screen width in memory location
    
    ; Initialize building off the right side of the screen
    MOVE.W SCREEN_W, D1
    MOVE.L D1, BUILDING_X

    ; Place the Player at the left
    MOVE.L  #100,        PLAYER_X     ; Start player near left side

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Players Y Position
    
    ;Road
    MOVE.L PLAYER_Y, D1
    ADD.L #PLYR_H_INIT, D1       ; Road right under player
    MOVE.L D1, ROAD_Y
    
    ;Place building on top of road 
    MOVE.L ROAD_Y, D1            ; Get road Y position
    SUB.L #BUILDING_H, D1        ; Building stands on road
    MOVE.L D1, BUILDING_Y        ; Store building Y

    ; Initialise Player Score
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #00,        D1          ; Init Score
    MOVE.L  D1,         PLAYER_SCORE
    
    CLR.L   JUMP_TIMER

    ; Initialise Player Velocity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.B  #PLYR_DFLT_V,D1         ; Init Player Velocity
    MOVE.L  D1,         PLYR_VELOCITY

    ; Initialise Player Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  #PLYR_DFLT_G,D1         ; Init Player Gravity
    MOVE.L  D1,         PLYR_GRAVITY

    ; Initialize Player on Ground
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Init Player on Ground

    ; Initial Position for small zombie
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_W,   D1          ; Place Screen width in D1
    MOVE.L  D1,         SMALLZOMB_X     ; Enemy X Position

    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         SMALLZOMB_Y     ; Enemy Y Position
    
    ; Place large zombie on top of road
    MOVE.L PLAYER_Y, D1             ; top of player
    MOVE.L D1, LARGEZOMB_Y          ; top of zombie
    
    ; Initialize Fuel
    MOVE.L  #100, FUEL       ; Start with 100 fuel units
    CLR.L   FUEL_TIMER

    ;Initial Position for Fuel
    CLR.L   D1
    MOVE.W  SCREEN_W, D1       ; Start off right side
    MOVE.L  D1, FUEL_X         ; X position

    CLR.L   D1
    MOVE.L  SMALLZOMB_Y, FUEL_Y
    
    MOVE.L  #1, FUEL_ACTIVE     
    CLR.L   FUEL_RESPAWN_TIMER  

    ; Enable the screen back buffer
	MOVE.B  #TC_DBL_BUF,D0          ; 92 Enables Double Buffer
    MOVE.B  #17,        D1          ; Combine Tasks
	TRAP	#15                     ; Trap (Perform action)

    ; Clear the screen 
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W  #$FF00,     D1          ; Fill Screen Clear
	TRAP	#15                     ; Trap (Perform action)

*-----------------------------------------------------------
* Subroutine    : Game
* Description   : Game including main GameLoop. GameLoop is like
* a while loop in that it runs forever until interupted
* (Input, Update, Draw). The Enemies Run at Player Jump to Avoid
*-----------------------------------------------------------
GAME:
    BSR     PLAY_RUN                ; Play Run Wav
    BSR     PLAY_BACKGROUND
GAMELOOP:
  
    ; Main Gameloop
    BSR     INPUT                   ; Check Keyboard Input
    BSR     UPDATE                  ; Update positions and points
    BSR     IS_PLAYER_ON_GND        ; Check if player is on ground
    BSR     CHECK_COLLISIONS        ; Check for Collisions
    BSR     DRAW                    ; Draw the Scene
    BRA     GAMELOOP                ; Loop back to GameLoop

*-----------------------------------------------------------
* Subroutine    : Input
* Description   : Process Keyboard Input
*-----------------------------------------------------------
INPUT:
    ; Process Input
    CLR.L   D1                      ; Clear Data Register
    MOVE.B  #TC_KEYCODE,D0          ; Listen for Keys
    TRAP    #15                     ; Trap (Perform action)
    MOVE.B  D1,         D2          ; Move last key D1 to D2
    CMP.B   #00,        D2          ; Key is pressed
    BEQ     PROCESS_INPUT ; Process Key
    TRAP    #15                     ; Trap for Last Key
    ; Check if key still pressed
    CMP.B   #$FF,       D1          ; Is it still pressed
    BEQ     PROCESS_INPUT           ; Process Last Key
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Process Input
* Description   : Branch based on keys pressed
*-----------------------------------------------------------
PROCESS_INPUT:
    MOVE.L  D2,         CURRENT_KEY ; Put Current Key in Memory
    CMP.L   #ESCAPE,    CURRENT_KEY ; Is Current Key Escape
    BEQ     EXIT                    ; Exit if Escape
    CMP.L   #SPACEBAR,  CURRENT_KEY ; Is Current Key Spacebar
    BEQ     JUMP                    ; Jump
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Update
* Description   : Main update loop update Player and Enemies
*-----------------------------------------------------------
UPDATE:

    ; Decrease jump cooldown if active
    CMP.L   #0, JUMP_TIMER
    BEQ     SKIP_TIMER_DEC
    SUB.L   #1, JUMP_TIMER
    
SKIP_TIMER_DEC:
    
    CMP.L   #1, FUEL_ACTIVE          ; Is fuel currently visible?
    BNE     HANDLE_FUEL_RESPAWN      ; If NOT active, handle respawn timer

    ;fuel is active
    MOVE.L  FUEL_X, D1               ; Load current fuel X position
    SUB.L   #1, D1                   ; Move fuel left by 1 pixel
    MOVE.L  D1, FUEL_X               ; Store new X position

    CMP.L   #0, D1                   ; Has fuel gone off left side?
    BGT     FUEL_DONE                ; If still on screen, finish update

    MOVE.L  #0, FUEL_ACTIVE          ; Off screen ? hide fuel
    CLR.L   FUEL_RESPAWN_TIMER       ; Reset respawn timer to 0
    BRA     FUEL_DONE                ; Skip respawn logic for now
      
    ; fuel is not active
HANDLE_FUEL_RESPAWN:
    ADD.L   #1, FUEL_RESPAWN_TIMER
    CMP.L   #180, FUEL_RESPAWN_TIMER
    BLT     FUEL_DONE

    ; Respawn fuel
    CLR.L   FUEL_RESPAWN_TIMER

    MOVE.W  SCREEN_W, D1
    MOVE.L  D1, FUEL_X



    MOVE.L  #1, FUEL_ACTIVE   
FUEL_DONE:    ; Update the Players Positon based on Velocity and Gravity
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.L  PLYR_VELOCITY, D1       ; Fetch Player Velocity
    MOVE.L  PLYR_GRAVITY, D2        ; Fetch Player Gravity
    ADD.L   D2,         D1          ; Add Gravity to Velocity
    MOVE.L  D1,         PLYR_VELOCITY ; Update Player Velocity
    CMP.L   #2, D1
    BLE     NO_FALL_LIMIT
    MOVE.L  #2, D1
    MOVE.L  D1, PLYR_VELOCITY
    
NO_FALL_LIMIT:
    ADD.L   PLAYER_Y,   D1          ; Add Velocity to Player
    MOVE.L  D1,         PLAYER_Y    ; Update Players Y Position 

   ;-----------------------------------
; Check SMALL zombie position
;-----------------------------------

    CLR.L   D1
    MOVE.L  SMALLZOMB_X, D1      ; Load small zombie X
    CMP.L   #0, D1               ; Has it reached left side?
    BLE     RESET_SMALL_ZOMBIE   ; If yes reset it

;-----------------------------------
; Check LARGE zombie position
;-----------------------------------

    CLR.L   D1
    MOVE.L  LARGEZOMB_X, D1      ; Load large zombie X
    CMP.L   #0, D1               ; Has it reached left side?
    BLE     RESET_LARGE_ZOMBIE   ; If yes reset it

;-----------------------------------
; Move both zombies
;-----------------------------------

    BSR     MOVE_ZOMBIE  
    
    ; Move building left
    SUB.L #1, BUILDING_X               ; Move 1 pixel left
    ; Reset building if it is offscreen (like small zombie)
    CMP.L #0, BUILDING_X
    BGE SKIP_BUILDING_RESET
    ; Offscreen: reset to right side
    MOVE.W SCREEN_W, D1
    MOVE.L D1, BUILDING_X

SKIP_BUILDING_RESET:

    ;Fuel Cowuntdown
    ADD.L   #1, FUEL_TIMER          ; increment timer per update
    CMP.L   #60, FUEL_TIMER         ; check if ~1 second passed (adjust if needed)
    BLT     SKIP_FUEL_DECREMENT     ; if not, skip decrement
    SUB.L   #1, FUEL                ; decrease fuel by 1
    CLR.L   FUEL_TIMER              ; reset timer
    CMP.L   #0, FUEL
    BGT     SKIP_GAME_OVER          ; if fuel > 0, skip game over
    BSR     EXIT                     ; fuel is 0 ? end game
SKIP_FUEL_DECREMENT:             ; label to continue normal update
SKIP_GAME_OVER:
            
    RTS                             ; Return to subroutine  
*-----------------------------------------------------------
* Subroutine    : Move Enemy
* Description   : Move Enemy Right to Left
*-----------------------------------------------------------
MOVE_ZOMBIE:
    ;move zombies by X values
    SUB.L   #1,        SMALLZOMB_X   
    SUB.L   #2,        LARGEZOMB_X
    
    ;DELAY loop
    MOVE.L  #3000,  D0
    
DELAY_LOOP:
    SUB.L   #1, D0
    BNE     DELAY_LOOP
    RTS
*-----------------------------------------------------------
* Subroutine    : Reset Small Zombie
* Description   : Resets the small zombie position when it moves off the right side of the screen.
*-----------------------------------------------------------
RESET_SMALL_ZOMBIE:
    CLR.L   D1                  ; Clear D1 register 
    MOVE.W  SCREEN_W, D1        ; Load screen width into D1 
    MOVE.L  D1, SMALLZOMB_X     ; Set small zombie's X position to right side of screen

    ; Reset Y position to middle of screen
    CLR.L   D1                  ; Clear D1 again
    MOVE.W  SCREEN_H, D1        ; Load screen height into D1
    DIVU    #2, D1              ; Divide D1 by 2 to get middle of screen
    MOVE.L  D1, SMALLZOMB_Y     ; Set small zombie's Y position to vertical center

    RTS                         ; Return from subroutine

*-----------------------------------------------------------
* Subroutine    : Reset Large Zombie
* Description   : Resets the large zombie position when it moves off the right side of the screen.
*-----------------------------------------------------------
RESET_LARGE_ZOMBIE:
    CLR.L   D1                  ; Clear D1 register
    MOVE.W  SCREEN_W, D1        ; Load screen width into D1
    ADD.L   #10, D1             ; Offset further right to spawn outside screen
    MOVE.L  D1, LARGEZOMB_X     ; Set large zombie's X position

    ; Reset Y position to middle of screen
    CLR.L   D1                  ; Clear D1
    MOVE.W  SCREEN_H, D1        ; Load screen height
    DIVU    #2, D1              ; Divide by 2 to center vertically
    MOVE.L  D1, LARGEZOMB_Y     ; Set large zombie's Y position

    RTS                         ; Return from subroutine    
*----------------------------------------------------------
* Subroutine    : Draw
* Description   : Draw Screen
*-----------------------------------------------------------
DRAW: 
    ; Enable back buffer
    MOVE.B  #94,        D0
    TRAP    #15

    ; Clear the screen
    MOVE.B	#TC_CURSR_P,D0          ; Set Cursor Position
	MOVE.W	#$FF00,     D1          ; Clear contents
	TRAP    #15                     ; Trap (Perform action)
	
	BSR     DRAW_ROAD
    BSR     DRAW_BUILDING
    BSR     DRAW_PLYR_DATA          ; Draw Draw Score, HUD, Player X and Y
    BSR     DRAW_PLAYER             ; Draw Player
    BSR     DRAW_SMALLZOMB          ; Draw small zombie
    BSR     DRAW_LARGEZOMB          ; Draw large zombie
    
    ;Draw Fuel and Repair Kits
    BSR     DRAW_FUEL


    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Draw Player Data
* Description   : Draw Player X, Y, Velocity, Gravity and OnGround
*-----------------------------------------------------------
DRAW_PLYR_DATA:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)

    ; Display Kill Counter
    MOVE.B #TC_CURSR_P, D0       ; Set cursor
    MOVE.W #$0201, D1            ; Row 1, Column 2
    TRAP #15                      ; Position cursor
    LEA KILL_MSG, A1              ; "Kills: " message
    MOVE #13, D0                  ; No line feed
    TRAP #15                      ; Print message

    MOVE.B #TC_CURSR_P, D0       ; Set cursor
    MOVE.W #$0801, D1            ; Row 1, Column 8 (after "Kills: ")
    TRAP #15                      ; Position cursor
    MOVE.L KILL_COUNT, D1        ; Load kill count
    MOVE.B #03, D0                ; Display as number
    TRAP #15                      ; Print count

    ; display fuel
    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  #$0202, D1              ; column 2, row 2
    TRAP    #15
    LEA     FUEL_MSG_LABEL, A1      ; pointer to "Fuel: "
    MOVE    #13, D0                 ; no linefeed
    TRAP    #15

    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  #$0902, D1              ; column 9, row 2 for value
    TRAP    #15
    MOVE.L  FUEL, D1                ; current fuel value
    MOVE.B  #03, D0                 ; display as number
    TRAP    #15
    
    ; display hull integrity
    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  #$0203, D1              ; c
    TRAP    #15
    LEA     HULL_INTEGRITY_LABEL, A1      ; pointer to "Hull Integrity: "
    MOVE    #13, D0                 ; no linefeed
    TRAP    #15

    MOVE.B  #TC_CURSR_P, D0
    MOVE.W  #$1003, D1              ; 
    TRAP    #15
    MOVE.L  HULL_INTEGRITY, D1                ; current fuel value
    MOVE.B  #03, D0                 ; display as number
    TRAP    #15

 
    RTS  
    
*-----------------------------------------------------------
* Subroutine    : Player is on Ground
* Description   : Check if the Player is on or off Ground
*-----------------------------------------------------------
IS_PLAYER_ON_GND:
    ; Check if Player is on Ground
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    CLR.L   D2                      ; Clear contents of D2 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  PLAYER_Y,   D2          ; Player Y Position
    CMP.L   D1,         D2        ; Compare middle of Screen with Players Y Position 
    BLT     SET_OFF_GROUND           ; The Player is on the Ground Plane
    BRA     SET_ON_GROUND          ; The Player is off the Ground
                              


*-----------------------------------------------------------
* Subroutine    : On Ground
* Description   : Set the Player On Ground
*-----------------------------------------------------------
SET_ON_GROUND:
    CLR.L   D1                      ; Clear contents of D1 (XOR is faster)
    MOVE.W  SCREEN_H,   D1          ; Place Screen width in D1
    DIVU    #02,        D1          ; divide by 2 for center on Y Axis
    MOVE.L  D1,         PLAYER_Y    ; Reset the Player Y Position
    CLR.L   PLYR_VELOCITY                     ; Clear contents of D1 (XOR is faster)
    MOVE.L  #GND_TRUE,  PLYR_ON_GND ; Player is on Ground
    RTS

*-----------------------------------------------------------
* Subroutine    : Off Ground
* Description   : Set the Player Off Ground
*-----------------------------------------------------------
SET_OFF_GROUND:
    MOVE.L  #GND_FALSE, PLYR_ON_GND ; Player if off Ground
    RTS                             ; Return to subroutine
*-----------------------------------------------------------
* Subroutine    : Jump
* Description   : Perform a Jump
*-----------------------------------------------------------
JUMP:
    CMP.L   #GND_TRUE, PLYR_ON_GND
    BNE     JUMP_DONE              ; Must be on ground

    CMP.L   #0, JUMP_TIMER
    BNE     JUMP_DONE              ; Cooldown still active

    BSR     PLAY_JUMP
    MOVE.L  #PLYR_JUMP_V, PLYR_VELOCITY

    MOVE.L  #100, JUMP_TIMER        ; Cooldown length (adjust this)

JUMP_DONE:
    RTS


*-----------------------------------------------------------
* Subroutines   : Sound Load and Play
* Description   : Initialise game sounds into memory 
* Current Sounds are RUN, JUMP and Opps for Collision
*-----------------------------------------------------------
RUN_LOAD:
    LEA     RUN_WAV,    A1          ; Load Wav File into A1
    MOVE    #RUN_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_RUN:
    MOVE    #RUN_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

JUMP_LOAD:
    LEA     JUMP_WAV,   A1          ; Load Wav File into A1
    MOVE    #JMP_INDEX, D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_JUMP:
    MOVE    #JMP_INDEX, D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

OPPS_LOAD:
    LEA     OPPS_WAV,   A1          ; Load Wav File into A1
    MOVE    #OPPS_INDEX,D1          ; Assign it INDEX
    MOVE    #71,        D0          ; Load into memory
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

PLAY_OPPS:
    MOVE    #OPPS_INDEX,D1          ; Load Sound INDEX
    MOVE    #72,        D0          ; Play Sound
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
BACKGROUND_LOAD:
    LEA     BACKGROUND_WAV,    A1       ; Load WAV file pointer
    MOVE    #BACKGROUND_INDEX, D1       ; Assign it a free index
    MOVE    #71,        D0       ; Load into memory
    TRAP    #15
    RTS
PLAY_BACKGROUND:
    MOVE    #BACKGROUND_INDEX, D1       ; Load Sound Index
    MOVE    #72,        D0       ; Play sound
    TRAP    #15
    RTS
    
*-----------------------------------------------------------
* Subroutine    : Draw Player
* Description   : Draw Player Square
*-----------------------------------------------------------
DRAW_PLAYER:
    ; Set Pixel Colors
    MOVE.L  #WHITE,     D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  PLAYER_X,   D1          ; X
    MOVE.L  PLAYER_Y,   D2          ; Y
    MOVE.L  PLAYER_X,   D3
    ADD.L   #PLYR_W_INIT,   D3      ; Width
    MOVE.L  PLAYER_Y,   D4 
    ADD.L   #PLYR_H_INIT,   D4      ; Height
    
    ; Draw Player
    MOVE.B  #87,        D0          ; Draw Player
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

*-----------------------------------------------------------
* Subroutine    : Draw small zombie
* Description   : Draw small zombie Square
*-----------------------------------------------------------
DRAW_SMALLZOMB:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  SMALLZOMB_X,    D1          ; X
    MOVE.L  SMALLZOMB_Y,    D2          ; Y
    MOVE.L  SMALLZOMB_X,    D3
    ADD.L   #SMALLZOMB_W_INIT,   D3      ; Width
    MOVE.L  SMALLZOMB_Y,    D4 
    ADD.L   #SMALLZOMB_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine
    
*-----------------------------------------------------------
* Subroutine    : Draw large zombie
* Description   : Draw large zombie Square
*-----------------------------------------------------------
DRAW_LARGEZOMB:
    ; Set Pixel Colors
    MOVE.L  #RED,       D1          ; Set Background color
    MOVE.B  #80,        D0          ; Task for Background Color
    TRAP    #15                     ; Trap (Perform action)

    ; Set X, Y, Width and Height
    MOVE.L  LARGEZOMB_X,    D1          ; X
    MOVE.L  LARGEZOMB_Y,    D2          ; Y
    MOVE.L  LARGEZOMB_X,    D3
    ADD.L   #LARGEZOMB_W_INIT,   D3      ; Width
    MOVE.L  LARGEZOMB_Y,    D4 
    ADD.L   #LARGEZOMB_H_INIT,   D4      ; Height
    
    ; Draw Enemy    
    MOVE.B  #87,        D0          ; Draw Enemy
    TRAP    #15                     ; Trap (Perform action)
    RTS                             ; Return to subroutine

    
*-------------------------------------------------
*DRAW_FUEL
*--------------------------------------------------
DRAW_FUEL:
    ; Only draw if fuel is active
    CMP.L   #1, FUEL_ACTIVE
    BNE     SKIP_DRAW_FUEL

    ; Set color to GREEN
    MOVE.L  #GREEN, D1
    MOVE.B  #80, D0           ; Task for background color
    TRAP    #15

    ; Draw fuel bar rectangle
    MOVE.L  FUEL_X, D1         ; X start
    MOVE.L  FUEL_Y, D2         ; Y start
    MOVE.L  FUEL_X, D3         ; X end
    ADD.L   #FUEL_W_INIT, D3           ; Width = current fuel
    MOVE.L  FUEL_Y, D4         ; Y end
    ADD.L   #FUEL_H_INIT, D4             ; Height of bar
    
    ;Draw fuel
    MOVE.B  #87, D0            ; Draw rectangle
    TRAP    #15
SKIP_DRAW_FUEL:
    RTS
    
*-------------------------------------------------
*DRAW_BUILDING
*--------------------------------------------------

DRAW_BUILDING:
    MOVE.L #WHITE, D1
    MOVE.B #80, D0      ; Set color
    TRAP #15

    MOVE.L BUILDING_X, D1
    MOVE.L BUILDING_Y, D2
    MOVE.L BUILDING_X, D3
    ADD.L #BUILDING_W, D3
    MOVE.L BUILDING_Y, D4
    ADD.L #BUILDING_H, D4

    MOVE.B #87, D0      ; Draw rectangle
    TRAP #15
    RTS
    
DRAW_ROAD:
    MOVE.L #WHITE, D1
    MOVE.B #80, D0
    TRAP #15

    MOVE.L #0, D1             ; X start
    MOVE.L ROAD_Y, D2         ; Y start
    MOVE.L SCREEN_W, D3       ; X end
    MOVE.L ROAD_Y, D4
    ADD.L #ROAD_HEIGHT, D4    ; Y end
    MOVE.B #87, D0
    TRAP #15
    RTS
*-----------------------------------------------------------
* Subroutine    : Collision Check
* Description   : Axis-Aligned Bounding Box Collision Detection
* Algorithm checks for overlap on the 4 sides of the Player and 
* Enemy rectangles
* PLAYER_X <= ENEMY_X + ENEMY_W &&
* PLAYER_X + PLAYER_W >= ENEMY_X &&
* PLAYER_Y <= ENEMY_Y + ENEMY_H &&
* PLAYER_H + PLAYER_Y >= ENEMY_Y
*-----------------------------------------------------------
CHECK_COLLISIONS:

; -----------------------------
; Check Small Zombie Collision
; -----------------------------
    CLR.L   D1                  ; Clear D1 to use as temporary register
    CLR.L   D2                  ; Clear D2 to use as temporary register

; X-axis: Check if player's left side is to the left of small zombie's right side
    MOVE.L  PLAYER_X, D1        ; D1 = PLAYER_X 
    MOVE.L  SMALLZOMB_X, D2     ; D2 = SMALLZOMB_X 
    ADD.L   SMALLZOMB_W_INIT, D2 ; D2 = zombie's right X
    CMP.L   D1, D2              ; Compare player's left X with zombie's right X
    BGT     CHECK_LARGEZOMB_COLLISION  ; If player is completely to the right, skip

; X-axis: Check if player's right side is to the right of small zombie's left side
    MOVE.L  PLAYER_X, D1        ; D1 = PLAYER_X
    ADD.L   PLYR_W_INIT, D1     ; D1 = player's right X
    MOVE.L  SMALLZOMB_X, D2     ; D2 = zombie's left X
    CMP.L   D1, D2              ; Compare player's right X with zombie's left X
    BLT     CHECK_LARGEZOMB_COLLISION  ; If player is completely to the left, skip

; Y-axis: Check if player's top is above small zombie's bottom
    MOVE.L  PLAYER_Y, D1        ; D1 = PLAYER_Y 
    MOVE.L  SMALLZOMB_Y, D2     ; D2 = zombie's top Y
    ADD.L   SMALLZOMB_H_INIT, D2 ; D2 = zombie's bottom Y
    CMP.L   D1, D2              ; Compare player's top Y with zombie's bottom Y
    BGT     CHECK_LARGEZOMB_COLLISION  ; If player is below zombie, skip

; Y-axis: Check if player's bottom is below small zombie's top
    MOVE.L  PLAYER_Y, D1        ; D1 = PLAYER_Y
    ADD.L   PLYR_H_INIT, D1     ; D1 = player's bottom Y
    MOVE.L  SMALLZOMB_Y, D2     ; D2 = zombie's top Y
    CMP.L   D1, D2              ; Compare player's bottom Y with zombie's top Y
    BLT     CHECK_LARGEZOMB_COLLISION  ; If player is above zombie, skip

; Collision confirmed for small zombie
    BSR     SMALLZOMB_COLLISION ; Call small zombie collision handler
    BRA     COLLISION_CHECK_DONE ; Skip large zombie check after collision

; -----------------------------
; Check Large Zombie Collision
; -----------------------------
CHECK_LARGEZOMB_COLLISION:
    CLR.L   D1                  ; Clear D1
    CLR.L   D2                  ; Clear D2

; X-axis: Check if player's left side is to the left of large zombie's right side
    MOVE.L  PLAYER_X, D1
    MOVE.L  LARGEZOMB_X, D2
    ADD.L   LARGEZOMB_W_INIT, D2
    CMP.L   D1, D2
    BGT     CHECK_FUEL_COLLISION  ; Skip if no horizontal overlap

; X-axis: Check if player's right side is to the right of large zombie's left side
    MOVE.L  PLAYER_X, D1
    ADD.L   PLYR_W_INIT, D1
    MOVE.L  LARGEZOMB_X, D2
    CMP.L   D1, D2
    BLT     CHECK_FUEL_COLLISION  ; Skip if no horizontal overlap

; Y-axis: Check if player's top is above large zombie's bottom
    MOVE.L  PLAYER_Y, D1
    MOVE.L  LARGEZOMB_Y, D2
    ADD.L   LARGEZOMB_H_INIT, D2
    CMP.L   D1, D2
    BGT     CHECK_FUEL_COLLISION  ; Skip if no vertical overlap

; Y-axis: Check if player's bottom is below large zombie's top
    MOVE.L  PLAYER_Y, D1
    ADD.L   PLYR_H_INIT, D1
    MOVE.L  LARGEZOMB_Y, D2
    CMP.L   D1, D2
    BLT     CHECK_FUEL_COLLISION  ; Skip if no vertical overlap

    BSR     LARGEZOMB_COLLISION ; Call large zombie collision 
; -----------------------------
; Check Fuel Collision
; ----------------------------- 
CHECK_FUEL_COLLISION:

    CMP.L   #1, FUEL_ACTIVE          ; Is the fuel currently visible?
    BNE     COLLISION_CHECK_DONE    ; If not active, skip collision check

    CLR.L   D1                        ; Clear D1 for calculations
    CLR.L   D2                        ; Clear D2 for calculations


    ; Check X-axis overlap
    MOVE.L  PLAYER_X, D1              ; Load player X position
    MOVE.L  FUEL_X, D2                ; Load fuel X position
    ADD.L   FUEL_W_INIT, D2           ; Add fuel width to get right edge
    CMP.L   D1, D2                     ; Compare left side of player with right side of fuel
    BLE     FUEL_X2_CHECK              ; If player left <= fuel right, continue X check
    BRA     COLLISION_CHECK_DONE         ; Otherwise, no collision

FUEL_X2_CHECK:
    ; Check second X-axis overlap: PLAYER_X + PLAYER_W_INIT >= FUEL_X
    ADD.L   PLYR_W_INIT, D1           ; Add player width to get right side of player
    MOVE.L  FUEL_X, D2                ; Reload fuel X
    CMP.L   D1, D2                     ; Compare right side of player to left side of fuel
    BGE     FUEL_Y1_CHECK              ; If player right >= fuel left, continue Y check
    BRA     COLLISION_CHECK_DONE        ; Otherwise, no collision

FUEL_Y1_CHECK:
    ; Check Y-axis overlap: PLAYER_Y <= FUEL_Y + FUEL_H_INIT
    MOVE.L  PLAYER_Y, D1              ; Load player Y position
    MOVE.L  FUEL_Y, D2                ; Load fuel Y position
    ADD.L   FUEL_H_INIT, D2           ; Add fuel height to get bottom of fuel
    CMP.L   D1, D2                     ; Compare top of player with bottom of fuel
    BLE     FUEL_Y2_CHECK              ; If player top <= fuel bottom, continue Y check
    BRA     COLLISION_CHECK_DONE       ; Otherwise, no collision

FUEL_Y2_CHECK:
    ; Check second Y-axis overlap
    ADD.L   PLYR_H_INIT, D1           ; Add player height to get bottom of player
    MOVE.L  FUEL_Y, D2                ; Reload fuel Y
    CMP.L   D1, D2                     ; Compare bottom of player with top of fuel
    BGE     FUEL_COLLECTED             ; If overlap confirmed, fuel collected
    BRA     COLLISION_CHECK_DONE         ; Otherwise, no collision

FUEL_COLLECTED:
    ;Fuel collected, update fuel and hide
    MOVE.L  FUEL, D1                  ; Load current fuel amount
    ADD.L   #12, D1                   ; Add 15 fuel (adjustable)
    CMP.L   #FUEL_MAX,  D1                   ;check if it goes over max
    BLE     FUEL_OK                     ;if fuel is is <= 100, then ok
    MOVE.L  #FUEL_MAX,  D1                ;otherwise stay to 100
FUEL_OK:
    MOVE.L  D1, FUEL
    MOVE.L  #0, FUEL_ACTIVE           ; Hide fuel until next respawn
    CLR.L   FUEL_RESPAWN_TIMER        ; Reset respawn timer
    BRA     COLLISION_CHECK_DONE      ; Finish fuel collision check
    
COLLISION_CHECK_DONE:

    ; Continue normal collision logic
    ADD.L   PLAYER_SCORE, D1          ; Update player score
    MOVE.L  D1, PLAYER_SCORE
    RTS                                ; Return from subroutine
; ENEMY COLLISION RESPONSE

SMALLZOMB_COLLISION:
    BSR     PLAY_OPPS
    MOVE.L  #0, PLAYER_SCORE
    ;small zombie kill count
    
    MOVE.L  KILL_COUNT, D1
    ADD.L   #1, D1
    MOVE.L  D1, KILL_COUNT
    ;reset small zombie psoiton
    
    MOVE.W  SCREEN_W, D1
    MOVE.L  D1, SMALLZOMB_X
    BRA     CHECK_FUEL_COLLISION
    
LARGEZOMB_COLLISION:
    BSR     PLAY_OPPS
    ; Reduce hull integrity
    MOVE.L  HULL_INTEGRITY, D1
    SUB.L   #10, D1           ; Damage value
    CMP.L   #0, D1
    BGE     HULL_OK
    MOVE.L  #0, D1            ; Hull cannot go below 0
HULL_OK:
    MOVE.L  D1, HULL_INTEGRITY
    
    CMP.L   #0, HULL_INTEGRITY        ; Is hull 0?
    BEQ     EXIT                       ; If yes, go to exit and end game

    ; Reset large zombie X position
    MOVE.W  SCREEN_W, D1
    MOVE.L  D1, LARGEZOMB_X
    BRA     CHECK_FUEL_COLLISION    
    
*-----------------------------------------------------------
* Subroutine    : EXIT
* Description   : Exit message and End Game
*-----------------------------------------------------------
EXIT:
    ; Show if Exiting is Running
    MOVE.B  #TC_CURSR_P,D0          ; Set Cursor Position
    MOVE.W  #$4004,     D1          ; Col 40, Row 1
    TRAP    #15                     ; Trap (Perform action)
    LEA     EXIT_MSG,   A1          ; Exit
    MOVE    #13,        D0          ; No Line feed
    TRAP    #15                     ; Trap (Perform action)
    
    MOVE.B  #TC_EXIT,   D0          ; Exit Code
    TRAP    #15                     ; Trap (Perform action)
    
    SIMHALT

*-----------------------------------------------------------
* Section       : Messages
* Description   : Messages to Print on Console, names should be
* self documenting
*-----------------------------------------------------------
GAME_TITLE_MSG DC.B '*** WELCOME TO ZOMBIE SPLATTER ***',0
START_MSG      DC.B 'Press SPACE to Start',0
OBEJECTIVE_TITLE    DC.B    'Main Objectives', 0
OBJECTIVE_1    DC.B    'DONT RUN OUT OF FUEL! - Pick up fuel that spawns to replenish - Green Rectangle', 0
OBJECTIVE_2    DC.B    'KIll small zombies to increase kill counter - small red square', 0
OBJECTIVE_3    DC.B    'Avoid the large the zombies or your hull gets damaged - large red square', 0

SCORE_MSG       DC.B    'Score : ', 0       ; Score Message
KEYCODE_MSG     DC.B    'KeyCode : ', 0     ; Keycode Message
JUMP_MSG        DC.B    'Jump....', 0       ; Jump Message

KILL_MSG        DC.B    'Kills: ', 0        ; Kill message
FUEL_MSG        DC.B    'Out of Fuel!', 0   ; Fuel message
HULL_MSG        DC.B    'HULL: ',0
FUEL_MSG_LABEL  DC.B    'Fuel: ', 0
HULL_INTEGRITY_LABEL    DC.B    'Hull Integrity: ', 0
IDLE_MSG        DC.B    'Idle....', 0       ; Idle Message
UPDATE_MSG      DC.B    'Update....', 0     ; Update Message
DRAW_MSG        DC.B    'Draw....', 0       ; Draw Message

X_MSG           DC.B    'X:', 0             ; X Position Message
Y_MSG           DC.B    'Y:', 0             ; Y Position Message
V_MSG           DC.B    'V:', 0             ; Velocity Position Message
G_MSG           DC.B    'G:', 0             ; Gravity Position Message
GND_MSG         DC.B    'GND:', 0           ; On Ground Position Message


GAME_OVER_MSG DC.B '*** GAME OVER ***',0
RESTART_MSG   DC.B 'Press SPACE to Restart',0
EXIT_GAME_MSG DC.B 'Press ESCAPE to Exit',0
EXIT_MSG        DC.B    'Exiting....', 0    ; Exit Message

*-----------------------------------------------------------
* Section       : Graphic Colors
* Description   : Screen Pixel Color
*-----------------------------------------------------------
WHITE           EQU     $00FFFFFF   ;white color for player
RED             EQU     $000000FF   ;red color for zombies
GREEN           EQU     $0000FF00  ; Green color for fuel
GREY            EQU     $80FFFFFF     ;grey color for repair kit 

*-----------------------------------------------------------
* Section       : Screen Size
* Description   : Screen Width and Height
*-----------------------------------------------------------
SCREEN_W        DS.W    01  ; Reserve Space for Screen Width
SCREEN_H        DS.W    01  ; Reserve Space for Screen Height

*-----------------------------------------------------------
* Section       : Keyboard Input
* Description   : Used for storing Keypresses
*-----------------------------------------------------------
CURRENT_KEY     DS.L    01  ; Reserve Space for Current Key Pressed

*-----------------------------------------------------------
* Section       : Character Positions
* Description   : Player and Enemy Position Memory Locations
*-----------------------------------------------------------
PLAYER_X        DS.L    01  ; Reserve Space for Player X Position
PLAYER_Y        DS.L    01  ; Reserve Space for Player Y Position
JUMP_TIMER      DS.L    01  ; Jump cooldown timer
PLAYER_SCORE    DS.L    01  ; Reserve Space for Player Score

PLYR_VELOCITY   DS.L    01  ; Reserve Space for Player Velocity
PLYR_GRAVITY    DS.L    01  ; Reserve Space for Player Gravity
PLYR_ON_GND     DS.L    01  ; Reserve Space for Player on Ground

SMALLZOMB_X     DS.L    01  ; Reserve Space for small zombie X Position
SMALLZOMB_Y     DS.L    01  ; Reserve Space for small zombie Y Position

ZOMBIE_SOUND_ACTIVE  DC.l 0   ; 0 = sound not playing, 1 = playing

LARGEZOMB_X     DS.L    01  ; Reserve Space for large zombie X Position
LARGEZOMB_Y     DS.L    01  ; Reserve Space for large zombie Y Position

BUILDING_X      DS.L    01    ; X position
BUILDING_Y      DS.L    01   ; Y position 

ROAD_Y          DS.L    1       ; Y position of road 

HULL_INTEGRITY  DC.L    01      ;

KILL_COUNT      DS.L    01  ; reserve space for kill counter
FUEL            DS.L    01  ; Player fuel
FUEL_TIMER      DS.L    01   ; Counts frames for fuel decrease
FUEL_RESPAWN_TIMER   DS.L   1

FUEL_X         DS.L  1  ; Fuel X position
FUEL_Y         DS.L  1  ; Fuel Y position
FUEL_ACTIVE    DS.L  1  ; 1 if visible, 0 if not
FUEL_AMOUNT    EQU    10 ; How much fuel is restored when collected

*-----------------------------------------------------------
* Section       : Sounds
* Description   : Sound files, which are then loaded and given
* an address in memory, they take a longtime to process and play
* so keep the files small. Used https://voicemaker.in/ to 
* generate and Audacity to convert MP3 to WAV
*-----------------------------------------------------------
JUMP_WAV        DC.B    'jump.wav',0        ; Jump Sound
RUN_WAV         DC.B    'run.wav',0         ; Run Sound
OPPS_WAV        DC.B    'opps.wav',0        ; Collision Opps
BACKGROUND_WAV  DC.B    'Zombie_Song.wav', 0


    END    START        ; last line of source













*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
