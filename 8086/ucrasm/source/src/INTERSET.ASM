StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
;
; intersect-	Intersects one set with another.
;
; inputs:
;
;	ES:DI-  Points at the destination set (at its mask byte).
;	DX:SI-	Points at the mask byte of the source set.
;
;
;
		public	sl_intersect
;
sl_intersect	proc	far
		push	ds
		push	ax
		push	cx
		push	si
		push	di
		mov	ds, dx
;
		mov	al, es:[di]		;Get mask bytes
		not	al
		mov	ah, [si]
		add	si, 8			;Skip to start of set
                add	di, 8
		mov	cx, 256
IsectLp:	test	ah, [si]
		jnz	Next
		and	es:[di], al
Next:		inc	si
		inc	di
		loop	IsectLp
;
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	ax 
		pop	ds
		ret
sl_intersect	endp
;
;
stdlib		ends
		end
