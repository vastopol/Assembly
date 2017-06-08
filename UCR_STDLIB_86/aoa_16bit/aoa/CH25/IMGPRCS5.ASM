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
; Version #5: Converted data arrays to words rather than bytes and operated
;	      on 16-bit values.  Yielded minimal speedup.
;
;	Performance comparisons (66 MHz 80486 DX/2 system).
;
;	This code-	       2.4 seconds.
;	3rd optimization pass- 2.5 seconds.
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

ImgData		byte	251 dup (256 dup (?))

InName		byte	"roller1.raw",0
OutName		byte	"roller2.raw",0
Iterations	word	0

dseg		ends


; This code makes the naughty assumption that the following
; segments are loaded contiguously in memory!  Also, because these
; segments are paragraph aligned, this code assumes that these segments
; will contain a full 65,536 bytes.  You cannot declare a segment with
; exactly 65,536 bytes in MASM.  However, the paragraph alignment option
; ensures that the extra byte of padding is added to the end of each
; segment.

DataSeg1	segment	para public 'ds1'
Data1a		byte	65535 dup (?)
DataSeg1	ends

DataSeg2	segment	para public 'ds2'
Data1b		byte	65535 dup (?)
DataSeg2	ends

DataSeg3	segment	para public 'ds3'
Data2a		byte	65535 dup (?)
DataSeg3	ends

DataSeg4	segment	para public 'ds4'
Data2b		byte	65535 dup (?)
DataSeg4	ends




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
; hloop.

GoodOpen:	mov	bx, ax		;File handle.
		lea	dx, ImgData
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
		mov	Iterations, ax
		cmp	ax, 0
		jle	Quit

		printf
		byte	"Computing Result for %d iterations",cr,lf,0
		dword	Iterations



; Copy the data and expand it from eight bits to sixteen bits.
; The first loop handles the first 32,768 bytes, the second loop
; handles the remaining bytes.

		mov	ax, DataSeg1
		mov	es, ax
		mov	ax, DataSeg3
		mov	fs, ax

		mov	ah, 0
		mov	cx, 32768
		lea	si, ImgData
		xor	di, di			;Output data is at ofs zero.
CopyLoop:	lodsb
		mov	fs:[di], ax
		stosw
		dec	cx
		jne	CopyLoop

		mov	di, DataSeg2
		mov	es, di
		mov	di, DataSeg4
		mov	fs, di
		mov	cx, (251*256) - 32768
		xor	di, di
CopyLoop1:	lodsb
		mov	fs:[di], ax
		stosw
		dec	cx
		jne	CopyLoop1

; hloop completes one iteration on the data moving it from Data1a/Data1b
; to Data2a/Data2b

hloop:		mov	ax, DataSeg1
		mov	ds, ax
		mov	ax, DataSeg3
		mov	es, ax

; Process the first 127 rows (65,024 bytes) of the array):

		mov	cl, 127
		lea	si, Data1a+202h		;Start at [1,1]
iloop0:		mov	ch, 254/2		;# of times through loop.
jloop0:		mov	dx, [si]		;[i,j]
		mov	bx, [si-200h]		;[i-1,j]
		mov	ax, dx
		shl	dx, 3			;[i,j] * 8
		add	bx, [si-1feh]		;[i-1,j+1]
		mov	bp, [si+2]		;[i,j+1]
		add	bx, [si+200h]		;[i+1,j]
		add	dx, bp
		add	bx, [si+202h]		;[i+1,j+1]
		add	dx, [si-202h]		;[i-1,j-1]
		mov	di, [si-1fch]		;[i-1,j+2]
		add	dx, [si-2]		;[i,j-1]
		add	di, [si+4]		;[i,j+2]
		add	dx, [si+1feh]		;[i+1,j-1]
		add	di, [si+204h]		;[i+1,j+2]
		shl	bp, 3			;[i,j+1] * 8
		add	dx, bx
		add	bp, ax
		shr	dx, 4			;Divide by 16.
		add	bp, bx
		mov	es:[si], dx		;Store [i,j] entry.
		add	bp, di
		add	si, 4			;Affects next store operation!
		shr	bp, 4			;Divide by 16.
		dec	ch
		mov	es:[si-2], bp		;Store [i,j+1] entry.
		jne	jloop0

		add	si, 4			;Skip to start of next row.

		dec	cl
		jne	iloop0

; Process the last 124 rows of the array).  This requires that we switch from
; one segment to the next.  Note that the segments overlap.

		mov	ax, DataSeg2
		sub	ax, 40h			;Back up to last 2 rows in DS2
		mov	ds, ax
		mov	ax, DataSeg4
		sub	ax, 40h			;Back up to last 2 rows in DS4
		mov	es, ax

		mov	cl, 251-127-1		;Remaining rows to process.
		mov	si, 202h		;Continue with next row.
iloop1:		mov	ch, 254/2		;# of times through loop.
jloop1:		mov	dx, [si]		;[i,j]
		mov	bx, [si-200h]		;[i-1,j]
		mov	ax, dx
		shl	dx, 3			;[i,j] * 8
		add	bx, [si-1feh]		;[i-1,j+1]
		mov	bp, [si+2]		;[i,j+1]
		add	bx, [si+200h]		;[i+1,j]
		add	dx, bp
		add	bx, [si+202h]		;[i+1,j+1]
		add	dx, [si-202h]		;[i-1,j-1]
		mov	di, [si-1fch]		;[i-1,j+2]
		add	dx, [si-2]		;[i,j-1]
		add	di, [si+4]		;[i,j+2]
		add	dx, [si+1feh]		;[i+1,j-1]
		add	di, [si+204h]		;[i+1,j+2]
		shl	bp, 3			;[i,j+1] * 8
		add	dx, bx
		add	bp, ax
		shr	dx, 4			;Divide by 16
		add	bp, bx
		mov	es:[si], dx		;Store [i,j] entry.
		add	bp, di
		add	si, 4			;Affects next store operation!
		shr	bp, 4
		dec	ch
		mov	es:[si-2], bp		;Store [i,j+1] entry.
		jne	jloop1

		add	si, 4			;Skip to start of next row.

		dec	cl
		jne	iloop1

		mov	ax, dseg
		mov	ds, ax
		assume	ds:dseg

		dec	Iterations
		je	Done0

; Unroll the iterations loop so we can move the data from DataSeg2/4 back
; to DataSeg1/3 without wasting extra time.  Other than the direction of the
; data movement, this code is virtually identical to the above.

		mov	ax, DataSeg3
		mov	ds, ax
		mov	ax, DataSeg1
		mov	es, ax

		mov	cl, 127
		lea	si, Data1a+202h
iloop2:		mov	ch, 254/2
jloop2:		mov	dx, [si]
		mov	bx, [si-200h]
		mov	ax, dx
		shl	dx, 3
		add	bx, [si-1feh]
		mov	bp, [si+2]
		add	bx, [si+200h]
		add	dx, bp
		add	bx, [si+202h]
		add	dx, [si-202h]
		mov	di, [si-1fch]
		add	dx, [si-2]
		add	di, [si+4]
		add	dx, [si+1feh]
		add	di, [si+204h]
		shl	bp, 3
		add	dx, bx
		add	bp, ax
		shr	dx, 4
		add	bp, bx
		mov	es:[si], dx
		add	bp, di
		add	si, 4
		shr	bp, 4
		dec	ch
		mov	es:[si-2], bp
		jne	jloop2

		add	si, 4

		dec	cl
		jne	iloop2


		mov	ax, DataSeg4
		sub	ax, 40h
		mov	ds, ax
		mov	ax, DataSeg2
		sub	ax, 40h
		mov	es, ax

		mov	cl, 251-127-1
		mov	si, 202h
iloop3:		mov	ch, 254/2
jloop3:		mov	dx, [si]
		mov	bx, [si-200h]
		mov	ax, dx
		shl	dx, 3
		add	bx, [si-1feh]
		mov	bp, [si+2]
		add	bx, [si+200h]
		add	dx, bp
		add	bx, [si+202h]
		add	dx, [si-202h]
		mov	di, [si-1fch]
		add	dx, [si-2]
		add	di, [si+4]
		add	dx, [si+1feh]
		add	di, [si+204h]
		shl	bp, 3
		add	dx, bx
		add	bp, ax
		shr	dx, 4
		add	bp, bx
		mov	es:[si], dx
		add	bp, di
		add	si, 4
		shr	bp, 4
		dec	ch
		mov	es:[si-2], bp
		jne	jloop3

		add	si, 4

		dec	cl
		jne	iloop3

		mov	ax, dseg
		mov	ds, ax
		assume	ds:dseg

		dec	Iterations
		je	Done2
		jmp	hloop

Done2:		mov	ax, DataSeg1
		mov	bx, DataSeg2
		jmp	Finish

Done0:		mov	ax, DataSeg3
		mov	bx, DataSeg4
Finish:		mov	ds, ax
		print
		byte	"Writing result",cr,lf,0

; Convert data back to byte form and write to the output file:

		mov	ax, dseg
		mov	es, ax

		mov	cx, 32768
		lea	di, ImgData
		xor	si, si			;Output data is at ofs zero.
CopyLoop3:	lodsw
		stosb
		dec	cx
		jne	CopyLoop3

		mov	ds, bx
		mov	cx, (251*256) - 32768
		xor	si, si
CopyLoop4:	lodsw
		stosb
		dec	cx
		jne	CopyLoop4


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
		mov	dx, dseg	;Where the data can be found.
		mov	ds, dx
		lea	dx, ImgData
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
