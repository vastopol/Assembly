; This is the companion program to the keycnt TSR.
; This program calls the "MyInt16" routine in the TSR to
; determine the number of keyboard interrupts.  It displays
; the approximate number of keystrokes (keyboard ints/2)
; and quits.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

cseg		segment	para public 'code'
		assume	cs:cseg, ds:nothing

Main		proc
		meminit

		print
		byte	"Approximate number of keys pressed: ",0
		mov	ah, 0FFh
		int	16h
                shr	ax, 1			;Must divide by two.
		putu
		putcr
		ExitPgm

Main		endp
cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
