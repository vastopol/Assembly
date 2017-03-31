StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
		extrn	sl_putc:far
;
;
		public	sl_print
sl_print	proc	far
		push	bp
		mov	bp, sp		
		push	ax
		push	es
		push	bx
;
		les	bx, 2[bp]	;Get return address
		jmp	short TestZero
;
PrintLoop:	call	sl_Putc
		inc	bx
TestZero:	mov	al, es:[bx]
		cmp	al, 0
		jnz	PrintLoop
;
		inc	bx
		mov	2[bp], bx
		pop	bx
		pop	es
		pop	ax
		pop	bp
		ret
sl_print	endp
stdlib		ends
		end
