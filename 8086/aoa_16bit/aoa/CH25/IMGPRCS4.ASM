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
;
; Version #2: Three major optimizations. (1) used movsd instruction rather
;	      than a loop to copy data from DataOut back to DataIn.
;	      (2) Used repeat..until forms for all loops.  (3) unrolled
;	      the innermost two loops (which is responsible for most of
;	      the performance improvement).
;
; Version #3: Used registers for all variables. Set up segment registers
;	      once and for all through the execution of the main loop so
;	      the code didn't have to reload ds each time through.  Computed
;	      index into each row only once (outside the j loop).
;
; Version #4: Eliminated copying data from DataOut to DataIn on each pass.
;	      Removed hazards.  Maintained common subexpressions. Did some
;	      more loop unrolling.
;
;
;	Performance comparisons (66 MHz 80486 DX/2 system).
;
;	This code-	       2.5 seconds.
;	2nd optimization pass-	 4 seconds.
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


		assume	ds:InSeg, es:OutSeg

		mov	ax, InSeg
		mov	ds, ax
		mov	ax, OutSeg
		mov	es, ax

; Copy the data once so we get the edges in both arrays.

		mov	cx, (251*256)/4
		lea	si, DataIn
		lea	di, DataOut
	rep	movsd


; "hloop" repeats once for each iteration.

hloop:
		mov	ax, InSeg
		mov	ds, ax
		mov	ax, OutSeg
		mov	es, ax

; "iloop" processes the rows in the matrices.

		mov	cl, 249
iloop:		mov	bh, cl			;i*256
		mov	bl, 1			;Start at j=1.
		mov	ch, 254/2		;# of times through loop.
		mov	si, bx
		mov	dh, 0			;Compute sum here.
		mov	bh, 0
		mov	ah, 0

; "jloop" processes the individual elements of the array.
; This loop has been unrolled once to allow the two portions to share
; some common computations.

jloop:

; The sum of DataIn [i-1][j] + DataIn[i-1][j+1] + DataIn[i+1][j] +
; DataIn [i+1][j+1] will be used in the second half of this computation.
; So save its value in a register (di) until we need it again.

		mov	dl, DataIn[si-256]	;[i-1,j]
		mov	al, DataIn[si-255]	;[i-1,j+1]
		mov	bl, DataIn[si+257]	;[i+1,j+1]
		add	dx, ax
		mov	al, DataIn[si+256]	;[I+1,j]
		add	dx, bx
		mov	bl, DataIn[si+1]	;[i,j+1]
		add	dx, ax
		mov	al, DataIn[si+255]	;[i+1,j-1]

		mov	di, dx			;Save partial result.

		add	dx, bx
		mov	bl, DataIn[si-1]	;[i,j-1]
		add	dx, ax
		mov	al, DataIn[si]		;[i,j]
		add	dx, bx
		mov	bl, DataIn[si-257]	;[i-1,j-1]
		shl	ax, 3			;DataIn[i,j] * 8.
		add	dx, bx
		add	dx, ax
		shr	ax, 3			;Restore DataIn[i,j] value.
		shr	dx, 4			;Divide by 16.
		add	di, ax
		mov	DataOut[si], dl

; Okay, process the next cell over.  Note that we've got a partial sum
; sitting in DI already.  Don't forget, we haven't bumped SI at this point,
; so the offsets are off by one.  (This is the second half of the unrolled
; loop.)

		mov	dx, di			;Contains partial sum.
		mov	bl, DataIn[si-254]	;[i-1,j+1]
		mov	al, DataIn[si+2]	;[i,j+1]
		add	dx, bx
		mov	bl, DataIn[si+258]	;[i+1,j+1];
		add	dx, ax
		mov	al, DataIn[si+1]	;[i,j]
		add	dx, bx
		shl	ax, 3			;DataIn[i][j]*8
		add	si, 2			;Bump array index.
		add	dx, ax
		mov	ah, 0			;Clear for next loop iter.
		shr	dx, 4			;Divide by 16
		dec	ch
		mov	DataOut[si-1], dl
		jne	jloop

		dec	cl
		jne	iloop

		dec	bp
		je	Done


; Special case so we don't have to move the data between the two arrays.
; This is an unrolled version of the hloop that swaps the input and output
; arrays so we don't have to move data around in memory.

		mov	ax, OutSeg
		mov	ds, ax
		mov	ax, InSeg
		mov	es, ax
		assume	es:InSeg, ds:OutSeg

hloop2:

		mov	cl, 249
iloop2:		mov	bh, cl
		mov	bl, 1
		mov	ch, 254/2
		mov	si, bx
		mov	dh, 0
		mov	bh, 0
		mov	ah, 0
jloop2:
		mov	dl, DataOut[si-256]
		mov	al, DataOut[si-255]
		mov	bl, DataOut[si+257]
		add	dx, ax
		mov	al, DataOut[si+256]
		add	dx, bx
		mov	bl, DataOut[si+1]
		add	dx, ax
		mov	al, DataOut[si+255]

		mov	di, dx

		add	dx, bx
		mov	bl, DataOut[si-1]
		add	dx, ax
		mov	al, DataOut[si]
		add	dx, bx
		mov	bl, DataOut[si-257]
		shl	ax, 3
		add	dx, bx
		add	dx, ax
		shr	ax, 3
		shr	dx, 4
		mov	DataIn[si], dl

		mov	dx, di
		mov	bl, DataOut[si-254]
		add	dx, ax
		mov	al, DataOut[si+2]
		add	dx, bx
		mov	bl, DataOut[si+258]
		add	dx, ax
		mov	al, DataOut[si+1]
		add	dx, bx
		shl	ax, 3
		add	si, 2
		add	dx, ax
		mov	ah, 0
		shr	dx, 4
		dec	ch
		mov	DataIn[si-1], dl
		jne	jloop2

		dec	cl
		jne	iloop2

		dec	bp
		je	Done2
		jmp	hloop


; Kludge to guarantee that the data always resides in the output segment.

Done2:
		mov	ax, InSeg
		mov	ds, ax
		mov	ax, OutSeg
		mov	es, ax
		mov	cx, (251*256)/4
		lea	si, DataIn
		lea	di, DataOut
	rep	movsd

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
