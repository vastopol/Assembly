; Ex8_4.asm
;
; Demonstration of IFDEF to control
; debugging features.  This code
; assumes there are two levels of
; debugging controlled by the two
; symbols DEBUG1 and DEBUG2.  In
; this code example DEBUG1 is
; defined while DEBUG2 is not.

		.xlist
		include	stdlib.a
		.list
		.nolistmacro
		.listif

DEBUG1		=	0

cseg		segment
DummyProc	proc
		ifdef	DEBUG2
		print
		byte	"In DummyProc"
		byte	cr,lf,0
		endif
		ret
DummyProc	endp

Main		proc
		ifdef	DEBUG1
		print
		byte	"Calling DummyProc"
		byte	cr,lf,0
		endif

		call	DummyProc

		ifdef	DEBUG1
		print
		byte	"Return from DummyProc"
		byte	cr,lf,0
		endif
		ret
Main		endp
cseg		ends
		end
