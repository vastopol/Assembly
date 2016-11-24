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
;
; Argc-		Counts the number of command line arguments
;
; inputs:
;
; Global variable PSP must hold the current program segment prefix.
;
; Outputs:
;
;	CX-	Contains the number of command line arguments.
;
;
cr		equ	13
;
;
		public	sl_Argc
;
sl_Argc		proc	far
		push	ds
		push	di
		push	ax
;
		mov	di, seg	PSP
		mov	ds, di
		mov	ds, ds:PSP
;
		mov	di, 80h			;Pointer to start of cmd line-1
		mov	cx, 0			;Start cnt at zero
CntLoop:	inc	di			;Move on to next char.
		cmp	byte ptr [di], ' '	;Skip all spaces here.
		je	CntLoop
		mov	al, [di]
		cmp	al, cr			;See if carriage return
		je	ArgcDone
;
; We just headed into a word of some sort. Skip all the chars in this argument.
;
		inc	cx			;First, count this argument
;
		cmp	al, '"'			;See if it's a string.
		je	GotString
		cmp	al, "'"
		je	GotString
;
; If not a string, skip to next space or CR.
;
SkipWord:	inc	di
		cmp	byte ptr [di], ' '
		je	CntLoop
		cmp	byte ptr [di], cr
		je	ArgcDone
		jmp	skipWord
;
; If we've got a string, skip to the delimiter or to the end of the line.
;
GotString:	inc	di
		cmp	al, [di]		;See if the delimiter
		je	CntLoop
		cmp	byte ptr [di], cr	;See if EOLN
		jne	GotString
;
; Come down here when we're done:
;
ArgcDone:	pop	ax
		pop	di
		pop	ds
		ret
sl_Argc		endp
;
;
stdlib		ends
		end
