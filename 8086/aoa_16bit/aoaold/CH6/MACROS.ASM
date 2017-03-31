; Example of a localized macro to help
; build a data table in memory.

Strct		struct
		byte	?
		word	?
		dword	?
		real8	?
Strct		ends

dseg		segment


MS		macro	lbl, i, j, k
lbl		Strct	{i, 0, j,k}
		endm

		MS	Var1, 1, 2, 3.1
		MS	Var2, 3, 2, 1.0
		MS	Var3, 5, 6, 7.0e5
dseg		ends
		end
