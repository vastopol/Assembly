LC3 Subroutine Libraies:
--------------------------
- I/O     -> {BIN_IN, BIN_OUT, DEC_IN, DEC_OUT}
- Bitwise -> {OR, XOR, NOR, XNOR} 
- Math    -> {SUB, MUL, DIV, MOD} 
- Trap

Locations in memory space:
--------------------------
* I/O  x4000 to x4300
* Bits x5000 to x5300
* Math x6000 to x6300

====================================================

INPUT/OUTPUT SUBROUTINE SYNTAX:
------------------------------
R1: SUBROUTINE POINTER
R2: VALUE

What this means:
- The expected input value will be returned in R2
- output value must be in R2 before subroutine call

BIN_IN  = input a string of binary upto 16 bits
BIN_OUT = print a string of binary 16 bits
DEC_IN  = input signed 5 digit number 
DEC_OUT = print a signed 5 digit number

=====================================================

BITWISE && MATH SUBROUTINE SYNTAX:
---------------------
R1: SUBROUTINE POINTER
R2: VARIABLE A
R3: VARIABLE B
R4: RESULT

What this means:
- "Return values" are to be expected in register R4
- computation will happen mostly in registers R4, R5, and R6
- register R7 is used for return address only
- for math routines numbers are 16 bit 2's compliment integers

===========================================================
    


** A core library containing
   modified versions of Trap routines

Trap x20 GETC read a single character (no echo)
Trap x21 OUT  output a character to the monitor
Trap x22 PUTS write a string to the console
Trap x23 IN   print prompt to console, read and echo character from keyboard
Trap x25 HALT halt the program

have: in, out, halt, puts