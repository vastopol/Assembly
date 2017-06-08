; StrDemo.asm-	Demonstration of some of the various UCR Standard Library 
;		string routines.

		include		stdlib.a
		includelib 	stdlib.lib

dseg		segment	para public 'data'

MemAvail	dw	?
String		byte	256 dup (0)

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


Main		proc
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax

		MemInit
		mov	MemAvail, cx
		printf
		db	"There are %x paragraphs of memory available."
		db	cr,lf,lf,0
		dd	MemAvail

; Demonstration of StrTrim:

		print
		db	"Testing strtrim on 'Hello there   '",cr,lf,0
		strdupl
HelloThere1	db	"Hello there   ",0
		strtrim
		mov	al, "'"
		putc
		puts
		putc
		putcr
		free

;Demonstration of StrTrimm:

		print
		db	"Testing strtrimm on 'Hello there   '",cr,lf,0
		lesi	HelloThere1
		strtrimm
		mov	al, "'"
		putc
		puts
		putc
		putcr
		free

; Demonstration of StrBdel

		print
		db	"Testing strbdel on '  Hello there   '",cr,lf,0
		strdupl
HelloThere3	db	"  Hello there   ",0
		strbdel
		mov	al, "'"
		putc
		puts
		putc
		putcr
		free

; Demonstration of StrBdelm

		print
		db	"Testing strbdelm on '  Hello there   '",cr,lf,0
		lesi	HelloThere3
		strbdelm
		mov	al, "'"
		putc
		puts
		putc
		putcr
		free


; Demonstrate StrCpyl:

		ldxi	string
		strcpyl
		byte	"Copy this string to the 'String' variable",0

		printf
		byte	"STRING = '%s'",cr,lf,0
		dword	String

; Demonstrate StrCatl:

		lesi	String
		strcatl
		byte	". Put at end of 'String'",0

		printf
		byte	"STRING = ",'"%s"',cr,lf,0
		dword	String

; Demonstrate StrChr:

		lesi	String
		mov	al, "'"
		strchr

		print
		byte	"StrChr: First occurrence of ", '"', "'"
		byte	'" found at position ',0
		mov	ax, cx
		puti
		putcr

; Demonstrate StrStrl:

		lesi	String
		strstrl
		byte	"String",0

		print
		byte	'StrStr: First occurrence of "String" found at position ',0

		mov	ax, cx
		puti
		putcr

; Demo of StrSet

		lesi	String
		mov	al, '*'
		strset

		printf
		byte	"Strset:  '%s'",cr,lf,0
		dword	String

; Demo of strlen

		lesi	String
		strlen

		print
		byte	"String length = ",0
		puti
		putcr




Quit:		mov     ah, 4ch
		int     21h
Main		endp

cseg		ends

; Allocate a reasonable amount of space for the stack (2k).

sseg		segment	para stack 'stack'
stk		db	256 dup ("stack   ")
sseg		ends



; zzzzzzseg must be the last segment that gets loaded into memory!

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
heap		db	1024 dup (?)
zzzzzzseg	ends
		end	Main
