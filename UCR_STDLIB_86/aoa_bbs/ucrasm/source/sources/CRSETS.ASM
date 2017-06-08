StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_malloc:far
;
; CreateSets-	Creates an 8-element array of sets.
;
; outputs:
;
;	es:di-	Pointer to first element.  Each successive element of the
;		array starts one byte later.
;
;	carry=0 if successful.
;	carry=1 if could not allocate sufficient memory for the set.
;
;
		public	sl_CreateSets
;
sl_CreateSets	proc	far
		push	ax
		push	cx
		pushf
;
		mov	cx, 256+16		;# of bytes for a set array.
		call	sl_malloc		;Allocate storage for the set.
		jc	BadAlloc
		xor	ax, ax			; Turn into the empty set.
		push	di
		mov	cx, (256+16)/2
		cld
	rep	stosw
		pop	di
		mov	word ptr es:[di], 201h	;Init the mask bytes
		mov	word ptr es:2[di], 804h
		mov	word ptr es:4[di], 2010h
		mov	word ptr es:6[di], 8040h
;
		popf
                pop	cx
		pop	ax
		clc
		ret
;
BadAlloc:	pop	di
		popf
                pop	cx
		pop	ax
		stc
		ret
sl_CreateSets	endp
;
;
stdlib		ends
		end
