include stdlib.a
include baseobj.a
include baseobj.aa
include exo.a
include exo.aa
include endo.a

;
; endo:		A MASM++ object that handles each window's intrinsics.
;
;
; Modification List:
;
; 29 Jan 92  Andrew G. Pomykal, Michael A. Griffith & Todd D. Vender:
;            Converted from old endo
; 
; 29 Jan 92  Todd D. Vender:
;	     Finished conversion.  Removed methods that are inherited.
;	     Added stubs for the not yet implemented methods.
;
; 01 Feb 92  Todd D. Vender, John M. Gibson:
;	     Wrote all the endo methods to control scrolling and cursor
;	     movement.  Tested and worked fine.
;
; 01 Feb 92  John M. Gibson, Todd D. Vender:
;            Fixed naming for put routines.
;            Wrote putchar.
;            Redefined cxo and cyo (see endo.a)
;
; 02 Feb 92  John M. Gibson:
;            Debugged and added wrap and stop features to putchar.
;            Tested and worked fine.
;            Wrote putstr.
;
; 03 Feb 92  John M. Gibson:
;            Debugged putstr.
;	     Tested and didn't work at all.  Needs to be rewritten to 
;	     accomodate the attribute byte for each character.  That
;	     means its probably going to be slow.
;	     Added new method movecursor.
;	     Rewrote putstr
;
; 03 Feb 92  Michael A. Griffith:
;            Changed all of the ds:si references to es:di (again).
;            May still have some problems, but the basic stuff works
;            again.  Also removed the Toddisms in shell.asm by making 
;            the endo constructor and destructors actually do something.
;


_EXPRESSD		SEGMENT PARA PUBLIC 'DATA'

endo__parent		baseobj <> 

_EXPRESSD 		ENDS



_EXPRESSC		SEGMENT PARA PUBLIC 'CODE'


;
;endo__new 	Returns an DS:SI pointer to a dyna-allocated
;		endo.  Necessarly destroys DS:SI.   Obviously
;		not meant for static objects.
;public			endo__new
endo__new		PROC ;FAR
			push	ax
			push	cx

			IsPtr
			jnc	new_preallocated	;If allocated
							;call realloc
							;to size it.
							;Otherwize
							;call malloc
							;to make it.
			mov	cx, sizeof endo
			malloc		
			jnc 	new_done
			call	es:[di].endo.methods.error
new_preallocated:	mov	cx, sizeof endo
			realloc
			jnc	new_done
			call	es:[di].endo.methods.error
new_done:	    	
			pop	cx
			pop	ax
			retf
endo__new		ENDP


;
;endo__constructor	Takes an ES:DI pointer to a endo, and initializes 
;			it regardless of whether it is statically or
;			dynamically allocated.


;public			endo__constructor
endo__constructor	PROC FAR
			push	ax
			push	cx
			push	es
			push	di
			push	ds
			push	si
			pushf

							;--------------------
							;Introduce child to
							;its parent
							;--------------------
			mov	ax, SEG endo__parent
			mov	WORD PTR es:[di].endo.parent, ax
			mov	ax, OFFSET endo__parent
			mov	WORD PTR es:[di].endo.parent[2], ax

							;--------------------
							;Make space for the
							;logical window
							;--------------------
			mov	ax, es:[di].endo.data.lxs
			mul	es:[di].endo.data.lys
			shl	ax, 1
			mov	cx, ax
			esXds
			malloc
			jnc	const_ok
			esXds
			call	es:[di].endo.methods.error
const_ok:
			mov	WORD PTR ds:[si].endo.data.logical, di
			mov	WORD PTR ds:[si].endo.data.logical[2], es 
			esXds
			
			
							;--------------------
							;Clear out the 
							;logical window
							;--------------------

							;cx still = size
			shr	cx, 1
			mov	al,  ' '
			mov	ah, es:[di].endo.data.attr
			cld
			les	di, es:[di].endo.data.logical
			rep	stosw

			popf
			pop	si
			pop	ds
			pop	di
			pop	es
			pop	cx	
			pop	ax
			retf
endo__constructor	ENDP




;
; endo__destructor	Takes an ES:DI pointer to an object, and de- 
;		        initializes the object.	
;
;public			endo__destructor
endo__destructor	PROC FAR
			push	es
			push	di

							;--------------------
							;Delete the logical 
							;window's memory
							;--------------------

			les	di, es:[di].endo.data.logical
			free	

			pop	di
			pop	es
			retf
endo__destructor	ENDP



;
; endo__printself	Takes an ES:DI pointer to an object, and prints 
;			the object to the standard output.  This 
;			function is used for debugging.
;

;public			endo__printself
endo__printself		PROC FAR
			push	ax

			print
			DB	"Class name:  ",0

			push	es
			push	di
			add	di, endo.data.classname
			puts
			print
			db	CR,LF,0
			pop	di
			pop	es

			print
			DB	"id:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.id
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"above:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.above
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"below:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.below
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"lxs:  ", 0
			xor	ah, ah			;ax <- 0
			mov	ax,  es:[di].endo.data.lxs
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"lys:  ", 0
			xor	ah, ah			;ax <- 0
			mov	ax,  es:[di].endo.data.lys
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"lxo:  ", 0
			xor	ah, ah			;ax <- 0
			mov	ax,  es:[di].endo.data.lxo
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"lyo:  ", 0
			xor	ah, ah			;ax <- 0
			mov	ax,  es:[di].endo.data.lyo
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"pxs:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.pxs
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"pys:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.pys
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"pxo:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.pxo
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"pyo:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.pyo
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"cxo:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.cxo
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"cyo:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.cyo
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"status:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.status
			puth
			print
			DB	"h", CR, LF, 0

			print
			DB	"attr:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].endo.data.attr
			puth
			print
			DB	"h", CR, LF, 0

			pop	ax
			retf
endo__printself		ENDP


;
; endo__nameof		Takes an ES:DI pointer to an object, and returns
;			a pointer to the name of that object, in a form
;			suitable for puts in ES:DI
;
;
;public			endo__nameof
endo__nameof		PROC
			add	di, baseobj__data.classname
			retf
endo__nameof		ENDP

;
; endo__putchar		Places a character at the cursor position in window.
;			Window is at ES:DI.  Character is in AL.
;			Attribute is in the exo.data.
;

;public			endo__putchar
endo__putchar		PROC 	FAR
			push	bx
			push	ds
			push	si

			; load the attribute byte next to the data and
			; save it for use later
			mov	ah, es:[di].exo.data.attr
			push	ax
							;--------------------
							; Put a character
							;--------------------

			; Get the logical window location in DS:SI
			lds	si, es:[di].endo.data.logical

			;-AX = cyo
			xor	ah, ah
			mov	al, es:[di].endo.data.cyo

			;-BX = lxs * 2
			mov	bx, es:[di].endo.data.lxs
			shl	bx, 1

			;-AX = cyo * (lxs * 2)
			mul	bx

			;-BX = (cyo * (lxs * 2)) + (cxo * 2)
			xor	bh, bh
			mov	bl, es:[di].endo.data.cxo
			shl	bx, 1
			add	bx, ax

			pop	ax
			mov	ds:[si][bx], ax
			push	ax

							;--------------------
							; Next cursor position
							;--------------------
			;-BX = lxs - 1
			mov	bx, es:[di].endo.data.lxs
			dec	bx

			;-AX = cxo
			xor	ah, ah
			mov	al, es:[di].endo.data.cxo

			;-if (cxo >= lxs - 1) then
			cmp	ax, bx
			jl	putchar_cxolxs

			;----if (cyo < lys - 1)
			mov	bx, es:[di].endo.data.lys
			dec	bx

			xor	ah, ah
			mov	al, es:[di].endo.data.cyo

			cmp	ax, bx
			jge	putchar_cyolys
			;-------cxo = 0
			mov	es:[di].endo.data.cxo, 0
			;-------cyo = cyo + 1
			inc	es:[di].endo.data.cyo
			;----else
putchar_cyolys:
			;-------who cares?
			jmp	putchar_out
			;-else
putchar_cxolxs:
			;----cxo = cxo + 1
			inc	es:[di].endo.data.cxo

putchar_out:
			pop	ax
			pop	si
			pop	ds
			pop	bx
			retf
endo__putchar		ENDP

;
; endo__putstr		Places a string at the cursor position in a window.
;			String is NULL terminated at DS:SI and window is at
;			ES:DI (of course).
;

;public			endo__putstr
endo__putstr		PROC
			push	es
			push	di
			push	dx
			push	cx
			push	bx
			push	ax
						;--------------------------
						; Get strlen
						;--------------------------
			;-CX = strlen(ds:[si])
			dsXes
			strlen
			dsXes

						;--------------------------
						; String Longer than L.Win.
						;--------------------------
putstr_longerwin:
			;-if (strlen < ((lxs*lys) - (cyo*lxs + cxo))) {begin}
			;-DX:AX = -----^
			;-BX = cxo
			mov	ax, es:[di].endo.data.lys
			xor	bh, bh
			mov	bl, es:[di].endo.data.cyo
			sub	ax, bx
			mov	dx, es:[di].endo.data.lxs
			mul	dx
			xor	bh, bh
			mov	bl, es:[di].endo.data.cxo
			sub	ax, bx
			;-if (strlen < ((lxs*lys) - (cyo*lxs + cxo))) {end}
			; This ignores DX.
			cmp	cx, ax

			;-then
			;----goto putstr_copy
			jb	putstr_copy

			;-else
			;----strlen = ((lxs*lys) - (cyo*lxs + cxo))
			call	es:[di].exo.methods.regs
			Getc
			mov	cx, ax
			; 

						;--------------------------
						; Copy string
						;--------------------------
			; copy string (of length strlen) to memory

putstr_copy:

			;-AX = cyo
			xor	ah, ah
			mov	al, es:[di].endo.data.cyo

			;-BX = lxs * 2
			mov	bx, es:[di].endo.data.lxs
			shl	bx, 1

			;-AX = cyo * (lxs * 2)
			mul	bl

			;-BX = (cyo * (lxs * 2)) + (cxo * 2)
			xor	bh, bh
			mov	bl, es:[di].endo.data.cxo
			shl	bx, 1
			add	bx, ax

			; Final computation for place to store string
			;-BX = DX = (cyo * (lxs * 2)) + (cxo * 2)
			mov	dx, bx

			; Set character attribute in AH
			mov	ah, es:[di].endo.data.attr

			; copy string

			; Remember the strlen
			push	cx
putstr_nextchar:
			mov	bx, cx
			dec	bx
			mov	al, ds:[si][bx]
			push	es
			push	di
			les	di, es:[di].endo.data.logical
			shl	bx, 1
			add	bx, dx
			mov	es:[di][bx], ax
			pop	di
			pop	es
			loop	putstr_nextchar

			;-CX = strlen
			pop	cx


			; Now update the cursor (without using div)
						;--------------------------
						; String Longer than Line
						;--------------------------
putstr_longerline:
			;-if ((strlen - cxo) < lxs)
			;-AX = strlen
			mov	ax, cx
			;-BX = cxo
			xor	bh, bh
			mov	bl, es:[di].endo.data.cxo
			;-AX = strlen - cxo
			sub	ax, bx
			;-DX = lxs
			mov	dx, es:[di].endo.data.lxs

			cmp	ax, dx
			;-then
			;----goto putstr_shorterline
			jb	putstr_shorterline
			;-else
			;----strlen = strlen - (lxs - cxo)
			sub	cx, dx
			add	cx, bx

			;----update cursor
			inc	es:[di].endo.data.cyo
			mov	es:[di].endo.data.cxo, 0
			jmp	putstr_longerline
						;--------------------------
						; Shorter than Line
						;--------------------------
putstr_shorterline:
			;-update cursor

			; cxo = cxo + strlen
			add	bx, cx
			mov	es:[di].endo.data.cxo, bl
			


			pop	ax
			pop	bx
			pop	cx
			pop	dx
			pop	di
			pop	es
			retf
endo__putstr		ENDP

;
; endo__putwin		Fills in an entire window with a character at once
;			Window in DS:SI, character in AL.  Attribute in
;			endo.data.
;

;public			endo__putwin
endo__putwin		PROC
			retf
endo__putwin		ENDP

;
; endo__up		Moves the cursor in a window up one line
;			Checks to make sure that you don't go above
;			physical limit of window.
;
;

;public			endo__up
endo__up		PROC

			cmp	es:[di].endo.data.cyo, 0
			je	cannot_decy
			dec 	es:[di].endo.data.cyo 
cannot_decy:
			retf
endo__up		ENDP

;
; endo__down		Moves the cursor in a window down one line
;			Checks to make sure that you don't go below
;			physical limit of window.
;
;

;public			endo__down
endo__down		PROC
			push	ax

			xor	ah, ah
			mov	al, es:[di].endo.data.pys
			dec	al				; ysize - 1
			cmp	es:[di].endo.data.cyo, al 
			je	cannot_incy
			inc	es:[di].endo.data.cyo
cannot_incy:
			pop	ax
			retf
endo__down		ENDP

;
; endo__left		Moves the cursor in a window left one character pos.
;			Checks to make sure that you don't preceed physical
;			limit of window.
;
;

;public			endo__left
endo__left		PROC
			cmp	es:[di].endo.data.cxo, 0h
			je	cannot_decx
			dec	es:[di].endo.data.cxo
cannot_decx:	
			retf
endo__left		ENDP

; 
; endo__right		Moves the cursor in a window right one character pos.
;			Checks to make sure that you don't go beyond physical
;			limit of window.
;
;

;public			endo__right
endo__right		PROC
			push	ax

			xor	ah, ah
			mov	al, es:[di].endo.data.cxo
			dec	al
			cmp	al, es:[di].endo.data.cxo
			je	cannot_incx
			inc	es:[di].endo.data.cxo
cannot_incx:
			pop	ax
			retf
endo__right		ENDP

;
; endo__movecursor	Move the cursor on a logical window to location
;			X = AX, Y = BX.  Window is in DS:SI.
;
;

;public			endo__movecursor
endo__movecursor	PROC
			retf
endo__movecursor	ENDP

;
; endo__scrup		Scroll the window up one line
;
;

;public			endo__scrup
endo__scrup		PROC
			push	ax
			push	bx

			mov	ax, es:[di].endo.data.lys
			shl	ax, 1
			xor	bh, bh
			mov	bl, es:[di].endo.data.pys
			shl	bx, 1
			sub	ax, bx 
			cmp	ax, es:[di].endo.data.lyo
			je	cannot_scrup
			inc	es:[di].endo.data.lyo
			inc	es:[di].endo.data.lyo
cannot_scrup:
			pop	bx
			pop	ax
			retf
endo__scrup		ENDP

;
; endo__scrdown		Scroll the window down one line
;
;

;public			endo__scrdown
endo__scrdown		PROC
			cmp	es:[di].endo.data.lyo, 0
			je	cannot_scrdown
			dec	es:[di].endo.data.lyo
			dec	es:[di].endo.data.lyo
cannot_scrdown:
			retf
endo__scrdown		ENDP

;
; endo__scrleft		Scroll the window left one column 
;
;

; public		endo__scrleft
endo__scrleft		PROC
			push	ax
			push	bx

			mov	ax, es:[di].endo.data.lxs
			shl	ax, 1
			xor	bh, bh
			mov	bl, es:[di].endo.data.pxs
			shl	bx, 1
			sub	ax, bx 
			cmp	ax, es:[di].endo.data.lxo
			je	cannot_scrleft
			inc	es:[di].endo.data.lxo
			inc	es:[di].endo.data.lxo
cannot_scrleft:
			pop	bx
			pop	ax
			retf
endo__scrleft		ENDP

;
; endo__scrright	Scroll the window right one column
;
;

; public		endo__scrright
endo__scrright		PROC
			cmp	es:[di].endo.data.lxo, 0
			je	cannot_scrright
			dec	es:[di].endo.data.lxo		;Must inc twice
			dec	es:[di].endo.data.lxo
cannot_scrright:
			retf
endo__scrright		ENDP



_EXPRESSC		ENDS


END
