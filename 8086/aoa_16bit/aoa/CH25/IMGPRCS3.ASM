; IMGPRCS.ASM
;
; An image processing program (Second optimization pass).
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
; Version #3: Used registers for all variables. Set up segment registers
;	      once and for all through the execution of the main loop so
;	      the code didn't have to reload ds each time through.  Computed
;	      index into each row only once (outside the j loop).
;
;
;	Performance comparisons (66 MHz 80486 DX/2 system).
;
;	This code-		 4 seconds.
;	1st optimization pass-	 6 seconds.
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

GoodRead:       print
		byte	"Enter number of iterations: ",0
		getsm
		atoi
		free
		mov	bp, ax
		cmp	ax, 0
		jle	Quit

		print
		byte	"Computing Result",cr,lf,0


; Copy the input data to the output buffer.


hloop:		mov	ax, InSeg
		mov	es, ax
		mov	ax, OutSeg
		mov	ds, ax
		lea	si, DataOut
		lea	di, DataIn
		mov	cx, (251*256)/4
	rep	movsd

		assume	ds:InSeg, es:OutSeg
		mov	ax, InSeg
		mov	ds, ax
		mov	ax, OutSeg
		mov	es, ax



		mov	cl, 249
iloop:		mov	bh, cl			;i*256
		mov	bl, 1			;Start at j=1.
		mov	ch, 254			;# of times through loop.
jloop:
		mov	dx, 0			;Compute sum here.
		mov	ah, dh
		mov	dl, DataIn[bx-257]	;DataIn[i-1][j-1]
		mov	al, DataIn[bx-256]	;DataIn[i-1][j]
		add	dx, ax
		mov	al, DataIn[bx-255]	;DataIn[i-1][j+1]
		add	dx, ax
		mov	al, DataIn[bx-1]	;DataIn[i][j-1]
		add	dx, ax
		mov	al, DataIn[bx+1]	;DataIn[i][j+1]
		add	dx, ax
		mov	al, DataIn[bx+255]	;DataIn[i+1][j-1]
		add	dx, ax
		mov	al, DataIn[bx+256]	;DataIn[i+1][j]
		add	dx, ax
		mov	al, DataIn[bx+257]	;DataIn[i+1][j+1]
		add	dx, ax

		mov	al, DataIn[bx]		;DataIn[i][j]
		shl	ax, 3			;DataIn[i][j]*8
		add	dx, ax
		shr	dx, 4			;Divide by 16
		mov	DataOut[bx], dl

		inc	bx
		dec	ch
		jne	jloop

		dec	cl
		jne	iloop

		dec	bp
		jne	hloop

Done:		print
		byte	"Writing result",cr,lf,0


; Okay, write the data to the output file:

		mov	ah, 3ch		;Create output file.
		mov	cx, 0		;Normal file attributes.
		mov	dx, dseg
		mov	ds, dx
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
