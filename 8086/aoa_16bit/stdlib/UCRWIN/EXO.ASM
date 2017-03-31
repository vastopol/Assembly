include stdlib.a
include baseobj.a
include baseobj.aa
include endo.a
include endo.aa
include exo.a

;
; exo : baseobj	A MASM++ object that represents a generalized window 
;		manager.
;
;		Written by Michael A. Griffith and Todd D. Vender		;
; Modification List:
;
; 25 Oct 91  Michael A. Griffith & Todd D. Vender:
;            Created.
;
; 26 Oct 91  Michael A. Griffith:
;
; 3 Nov 91   Michael A. Griffith:
;	     Started real coding
;
; 16 Dec 91  Michael A. Griffith:
;	     Float and sinkwin.
;
; 19 Dec 91  Michael A. Griffith:
;	     More float and sink.  Changed call to malloc in exo__new.
;	     Wrote destroywin and createwin.
;
; 20 Dec 91  Michael A. Griffith:
;	     More create, and begun the non-overlay parts of engine.
;
; 27 Dec 91  Michael A. Griffith:
;	     Picked up some more assemble time errors and removed
;            the dx:[si] usages.
;
; 29 Dec 91  Michael A. Griffith & John Gibson:
;	     Wrote the overlay part of engine & revised printself
;            to dump the VSM
;
; 5 Jan 92   Michael A. Griffith;
;	     Reduced number of MULs required by storing the VSMsize.
;            Finished off the methods that had not been written.
;            Pared down the size of the data objects needed.
;	     Cleared VSM in engine.   Added border support in engine.
;	     UNIFIED SCREEN AND EXO OBJECTS.
;
; 6 Jan 92   Michael A. Griffith & Todd D. Vender:
;	     Began update and fixed printself so that it doesn't 
;            use G as the separator.
;
; 12 Jan 92  Michael A. Griffith & Andrew G. Pomykal:
;	     Fixing constructor -trying to find where it hung
;
; 13 Jan 92  Andrew G. Pomykal 
;	     Began update and fixed constructor so that it detects
;            the correct monitor and card
;
; 15 Jan 92  Michael A. Griffith & Andrew G. Pomykal:
;	     Fixing constructor -VSM filling with zeros
;
; 19 Jan 92  Andrew G. Pomykal 
;	     Really fixed constructor so that it mallocs the VSM
;	     and stores the pointer to it in the structure 
;
; 29 Jan 92  Todd D. Vender, Michael A. Griffith, & Andrew G. Pomykal
;            Really, really fixed constructor.  Took out PrintReg.
;	     Debugged createwin (Still need to modify bottom)
;
; 30 Jan 92  Todd D. Vender 
;	     Fixed evil bug in Create Win that overwrote the IVT
;
; 31 Jan 92  Todd D. Vender
;	     Fixed Engine.  VSM is now written to correctly
;            Modified Update.  Got FIRST VISIBLE WINDOW.
;	     Changed engine to handle border corners.
;
; 01 Feb 92  Todd D. Vender and John M. Gibson
;	     Modified update to handle the data pointers.  
;	     Debugged movewin, resizewin
;	     Rewrote float, sink
;
; 03 Feb 92  Michael A. Griffith and Andrew Pomykal
;	     Added the free back to the destructor.
;            Copped the attitude of curses:  user needs to call engine
;	     himself.  Result:  No more repetitive calls to engine within 
;	     exo/endo methods.
;

_EXPRESSD		SEGMENT PARA PUBLIC 'DATA'

exo__parent		baseobj <>

_EXPRESSD 		ENDS



_EXPRESSC		SEGMENT PARA PUBLIC 'CODE'


;
;exo__new 	Returns an ES:DI pointer to a dyna-allocated
;		exo.  Necessarly destroys ES:DI.   Obviously
;		not meant for static objects.

exo__new		PROC
			push	ax
			push	cx
			IsInHeap
			jnc	new_preallocated	;If allocated
							;call realloc
							;to size it.
							;Otherwize
							;call malloc
							;to make it.
			mov	cx, sizeof exo
			clc
			malloc		
			jnc 	new_done
			call	es:[di].exo.methods.error
new_preallocated:	mov	cx, sizeof exo
			realloc
			jnc 	new_done
			call	es:[di].exo.methods.error
new_done:	    	
			pop	cx
			pop	ax
			retf
exo__new		ENDP


;
;exo__constructor	Takes an ES:DI pointer to a exo, and initializes 
;			it regardless of whether it is statically or
;			dynamically allocated.

exo__constructor	PROC
			push	ax
			push	bx
			push	cx
			push	si
			push	ds
			pushf

							;-------------------
							;Introduce the child
							;to it's parent
							;-------------------

			mov	ax, SEG exo__parent
			mov	WORD PTR es:[di].exo.parent, ax
			mov	ax, OFFSET exo__parent
			mov	WORD PTR es:[di].exo.parent[2], ax

							;------------------
							;Determine display
							;------------------
			push	di
			push	es
			mov	bx, 0040h
			mov	es, bx
			mov	bx, es:10h
			pop	es
			pop	di
			


	;		test	bx, 30h
		;	jne	const_done
			mov	WORD PTR es:[di].exo.data.videoRAM[2], exo__MONO
			mov	WORD PTR es:[di].exo.data.videoRAM, 0 
			jmp	const_done
const_color:		mov	WORD PTR es:[di].exo.data.videoRAM[2], exo__COLOR 
			mov	WORD PTR es:[di].exo.data.videoRAM, 0

const_done:
							;------------------
							;Turn off cursor
							;------------------
			mov	ah, 01h
			mov	cx, 2000h
			int	10h


							;-------------------
							;How big is the VSM?
							;-------------------

			mov	ax, es:[di].exo.data.hsize
			mul	es:[di].exo.data.vsize
			mov	es:[di].exo.data.VSMsize, ax

							;-------------------
							;Make space for
							;the VSM
							;-------------------
			push	es
			push	di
			clc
			mov	cx, ax
			shl	cx, 1
			shl	cx, 1
			malloc 
			jnc	const_vsmok		
			pop	di
			pop	es
			call	es:[di].exo.methods.error
const_vsmok:		
			push	es
			pop	ds			
			mov	si, di		 	;ds:si <- es:di	

			pop	di
			pop	es			;es:di <- this
			
			mov	WORD PTR es:[di].exo.data.VSM[2], ds
			mov	WORD PTR es:[di].exo.data.VSM, si

							;-------------------
							;Set VSM to all zeros
							;-------------------
			push	es
			push	di
		
			mov	ax, 00h			;ax <- 0
			mov	cx, es:[di].exo.data.VSMsize
			shl	cx, 1
			shl	cx, 1
			cld				;forward direction
			les	di, es:[di].exo.data.VSM
			rep 	stosw

			pop	di
			pop	es	
							;-------------------
							;Set top and bottom
							;win's to zero
							;-------------------
			mov	es:[di].exo.data.bottom, 1 
			mov	es:[di].exo.data.top, 0 

							;-------------------
							;How many windows?
							;-------------------
			mov	bl, exo__WINNUM
			mov	es:[di].exo.data.winnum, bl

							;-------------------
							;Zero out the wintbl
							;-------------------
con_wintbllp:		
                        cmp	bl, 0
			je	con_wintbldone
			mov	WORD PTR es:[di].exo.data.wintbl[bx], 0 
			mov	WORD PTR es:[di].exo.data.wintbl[bx]+2, 0
			dec	bx
			jmp	con_wintbllp
con_wintbldone:


			popf
			pop	ds
			pop	si
			pop	cx
			pop	bx
			pop	ax			
			retf
exo__constructor	ENDP



;
;exo__destructor	Takes an ES:DI pointer to a exo, and de-initializes 
;			it regardless of whether it is statically or
;			dynamically allocated.
exo__destructor		PROC
			push	ax
			push	cx
			push	es
			push	di
							;------------------
							;Deallocate VSM
							;------------------

			les	di, es:[di].exo.data.VSM
			free
							;------------------
							;Turn on cursor
							;------------------
			mov	ah, 01h
			mov	cx, 10h
			int	10h

			pop	di	
			pop	es
			pop	cx
			pop	ax
			retf
exo__destructor		ENDP




;
; exo__printself	Takes an ES:DI pointer to an object, and prints 
;			the object to the standard output.  This 
;			function is used for debugging.
;

exo__printself		PROC
			push	ax
			push	bx
			push	cx
			push	si
			push	ds

			print
			DB	"Class name:  ", 0

			push	es
			push	di
			add	di, exo.data.classname
			puts
			pop	di
			pop	es

			print
			db	CR, LF
			db	"Bottom window:  ", 0
			mov	al, es:[di].exo.data.bottom 
			puth
			print
			db	"h", CR, LF, 0 

			print
			db	"Top window:  ", 0
			mov	al, es:[di].exo.data.top 
			puth
			print
			db	"h", CR, LF, 0 

			print
			db	"Number of windows:  ", 0
			mov	al, es:[di].exo.data.winnum 
			puth
			print
			db	"h", CR, LF, 0

			print
			DB	"Video RAM:  ", 0 
			mov	ax, WORD PTR es:[di].exo.data.videoRAM[1]
			xchg	al, ah
			puth
			xchg	al, ah
			puth
			print
			DB	"h", CR, LF

			DB	"Default Attribute:  ", 0
			xor	ah, ah
			mov	al, es:[di].exo.data.attr
			puth
			print
			DB	"h", CR, LF
	

			db	"Horizontal size:  ", 0
			mov	ax, es:[di].exo.data.hsize 
			puth
			print
			db	"h", CR, LF, 0

			print
			db	"Vertical size:  ", 0
			xor	ah, ah				;ah <- 0
			mov	al, es:[di].exo.data.vsize 
			puth
			print
			db	"h", CR, LF, 0

			print
			db	"VSM size:  ", 0
			mov	ax, es:[di].exo.data.VSMsize 
			xchg	al, ah
			puth
			xchg	al, ah
			puth
			print
			db	"h", CR, LF

			db 	"VSM address:  ", 0
			mov	ax, WORD PTR es:[di].exo.data.VSM[1] 
			xchg	al, ah
			puth
			xchg	al, ah
			puth
			mov	al, ':'
			putc
			mov	ax, WORD PTR es:[di].exo.data.VSM
			xchg	al, ah
			puth
			xchg	al, ah
			puth
			print
			db	"h", CR, LF

			db	"VSM:", CR, LF, 0
			mov	cx, es:[di].exo.data.VSMsize
			xor	bx, bx				;bx <- 0
			lds	si, es:[di].exo.data.VSM
print_loop:		

			mov	ax, WORD PTR ds:[si][bx]
			xchg	al, ah
			puth
			xchg	al, ah
			puth
			mov	al, ':'
			putc
			mov	ax, WORD PTR ds:[si][bx][2]
			xchg	al, ah
			puth
			xchg	al, ah
			puth
			mov	al, ' '
			putc
			inc	bx
			inc	bx
			inc	bx
			inc	bx
			loop	print_loop
			putcr

			pop	ds
			pop	si
			pop	cx
			pop	bx
			pop	ax
			retf
exo__printself		ENDP


;
; exo__nameof		Takes an ES:DI pointer to an object, and returns
;			a pointer to the name of that object, in a form
;			suitable for puts in ES:DI
;

exo__nameof		PROC
			add	di, exo.data.classname
			retf
exo__nameof		ENDP



;
; exo__engine		Takes an ES:DI pointer to an exo object, and updates
;		        it's VSM, based on new changes to the system that 
;			have recently taken place.
;
exo__engine		PROC
			push	ax
			push	bx
			push	cx
			push	dx
			push	si
			push	di
			push	es
			push	ds
			pushf
							;-------------------
							;Clear out the old
							;VSM
							;-------------------
			push	es
			push	di

			mov	cx, es:[di].exo.data.VSMsize
			shl	cx, 1
			cld
			les 	di, es:[di].exo.data.VSM
			mov	ax, 0
			rep	stosw

			pop	di
			pop	es

			

							;-------------------
							;Start from bottom
							;and work upward.
							;-------------------
			xor	ax, ax			;ax <- 0
			xor	bh, bh			;bh <- 0
			mov	bl, es:[di].exo.data.bottom
			shl	bx, 1
			shl	bx, 1

			lds	si, es:[di].exo.data.wintbl[bx]
							;DS:SI has ptr to
							;an endo window.

							;-------------------
							;Overlay onto VSM
							;-------------------
engi_zero:
			push	ax
			push	bx
			push	di
			push	es
			push	bp


			
	
			xor	ah, ah
			mov	al, ds:[si].endo.data.pyo		
			mul	es:[di].exo.data.hsize
			xor	bh, bh	
			mov	bl, ds:[si].endo.data.pxo
			add	ax, bx
			mov	bx, ax	
			shl	bx, 1
			shl	bx, 1
	
			mov 	ax, ds:[si].endo.data.lyo
			mul	ds:[si].endo.data.lxs
			add	ax, ds:[si].endo.data.lxo
			mov	dx, ax			
							;dx <- logical offset

			xor	ch, ch			
			mov	cl, ds:[si].endo.data.pxs
							;cx <- line length	
			xor	ah, ah		
			mov	al, ds:[si].endo.data.id 
							;ax <- window ID


							;-------------------
							;Write top border
							;-------------------
			push	bx
			shr	bx, 1
			shr	bx, 1
			sub	bx, es:[di].exo.data.hsize
			shl	bx, 1
			shl	bx, 1
			push	es
			push	di
			dec	bx
			dec	bx
			dec	bx
			dec	bx
			les	di, es:[di].exo.data.VSM
			mov	WORD PTR es:[di][bx], exo__ULCB
			mov	WORD PTR es:[di][bx][2], 0h 
			inc	bx
			inc	bx
			inc	bx
			inc	bx
engi_toplp:		mov	WORD PTR es:[di][bx], exo__TOPB 
			mov	WORD PTR es:[di][bx][2], 0h 
			inc	bx
			inc	bx
			inc	bx
			inc	bx
			loop	engi_toplp
			mov	WORD PTR es:[di][bx], exo__URCB
			mov	WORD PTR es:[di][bx][2], 0h 
			pop	di
			pop	es
			pop	bx



			xor	ch, ch
			mov	cl, ds:[si].endo.data.pys
						
							;-------------------
							;Line-by-line to VSM
							;-------------------
engi_winlp:
			push	cx		; outer loop
			push	bx
			push	dx
							;-------------------
							;Write line to VSM
							;-------------------
							;Left border char
			dec	bx
			dec	bx
			dec	bx
			dec	bx
			push	es
			push	di
			les	di, es:[di].exo.data.VSM
			mov	WORD PTR es:[di][bx], exo__LEFTB
			mov	WORD PTR es:[di][bx][2], 0h 
			pop	di
			pop	es
			inc	bx
			inc	bx
			inc	bx
			inc	bx


			xor	ch, ch			
			mov	cl, ds:[si].endo.data.pxs ; get line len

			push	es
			push	di
			les	di, es:[di].exo.data.VSM
engi_linelp:		mov	WORD PTR es:[di][bx], ax
			mov	WORD PTR es:[di][bx][2], dx
			inc	bx
			inc	bx
			inc	bx
			inc	bx

			inc	dx
			inc	dx
			loop	engi_linelp
			pop	di
			pop	es



							;Right border char
			push	es
			push	di
			les	di, es:[di].exo.data.VSM

			mov	WORD PTR es:[di][bx], exo__RIGHTB
			mov	WORD PTR es:[di][bx][2], 0h 
	
			pop	di
			pop	es

			pop	dx
			pop	bx

			add	bx, es:[di].exo.data.hsize
			add	bx, es:[di].exo.data.hsize
			add	bx, es:[di].exo.data.hsize
			add	bx, es:[di].exo.data.hsize
			add	dx, ds:[si].endo.data.lxs
			add	dx, ds:[si].endo.data.lxs
			pop	cx
			loop	engi_winlp

							;-------------------
							;Write bottom border
							;-------------------

			xor	ch, ch			
			mov	cl, ds:[si].endo.data.pxs ; get line len
	
			push	es
			push	di
			les	di, es:[di].exo.data.VSM
			dec	bx
			dec	bx
			dec	bx
			dec	bx
			mov	WORD PTR es:[di][bx], exo__LLCB
			mov	WORD PTR es:[di][bx][2], 0h
			inc	bx
			inc	bx
			inc	bx
			inc	bx
engi_bottlp:		mov	WORD PTR es:[di][bx], exo__BOTTOMB 
			mov	WORD PTR es:[di][bx][2], 0h
			inc	bx
			inc	bx
			inc	bx
			inc	bx
			loop	engi_bottlp
			mov	WORD PTR es:[di][bx], exo__LRCB
			mov	WORD PTR es:[di][bx][2], 0h
			pop	di
			pop	es



			pop	bp
			pop	es
			pop	di
			pop	bx
			pop	ax


							;-------------------
							;Load window above 
							;-------------------
			xor	bh, bh			;bh <- 0
			mov	bl, ds:[si].endo.data.above
			cmp	bx, 0
			je	engi_yes
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
							;-------------------
							;Loop back for a 
							;validity check
							;-------------------
			jmp	engi_zero
engi_yes:
							;-------------------
							;We're done
							;-------------------
			popf
			pop	ds
			pop	es
			pop	di
			pop	si
			pop	dx
			pop	cx
			pop	bx
			pop	ax
			retf
exo__engine		ENDP


;
; exo__createwin	Takes an ES:DI pointer to an exo object, as well
;		        as a DS:SI pointer to a endowindow to be added
;			to the system.
;
exo__createwin		PROC 
			push	ax
			push	bx
			push	cx
			push	dx
			push	si
			push	ds			
			push	di
			push	es
							;-------------------
							;Find first vacant
							;slot in the wintbl
							;-------------------
			mov	ax, 0
			mov	bx, 4
			mov	ch, 0
			mov	cl, es:[di].exo.data.winnum
			shl	cx, 1
			shl	cx, 1
crea_findfree:		cmp	WORD PTR es:[di].exo.data.wintbl[bx], ax 
			jne	crea_no
crea_maybe:		cmp	WORD PTR es:[di].exo.data.wintbl[bx][2], ax 
			je	crea_yes
crea_no:
			add	bx, 4
			cmp	bx, cx
			jb	crea_findfree
			call    es:[di].exo.methods.error	
							;-------------------
							;Fill it in
							;-------------------


crea_yes :		
	 		mov	WORD PTR es:[di].exo.data.wintbl[bx], si	
			mov	si, ds
			mov	WORD PTR es:[di].exo.data.wintbl[bx][2], si	

							;-------------------
							;Set up the links:
							;-------------------
			shr	bx, 1
			shr	bx, 1

			xor	ah, ah			
			mov	al, es:[di].exo.data.top;ax = old top win
			mov	es:[di].exo.data.top, bl;bx = new top win

			shl	bx, 1			;bx = new top win*4
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
			shr	bx, 1			;bx = new top win
			shr	bx, 1
			mov	ds:[si].endo.data.id, bl   ;set the id of new 
			mov	ds:[si].endo.data.above, 0 ;none above it
			mov	ds:[si].endo.data.below, al;old top below it

			cmp	al, 0			; First Window
			je	FirstWin
			
			xchg	ax, bx			;bx = old top win
			shl	bx, 1			;old top win*4
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ds:[si].endo.data.above, al
			
FirstWin:
			pop	es
			pop	di
			pop	ds			
			pop	si
			pop	dx	
			pop	cx
			pop	bx
			pop	ax
			retf
exo__createwin		ENDP


;
; exo__destroywin	Takes an ES:DI pointer to an exo object, as well
;		        the window id in BX, and removes the window from 
;			the system 
;
exo__destroywin		PROC
			push	dx
			push	si
			push	ds

			cmp	es:[di].exo.data.bottom, bl
			jne	dest_notbott
								
							;-------------------
							;Case I:  Bottom win
							;-------------------

							;If it is the bottom
							;window, load it
			push	bx
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ah, ah			;ah <- 0
			mov	al, ds:[si].endo.data.above
							;ax = new
							;bx = old*4
			mov	es:[di].exo.data.bottom, al
 							;Set bottom ptr to new
			xchg	ax, bx			
							;ax = old*4
							;bx = new
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
							;Now, none below new
			mov	ds:[si].endo.data.below, 0
			pop	bx
			jmp	dest_done
		
dest_notbott:		cmp	es:[di].exo.data.top, bl
			jne	dest_nottop
							;-------------------
							;Case II:  Top win
							;-------------------

							;If it is the top
							;window, load it
			push	bx
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	al, ds:[si].endo.data.below

							;ax = new
							;bx = old*4
			mov	es:[di].exo.data.top, al;Set top ptr to new
			xchg	ax, bx			
							;ax = old*4
							;bx = new
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
							;Now, none above new
			mov	ds:[si].endo.data.above, 0
			pop	bx
			jmp	dest_done
dest_nottop:						
							;-------------------
							;Case III:  Neither
							;-------------------
			push	ax
			push	bx
			push	cx
			shl	bx, 1	
			shl	bx, 1	
			lds	si, es:[di].exo.data.wintbl[bx]
							;ax = old->above
							;bx = old*4
							;cx = old->below
			mov	al, ds:[si].endo.data.above
			mov	cl, ds:[si].endo.data.below	
			push	ax
			xchg	ax, bx			;ax = old*4
			shl	bx, 1			;bx = old->above*4
			shl	bx, 1
							;cx = old->below
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ds:[si].endo.data.below, cl	

			pop	ax			;ax = old->above
			xchg	bx, cx			;bx = old->below*4
			shl	bx, 1			;cx = old*4
			shl	bx, 1

			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ds:[si].endo.data.above, al

			pop	cx
			pop	bx
			pop	ax
dest_done:
			pop	ds			
			pop	si
			pop	dx
			retf
exo__destroywin		ENDP


;
; exo__movewin		Takes an ES:DI pointer to an exo object, the window 
;		        id in BX, new coordinates in (AL, AH) and moves the 
;			window in the system.	
;
exo__movewin		PROC
			push	ds
			push	si
			push	bx

							;-------------------
							;Load the endo win
							;-------------------
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
							;-------------------
							;Alter the endo win
							;-------------------

			mov	ds:[si].endo.data.pxo, al
			mov	ds:[si].endo.data.pyo, ah
							;-------------------
							;Update the system
							;-------------------

			pop	bx
			pop	si
			pop	ds

			retf
exo__movewin		ENDP


;
; exo__resizewin	Takes an ES:DI pointer to an exo object, the window 
;		        id in BX, new dimentions in (AL, AH) and resizes the 
;			window in the system.	
;
exo__resizewin		PROC
			push	ds
			push	si
			push	bx

							;-------------------
							;Load the endo win
							;-------------------
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
							;-------------------
							;Alter the endo win
							;-------------------
			cmp	al, 1
			jl	error			; smallest win is 1x1
			cmp	ah, 1
			jl	error	

			mov	ds:[si].endo.data.pxs, al
			mov	ds:[si].endo.data.pys, ah
							;-------------------
							;Update the system
							;-------------------

error:
			pop	bx
			pop	si
			pop	ds
			retf
exo__resizewin		ENDP


;
; exo__floatwin		Takes an ES:DI pointer to an exo object, as well
;		        the window id in BX, and places that window logically
;			on the top of a screen.	
;
exo__floatwin		PROC
			push	ax			;ax = old
			push	bx			;bx = new
			push	dx			
			push	si
			push	ds

			shl	bx,1
			shl	bx,1
			lds	si, es:[di].exo.data.wintbl[bx]
			shr	bx, 1
			shr	bx, 1
			mov	al, es:[di].exo.data.top;Hold old top win
			cmp	al, bl
			je	done			;already top	
			cmp	bl, es:[di].exo.data.bottom
			je	is_bottom
			jmp	not_bottom


is_bottom:
			push	ds
			push	si
			push	bx
			push	ax

			mov	al, ds:[si].endo.data.above
			mov	es:[di].exo.data.bottom, al 

			mov	bl, ds:[si].endo.data.above
			shl	bx,1
			shl	bx,1
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ds:[si].endo.data.below, 0

			
			pop	ax

			jmp	share
			
not_bottom:
			push	ds
			push	si
			push	bx
			push	cx
	
			mov	ch, ds:[si].endo.data.above
			mov	cl, ds:[si].endo.data.below
			mov	bl, ch
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ds:[si].endo.data.below, cl
			mov	bl, cl
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ds:[si].endo.data.above, ch
			
				
			pop	cx
			


share:
			mov	bl, es:[di].exo.data.top
			shl	bx,1
			shl	bx,1
			lds	si, es:[di].exo.data.wintbl[bx]
			pop	bx
			mov	ds:[si].endo.data.above, bl
			
			pop	si
			pop	ds

			mov	al, es:[di].exo.data.top
			mov	ds:[si].endo.data.below, al 
			mov	ds:[si].endo.data.above, 0
			mov	es:[di].exo.data.top, bl
done:
				
			pop	ds
			pop	si
			pop	dx
			pop	bx
			pop	ax

			retf
exo__floatwin		ENDP


;
; exo__sinkwin		Takes an ES:DI pointer to an exo object, as well
;		        the window id in BX, and places that window logically
;			on the bottom of a screen.	
;
exo__sinkwin		PROC
			push	ax			;ax = old
			push	bx			;bx = new
			push	dx			
			push	si
			push	ds

			shl	bx,1
			shl	bx,1
			lds	si, es:[di].exo.data.wintbl[bx]
			shr	bx, 1
			shr	bx, 1
			mov	al, es:[di].exo.data.bottom	;Hold bottom win
			cmp	al, bl
			je	done			;already bottom	
			cmp	bl, es:[di].exo.data.top
			je	is_top
			jmp	not_top


is_top:
			push	ds
			push	si
			push	bx
			push	ax

			mov	al, ds:[si].endo.data.below
			mov	es:[di].exo.data.top, al 

			mov	bl, ds:[si].endo.data.below
			shl	bx,1
			shl	bx,1
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ds:[si].endo.data.above, 0

			
			pop	ax

			jmp	share
			
not_top:
			push	ds
			push	si
			push	bx
			push	cx
	
			mov	ch, ds:[si].endo.data.above
			mov	cl, ds:[si].endo.data.below
			mov	bl, ch
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ds:[si].endo.data.below, cl
			mov	bl, cl
			shl	bx, 1
			shl	bx, 1
			lds	si, es:[di].exo.data.wintbl[bx]
			mov	ds:[si].endo.data.above, ch
			
				
			pop	cx
			


share:
			mov	bl, es:[di].exo.data.bottom
			shl	bx,1
			shl	bx,1
			lds	si, es:[di].exo.data.wintbl[bx]
			pop	bx
			mov	ds:[si].endo.data.below, bl
			
			pop	si
			pop	ds

			mov	al, es:[di].exo.data.bottom
			mov	ds:[si].endo.data.above, al 
			mov	ds:[si].endo.data.below, 0
			mov	es:[di].exo.data.bottom, bl
done:
				
			pop	ds
			pop	si
			pop	dx
			pop	bx
			pop	ax

			retf
exo__sinkwin		ENDP



;
; exo__update		Given an ES:DI pointer to an exo object, updates
;		        the physical screen based on the recent state of  
;			the VSM.
;
exo__update		PROC
			push	ax
			push	bx
			push	cx
			push	dx
			push	si
			push	di
			push	bp
			push	es	
			push	ds
							;-------------------
							;es:di is either
							;this or video	
							;-------------------

							;-------------------
							;ds:si is either
							;VSM or logical	
							;-------------------
			mov	cx, es:[di].exo.data.VSMsize

			lds	si, es:[di].exo.data.VSM
			xor	bp, bp			;bp <- 0
update_lp:

			mov	bx, WORD PTR ds:[si][bp]	;VSM winID
			mov	ax, WORD PTR ds:[si][bp][2]	;VSM offset

			push	ds
			push	si

			cmp	bx, 0
			jne	maybe_border	
			mov	al, ' '
			jmp	put_data	
maybe_border:
			cmp	bx, exo__TOPB 
			jne	nextr
			mov	al, 205d
			jmp	put_data 
nextr:			cmp	bx, exo__RIGHTB 
			jne	nextb
			mov	al, 186d
			jmp	put_data	
nextb:			cmp	bx, exo__BOTTOMB 
			jne	nextl
			mov	al, 205d
			jmp	put_data	
nextl:			cmp	bx, exo__LEFTB 
			jne	nextulc	
			mov	al, 186d
			jmp	put_data	
nextulc:		cmp	bx, exo__ULCB 
			jne	nexturc	
			mov	al, 201d
			jmp	put_data	
nexturc:		cmp	bx, exo__URCB 
			jne	nextlrc	
			mov	al, 187d
			jmp	put_data	
nextlrc:		cmp	bx, exo__LRCB 
			jne	nextllc	
			mov	al, 188d
			jmp	put_data	
nextllc:		cmp	bx, exo__LLCB 
			jne	not_border
			mov	al, 200d
			jmp	put_data	

loop_middle:
			jmp	update_lp

not_border:	
			shl	bx, 1
			shl	bx, 1


			lds 	si, es:[di].exo.data.wintbl[bx]
			lds	si, ds:[si].endo.data.logical
			xchg	ax, bx

			mov	ax, ds:[si][bx]
put_data:
			mov	ah, es:[di].exo.data.attr

			push	es
			push	di

			les	di, es:[di].exo.data.videoRAM
			shr	bp, 1
			mov	WORD PTR es:[di][bp], ax
			shl	bp, 1

			pop	di
			pop	es
			

			pop	si
			pop	ds

			add	bp, 4
			loop	loop_middle	

			pop	ds
			pop	es
			pop	bp
			pop	di
			pop	si
			pop	dx
			pop	cx
			pop	bx
			pop	ax
			retf
exo__update		ENDP



;
; exo__clear		Given an ES:DI pointer to a exo object, clears
;			the screen in text mode.
;
exo__clear		PROC
		        push	ax
			push	bx
			push	cx
			push	di
			push	es
			pushf

							;------------------
							;Remember default
							;attribute
							;------------------
			mov	bl, es:[di].exo.data.attr

							;------------------
							;Find the size of 
							;video to clear
							;------------------

			mov	cx, es:[di].exo.data.VSMsize

							;------------------
							;Load es:di to base
							;of video
							;------------------
			les	di, es:[di].exo.data.videoRAM
			cld 				;Forward direction
			mov	ah, bl 
			mov	al, ' ' 
			rep	stosw

			popf
			pop	es
			pop	di
			pop	cx
			pop	bx
			pop	ax
			retf
exo__clear		ENDP



_EXPRESSC		ENDS


END
