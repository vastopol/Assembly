; REDIRECT.ASM -Demonstrates how to redirect I/O for a child process.
;               This particular program invokes COMMAND.COM to execute
;               a DIR command, when is sent to the specified output file.

		include	stdlib.a
		includelib	stdlib.lib

dseg		segment	para public 'data'

OrigOutHandle	word	?			;Holds copy of STDOUT handle.
FileHandle	word	?			;File I/O handle.
FileName	byte	"dirctry.txt",0		;Filename for output data.

; MS-DOS EXEC structure.

ExecStruct	word	0			;Use parent's Environment blk.
		dword	CmdLine			;For the cmd ln parms.
		dword	DfltFCB
		dword	DfltFCB

DfltFCB		byte	3,"           ",0,0,0,0,0
CmdLine		byte	7, " /c DIR", 0dh	;Do a directory command.
PgmName		dword	PgmNameStr		;Points at pgm name.
PgmNameStr	byte	"c:\command.com",0

dseg		ends


cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


Main		proc
		mov	ax, dseg		;Get ptr to vars segment
		mov	ds, ax
		MemInit				;Start the memory mgr.

; Free up some memory for COMMAND.COM:

		mov	ah, 62h			;Get our PSP value
		int	21h
		mov	es, bx
		mov	ax, zzzzzzseg		;Compute size of
		sub	ax, bx			; resident run code.
		mov	bx, ax
		mov	ah, 4ah			;Release unused memory.
		int	21h

; Save original output file handle.

		mov	bx, 1			;Std out is file handle 1.
		mov	ah, 45h			;Duplicate the file handle.
		int	21h
		mov     OrigOutHandle, ax	;Save duplicate handle.

; Open the output file:

		mov	ah, 3ch			;Create file.
		mov	cx, 0			;Normal attributes.
		lea	dx, FileName
		int	21h
		mov	FileHandle, ax		;Save opened file handle.

; Force the standard output to send its output to this file.
; Do this by forcing the file's handle onto file handle #1 (stdout).

		mov	ah, 46h			;Force dup file handle
		mov	cx, 1			;Existing handle to change.
		mov	bx, FileHandle		;New file handle to use.
		int	21h

; Print the first line to the file:

		print
		byte	"Redirected directory listing:",cr,lf,0

; Okay, execute the DOS DIR command (that is, execute COMMAND.COM with
; the command line parameter "/c DIR").

		mov	bx, seg ExecStruct
		mov	es, bx
		mov	bx, offset ExecStruct	;Ptr to program record.
		lds	dx, PgmName
		mov	ax, 4b00h		;Exec pgm
		int	21h

		mov	bx, sseg   		;Reset the stack on return.
		mov	ss, ax
		mov	sp, offset EndStk
		mov	bx, seg dseg
		mov	ds, bx

; Okay, close the output file and switch standard output back to the
; console.

		mov	ah, 3eh			;Close output file.
		mov	bx, FileHandle
		int	21h

		mov	ah, 46h			;Force duplicate handle
		mov	cx, 1			;StdOut
		mov	bx, OrigOutHandle	;Restore previous handle.
		int	21h

; Return control to MS-DOS

Quit:		ExitPgm
Main		endp
cseg		ends

sseg		segment	para stack 'stack'
		dw	128 dup (0)
endstk		dw	?
sseg		ends

; Set aside some room for the heap.

zzzzzzseg	segment	para public 'zzzzzzseg'
Heap		db	200h dup (?)
zzzzzzseg	ends
		end	Main
