Title: ZOMBIE SPLATTER

Written by: Josh Tobin

Date: 06/03/2026

Description: 
ZOMBIE SPLATTER is a 2D side scrolling game. My game is structured into several main parts so for the 
code to work like controlling the menu screen, game 
initialization, the main game loop, player controls, object movement, collision detection, 
and drawing graphics to the screen.

When the program first starts, it is enabled and excuted from the START labe, my program will then 
first call START_MENU routine, this routine displays words to 
the screen like game title and the objectives i have, you can then click the 
space bar to activte the game.

After the game has been acivated the INITIILASE routine begins. This section prepares and intiailies all the code that i have scripted to begin 
at the start of the game such as loading sounds, setting up screen size and initailising the most important 
things such as player's position, velocity, gravity, kill counter, fuel level, hull integrity, and the starting 
positions of the small zombie, large zombie, building, and fuel pickup.

Once intitialisation is complete the program will then enter the GAME routine which contains  the main game loop for this game.
This loop will run throughout the game and controls all that happens. This loop handles important thins such as 
processing player input, updating the positions of game objects, checking for collisions, and redrawing the screen.

The INPUT routine is used to look out for input from the player such as spacebar using trap codes. The input is used
to detect aswell when the player can jump when it is on the ground or when it has reached the ground from a previous jump
so it does not allow infinite jumps. The player is always able to fall back down from a jump land on the ground and then
jump again

The UPDATE routine handles most of the game logic throughout the code. It updates the players vertical movement using velocity and
gravity, it can moves the zombies across the screen and other objects if i wish such as fuel and controls timers for things like 
my jump cooldown and the countdown on my fuel that decreases until it reaches 0.

My program also contains routines for the actual drawing of my game objects that appear on my screen or else nothing would show.
The draw routine used double bufffering to prevent screen glitching and within it calls other routines to be called too. These routines 
draw objects such as the player, zombies, road, building , fuel pick ups and the information in the top left of the corner of the game 
that displays kill count, fuel remainging and my hull integrity.

The key part of my code is the collision routines that ensure that my game logic can work when objects collide with each other.
The collsion check between the player and the other objects that spawn such as the various zombies and the fuel. It uses its 
x-axis and y-axis to calulate a collsion between them. If the player collides with a samll zombie then the kill counter increases, if the
player collides with the large zombie then the hull integrity will decrease by 10 with each hit until 0 then lose, and then if the player 
collides with the fuel then it replenishes the fuel by 12 until the fuel reaches 0 then lose.

Overall my game uses many of these routines to function and to work, which results in functioning gameplay
--------------------------------------------------------------------------------------------------------------
KNOWN BUG: Fuel can sometimes not collide with player and then proceeds to not respawn, 
an issue i tried to fix but I couldnt fix without breaking everything else 

Visual glitches: - road does not reach end of screen 

Game problems: - building only appears once
                - Large zombies and fuel not aligned
                  
