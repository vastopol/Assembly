Constant	=	5
Textual		textequ	<5>
Equate		equ	<5>
Equate2		equ	6

Mac		macro	i,j
i		byte	j
		endm

structure	struct
i		byte	?
j		word	?
k		dword	?
structure	ends

dseg		segment
		Mac	a, 10
d		structure {}
r		real4	?
dseg		ends

cseg		segment
		assume	ds:dseg

NearProc	proc	near
NearLocal:	ret
NearProc	endp

FarProc		proc	far
FarGlobal::	ret
FarProc		endp
cseg		ends
		end
