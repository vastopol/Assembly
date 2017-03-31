; Project #4 for Chapter Four.
; This program will fill the screen with a specified set of values
; when you run it.  Currently, this program is incomplete.  Please
; read the comments carefully to determine where to insert your code
; into this program.


		.386
		option		segment:use16

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


;****************************************************************************
;
; For Loop Support macros  (See Chapter Six for a description of how
; these macros work).



ForLp		macro	LCV, start, stop	;LCV="Loop Ctrl Var"
		local	ForLoop

		ifndef	$$For&LCV&
$$For&LCV&	=	0
		else
$$For&LCV&	=	$$For&LCV& + 1
		endif

;; Emit the instructions to initialize the loop control variable.

		mov	ax, Start
		mov	LCV, ax

;; Output Loop Label:

ForLoop		catstr	<$$For&LCV&>, %$$For&LCV&
&ForLoop&:

;; Output test to see if the loop is done:

		mov	ax, LCV
		cmp	ax, Stop
		jg	@catstr(<$$Next&LCV&>, %$$For&LCV&)
		endm




; Here is the NEXT macro:


Next		macro	LCV
		local	ForDone

		inc	LCV
		jmp	@catstr(<$$For&LCV&>, %$$For&LCV&)
ForDone		catstr	<$$Next&LCV&>, %$$For&LCV&
&ForDone&:
		endm

;****************************************************************************






dseg		segment	para public 'data'

; Insert declarations for the 16-bit integer variables I and J here.

i		word	?
j		word	?


dseg		ends





cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg




; Here's the procedure you need to modify.  On entry, AX contains a word
; to write to display[i,j].  Compute this index in BX and write the value
; in AX to location ES:[bx] (the base address is es:0).

PutScreen	proc
		push	es
		mov	bx, 0b800h	;Change to 0b000h for mono displays.
		mov	es, bx


;****************************************************************************

		mov	bx, i
		imul	bx, 80
		add	bx, j
		add	bx, bx
		mov	es:[bx], ax

; End of your code.
;
;****************************************************************************

		pop	es
		ret
PutScreen	endp










; This is the main program that calls the procedure above (that you should
; have modified).  You shouldn't need to modify this code at all.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


		forlp	j,0,79
		forlp	i,0,24

		mov	ax, 500h+"."	;Colored periods
		call	putscreen

		next	i
		next	j

		getc			;Pause by reading the keyboard.

		forlp	j,0,79
		forlp	i,0,24

		mov	ax, 1000h+" "	;Blue spaces.
		call	Putscreen

		next	i
		next	j


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
