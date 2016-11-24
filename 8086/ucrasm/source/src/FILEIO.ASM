;******************************************************************************
;
;                       New routines and functions
;                         for the Stdlib package
;
;               Featuring:
;                       - Opening and closing files
;                       - Creating new files
;                       - Blocked I/O:
;                               -Reading from files using getc
;                               -Writing to files using putc and puts
;				- File-Buffer Flushing
;			- File Seeking
;			- File Deleting
;			- File Renaming
;
;******************************************************************************
;
;               Written by:
;
;                       Mark Radleigh
;                           &
;                       Brian Harvey
;
;			(CS 13)
;
;******************************************************************************
;
;
;******************************************************************************
;		These externs are needed for this demonstration program.
;******************************************************************************
;
;
StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
;
; Some useful constants:
;
cr              equ    	13
lf              equ    	10
eos             equ    	0
EOF             equ     04h
;
true            equ     1
false           equ     0
NIL		equ	0
;
;******************************************************************************
;	The following is a Struct that contains all necessary information to
;	handle multiple files opened or closed.
;******************************************************************************
;
ftype		struc
fbuffptr	dd	?		;Buffer pointer that holds the Data
fhandle		dw	?		;DOS FileHandle
findex		dw	?		;Index into Buffer
fcounter	dw	?
fflush_flag	db	?		;Says if you can flush the buffer or not
ftype		ends
;
;******************************************************************************
;	The Folowing declares neccessary variables for the library.
;	FILES is the base struct for the alloted number of files opened.
;******************************************************************************
;
FILES		ftype	10 dup (<NIL,NIL,NIL,NIL,NIL>)
Old_out_addrss  dd      0               ;Keep the old address of output
Old_in_addrss   dd      0               ;Keep the old address of input
current_fwrite	dw	?		;Keep the current index of writing
current_fread	dw	?		;Keep the current index of reading
;
;******************************************************************************
;	The following are variables used by the demonstration program.
;******************************************************************************
;
fileptr		dw	?
fileptr2	dw	?
fileptr3	dw	?
;
StdData		ends
;
stdlib          segment para public 'slcode'
		assume  cs:StdGrp, ds:nothing
;
		extrn	sl_SetOutAdrs:far, sl_GetOutAdrs:far
		extrn	sl_SetInAdrs:far, sl_GetInAdrs:far
		extrn	sl_malloc:far, sl_free:far
;
;
;----------------------------------------------------------------------------
;  Fcreate -> A procedure that creates a file for writing (Deletes any previous
;	      file of the same name.)
;	INPUT-> ES:DI Contains the address of the filename for the new file.
;	OUTPUT-> CARRY Flag is set if error occurs.
;	OUTPUT-> AX contains the error code if carry flag is set, else AX
;		 contains the STDLIB FileHandle.
;
		public	sl_fcreate
sl_fcreate	proc	far
		push	ds
		push	dx
		push	cx
		push	si
;
fcreate_read:	xor 	si, si
fcreate_test:	cmp	word ptr StdGrp:FILES[si].fbuffptr + 2, NIL
		jne	fcreate_test2
		cmp	word ptr StdGrp:FILES[si].fbuffptr, NIL
		je	Fcreate_file
fcreate_test2: 	add	si, size ftype
		cmp	si, length FILES * size ftype
		jbe	fcreate_test
		stc
		mov	ax, 10		;No more file buffer ->error
		jmp	fcreate_done
Fcreate_file:
		mov	dx, es
		mov	ds, dx		;get the segment adrs ready
					;for DOS
		mov	dx, di		;get the offset adrs ready
					;for DOS
		mov	ah, 3ch		;command for CREATE
		mov	cx, 0		;Tells DOS file is ARCHIVED.
		int	21h
		jc	fcreate_done
		mov	StdGrp:FILES[si].fflush_flag, true 	;So we can flush
							;the buffer!
		mov	StdGrp:FILES[si].fhandle, ax
		mov	ax, si
		call	fmalloc_this		;Malloc space for the buffer
;
fcreate_done:	pop	si
		pop	cx
		pop	dx
		pop	ds
		ret
sl_fcreate	endp
;
;-----------------------------------------------------------------------------
;  Fopen -> A procedure that opens a file for reading/writing.
;	INPUT-> ES:DI Contains the address of the filename for the new file.
;	OUTPUT-> CARRY Flag is set if error occurs.
;	OUTPUT-> AX contains the error code if carry flag is set, else AX
;		 contains the STDLIB FileHandle.
;
;
		public	sl_fopen
sl_fopen	proc	far
		push	cx
		push	dx
		push	si
		push	di
		push 	ds
		push	es
		cmp	al, 1		;Want to open for writing?
		je	fopen_write
		cmp	al, 0		;Want to open for reading?
		je	fopen_read
		stc
		mov	ax, 5		;Incorrect sub function passed in al
		jmp	fopen_done
;
;--------------------------------------------------
;	Here we open the file for reading..
;	We first test to see if there is an open buffer, then we open the file,
;	and if everything is ok, we Malloc space for the buffer.
;
fopen_read:	xor 	si, si
fread_test:	cmp	word ptr StdGrp:FILES[si].fbuffptr + 2, NIL
		jne	fread_test2
		cmp	word ptr StdGrp:FILES[si].fbuffptr, NIL
		je	Open_file_r
fread_test2: 	add	si, size ftype
		cmp	si, length FILES * size ftype
		jbe	fread_test
		stc
		mov	ax, 10			;No more file buffers ->error
		jmp	fopen_done
;
Open_file_r:	mov	dx, es
		mov	ds, dx
		mov	dx, di
		mov	ah, 3dh			; Code for opening for reading
		int 	21h
		jc	fopen_done
		mov	StdGrp:FILES[si].fflush_flag, false	;so we don't flush the
							;buffer
		mov    	StdGrp:FILES[si].fhandle, ax
		mov	ax, si
		call	fmalloc_this		;Get some buffer space
		jmp	fopen_done
;
;--------------------------------------------------
;	Here we open the file for writing..
;	We first test to see if there is an open buffer, then we open the file,
;	and if everything is ok, we Malloc space for the buffer.
;
fopen_write: 	mov	si, 0
fwrite_test:	cmp	word ptr StdGrp:FILES[si].fbuffptr + 2, NIL
		jne	fwrite_test2
		cmp	word ptr StdGrp:FILES[si].fbuffptr, NIL
		je	Open_file_w
;
fwrite_test2: 	add	si, size ftype
		cmp	si, length FILES * size ftype
		jbe	fwrite_test
		stc
		mov	ax, 10
		jmp	fopen_done
;
Open_file_w:	mov	dx, es
		mov	ds, dx
		mov	dx, di
		mov	ah, 3dh 		;Code for open for writing
		int	21h
		jc	fopen_done
		mov	StdGrp:FILES[si].fflush_flag, true	;So we do flush
							;File buffer
		mov	StdGrp:FILES[si].fhandle, ax
		mov	ax, si
		call	fmalloc_this		;Get some buffer space!
;
fopen_done:
		pop	es
		pop	ds
		pop	di
		pop	si
		pop	dx
		pop 	cx
		ret
sl_fopen	endp
;
;*****************************************************************************
;	This small procedure Mallocs some space for our FILES buffer pointers,
;	so we can read in and write out blocks at a time.
;*****************************************************************************
;
fmalloc_this 	proc	near
		mov	cx, 256
		call	sl_malloc
		jnc	FMalloc_it
		mov	ax, 10
FMalloc_it:
		mov	bx, es
		mov	word ptr StdGrp:FILES[si].fbuffptr + 2, bx
		mov	word ptr StdGrp:FILES[si].fbuffptr, di
		mov	StdGrp:FILES[si].findex, 0
		ret
fmalloc_this	endp
;
;
;---------------------------------------------------------------------------
;	Readon -> A procedure that changes the stdlib fuctions of character
;		  and string input to a specified file.
;	       -INPUT  -> AX contains the FileHandle variable.
;
		public	sl_freadon
sl_freadon	proc	far
		push	es
		push	di
		push	bx
						;The following cmp instructions
						;See if we have already set
						;READON
		mov	bx, word ptr StdGrp:Old_in_addrss + 2
		cmp	bx, 0
		jne	freadon_done
		mov	di, word ptr StdGrp:Old_in_addrss
		cmp	di, 0
		jne	freadon_done
;
		mov	current_fread, ax
		call	sl_GetInAdrs		;Get the origonal input adrs
		mov	bx, es
		mov	word ptr StdGrp:Old_in_addrss + 2, bx
		mov	word ptr StdGrp:Old_in_addrss, di
		mov	bx, cs			;Now we load in our fgetc
		mov	es, bx
		lea	di, sl_fgetc
		call	sl_SetInAdrs		;Set to the new input adrs
freadon_done:
		pop	bx
		pop	di
		pop	es
		ret
sl_freadon	endp
;
;---------------------------------------------------------------------------
;	Readoff -> A procedure that resets the stdlib functions of character
;		  and string input.
;
		public	sl_freadoff
sl_freadoff	proc	far
		push	es
		push	di
		les	di, StdGrp:Old_In_Addrss
		call	sl_SetInAdrs
		mov	word ptr StdGrp:Old_In_Addrss + 2, 0
		mov	word ptr StdGrp:Old_In_Addrss, 0
		pop	di
		pop	es
		ret
sl_freadoff	endp
;
;----------------------------------------------------------------------------
;	Fgetc -> A procedure that is called whenever GETC is called and
;		 READON was called previously.
;	NOTE:  	 CARRY FLAG IS SET and AX contains 8 if it encounters EOF.
;
		public	sl_fgetc
sl_fgetc	proc	far
		push	si
		push	di
		push	ds
		push	dx
		push	cx
		push	bx
;
		mov	si, StdGrp:current_fread		;Get the current
							;Readfile index
							;-----------------
							;The following 4 instruc
							;see if we have an
							;available buffer...
		cmp	word ptr StdGrp:FILES[si].fbuffptr + 2, NIL
		jne	fgetc_getchar
		cmp	word ptr StdGrp:FILES[si].fbuffptr, NIL
		je	fgetc_nada
fgetc_getchar:
		cmp	StdGrp:FILES[si].fcounter, 0
		je	fget_new_block
		les	di, StdGrp:FILES[si].fbuffptr
		add	di, StdGrp:FILES[si].findex
		mov	al, es:[di]
		inc	StdGrp:FILES[si].findex
		dec	StdGrp:FILES[si].fcounter
		jmp	fgetc_done
fget_new_block:
		lds	dx, StdGrp:FILES[si].fbuffptr
		mov	bx, StdGrp:FILES[si].fhandle
		mov	cx, 256
		mov	ah, 3fh
		int	21h
		jc	fgetc_done
		cmp	ax, 0			;How many bytes did it read in?
		je	EOF_error
		mov	StdGrp:FILES[si].fcounter, ax
		mov	StdGrp:FILES[si].findex, 0
		jmp	fgetc_getchar
fgetc_nada:	stc
		mov	ax, 6			;Invalid FileHandle
						;(Just a safeguard)
EOF_error:	stc
		mov	ax, 8			;End of file...
;
fgetc_done:
		pop	bx
		pop	cx
		pop	dx
		pop	ds
		pop	di
		pop	si
		ret
sl_fgetc	endp
;
;
;
;------------------------------------------------------------------------------
;
;  Fclose - A procedure that closes an open file.
;         - INPUT -> AX contains the FileHandle variable of the file to close.
;         - OUTPUT -> Carry flag is set if error occurs.
;         - OUTPUT -> Ax contains 6 which is invalid file handle error (if
;                     carry flag is set) or AX contains 7 if trouble with FREE.
;
		public  sl_fclose
sl_fclose       proc    far
		push    bx
		push	si
		mov	si, ax
		mov     bx, StdGrp:FILES[si].fhandle   ;Move file handle into bx
		cmp    	StdGrp:FILES[si].fflush_flag, true
		jne	fclose_it
		call    far ptr sl_fflush        ;Make sure the buffer is empty
fclose_it:
		mov     ah, 3eh
		int     21h
		les	di, StdGrp:FILES[si].fbuffptr
		call	sl_free			;Conserve space!!!!!
		jnc	fclose_cont
		mov	ax, 7			;Trouble with FREE
fclose_cont:
		mov	word ptr StdGrp:FILES[si].fbuffptr + 2, 0
		mov	word ptr StdGrp:FILES[si].fbuffptr, 0
		mov	StdGrp:FILES[si].findex, 0
		mov	StdGrp:FILES[si].fcounter, 0

		pop	si
		pop     bx
		ret
sl_fclose       endp
;
;
;------------------------------------------------------------------------------
;	Fflush -> A procedure that flushes the write buffer into the file.
;		  Usefull if user didn't read in 256 blocks
;	INPUT ->  AX contains the STDLIB FileHandle
;
		public  sl_fflush
sl_fflush       proc    far
		push	di
		push    si
		push    ds
		push    dx
		push    cx
		push    bx
		mov	di, ax
		mov     si, StdGrp:FILES[di].findex
		cmp     si, 0			;Is the buffer empty?
		je     fwbuffempty
		mov     cx, si			;The number of bytes to write
		lds     dx, StdGrp:FILES[di].fbuffptr
		mov     ah, 40h
		int     21h
fwbuffempty:
		pop     bx
		pop     cx
		pop     dx
		pop     ds
		pop     si
		pop	di
		ret
sl_fflush       endp

;------------------------------------------------------------------------------
;
;  Writeon - A procedure that changes stdlib functions of character and string
;            output to a specified file instead.
;          -INPUT -> AX contains the FileHandle variable.
;
		public  sl_fwriteon
sl_fwriteon     proc    far
		push    es
		push    di
		push    bx
						;The following cmp instructions
						;See if we have already set
						;WRITEON
;
		mov     bx, word ptr StdGrp:Old_out_addrss + 2
		cmp	bx, 0
		jne	fwriteon_done
		mov     di, word ptr StdGrp:Old_out_addrss
		cmp	di, 0
		jne	fwriteon_done
;
		mov	StdGrp:current_fwrite, ax
		call    sl_GetOutAdrs   	;Get the original ouput address
		mov     bx, es
		mov     word ptr StdGrp:Old_out_addrss + 2, bx
		mov     word ptr StdGrp:Old_out_addrss, di
		mov     bx, cs			;Load in our fputc
		mov     es, bx
		lea     di, StdGrp:sl_fputc
		call    sl_SetOutAdrs   	;sets the ouput address to file
fwriteon_done:
		pop     bx
		pop     di
		pop     es
		ret
sl_fwriteon     endp
;
;
;------------------------------------------------------------------------------
;	Fputc -> A procedure that is called whenever PUTC is called and
;		 WRITEON was called previously.
;
		public	sl_fputc
sl_fputc	proc	far
		push	si
		push	di
		push	ds
		push	dx
		push	cx
		push	bx
;
		mov	si, StdGrp:current_fwrite	;gets the current index of FILES
						;The following comparisons see
						;If we have a valid buffer..
		cmp	word ptr StdGrp:FILES[si].fbuffptr + 2, NIL
		jne	fputc_do_this
		cmp	word ptr StdGrp:FILES[si].fbuffptr, NIL
		je	no_such_thing
fputc_do_this:
		les	di, StdGrp:FILES[si].fbuffptr
		add	di, StdGrp:FILES[si].findex
		mov	es:[di], al		;Stick that char in the buffer
		inc	byte ptr StdGrp:FILES[si].findex
		jne	fwrite_done		;If we hit 0, write the buffer!
		lds	dx, StdGrp:FILES[si].fbuffptr
		mov	bx, StdGrp:FILES[si].fhandle
		mov	cx, 256
		mov	ah, 40h
		int 	21h
;
fwrite_done:
		pop	bx
		pop	cx
		pop	dx
		pop	ds
		pop	di
		pop	si
		ret
no_such_thing:	stc
		mov	ax, 6		;invalid filehandle
					;(Safe guard - shouldn't happen)
		jmp	fwrite_done
sl_fputc	endp

;
;
;---------------------------------------------------------------------------
;	Writeoff -> A procedure that resets the stdlib functions of character
;		  and string output.
;
		public  sl_fwriteOff
sl_fwriteOff    proc    far
		push    es
		push    di
		mov     es, word ptr StdGrp:Old_out_addrss + 2
		mov     di, word ptr StdGrp:Old_out_addrss
		call    sl_SetOutAdrs
		mov	word ptr StdGrp:Old_out_addrss + 2, 0
		mov	word ptr StdGrp:Old_out_addrss, 0
		pop     di
		pop     es
		ret
sl_fwriteOff    endp
;
;
;
;
;------------------------------------------------------------------------
;  Fseek -> Moves the File Pointer a specified # of Bytes..
;       INPUT-> AL contains the offset from where to start the file seeking.
;               AL=0;  Seek from the begining of the file.
;               AL=1;  Seek from the current pointer possition.
;               AL=2;  Seek backwards from the end of the file.
;       INPUT-> SI contains the Unique FileHandle given by these procedures.
;       INPUT-> CX:DX contains the number of bytes to seek (Unsigned number).
;       OUTPUT -> Carry flag is set if error..
;       OUTPUT -> AX contains the error code.
;       OUTPUT -> DX:AX contains the new file positoin if no error.
;
		public  sl_fseek
sl_fseek        proc    far
		push    bx
		mov     ah, 42h
		mov     bx, StdGrp:FILES[si].fhandle   ;Get the FileHandle
		int     21h
		pop     bx
sl_fseek        endp
;
;-----------------------------------------------------------------------
;  DOSHandle -> A procedure that returns the DOS given FileHandle.
;       INPUT-> AX contains the stdlib given FileHandle.
;       OUTPUT->Carry is set if error.
;       OUTPUT->AX contains error code.
;               AX=1; Invalid user input FileIndex.
;       OUTPUT->AX contains the DOS FileHandle.
;
		public  sl_DOSHandle
sl_DOSHandle    proc    far
		push    si
		mov     si, ax
		cmp     si, length FILES * size ftype
		ja      Handle_error
		cmp     si, 0
		jb      Handle_error
		clc
		mov     ax, StdGrp:FILES[si].fhandle
		jmp     DOS_Done
Handle_error:   stc
		mov     ax, 1
DOS_Done:
		pop     si
		ret
sl_DOSHandle    endp
;
;--------------------------------------------------------------------------
;  Fdel -> A procedure that deletes a file.
;	INPUT->ES:DI contains the address of zero terminated pathname of file.
;	OUTPUT -> CARRY Flag is set if error and
;		  AX=2 File not found
;		  AX=5 Access denied
;
		public	sl_fdel
sl_fdel		proc	far
		push	ds
		push	dx
		mov	dx, es
		mov	ds, dx
		mov	dx, di
		mov	ah, 41h
		int 	21h
		pop	dx
		pop	ds
		ret
sl_fdel		endp
;
;--------------------------------------------------------------------------
;  Frename -> A procedure that renames one file to another.
;	INPUT -> DX:SI contains the origonal pathname of the file.
;	INPUT -> ES:DI contains the new pathname of the file.
;	OUTPUT -> CARRY Flag is set if error and:
;		  AX=2  File not found
;		  AX=5  Access denied
;		  AX=17 Not the Same device
;
		public	sl_frename
sl_frename	proc	far
		push	ds
		mov	ds, dx
		mov	dx, si
		mov	ah, 56h
		int 	21h
		pop	ds
		ret
sl_frename	endp
;
;
stdlib          ends
;
;
		end

