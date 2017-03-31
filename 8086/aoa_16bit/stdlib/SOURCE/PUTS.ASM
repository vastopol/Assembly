StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
		extrn	sl_putc:far
;
; Puts prints the string that ES:DI points at to the std output.
;
;
		public  sl_puts
sl_Puts         proc    far
		push    di
		push    ax
		jmp     short PStart
;
PutsLp:         call    sl_Putc
PStart:         mov	al, es:[di]
		inc	di
		cmp     al, 0
		jnz     PutsLp
		pop     ax
		pop     di
		ret
sl_Puts         endp
stdlib		ends
		end
