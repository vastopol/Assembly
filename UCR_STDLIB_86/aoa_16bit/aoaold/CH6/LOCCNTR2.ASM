; Demonstration of ORG Directive:
		assume	ds:dseg
dseg		segment
		org	20h
i		word	?
j		sword	?
dseg		ends

cseg		segment
		org	100h
MyProc		proc
		push	ax
		mov	ax, i
		cmp	ax, 0
		jns	IsPositive
		neg	ax
IsPositive:	mov	j, ax
		pop	ax
		ret
MyProc		endp
cseg		ends
		end