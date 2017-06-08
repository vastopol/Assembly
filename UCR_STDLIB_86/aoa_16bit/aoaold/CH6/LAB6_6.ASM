		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list
		.nolistmacro


cseg		segment	para public 'code'

proc1		proc	near
		print
		byte	"You have entered proc1"
		byte	cr,lf,0
		ret
proc1		endp

proc2		proc	near
		print
		byte	"You have entered proc2"
		byte	cr,lf,0
		ret
proc2		endp



Main		proc
		print
		byte	"Calling Proc1",cr,lf,0

		call	Proc1

		print
		byte	"Returned from Proc1"
		byte	cr,lf,lf
		byte	"Calling Proc2"
		byte	cr,lf,0

		call	Proc2

		print
		byte	"Returned from Proc2"
		byte	cr,lf,0

Quit:		ExitPgm
Main		endp

cseg            ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
