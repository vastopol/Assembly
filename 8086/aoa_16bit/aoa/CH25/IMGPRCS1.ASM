; IMGPRCS.ASM
;
; An image processing program.
;
; This program blurs an eight-bit grayscale image by averaging a pixel
; in the image with the eight pixels around it.  The average is computed
; by (CurCell*8 + other 8 cells)/16, weighting the current cell by 50%.
;
; Because of the size of the image (almost 64K), the input and output
; matrices are in different segments.
;
; Version #1: Straight-forward translation from Pascal to Assembly.
;
;	Performance comparisons (66 MHz 80486 DX/2 system).
;
;	This code-		36 seconds.
;	Borland Pascal v7.0-	45 seconds.
;	Borland C++ v4.02-	29 seconds.
;	Microsoft C++ v8.00-	21 seconds.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list
		.286

dseg		segment	para public 'data'

; Loop control variables and other variables:

h		word	?
i		word	?
j		word	?
k		word	?
l		word	?
sum		word	?
iterations	word	?

; File names:

InName		byte	"roller1.raw",0
OutName		byte	"roller2.raw",0

dseg		ends


; Here is the input data that we operate on.

InSeg		segment	para public 'indata'

DataIn		byte	251 dup (256 dup (?))

InSeg		ends


; Here is the output array that holds the result.

OutSeg		segment	para public 'outdata'

DataOut		byte	251 dup (256 dup (?))

OutSeg		ends




cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg

Main		proc
		mov	ax, dseg
		mov	ds, ax
		meminit

		mov	ax, 3d00h	;Open input file for reading.
		lea	dx, InName
		int	21h
		jnc	GoodOpen
		print
		byte	"Could not open input file.",cr,lf,0
		jmp	Quit

GoodOpen:	mov	bx, ax		;File handle.
		mov	dx, InSeg	;Where to put the data.
		mov	ds, dx
		lea	dx, DataIn
		mov	cx, 256*251	;Size of data file to read.
		mov	ah, 3Fh
		int	21h
		cmp	ax, 256*251	;See if we read the data.
		je	GoodRead
		print
		byte	"Did not read the file properly",cr,lf,0
		jmp	Quit

GoodRead:       mov	ax, dseg
		mov	ds, ax
		print
		byte	"Enter number of iterations: ",0
		getsm
		atoi
		free
		mov	iterations, ax
		print
		byte	"Computing Result",cr,lf,0

; Copy the input data to the output buffer.

		mov	i, 0
iloop0:		cmp	i, 250
		ja	iDone0
		mov	j, 0
jloop0:		cmp	j, 255
		ja	jDone0

		mov	bx, i			;Compute index into both
		shl	bx, 8			; arrays using the formula
		add	bx, j			; i*256+j (row major).

		mov	cx, InSeg		;Point at input segment.
		mov	es, cx
		mov	al, es:DataIn[bx]	;Get DataIn[i][j].

		mov	cx, OutSeg		;Point at output segment.
		mov	es, cx
		mov	es:DataOut[bx], al	;Store into DataOut[i][j]

		inc	j			;Next iteration of j loop.
		jmp	jloop0

jDone0:		inc	i			;Next iteration of i loop.
		jmp	iloop0

iDone0:

; for h := 1 to iterations-

		mov	h, 1
hloop:		mov	ax, h
		cmp	ax, iterations
		ja	hloopDone



; for i := 1 to 249 -

		mov	i, 1
iloop:		cmp	i, 249
		ja	iloopDone

; for j := 1 to 254 -
		mov	j, 1
jloop:		cmp	j, 254
		ja	jloopDone


; sum := 0;
; for k := -1 to 1 do for l := -1 to 1 do

		mov	ax, InSeg		;Gain access to InSeg.
		mov	es, ax

		mov	sum, 0
		mov	k, -1
kloop:		cmp	k, 1
		jg	kloopDone

		mov	l, -1
lloop:		cmp	l, 1
		jg	lloopDone

; sum := sum + datain [i+k][j+l]

		mov	bx, i
		add	bx, k
		shl	bx, 8		;Multiply by 256.
		add	bx, j
		add	bx, l

		mov	al, es:DataIn[bx]
		mov	ah, 0
		add	Sum, ax

		inc	l
		jmp	lloop

lloopDone:	inc	k
		jmp	kloop


; dataout [i][j] := (sum + datain[i][j]*7) div 16;

kloopDone:	mov	bx, i
		shl	bx, 8			;*256
		add	bx, j
		mov	al, es:DataIn[bx]
		mov	ah, 0
		imul	ax, 7
		add	ax, sum
		shr	ax, 4		       	;div 16

		mov	bx, OutSeg
		mov	es, bx

		mov	bx, i
		shl	bx, 8
		add	bx, j
		mov	es:DataOut[bx], al

		inc	j
		jmp	jloop

jloopDone:	inc	i
		jmp	iloop

iloopDone:
; Copy the output data to the input buffer.

		mov	i, 0
iloop1:		cmp	i, 250
		ja	iDone1
		mov	j, 0
jloop1:		cmp	j, 255
		ja	jDone1

		mov	bx, i			;Compute index into both
		shl	bx, 8			; arrays using the formula
		add	bx, j			; i*256+j (row major).

		mov	cx, OutSeg		;Point at input segment.
		mov	es, cx
		mov	al, es:DataOut[bx]	;Get DataIn[i][j].

		mov	cx, InSeg		;Point at output segment.
		mov	es, cx
		mov	es:DataIn[bx], al	;Store into DataOut[i][j]

		inc	j			;Next iteration of j loop.
		jmp	jloop1

jDone1:		inc	i			;Next iteration of i loop.
		jmp	iloop1

iDone1:		inc	h
		jmp	hloop

hloopDone:	print
		byte	"Writing result",cr,lf,0


; Okay, write the data to the output file:

		mov	ah, 3ch		;Create output file.
		mov	cx, 0		;Normal file attributes.
		lea	dx, OutName
		int	21h
		jnc	GoodCreate
		print
		byte	"Could not create output file.",cr,lf,0
		jmp	Quit

GoodCreate:	mov	bx, ax		;File handle.
		push	bx
		mov	dx, OutSeg	;Where the data can be found.
		mov	ds, dx
		lea	dx, DataOut
		mov	cx, 256*251	;Size of data file to write.
		mov	ah, 40h		;Write operation.
		int	21h
		pop	bx		;Retrieve handle for close.
		cmp	ax, 256*251	;See if we wrote the data.
		je	GoodWrite
		print
		byte	"Did not write the file properly",cr,lf,0
		jmp	Quit

GoodWrite:	mov	ah, 3eh		;Close operation.
		int	21h


Quit:		ExitPgm			;DOS macro to quit program.
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		byte	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	byte	16 dup (?)
zzzzzzseg	ends
		end	Main
