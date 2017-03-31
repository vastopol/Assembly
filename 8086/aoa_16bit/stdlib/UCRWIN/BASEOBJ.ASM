include stdlib.a
include baseobj.a

;
; baseobj :	A MASM++ object that is the parent of all objects.
;		Written by Michael A. Griffith and Todd D. Vender		;
; Modification List:
;
; 25 Oct 91  Michael A. Griffith & Todd D. Vender:
;            Created.
;
; 26 Oct 91  Michael A. Griffith:
;
; 3 Nov 91   Michael A. Griffith:
;	     Added publics. 
;	    
; 19 Dec 91  Michael A. Griffith:
;	     Wrote virtual function error 
;
; 27 Dec 91  Michael A. Griffith:
;	     error function needed some work 
;
; 29 Dec 91  Michael A. Griffith:
;            Fixed printing of parent's address in error
;	     
; 15 Jan 92  Michael A. Griffith & Andrew G. Pomykal:
;            changes REGS to print all of the register
;	     
; 29 Jan 92  Michael A. Griffith, Todd D. Vender, & Andrew G. Pomykal
;	     Changed the IsInHeap, to an IsPtr
;
; 31 Jan 92  Todd D. Vender 
;	     Fixed regs so that es prints word in proper order.
;


_EXPRESSD		SEGMENT PARA PUBLIC 'DATA'

obj			baseobj <> 

_EXPRESSD 		ENDS



_EXPRESSC		SEGMENT PARA PUBLIC 'CODE'


;
;baseobj__new 	Returns an ES:DI pointer to a dyna-allocated
;		baseobject.  Necessarly destroys ES:DI.   Obviously
;		not meant for static objects.
public			baseobj__new
baseobj__new		PROC FAR
			push	ax
			push	cx
			IsPtr
			jnc	new_preallocated	;If allocated
							;call realloc
							;to size it.
							;Otherwize
							;call malloc
							;to make it.
			mov	cx, sizeof baseobj
			malloc		
			jnc 	new_done
			call	baseobj__error
new_preallocated:	mov	cx, sizeof baseobj
			realloc

new_done:	    	mov	ax, 1	
			mov	es:[di].baseobj.data.dynamic, 1	
							;Set the dynamic
							;flag so in later
							;use, we know that	
							;this was malloc'ed
			pop	cx
			pop	ax
			retf
baseobj__new		ENDP

;
;baseobj__constructor	Takes an ES:DI pointer to a baseobj, and initializes 
;			it regardless of whether it is statically or
;			dynamically allocated.


public			baseobj__constructor
baseobj__constructor	PROC FAR
			push	ax
			xor	ax, ax				;ax <- 0
			mov	WORD PTR es:[di].baseobj.parent, ax
			mov	WORD PTR es:[di].baseobj.parent[2], ax
			pop	ax			
			retf
baseobj__constructor	ENDP

public			baseobj__destructor
baseobj__destructor	PROC FAR
			retf
baseobj__destructor	ENDP



;
;baseobj__delete	Takes an ES:DI pointer to a baseobj, and calls
;			free on the pointer.  ES:DI will both equal 0
;			and the carry flag will be cleared if this operation
;			went as planned.  If the object was not dyna-allocated,
;			then the carry flag will be set.

public			baseobj__delete
baseobj__delete		PROC FAR
			free
			jnc	delete_not_a_pointer
			mov	di, 0
			mov	es, di
delete_not_a_pointer:	retf
baseobj__delete		ENDP


;
; baseobj__printself	Takes an ES:DI pointer to an object, and prints 
;			the object to the standard output.  This 
;			function is used for debugging.
;

public			baseobj__printself
baseobj__printself	PROC FAR
			push	ax

			print
			DB	"Class name:  ", 0

			push	es
			push	di
			add	di, baseobj.data.classname
			puts
			pop	di
			pop	es

			print
			DB	CR, LF, "Dynamic:  ", 0
			xor	ah, ah			;ax <- 0
			mov	al,  es:[di].baseobj.data.dynamic
			puth
			print
			DB	"h", CR, LF, 0

			pop	ax
			retf
baseobj__printself	ENDP


;
; baseobj__nameof	Takes an ES:DI pointer to an object, and returns
;			a pointer to the name of that object, in a form
;			suitable for puts in ES:DI
;

public			baseobj__nameof
baseobj__nameof		PROC
			add	di, baseobj__data.classname
			retf
baseobj__nameof		ENDP


;
; baseobj__error	Takes an ES:DI pointer to an object, and begins
;			a "nuclear power plant-style" shutdown procedure. 
;
baseobj__error		PROC

			print
			DB	"FATAL ERROR TRACEBACK", CR, LF
			DB  	"---------------------", CR, LF, 0
			call	es:[di].baseobj.methods.regs
			call	es:[di].baseobj.methods.printself
			call	es:[di].baseobj.methods.destructor

			mov     si, WORD PTR es:[di].baseobj.parent
			mov	ds, si
			mov     si, WORD PTR es:[di].baseobj.parent[2]

			print
			DB	"Parent address:  ", 0
			mov	ax, ds
			xchg	al, ah	
			puth
			xchg	al, ah	
			puth
			print
			DB	"h:", 0
			mov	ax, si
			xchg	al, ah	
			puth
			xchg	al, ah	
			puth
			print
			DB	"h", CR, LF, CR, LF, 0
			
			mov	ax, ds
			cmp	ax, 0
			jz	erro_noparent
erro_parent:
			push	es
			push	di

			push	ds			
			pop	es			;es <- ds
			mov	di, si
			call	es:[di].baseobj.methods.error

			pop	di
			pop	es
erro_noparent:
			call	es:[di].baseobj.methods.delete
							;Exit to DOS
			mov	ah, 4ch
			int	21h
baseobj__error		ENDP


; baseobj__regs		Prints a snapshot of the CPU registers to 
;			the standard output to aid in the debugging of
;			programs.
;
baseobj__regs		PROC
			push	ax

			print
			DB	"ax: ", 0
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h bx: ", 0
			mov	ax, bx
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h cx: ", 0
			mov	ax, cx
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h dx: ", 0
			mov	ax, dx
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h si: ", 0
			mov	ax, si
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h di: ", 0
			mov	ax, di
			xchg	al, ah
			puth
			xchg	al, ah
			puth
			print
			DB	"h", CR, LF, 0
			
			print
			DB	"bp: ", 0
			mov	ax, bp
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h sp: ", 0
			mov	ax, sp
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h fl: ", 0
			pushf
			pop	ax
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h cs: ", 0
			mov	ax, cs
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h ds: ", 0
			mov	ax, ds
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h ss: ", 0
			mov	ax, ss
			xchg	al, ah
			puth
			xchg	al, ah
			puth

			print
			DB	"h es: ", 0
			mov	ax, es
			xchg	al, ah
			puth
			xchg	al, ah
			puth
			putcr

			pop	ax
			retf
baseobj__regs		ENDP

_EXPRESSC		ENDS


END
