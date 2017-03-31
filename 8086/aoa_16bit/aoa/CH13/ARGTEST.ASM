
		include 	stdlib.a
		includelib	stdlib.lib


dseg		segment	para public 'data'
ArgCnt		word	0
dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

; Must call the memory manager initialization routine if you use any
; routine which calls malloc!  ARGV is a good example of a routine which
; calls malloc.

		meminit


		argc			;Get the command line arg count.
		jcxz	Quit		;Quit if no cmd ln args.
		mov	ArgCnt, 1	;Init Cmd Ln count.
PrintCmds:	printf			;Print the
		byte	"\n%2d: ",0
		dword	ArgCnt

		mov	ax, ArgCnt	;Get the next command line guy.
		argv
		puts
		inc	ArgCnt		;Move on to next arg.
		loop	PrintCmds       ;Repeat for each arg.
		putcr


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends



sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends


;zzzzzzseg is required by the standard library routines.

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
