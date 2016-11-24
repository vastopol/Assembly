StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
;
scptr1		dd	?
strlen1		dw	?
scptr2		equ	2[bp]
rtnadrs		dw	?
strlen2		dw	?
;
StdData		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp
;
		extrn	sl_malloc:far
;
; strcatml-Computes the lengths of two strings pointed at by es:di and follow-
;	  ing the call.  It then allocates storage for a string long enough
;	  to hold the concatentation of these two strings.  Finally, it con-
;	  catenates the two strings storing the resulting string into the new
;	  buffer.  Returns ES:DI pointing at the new string.
;
; inputs:
;
;	ES:DI-	Points at the first string.
;
;	Return address points at the string to append.
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
		public	sl_strcatml
;
sl_strcatml	proc	far
		push	bp
                mov	bp, sp
		push	cx
		push	ax
		push	ds
		push	si
		pushf
		cld
;
; Save pointers to the strings
;
		mov	word ptr StdGrp:scptr1, di
		mov	word ptr StdGrp:scptr1+2, es
;
; Compute the length of the string following the call.
;
		mov	al, 0
		les	di, scptr2
		mov	cx, 0ffffh
	repne	scasb
		mov	StdGrp:rtnadrs, di		;Save return address
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
		lds	si, scptr2
		mov	cx, StdGrp:strlen2
		shr	cx, 1
		jnc	cs2
		lodsb
		stosb
cs2:	rep	movsw
;
		mov	ax, StdGrp:rtnadrs
		mov	scptr2, ax
		pop	di
		pop	es
		popf
		pop	si
		pop	ds
		pop	ax
		pop	cx
		pop	bp
		clc
		ret
;
BadStrCat2:	mov	es, word ptr StdGrp:scptr1+2
		mov	si, word ptr StdGrp:scptr1
		mov	ax, StdGrp:rtnadrs
		mov	scptr2, ax
		popf
		pop	di
		pop	ds
		pop	ax
		pop	cx
		pop	bp
		stc
		ret
sl_strcatml	endp
;
;
stdlib		ends
		end
