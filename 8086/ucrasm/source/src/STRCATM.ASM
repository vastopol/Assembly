StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
		public	sl_strcatm
;
scptr1		dd	?
strlen1		dw	?
scptr2		dd	?
strlen2		dw	?
;
StdData		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp
;
		extrn	sl_malloc:far
;
; strcatm-Computes the lengths of two strings pointed at by es:di and dx:si
;	  then allocates storage for a string long enough to hold the con-
;	  catentation of these two strings.  Finally, it concatenates the
;	  two strings storing the resulting string into the new buffer.
;	  Returns ED:SI pointing at the new string.
;
; inputs:
;
;	ES:DI- Points at the first string.
;
;	DX:SI- Points at the string to append.
;
;
; outputs:
;
;	ES:DI- Points at new string containing the concatenation of the
;	       two strings.
;
;	carry=0 if no error.
;	carry=1 if strcat2 could not allocate enough memory to hold
;		the resulting string.
;
sl_strcatm	proc	far
		push	ds
		push	si
		push	cx
		push	ax
		pushf
		cld
;
; Save pointers to the strings
;
		mov	word ptr StdGrp:scptr1, di
		mov	word ptr StdGrp:scptr1+2, es
		mov	word ptr StdGrp:scptr2, si
		mov	word ptr StdGrp:scptr2+2, dx
;
; Compute the length of the second string.
;
		mov	al, 0
		les	di, StdGrp:scptr2
		mov	cx, 0ffffh
	repne	scasb
		neg	cx
		dec	cx
		mov	StdGrp:StrLen2, cx
;
; Find the end of the first string:
;
		les	di, StdGrp:scptr1
		mov	cx, 0ffffh
	repne	scasb
		neg	cx
		dec	cx
		dec	cx
		mov	StdGrp:StrLen1, cx
;
; Malloc the appropriate storage:
;
		add	cx, StdGrp:StrLen2
		call	sl_malloc
		jc	BadStrCat2
;
; Save ptr to dest
;
		push	es
		push	di		
;
; Copy the strings:
;
		lds	si, StdGrp:scptr1
		mov	cx, StdGrp:strlen1
		shr	cx, 1
		jnc	cs1
		lodsb
		stosb
cs1:	rep	movsw
		lds	si, StdGrp:scptr2
		mov	cx, StdGrp:strlen2
		shr	cx, 1
		jnc	cs2
		lodsb
		stosb
cs2:	rep	movsw
;
		pop	di
		pop	es
		popf
		pop	ax
		pop	cx
		pop	si
		pop	ds
		clc
		ret
;
BadStrCat2:	les	di, StdGrp:scptr1
		popf
		pop	ax
		pop	cx
		pop	si
		pop	ds
		stc
		ret
sl_strcatm	endp
;
;
stdlib		ends
		end
