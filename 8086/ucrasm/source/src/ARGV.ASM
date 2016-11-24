;
		extrn	PSP:word
;
StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far
;
; Argv-		Returns a string containing a specified command line
;		parameter.
;
; inputs:
;
;	AX-	Contains the number of the parameter you wish to obtain.
;	PSP-	Global variable which must point at the PSP.
; 
;
; Outputs:
;
;	ES:DI-	Points at the newly allocated string on the heap which contains
;		the command line parameter.
;
;
cr		equ	13
;
;
		public	sl_Argv
;
sl_Argv		proc	far
		push	ds
		push	si
		push	ax
		push	cx
;
		mov	si, seg	PSP
		mov	ds, si
		mov	ds, ds:PSP
;
; Skip to the first parameter
;
		mov	si, 80h			;Pointer to start of cmd line-1
CntLoop:	inc	si			;Move on to next char.
		cmp	byte ptr [si], ' '	;Skip all spaces here.
		je	CntLoop
;
		mov	cl, [si]
		cmp	cl, cr			;See if carriage return
		je	NoSuchParm
;
; We just encountered an argument, is it the one we want?
;
		dec	ax
		jz	GrabThisOne
;
; If this isn't the argument we want, skip it.
;
		cmp	cl, '"'			;See if it's a string.
		je	GotString
		cmp	cl, "'"
		je	GotString
;
; If not a string, skip to next space or CR.
;
SkipWord:	inc	si
		cmp	byte ptr [si], ' '
		je	CntLoop
		cmp	byte ptr [si], cr
		je	NoSuchParm
		jmp	skipWord
;
; If we've got a string, skip to the delimiter or to the end of the line.
;
GotString:	inc	si
		cmp	cl, [si]		;See if the delimiter
		je	CntLoop
		cmp	byte ptr [si], cr	;See if EOLN
		jne	GotString
		jmp	NoSuchParm
;
; If the argument counter just went to zero, return the specified string.
;
GrabThisOne:	cmp	cl, "'"			;Special case for strings
		je	GetAString
		cmp	cl, '"'
		je	GetAString
;
; This is not a parameter surrounded by quotes or apostrophes.  Deal with that
; here.
;
; First, compute the length of this guy-
;
		push	ds
		push	si
		mov	cx, 0
CntChars:	inc	cx
		inc	si
		cmp	byte ptr [si], ' '
		je	EndOfParm
		cmp	byte ptr [si], cr
		jne	CntChars
;
EndOfParm:	pop	si
		pop	ds
;
; Okay, allocate storage for the new string
;
CopyString:	inc	cx			;Don't forget zero byte!
		push	cx
		call	sl_malloc
		pop	cx
		jc	ArgvDone		;Return if error.
		push	es
		push	di
	rep	movsb				;Copy the string
		mov	byte ptr es:[di-1], 0	;Put in zero terminating byte.
		pop	di
		pop	es
		clc				;Return w/no error.
		jmp	ArgvDone
;
;
; If the parameter is a string surrounded by " or ' then process that down
; here
;
GetAString:	mov	al, cl			;Save delimeter.
		push	ds
		push	si
		mov	cx, -1			;Don't count quote char
CntChars2:	inc	cx
		inc	si
		cmp	al, [si]
		je	EndOfStr
		cmp	byte ptr [si], cr
		jne	CntChars2
;
EndOfStr:	pop	si
		pop	ds
		inc	si			;Skip delimeter
		jmp	CopyString
;
; If the user selected a phantom parameter, return a pointer to an
; empty string:
;
NoSuchParm:	mov	di, seg StdGrp:EmptyParm
		mov	es, di
		mov	di, offset StdGrp:EmptyParm
;
; Come down here when we're done:
;
ArgvDone:	pop	cx
		pop	ax
		pop	si
		pop	ds
		ret
sl_Argv		endp
;
EmptyParm	db	0,0,0
;
stdlib		ends
		end
