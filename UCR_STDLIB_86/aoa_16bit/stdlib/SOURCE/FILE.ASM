		include	file.a
StdGrp		group	stdlib,stddata

stddata		segment	para public 'sldata'
stddata		ends

		ifndef	@version
@version	=	500
		endif


stdlib		segment	para public 'slcode'
		assume	cs:stdgrp


		if	@version ge 600

; sl_fopen- Opens a file.
;	On entry:
;			AX contains mode (0=read, 1=write)
;			ES:DI points at a file variable.
;			DX:SI points at a file name.
;	On Exit:
;			Carry is clear if no error.
;			AX contains (DOS) error code if carry is set.

		public	sl_fopen
sl_fopen     	proc	far
		push	ds
		push	dx
		push	ax

		mov	ds, dx
		mov	dx, si

		cmp	ax, 1
		ja	BadMode
		mov	es:[di].FileVar.fvMode, ax
		mov	es:[di].FileVar.fvIndex, 511	;Assume read mode
		mov	es:[di].FileVar.fvByteCount, 0
		test	ax, ax				;See if read mode
		jz	DoOpen
		mov	es:[di].FileVar.fvIndex, 0	;It's write mode.

DoOpen:		mov	ah, 3dh		;DOS Open call.
		int	21h
		jc	fopenError
		mov	es:[di].FileVar.fvHandle, ax

		pop	ax
		pop	dx
		pop	ds
		ret

BadMode:	mov	ax, 1		;Invalid function error code if
		stc			; bad r/w access specified.
fopenError:	pop	es		;Return error in AX!
		pop	dx
		pop	ds
		ret
sl_fopen	endp



; sl_fcreate- Creates a new file.
;	On entry:
;			ES:DI points at a file variable.
;			DX:SI points at a file name.
;	On Exit:
;			Carry is clear if no error.
;			AX contains (DOS) error code if carry is set.

		public	sl_fcreate
sl_fcreate     	proc	far
		push	ds
		push	es
		push	dx
		push	cx
		push	ax

		mov	ds, dx		;Point DS:DX at filename.
		mov	dx, si

		mov	es:[di].FileVar.fvMode, 1	;Mode is write.
		mov	es:[di].FileVar.fvIndex, 0	;It's write mode.

		xor	cx, cx		;Normal file.
		mov	ah, 3ch		;DOS Open call.
		int	21h
		jc	fcreateError
		mov	es:[di].FileVar.fvHandle, ax

		pop	ax
		pop	cx
		pop	dx
		pop	es
		pop	ds
		ret

fcreateError:	pop	cx		;Return error in AX!
		pop	cx
		pop	dx
		pop	es
		pop	ds
		ret
sl_fcreate	endp



; sl_fclose-	Closes a file.
;
;	On Entry:
;		ES:DI points at a file variable.
;
;	On Exit:
;		Carry flag denotes error (AX contains error code).

		public	sl_fclose
sl_fclose	proc	far
		push	ax
		push	bx

		cmp	es:[di].FileVar.fvMode, 1
		jb	NoFlush
		ja	BadClose			;Sanity check for 1.

		call	sl_fflush
		jc	CloseError

NoFlush:	mov	bx, es:[di].FileVar.fvHandle
		test	bx, bx				;Don't close STDIN.
		jz	CloseDone
		mov	ah, 3eh
		int	21h
		jc	CloseError
CloseDone:	pop	bx
		pop	ax
		clc
		ret

BadClose:	mov	ax, 6			;Invalid handle error.
CloseError:	pop	bx
		add	sp, 2			;Return error in AX.
		stc
		ret
sl_fclose	endp


; sl_fflush-	Flushes a file buffer to disk.
;
;	On Entry:
;		ES:DI points at a file variable
;
;	On Exit:
;		Carry flag denotes error status (AX contains error #).

		public	sl_fflush
sl_fflush	proc	far
		push	ds
		push	ax
		push	bx
		push	cx
		push	dx

		cmp	es:[di].FileVar.fvMode, 1
		jb	NoWrite
		ja	BadFlush			;Sanity check for 1.

		cmp	es:[di].FileVar.fvIndex, 0	;Any data in buffer?
		je	NoWrite

		lea	dx, [di].FileVar.fvBuffer
		push	es
		pop	ds
		mov	cx, es:[di].FileVar.fvIndex
		mov	bx, es:[di].FileVar.fvHandle
		mov	ah, 40h
		int	21h
		jc	FlushError
		mov	es:[di].FileVar.fvIndex, 0 ;Reset byte count to zero.
NoWrite:	pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		clc
		ret

BadFlush:       mov	ax, 6
FlushError:	pop	dx
		pop	cx
		pop	bx
		add	sp, 2		;Return error code in AX
		pop	ds
		stc
		ret
sl_fflush	endp




; sl_fgetc-	Reads a single byte from a file.
;
;	On Entry:
;		ES:DI-	Points at file variable.
;
;	On Exit:
;		AL contains byte read (if no error).
;		AX contains error code (if error, C=1).


		public	sl_fgetc
sl_fgetc	proc	far
		push	bx

		cmp     es:[di].FileVar.fvMode, 0	;Reading file?
		jne	BadGetc


		mov	bx, es:[di].FileVar.fvIndex
		inc	bx
		cmp	bx, 512
		jae	ReadNewBlock

		dec	es:[di].FileVar.fvByteCount
		js      EOFRB2

		mov	al, es:[bx+di].FileVar.fvBuffer
		mov	es:[di].FileVar.fvIndex, bx
		mov	ah, 1			;Read one char from file.
		pop	bx
		clc
		ret


; If bx gets bumped to 512, we need to read a new block of data from the
; file.

ReadNewBlock:	push	ds
		push	cx
		push	dx

		mov	ah, 3fh
		mov	bx, es:[di].FileVar.fvHandle
		mov	cx, 512
		lea	dx, [di].FileVar.fvBuffer
		push	es
		pop	ds
		int	21h
		jc	BadRB

		dec	ax
		mov	es:[di].FileVar.fvByteCount, ax
		js	EOFRB

		mov	es:[di].FileVar.fvIndex, 0
		mov	al, es:[di].FileVar.fvBuffer
		mov	ah, 1				;Read one char.
		pop	dx
		pop	cx
		pop	ds
		pop	bx
		clc
		ret

EOFRB:		mov	ax, 0		;EOF error.
BadRB:		pop	dx
		pop	cx
		pop	ds
		pop	bx
		stc
		ret

EOFRB2:		mov	ax, 0		;EOF error.
		pop	bx
		stc
		ret

BadGetc:	mov	ax, 5		;Access denied error code.
		pop	bx
		stc
		ret

sl_fgetc	endp



; sl_fread-	Reads a block of bytes from the file.
;	On Entry:
;		CX contains the number of bytes to read.
;		ES:DI points at the file variable.
;		DX:SI points at the destination block.
;
;	On Exit:
;		AX contains actual bytes read (0=EOF).
;		AX contains error code if error (C=1, AX=0 is EOF).

		public	sl_fread
sl_fread	proc	far
		push	ds
		push	bx
		push	cx
		push	dx
		push	si

		cmp	es:[di].FileVar.fvMode, 0	;Read Mode?
		jne	Badfread

		mov	ds, dx

; There are three cases we've got to deal with:
;	(1) there is no data in the file variable buffer and we need to
;	    read all data from the file.
;	(2) part of the data is in the file variable buffer area and part
;	    must be read from the file.
;	(3) all the data is in the file variable buffer area.

		mov	ax, es:[di].FileVar.fvByteCount
		test	ax, ax				;Bytecnt = 0?
		je	AllNewRead
		cmp	cx, ax
		jbe	AllFromBuffer

; At this point, part of the data is in the file buffer, part of it must be
; read from the file.  First, copy the data from the buffer to the destination
; then fall through to AllNewRead to read remaining bytes from the file.

		sub	cx, ax				;# bytes not in buf.
		push	cx
		mov	cx, ax
		mov	bx, es:[di].FileVar.fvIndex
CopyLoop1:	inc	bx
		mov	al, es:[bx+di].FileVar.fvBuffer
		mov	ds:[si], al
		inc	si
		loop	CopyLoop1
		pop	cx

; The following code reads CX bytes from the file and stores them into memory
; at location DS:SI.

AllNewRead:	mov	dx, si
		mov	bx, es:[di].FileVar.fvHandle
		mov	ah, 3fh
		int	21h
		jc	BadFRB

; Note: AX contains bytes read from file.

		mov	es:[di].FileVar.fvIndex, 511	;Mark buf as empty.
		mov	es:[di].FileVar.fvByteCount, 0

		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ds
		;clc
		ret

Badfread:	mov	ax, 5			;Access denied
BadFRB:		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ds
		stc
		ret


; If we come down here, we can read the entire line from the buffer:

AllFromBuffer:  mov	bx, es:[di].FileVar.fvIndex
AFBLoop:	inc	bx
		mov	al, es:[bx+di].FileVar.fvBuffer
		mov	ds:[si], al
		inc	si
		loop	AFBLoop
		mov	es:[di].FileVar.fvIndex, bx

		pop	si
		pop	dx
		pop	cx
		mov	ax, cx
		pop	bx
		pop	ds
		clc
		ret
sl_fread	endp





; sl_fputc-	Writes a single byte to a file.
;
;	On Entry:
;		ES:DI-	Points at file variable.
;		AL-	Contains the output character.
;
;	On Exit:
;		AX contains error code (if error, C=1).


		public	sl_fputc
sl_fputc	proc	far
		push	es
		push	bx

		cmp     es:[di].FileVar.fvMode, 1	;Writing file?
		jne	BadPutc

		mov	bx, es:[di].FileVar.fvIndex
		mov	es:[bx+di].FileVar.fvBuffer, al
		inc	bx
		cmp	bx, 512
		jae	WriteNewBlock
		mov	es:[di].FileVar.fvIndex, bx
		pop	bx
		pop	es
		clc
		ret


; If bx gets bumped to 512, we need to read a new block of data from the
; file.

WriteNewBlock:	push	ds
		push	cx
		push	dx
		push	ax

		mov	ah, 40h
		mov	bx, es:[di].FileVar.fvHandle
		mov	cx, 512
		lea	dx, [di].FileVar.fvBuffer
		push	es
		pop	ds
		int	21h
		jc	BadWB

		mov	es:[di].FileVar.fvIndex, 0

		pop	ax
		pop	dx
		pop	cx
		pop	ds
		pop	bx
		pop	es
		clc
		ret

BadPutc:	mov	ax, 5			;Access denied error code.
BadWB:		pop	dx			;Keep error code in AX
		pop	dx
		pop	cx
		pop	ds
		pop	bx
		pop	es
		stc
		ret
sl_fputc	endp



; sl_fwrite-	Write a block of bytes to the file.
;	On Entry:
;		CX contains the number of bytes to write.
;		ES:DI points at the file variable.
;		DX:SI points at the data buffer to write.
;
;	On Exit:
;		AX contains error code if C=1.


		public	sl_fwrite
sl_fwrite	proc	far
		push	ds
		push	bx
		push	cx
		push	dx
		push	ax

		cmp	es:[di].FileVar.fvMode, 1
		jne	Badfwrite

		call	sl_fflush
		jc      BadFWB

		mov	ds, dx
		mov	dx, si
		mov	ah, 40h
		mov	bx, es:[di].FileVar.fvHandle
		int	21h
		jc	BadFWB

		pop	ax
		pop	dx
		pop	cx
		pop	bx
		pop	ds
		;clc
		ret

Badfwrite:	mov	ax, 5			;Access denied
BadFWB:		pop	dx			;Keep error code in AX
		pop	dx
		pop	cx
		pop	bx
		pop	ds
		stc
		ret
sl_fwrite	endp





;----------------------------------------------------------------------------
		else			;We have TASM or MASM 5.1
;----------------------------------------------------------------------------





		public	sl_fopen
sl_fopen     	proc	far
		push	ds
		push	dx
		push	ax

		mov	ds, dx
		mov	dx, si

		cmp	ax, 1
		ja	BadMode
		mov	es:[di].fvMode, ax
		mov	es:[di].fvIndex, 511	;Assume read mode
		mov	es:[di].fvByteCount, 0
		test	ax, ax				;See if read mode
		jz	DoOpen
		mov	es:[di].fvIndex, 0	;It's write mode.

DoOpen:		mov	ah, 3dh		;DOS Open call.
		int	21h
		jc	fopenError
		mov	es:[di].fvHandle, ax

		pop	ax
		pop	dx
		pop	ds
		ret

BadMode:	mov	ax, 1		;Invalid function error code if
		stc			; bad r/w access specified.
fopenError:	pop	es		;Return error in AX!
		pop	dx
		pop	ds
		ret
sl_fopen	endp



; sl_fcreate- Creates a new file.
;	On entry:
;			ES:DI points at a file variable.
;			DX:SI points at a file name.
;	On Exit:
;			Carry is clear if no error.
;			AX contains (DOS) error code if carry is set.

		public	sl_fcreate
sl_fcreate     	proc	far
		push	ds
		push	es
		push	dx
		push	cx
		push	ax

		mov	ds, dx		;Point DS:DX at filename.
		mov	dx, si

		mov	es:[di].fvMode, 1	;Mode is write.
		mov	es:[di].fvIndex, 0	;It's write mode.

		xor	cx, cx		;Normal file.
		mov	ah, 3ch		;DOS Open call.
		int	21h
		jc	fcreateError
		mov	es:[di].fvHandle, ax

		pop	ax
		pop	cx
		pop	dx
		pop	es
		pop	ds
		ret

fcreateError:	pop	cx		;Return error in AX!
		pop	cx
		pop	dx
		pop	es
		pop	ds
		ret
sl_fcreate	endp



; sl_fclose-	Closes a file.
;
;	On Entry:
;		ES:DI points at a file variable.
;
;	On Exit:
;		Carry flag denotes error (AX contains error code).

		public	sl_fclose
sl_fclose	proc	far
		push	ax
		push	bx

		cmp	es:[di].fvMode, 1
		jb	NoFlush
		ja	BadClose			;Sanity check for 1.

		call	far ptr sl_fflush
		jc	CloseError

NoFlush:	mov	bx, es:[di].fvHandle
		test	bx, bx				;Don't close STDIN.
		jz	CloseDone
		mov	ah, 3eh
		int	21h
		jc	CloseError
CloseDone:	pop	bx
		pop	ax
		clc
		ret

BadClose:	mov	ax, 6			;Invalid handle error.
CloseError:	pop	bx
		add	sp, 2			;Return error in AX.
		stc
		ret
sl_fclose	endp


; sl_fflush-	Flushes a file buffer to disk.
;
;	On Entry:
;		ES:DI points at a file variable
;
;	On Exit:
;		Carry flag denotes error status (AX contains error #).

		public	sl_fflush
sl_fflush	proc	far
		push	ds
		push	ax
		push	bx
		push	cx
		push	dx

		cmp	es:[di].fvMode, 1
		jb	NoWrite
		ja	BadFlush			;Sanity check for 1.

		cmp	es:[di].fvIndex, 0	;Any data in buffer?
		je	NoWrite

		lea	dx, [di].fvBuffer
		push	es
		pop	ds
		mov	cx, es:[di].fvIndex
		mov	bx, es:[di].fvHandle
		mov	ah, 40h
		int	21h
		jc	FlushError
		mov	es:[di].fvIndex, 0 ;Reset byte count to zero.
NoWrite:	pop	dx
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		clc
		ret

BadFlush:       mov	ax, 6
FlushError:	pop	dx
		pop	cx
		pop	bx
		add	sp, 2		;Return error code in AX
		pop	ds
		stc
		ret
sl_fflush	endp




; sl_fgetc-	Reads a single byte from a file.
;
;	On Entry:
;		ES:DI-	Points at file variable.
;
;	On Exit:
;		AL contains byte read (if no error).
;		AX contains error code (if error, C=1).

		public	sl_fgetc
sl_fgetc	proc	far
		push	bx

		cmp     es:[di].fvMode, 0	;Reading file?
		jne	BadGetc


		mov	bx, es:[di].fvIndex
		inc	bx
		cmp	bx, 512
		jae	ReadNewBlock

		dec	es:[di].fvByteCount
		js      EOFRB2

		mov	al, es:[bx+di].fvBuffer
		mov	es:[di].fvIndex, bx
		mov	ah, 1
		pop	bx
		clc
		ret


; If bx gets bumped to 512, we need to read a new block of data from the
; file.

ReadNewBlock:	push	ds
		push	cx
		push	dx

		mov	ah, 3fh
		mov	bx, es:[di].fvHandle
		mov	cx, 512
		lea	dx, [di].fvBuffer
		push	es
		pop	ds
		int	21h
		jc	BadRB

		dec	ax
		mov	es:[di].fvByteCount, ax
		js	EOFRB

		mov	es:[di].fvIndex, 0
		mov	al, es:[di].fvBuffer
		mov	ah, 1
		pop	dx
		pop	cx
		pop	ds
		pop	bx
		clc
		ret

EOFRB:		mov	ax, 0		;EOF error.
BadRB:		pop	dx
		pop	cx
		pop	ds
		pop	bx
		stc
		ret

EOFRB2:		mov	ax, 0		;EOF error.
		pop	bx
		stc
		ret

BadGetc:	mov	ax, 5		;Access denied error code.
		pop	bx
		stc
		ret

sl_fgetc	endp



; sl_fread-	Reads a block of bytes from the file.
;	On Entry:
;		CX contains the number of bytes to read.
;		ES:DI points at the file variable.
;		DX:SI points at the desintation block.
;
;	On Exit:
;		AX contains actual bytes read (0=EOF).
;		AX contains error code if error (C=1, AX=0 is EOF).

		public	sl_fread
sl_fread	proc	far
		push	ds
		push	bx
		push	cx
		push	dx
		push	si

		cmp	es:[di].fvMode, 0	;Read Mode?
		jne	Badfread

		mov	ds, dx

; There are three cases we've got to deal with:
;	(1) there is no data in the file variable buffer and we need to
;	    read all data from the file.
;	(2) part of the data is in the file variable buffer area and part
;	    must be read from the file.
;	(3) all the data is in the file variable buffer area.

		mov	ax, es:[di].fvByteCount
		test	ax, ax
		je	AllNewRead
		cmp	cx, ax
		jbe	AllFromBuffer

; At this point, part of the data is in the file buffer, part of it must be
; read from the file.  First, copy the data from the buffer to the destination
; then fall through to AllNewRead to read remaining bytes from the file.

		sub	cx, ax				;# bytes not in buf.
		push	cx
		mov	cx, ax
		mov	bx, es:[di].fvIndex
CopyLoop1:	inc	bx
		mov	al, es:[bx+di].fvBuffer
		mov	ds:[si], al
		inc	si
		loop	CopyLoop1
		pop	cx

; The following code reads CX bytes from the file and stores them into memory
; at location DS:SI.

AllNewRead:	mov	dx, si
		mov	bx, es:[di].fvHandle
		mov	ah, 3fh
		int	21h
		jc	BadFRB

; Note: AX contains bytes read from file.

		mov	es:[di].fvIndex, 511	;Mark buf as empty.
		mov	es:[di].fvByteCount, 0

		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ds
		;clc
		ret

Badfread:	mov	ax, 5			;Access denied
BadFRB:		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ds
		stc
		ret


; If we come down here, we can read the entire line from the buffer:

AllFromBuffer:  mov	bx, es:[di].fvIndex
AFBLoop:	inc	bx
		mov	al, es:[bx+di].fvBuffer
		mov	ds:[si], al
		inc	si
		loop	AFBLoop
		mov	es:[di].fvIndex, bx

		pop	si
		pop	dx
		pop	cx
		mov	ax, cx
		pop	bx
		pop	ds
		clc
		ret
sl_fread	endp





; sl_fputc-	Writes a single byte to a file.
;
;	On Entry:
;		ES:DI-	Points at file variable.
;
;	On Exit:
;		AL contains byte read (if no error).
;		AX contains error code (if error, C=1).

		public	sl_fputc
sl_fputc	proc	far
		push	es
		push	bx

		cmp     es:[di].fvMode, 1	;Writing file?
		jne	BadPutc

		mov	bx, es:[di].fvIndex
		mov	es:[bx+di].fvBuffer, al
		inc	bx
		cmp	bx, 512
		jae	WriteNewBlock
		mov	es:[di].fvIndex, bx
		pop	bx
		pop	es
		clc
		ret


; If bx gets bumped to 512, we need to read a new block of data from the
; file.

WriteNewBlock:	push	ds
		push	cx
		push	dx
		push	ax

		mov	ah, 40h
		mov	bx, es:[di].fvHandle
		mov	cx, 512
		lea	dx, [di].fvBuffer
		push	es
		pop	ds
		int	21h
		jc	BadWB

		mov	es:[di].fvIndex, 0

		pop	ax
		pop	dx
		pop	cx
		pop	ds
		pop	bx
		pop	es
		clc
		ret

BadPutc:	mov	ax, 5			;Access denied error code.
BadWB:		pop	dx			;Keep error code in AX
		pop	dx
		pop	cx
		pop	ds
		pop	bx
		pop	es
		stc
		ret
sl_fputc	endp



; sl_fwrite-	Write a block of bytes to the file.
;	On Entry:
;		CX contains the number of bytes to write.
;		ES:DI points at the file variable.
;		DX:SI points at the data buffer to write.
;
;	On Exit:
;		AX contains error code if C=1.

		public	sl_fwrite
sl_fwrite	proc	far
		push	ds
		push	bx
		push	cx
		push	dx
		push	ax

		cmp	es:[di].fvMode, 1
		jne	Badfwrite

		call	sl_fflush
		jc      BadFWB

		mov	ds, dx
		mov	dx, si
		mov	ah, 40h
		mov	bx, es:[di].fvHandle
		int	21h
		jc	BadFWB

		pop	ax
		pop	dx
		pop	cx
		pop	bx
		pop	ds
		;clc
		ret

Badfwrite:	mov	ax, 5			;Access denied
BadFWB:		pop	dx			;Keep error code in AX
		pop	dx
		pop	cx
		pop	bx
		pop	ds
		stc
		ret
sl_fwrite	endp


		endif


stdlib		ends
		end
