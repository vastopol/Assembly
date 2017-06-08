; Demonstration of location counter values
; in an assembly listing.  Assemble this
; code with the /Fl command line option.

cseg		segment
MyProc		proc
		push	ax
		mov	al, 0
		mov	ax, 0
		mov	bx, ax
		mov	ax, 1234h[bx]
		jmp	$+2
		pop	ax
		ret
MyProc		endp
cseg		ends
		end