; PROJ7_5.ASM
;
; Boolean Functions.
;
; For this project you are to write several procedures.  One should read the
; four switch inputs and (appropriately) set up the sw1..sw4 variables.
; Another should combine the values in the out1..out4 variables and write
; this combined value to the LEDs.
; You will also need to write four routines to compute the logic functions
; described in the lab manual.



dseg		segment	para public 'data'

OutPort		word	?	;I/O address for LEDs
InPort		word	?	;Input address for switches.


; Put the declarations for the sw1..sw4 and out1..out4 variables here.

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; Read the four switches on your circuitry and store the results (zero or one)
; in the sw1..sw4 variables.  Sw1=1 means switch #1 is in the on position.
; Be sure to preserve all registers you use.

ReadSw		proc
		ret
ReadSw		endp





; PutLEDs-	Takes the four values in out1..out4 (these four variables
;		should contain zero or one) and combine them into a single
;		byte.  Then outputs this byte to the LEDs on your circuit.
;		Be sure to preserve all registers you use.

PutLEDs		proc
		ret
PutLEDs		endp



; The following procedures compute the four logic functions described in
; the lab manual.  Be sure to preserve all the registers you modify.

LFout1		proc
		ret
LFout1		endp


LFout2		proc
		ret
LFout2		endp


LFout3		proc
		ret
LFout3		endp


LFout4		proc
		ret
LFout4		endp



; The main program tests the code above.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax


LogicLoop:	call	ReadSw
		call	LFout1
		call	LFout2
		call	LFout3
		call	LFout4
		call    PutLEDs

		mov	ah, 1		;Test to see if the user has pressed
		int	16h		; a key on the keyboard, repeat the
		jz	LogicLoop	; code above until they do.

		mov	ah, 0		;Eat the key pressed by the user.
		int	16h


Quit:		mov	ah, 4ch			;DOS opcode to quit program.
		int	21h			;Call DOS.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
