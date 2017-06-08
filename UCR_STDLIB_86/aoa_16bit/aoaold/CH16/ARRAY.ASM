		.286			;Needs additional imul instr.
		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list

array		macro	name,dim1,dim2
&name&_1	equ	dim1
name		word	dim1 dup (dim2 dup(0))
		endm

fetch		macro	name,index1,index2
		mov	bx, index1
		imul	bx, &name&_1
		add	bx, index2
		shl	bx, 1
		mov	ax, name[bx]
		endm

store		macro	name,index1,index2
		mov	bx, index1
		imul	bx, &name&_1
		add	bx, index2
		shl	bx, 1
		mov	name[bx], ax
		endm

address		macro	name,index1,index2
		mov	bx, index1
		imul	bx, &name&_1
		add	bx, index2
		shl	bx, 1
		lea	bx, name[bx]
		endm


dseg		segment	para public 'data'
j		word	?
k		word	?
		array	a, 10, 10
		array	b, 10, 10
dseg		ends

cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit

		mov	j, 0
ForJLp:		cmp	j, 10
		jnle	EndJ
		mov	k, 0
ForKLp:		cmp	k, 10
		jnle	EndK

		fetch	a, j, k
		store	b, j, k

		inc	k
		jmp	ForKLp

EndK:		inc	j
		jmp	ForJLp

EndJ:


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg            ends
sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
