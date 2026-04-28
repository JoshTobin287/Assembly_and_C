Title: Project 2
Written By: Josh Tobin
Desctiption: For my project i converted an EASY 68k program into x86_64 assemlby porgram which does a loop that prompt a user to enter a number twice 3 times, 
with a sum after each prompt which then results in a final sum that adds all prompt numbers togther. The user cannot enter more than 4 numbers, so the maximum number
is set to 9999, and the minumm is 0 so if the user enters more than 5 numbers or a negative then error message will show. Most labels and core functions are very similar
to that of Easy 68k to keep the core functions, chagning the code based on x86 code used.

Project features summarised:
x86_64 NASM assmebly as the main program for conversion \
Uses _start as an entry point for the program to execute
Used C Library functions such as printf and scanf, this is throguhout out my project to help print messages and read input from keyboard
The program executes three times per loop
THe running total is stored in a register
An addition subroutine is used (REGISTER_ADDER), so that the numbers can be added per sum and then the final sum
Input validation has been set 

How the program runs:
First the limit message is displayed to warn users of limit or try again, then user is asked for a number, validate the input of the first number,
then the user is asked for the second number,validate input again and both numbers are added through the REGISTER_ADDER, with the sum of those 
numbers being shown. Lastly ones the 3 loops are completed, the final sum of all three sums are added together to display the final result, then 
program ends.

How to use my program: 
To use my program you must use ./project_02, this will execute the process to begin.


