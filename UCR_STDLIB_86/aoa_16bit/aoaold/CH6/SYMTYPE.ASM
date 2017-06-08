; Program with symbols of various types.

dseg		segment
i		byte	0
j		word	0
k		dword	0
l		qword	0
dseg		ends

cseg		segment
MyProc		proc	near
		nop
MyLbl:		nop
MyLbl2::	nop
		ret
MyProc		endp

FarProc		proc	far
		nop
		ret
FarProc		endp
cseg		ends

Value1		=	1
Value2		=	2
Value3		equ	2
Value4		equ	<2>
Value5		textequ	<2>
		end
