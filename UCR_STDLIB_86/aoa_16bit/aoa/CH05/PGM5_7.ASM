; Structures Containing Structures as fields
; Structures Containing Arrays as fields
;
; Randall Hyde


dseg		segment	para public 'data'

Point		struct
X		word	?
Y		word	?
Point		ends

; We can define a rectangle with only two points.
; The color field contains an eight-bit color value.
; Note: the size of a Rect is 9 bytes.

Rect		struct
UpperLeft	Point	{}
LowerRight	Point	{}
Color		byte	?
Rect		ends

; Pentagons have five points, so use an array of points to
; define the pentagon.  Of course, we also need the color
; field.
; Note: the size of a pentagon is 21 bytes.

Pent		struct
Color		byte	?
Pts		Point	5 dup ({})
Pent		ends


; Okay, here are some variable declarations:

Rect1		Rect	{}
Rect2		Rect	{{0,0}, {1,1}, 1}

Pentagon1	Pent	{}
Pentagons	Pent	{}, {}, {}, {}

Index		word	2

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg	;These statements are provided by
		mov	ds, ax		; shell.asm to initialize the
		mov	es, ax		; segment register.

; Rect1.UpperLeft.X := Rect2.UpperLeft.X

		mov	ax, Rect2.Upperleft.X
		mov	Rect1.Upperleft.X, ax

; Pentagon1 := Pentagons[Index]

		mov	ax, Index	;Need Index*21
		mov	bx, 21
		mul	bx
		mov	bx, ax

; Copy the first point:

		mov	ax, Pentagons[bx].Pts[0].X
		mov	Pentagon1.Pts[0].X, ax

		mov	ax, Pentagons[bx].Pts[0].Y
		mov	Pentagon1.Pts[0].Y, ax

; Copy the second point:

		mov	ax, Pentagons[bx].Pts[2].X
		mov	Pentagon1.Pts[4].X, ax

		mov	ax, Pentagons[bx].Pts[2].Y
		mov	Pentagon1.Pts[4].Y, ax

; Copy the third point:

		mov	ax, Pentagons[bx].Pts[4].X
		mov	Pentagon1.Pts[8].X, ax

		mov	ax, Pentagons[bx].Pts[4].Y
		mov	Pentagon1.Pts[8].Y, ax

; Copy the fourth point:

		mov	ax, Pentagons[bx].Pts[6].X
		mov	Pentagon1.Pts[12].X, ax

		mov	ax, Pentagons[bx].Pts[6].Y
		mov	Pentagon1.Pts[12].Y, ax

; Copy the fifth point:

		mov	ax, Pentagons[bx].Pts[8].X
		mov	Pentagon1.Pts[16].X, ax

		mov	ax, Pentagons[bx].Pts[8].Y
		mov	Pentagon1.Pts[16].Y, ax

; Copy the Color:

		mov	al, Pentagons[bx].Color
		mov	Pentagon1.Color, al


Quit:		mov	ah, 4ch		;Magic number for DOS
		int	21h		; to tell this program to quit.
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
