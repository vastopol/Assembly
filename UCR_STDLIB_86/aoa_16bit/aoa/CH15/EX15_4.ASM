; EX15_4.asm
;
; This program compares the performance of length prefixed strings versus
; zero terminated strings using some simple examples.
;
; Note: these routines all assume that the strings are in the data segment
;       and both ds and es already point into the data segment.

		.386
		option		segment:use16

		include 	stdlib.a
		includelib	stdlib.lib


dseg		segment	para public 'data'

LStr1		byte	17,"This is a string."
LResult		byte	256 dup (?)

ZStr1		byte	"This is a string",0
ZResult		byte	256 dup (?)

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; LStrCpy: Copies a length prefixed string pointed at by SI to 
;          the length prefixed string pointed at by DI.

LStrCpy		proc
		push	si
		push	di
		push	cx

		cld

		mov	cl, [si]	;Get length of string.
		mov	ch, 0
		inc	cx		;Include length byte.
	rep	movsb

		pop	cx
		pop	di
		pop	si
		ret
LStrCpy		endp



; LStrCat-	Concatenates the string pointed at by SI to the end
;		of the string pointed at by DI using length
;		prefixed strings.

LStrCat		proc
		push	si
		push	di
		push	cx

		cld

; Compute the final length of the concatenated string

		mov	cl, [di]		;Get orig length.
		mov	ch, [si]		;Get 2nd Length.
		add	[di], ch		;Compute new length.

; Move SI to the first byte beyond the end of the first string.

		mov	ch, 0			;Zero extend orig len.
		add	di, cx			;Skip past str.
		inc	di			;Skip past length byte.

; Concatenate the second string (SI) to the end of the first string (DI)

	rep	movsb				;Copy 2nd to end of orig.

		pop	cx
		pop	di
		pop	si
		ret
LStrCat		endp
		


; LStrCmp-	String comparison using two length prefixed strings.
;		SI points at the first string, DI points at the
;		string to compare it against.

LStrCmp		proc
		push	si
		push	di
		push	cx

		cld

; When comparing the strings, we need to compare the strings
; up to the length of the shorter string.  The following code
; computes the minimum length of the two strings.

		mov	cl, [si]	;Get the minimum of the two lengths
		mov	ch, [di]
		cmp	cl, ch
		jb	HasMin
		mov	cl, ch
HasMin:		mov	ch, 0

	repe	cmpsb			;Compare the two strings.
		je	CmpLen
		pop	cx
		pop	di
		pop	si
		ret

; If the strings are equal through the length of the shorter string,
; we need to compare their lengths

CmpLen:		pop	cx
		pop	di
		pop	si

		mov	cl, [si]
		cmp	cl, [di]
		ret
LStrCmp		endp
		

; ZStrCpy- Copies the zero terminated string pointed at by SI
;          to the zero terminated string pointed at by DI.

ZStrCpy		proc
		push	si
		push	di
		push	ax

ZSCLp:		mov	al, [si]
		inc	si
		mov	[di], al
		inc	di
		cmp	al, 0
		jne	ZSCLp

		pop	ax
		pop	di
		pop	si
		ret
ZStrCpy		endp


; ZStrCat-	Concatenates the string pointed at by SI to the end
;		of the string pointed at by DI using zero terminated
;		strings.

ZStrCat		proc
		push	si
		push	di
		push	cx
		push	ax

		cld

; Find the end of the destination string:

		mov	cx, 0FFFFh
		mov	al, 0		;Look for zero byte.
	repne	scasb

; Copy the source string to the end of the destination string:

ZcatLp:		mov	al, [si]
		inc	si
		mov	[di], al
		inc	di
		cmp	al, 0
		jne	ZCatLp

		pop	ax
		pop	cx
		pop	di
		pop	si
		ret
ZStrCat		endp
		

; ZStrCmp-	Compares two zero terminated strings.
;		This is actually easier than the length
;		prefixed comparison.

ZStrCmp		proc
		push	cx
		push	si
		push	di

; Compare the two strings until they are not equal
; or until we encounter a zero byte.  They are equal
; if we encounter a zero byte after comparing the
; two characters from the strings.

ZCmpLp:		mov	al, [si]
		inc	si
		cmp	al, [di]
		jne	ZCmpDone
		inc	di
		cmp	al, 0
		jne	ZCmpLp

ZCmpDone:	pop	di
		pop	si
		pop	cx
		ret
ZStrCmp		endp


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit



		print
		byte	"The following code does 1,000,000 string "
		byte	"operations using",cr,lf
		byte	"length prefixed strings.  Measure the amount "
		byte	"of time this code",cr,lf
		byte	"takes to run.",cr,lf,lf
		byte	"Press any key to begin:",0

		getc
		putcr

		mov	edx, 1000000
LStrCpyLp:	lea	si, LStr1
		lea	di, LResult
		call	LStrCpy
		call	LStrCat
		call	LStrCat
		call	LStrCat
		call	LStrCpy
		call	LStrCmp
		call	LStrCat
		call	LStrCmp

		dec	edx
		jne	LStrCpyLp


		print
		byte	"The following code does 1,000,000 string "
		byte	"operations using",cr,lf
		byte	"zero terminated strings.  Measure the amount "
		byte	"of time this code",cr,lf
		byte	"takes to run.",cr,lf,lf
		byte	"Press any key to begin:",0

		getc
		putcr

		mov	edx, 1000000
ZStrCpyLp:	lea	si, ZStr1
		lea	di, ZResult
		call	ZStrCpy
		call	ZStrCat
		call	ZStrCat
		call	ZStrCat
		call	ZStrCpy
		call	ZStrCmp
		call	ZStrCat
		call	ZStrCmp



		dec	edx
		jne	ZStrCpyLp




Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
