		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

dseg		segment	para public 'data'

String1		byte	"Hello there, how are you?",0
String2		byte	"Hi there, how are you?",0

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg




MatchPre	proc	far		;Must be far!
		push	bp
		mov	bp, sp
		push	ax
		push	ds
		push	si
		push	di

		lds	si, 2[bp]	;Get the return address.
CmpLoop:	mov	al, ds:[si]	;Get string to match.
		cmp	al, 0		;If at end of prefix,
		je	Success		; we succeed.
		cmp	al, es:[di]	;See if it matches prefix,
		jne	Failure		; if not, immediately fail.
		inc	si
		inc	di
		jmp	CmpLoop

Success:	add	sp, 2		;Don't restore di.
		inc	si		;Skip zero terminating byte.
		mov	2[bp], si	;Save as return address.
		pop	si
		pop	ds
		pop	ax
		pop	bp
		stc			;Return success.
		ret

Failure:        inc	si		;Need to skip to zero byte.
		cmp	byte ptr ds:[si], 0
		jne	Failure
		inc	si
		pop	di
		mov	2[bp], si	;Save as return address.
		pop	si
		pop	ds
		pop	ax
		pop	bp
		clc			;Return failure.
		ret
MatchPre	endp


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

		meminit

		lesi    String1
		call	MatchPre
		byte	"Hello",0
		jc	Success1
		print
		byte	"String1 does not begin with 'Hello'",cr,lf,0
		jmp	Try2

Success1:	print
		byte	"String1 begins with 'Hello'",cr,lf,0

Try2:		lesi	String2
		call	MatchPre
		byte	"Hello",0
		jc	Success2
		print
		byte	"String2 does not begin with 'Hello'",cr,lf,0
		jmp	Quit

Success2:	print
		byte	"String2 begins with 'Hello'",cr,lf,0



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
