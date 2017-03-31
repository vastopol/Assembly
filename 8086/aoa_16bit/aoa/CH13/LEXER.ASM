; Lexer.asm
;
; This program displays the individual components on a DOS command line.

		include		stdlib.a
		includelib	stdlib.lib

cseg		segment		byte public 'CODE'
		assume		cs:cseg, ds:dseg, es:dseg, ss:sseg

; Equates into command line-

CmdLnLen	equ	byte ptr es:[80h]	;Command line length
CmdLn		equ	byte ptr es:[81h]	;Command line data

tab		equ	09h

MainPgm		proc	far

; Properly set up the segment registers:

		push	ds			;Save PSP
		mov	ax, seg dseg
		mov	ds, ax
		pop	PSP

;---------------------------------------------------------------

		print
		byte	cr,lf
		byte	'Items on this line:',cr,lf,lf,0

		mov	es, PSP		 	;Point ES at PSP
		lea	bx, CmdLn		;Point at command line
PrintLoop:	print
		byte	cr,lf,'Item: ',0
		call	SkipDelimiters		;Skip over leading delimiters
PrtLoop2:	mov	al, es:[bx]		;Get next character
		call	TestDelimiter		;Is it a delimiter?
		jz	EndOfToken		;Quit this loop if it is
		putc				;Print char if not.
		inc	bx			;Move on to next character
		jmp	PrtLoop2

EndOfToken:	cmp	al, cr			;Carriage return?
		jne	PrintLoop		;Repeat if not end of line

		print
		byte	cr,lf,lf
		byte	'End of command line',cr,lf,lf,0
		ExitPgm
MainPgm		endp

; The following subroutine sets the zero flag if the character in 
; the AL register is one of DOS' six delimiter characters, 
; otherwise the zero flag is returned clear. This allows us to use 
; the JE/JNE instructions afterwards to test for a delimiter.

TestDelimiter	proc	near
		cmp	al, ' '
		jz	ItsOne
		cmp	al,','
		jz	ItsOne
		cmp	al,Tab
		jz	ItsOne
		cmp	al,';'
		jz	ItsOne
		cmp	al,'='
		jz	ItsOne
		cmp	al, cr
ItsOne:		ret
TestDelimiter	endp

; SkipDelimiters skips over leading delimiters on the command 
; line. It does not, however, skip the carriage return at the end 
; of a line since this character is used as the terminator in the 
; main program.

SkipDelimiters	proc	near
		dec	bx			;To offset INC BX below
SDLoop:		inc	bx			;Move on to next character.
		mov	al, es:[bx]		;Get next character
		cmp	al, 0dh 		;Don’t skip if CR.
		jz	QuitSD
		call	TestDelimiter		;See if it’s some other
		jz	SDLoop			; delimiter and repeat.
QuitSD:		ret
SkipDelimiters	endp

cseg		ends

dseg		segment	byte public 'data'

PSP		word	?			;Program segment prefix
dseg		ends

sseg		segment	byte stack 'stack'
stk		word	0ffh dup (?)
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	MainPgm
