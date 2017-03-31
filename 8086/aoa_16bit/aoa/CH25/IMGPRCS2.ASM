; IMGPRCS2.ASM
;
; An image processing program (First optimization pass).
;
; This program blurs an eight-bit grayscale image by averaging a pixel
; in the image with the eight pixels around it.  The average is computed
; by (CurCell*8 + other 8 cells)/16, weighting the current cell by 50%.
;
; Because of the size of the image (almost 64K), the input and output
; matrices are in different segments.
;
; Version #1: Straight-forward translation from Pascal to Assembly.
; Version #2: Three major optimizations. (1) used movsd instruction rather
;	      than a loop to copy data from DataOut back to DataIn.
;	      (2) Used repeat..until forms for all loops.  (3) unrolled
;	      the innermost two loops (which is responsible for most of
;	      the performance improvement).
;
;
;	Performance comparisons (66 MHz 80486 DX/2 system).
;
;	This code-		 6 seconds.
;	Original ASM code-	36 seconds.
;	Borland Pascal v7.0-	45 seconds.
;	Borland C++ v4.02-	29 seconds.
;	Microsoft C++ v8.00-	21 seconds.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list
		.386
		option		segment:use16

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

; Optimization modification- read the data into DataOut rather than
; DataIn because we'll move it into DataIn at the beginning of the
; h loop.

GoodOpen:	mov	bx, ax		;File handle.
		mov	dx, OutSeg	;Where to put the data.
		mov	ds, dx
		lea	dx, DataOut
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
		cmp	ax, 0
		jle	Quit

		print
		byte	"Computing Result",cr,lf,0

; for h := 1 to iterations-

		mov	h, 1
hloop:

; Copy the input data to the output buffer.
; Optimization step #1: Replace with movs instruction.

		push	ds
		mov	ax, OutSeg
		mov	ds, ax
		mov	ax, InSeg
		mov	es, ax
		lea	si, DataOut
		lea	di, DataIn
		mov	cx, (251*256)/4
	rep	movsd
		pop	ds


; Optimization Step #1: Convert loops to repeat..until form.

; for i := 1 to 249 -

		mov	i, 1
iloop:

; for j := 1 to 254 -

		mov	j, 1
jloop:


; Optimization.  Unroll the innermost two loops:

		mov	bh, byte ptr i		;i is always less than 256.
		mov	bl, byte ptr j		;Computes i*256+j!

		push	ds
		mov	ax, InSeg		;Gain access to InSeg.
		mov	ds, ax

		mov	cx, 0			;Compute sum here.
		mov	ah, ch
		mov	cl, ds:DataIn[bx-257]	;DataIn[i-1][j-1]
		mov	al, ds:DataIn[bx-256]	;DataIn[i-1][j]
		add	cx, ax
		mov	al, ds:DataIn[bx-255]	;DataIn[i-1][j+1]
		add	cx, ax
		mov	al, ds:DataIn[bx-1]	;DataIn[i][j-1]
		add	cx, ax
		mov	al, ds:DataIn[bx+1]	;DataIn[i][j+1]
		add	cx, ax
		mov	al, ds:DataIn[bx+255]	;DataIn[i+1][j-1]
		add	cx, ax
		mov	al, ds:DataIn[bx+256]	;DataIn[i+1][j]
		add	cx, ax
		mov	al, ds:DataIn[bx+257]	;DataIn[i+1][j+1]
		add	cx, ax

		mov	al, ds:DataIn[bx]	;DataIn[i][j]
		shl	ax, 3			;DataIn[i][j]*8
		add	cx, ax
		shr	cx, 4			;Divide by 16
		mov	ax, OutSeg
		mov	ds, ax
		mov	ds:DataOut[bx], cl
		pop	ds

		inc	j
		cmp	j, 254
		jbe	jloop

		inc	i
		cmp	i, 249
		jbe	iloop

		inc	h
		mov	ax, h
		cmp	ax, Iterations
		jnbe	Done
		jmp	hloop

Done:		print
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
