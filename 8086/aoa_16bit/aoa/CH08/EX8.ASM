; Sample program for Chapter Eight
; Demonstrates the use of many MASM features discussed in Chapter Six
; including label types, constants, segment ordering, procedures, equates,
; address expressions, coercion and type operators, segment prefixes,
; the assume directive, conditional assembly, macros, listing directives,
; separate assembly, and using the UCR Standard Library.
;
; Include the header files for the UCR Standard Library.  Note that the
; "stdlib.a" file defines two segments; MASM will load these segments into
; memory before "dseg" in this program.
;
; The ".nolist" directive tells MASM not to list out all the macros for
; the standard library when producing an assembly listing.  Doing so would
; increase the size of the listing by many tens of pages and would tend to
; obscure the real code in this program.
;
; The ".list" directive turns the listing back on after MASM gets past the
; standard library files.  Note that these two directives (".nolist" and
; ".list") are only active if you produce an assembly listing using MASM's
; "/Fl" command line parameter.


		.nolist
		include 	stdlib.a
		includelib	stdlib.lib
		.list



; The following statement includes the special header file for this
; particular program.  The header file contains external definitions
; and various data type definitions.

		include		matrix.a


; The following two statements allow us to use 80386 instructions
; in the program.  The ".386" directive turns on the 80386 instruction
; set, the "option" directive tells MASM to use 16-bit segments by
; default (when using 80386 instructions, 32-bit segments are the default).
; DOS real mode programs must be written using 16-bit segments.

		.386
		option	segment:use16



dseg		segment	para public 'data'

Rows		integer	?		;Number of rows in matrices
Columns		integer	?		;Number of columns in matrices


; Input line is an input buffer this code uses to read a string of text
; from the user.  In particular, the GetWholeNumber procedure passes the
; address of InputLine to the GETS routine that reads a line of text
; from the user and places each character into this array.  GETS reads
; a maximum of 127 characters plus the enter key from the user.  It zero
; terminates that string (replacing the ASCII code for the ENTER key with
; a zero).  Therefore, this array needs to be at least 128 bytes long to
; prevent the possibility of buffer overflow.
;
; Note that the GetArray module also uses this array.

InputLine	char	128 dup (0)


; The following two pointers point at arrays of integers.
; This program dynamically allocates storage for the actual array data
; once the user tells the program how big the arrays should be.  The
; Rows and Columns variables above determine the respective sizes of
; these arrays.  After allocating the storage with a call to MALLOC,
; this program stores the pointers to these arrays into the following
; two pointer variables.

RowArray	dword	?		;Pointer to Row values
ColArray	dword	?		;Pointer to column values.



; ResultArrays is an array of dope vectors(*) to hold the results
; from the matrix operations:
;
; [0]- addition table
; [1]- subtraction table
; [2]- multiplication table
; [3]- division table
;
; [4]- modulo (remainder) table -- if the symbol "DoMOD" is defined.
;
; The equate that follows the ResultArrays declaration computes the number
; of elements in the array.  "$" is the offset into dseg immediately after
; the last byte of ResultArrays.  Subtracting this value from ResultArrays
; computes the number of bytes in ResultArrays.  Dividing this by the size
; of a single dope vector produces the number of elements in the array.
; This is an excellent example of how you can use address expressions in
; an assembly language program.
;
; The IFDEF DoMOD code demonstrates how easy it is to extend this matrix.
; Defining the symbol "DoMOD" adds another entry to this array.  The
; rest of the program adjusts for this new entry automatically.
;
; You can easily add new items to this array of dope vectors.  You will
; need to supply a title and a function to compute the matrice's entries.
; Other than that, however, this program automatically adjusts to any new
; entries you add to the dope vector array.
;
; (*) A "Dope Vector" is a data structure that describes a dynamically
; allocated array.  A typical dope vector contains the maximum value for
; each dimension, a pointer to the array data in memory, and some other
; possible information.  This program also stores a pointer to an array
; title and a pointer to an arithmetic function in the dope vector.


ResultArrays	DopeVec	{AddTbl,Addition}, {SubTbl,Subtraction}
		DopeVec	{MulTbl,Multiplication}, {DivTbl,Division}

		ifdef	DoMOD
		DopeVec	{ModTbl,Modulo}
		endif

; Add any new functions of your own at this point, before the following equate:


RASize		=	($-ResultArrays) / (sizeof DopeVec)


; Titles for each of the four (five) matrices.

AddTbl		char	"Addition Table",0
SubTbl  	char	"Subtraction Table",0
MulTbl		char	"Multiplication Table",0
DivTbl		char	"Division Table",0

		ifdef	DoMOD
ModTbl		char	"Modulo (Remainder) Table",0
		endif

; This would be a good place to put a title for any new array you create.

dseg		ends




; Putting PrintMat inside its own segment demonstrates that you can have
; multiple code segments within a program.  There is no reason we couldn't
; have put "PrintMat" in CSEG other than to demonstrate a far call to a
; different segment.

PrintSeg	segment	para public 'PrintSeg'

; PrintMat-	Prints a matrix for the cross product operation.
;
;		On Entry:
;
;			DS must point at DSEG.
;			DS:SI points at the entry in ResultArrays for the
;			array to print.
;
; The output takes the following form:
;
;	Matrix Title
;
;	       <- column matrix values ->
;
;	^      *------------------------*
;	|      |                        |
;	R      |                        |
;	o      | Cross Product Matrix   |
;       w      |       Values           |
;	       |                        |
;       V      |                        |
;	a      |                        |
;	l      |                        |
;	u      |                        |
;	e      |                        |
;	s      |                        |
;	|      |                        |
;	v      *------------------------*


PrintMat	proc	far
		assume	ds:dseg


; Note the use of conditional assembly to insert extra debugging statements
; if a special symbol "debug" is defined during assembly.  If such a symbol
; is not defined during assembly, the assembler ignores the following
; statements:

		ifdef	debug
		print
		char	"In PrintMat",cr,lf,0
		endif


; First, print the title of this table.  The TTL field in the dope vector
; contains a pointer to a zero terminated title string.  Load this pointer
; into es:di and call PUTS to print that string.

		putcr
		les	di, [si].DopeVec.TTL
		puts

; Now print the column values.  Note the use of PUTISIZE so that each
; value takes exactly six print positions. The following loop repeats
; once for each element in the Column array (the number of elements in
; the column array is given by the Dim2 field in the dope vector).

		print				;Skip spaces to move past the
		char	cr,lf,lf,"       ",0	; row values.

		mov	dx, [si].DopeVec.Dim2	;# of times to repeat the loop.
		les	di, ColArray		;Base address of array.
ColValLp:	mov	ax, es:[di]		;Fetch current array element.
		mov	cx, 6			;Print the value using a
		putisize			; minimum of six positions.
		add	di, 2			;Move on to next array element.
		dec	dx			;Repeat this loop DIM2 times.
		jne	ColValLp
		putcr				;End of column array output
		putcr				;Insert a blank line.

; Now output each row of the matrix.  Note that we need to output the
; RowArray value before each row of the matrix.
;
; RowLp is the outer loop that repeats for each row.

		mov	Rows, 0			;Repeat for 0..Dim1-1 rows.
RowLp:		les	di, RowArray		;Output the current RowArray
		mov	bx, Rows		; value on the left hand side
		add	bx, bx			; of the matrix.
		mov	ax, es:[di][bx]		;ES:DI is base, BX is index.
		mov	cx, 5			;Output using five positions.
		putisize
		print
		char	": ",0

; ColLp is the inner loop that repeats for each item on each row.

		mov	Columns, 0		;Repeat for 0..Dim2-1 columns.
ColLp:		mov	bx, Rows		;Compute index into the array
		imul	bx, [si].DopeVec.Dim2	; index := (Rows*Dim2 +
		add	bx, Columns		;		columns) * 2
		add	bx, bx

; Note that we only have a pointer to the base address of the array, so we
; have to fetch that pointer and index off it to access the desired array
; element.  This code loads the pointer to the base address of the array into
; the es:di register pair.

		les	di, [si].DopeVec.Data	;Base address of array.
		mov	ax, es:[di][bx]		;Get array element

; The functions that compute the values for the array store an 8000h into
; the array element if some sort of error occurs.  Of course, it is possible
; to produce 8000h as an actual result, but giving up a single value to
; trap errors is worthwhile.  The following code checks to see if an error
; occurred during the cross product.  If so, this code prints "  ****",
; otherwise, it prints the actual value.

		cmp	ax, 8000h		;Check for error value
		jne	GoodOutput
		print
		char	"  ****",0		;Print this for errors.
		jmp	DoNext

GoodOutput:	mov	cx, 6			;Use six print positions.
		putisize			;Print a good value.

DoNext:		mov	ax, Columns		;Move on to next array
		inc	ax			; element.
		mov	Columns, ax
		cmp	ax, [si].DopeVec.Dim2	;See if we're done with
		jb	ColLp			; this column.

		putcr				;End each column with CR/LF

		mov	ax, Rows		;Move on to the next row.
		inc	ax
		mov	Rows, ax
		cmp	ax, [si].DopeVec.Dim1	;Have we finished all the
		jb	RowLp			; rows?  Repeat if not done.
		ret
PrintMat	endp
PrintSeg	ends





cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


;GetWholeNum-	This routine reads a whole number (an integer greater than
;		zero) from the user.  If the user enters an illegal whole
;		number, this procedure makes the user re-enter the data.

GetWholeNum	proc	near
		lesi	InputLine	;Point es:di at InputLine array.
		gets

		call	Geti		;Get an integer from the line.
		jc	BadInt		;Carry set if error reading integer.
		cmp	ax, 0		;Must have at least one row or column!
		jle	BadInt
		ret

BadInt:		print
		char	Bell
		char	"Illegal integer value, please re-enter",cr,lf,0
		jmp	GetWholeNum
GetWholeNum	endp




; Various routines to call for the cross products we compute.
; On entry, AX contains the first operand, dx contains the second.
; These routines return their result in AX.
; They return AX=8000h if an error occurs.
;
; Note that the CrossProduct function calls these routines indirectly.

addition	proc	far
		add	ax, dx
		jno	AddDone		;Check for signed arithmetic overflow.
		mov	ax, 8000h	;Return 8000h if overflow occurs.
AddDone:	ret
addition	endp


subtraction	proc	far
		sub	ax, dx
		jno	SubDone
		mov	ax, 8000h	;Return 8000h if overflow occurs.
SubDone:	ret
subtraction	endp

multiplication	proc	far
		imul	ax, dx
		jno	MulDone
		mov	ax, 8000h	;Error if overflow occurs.
MulDone:	ret
multiplication	endp

division	proc	far
		push	cx		;Preserve registers we destory.

		mov	cx, dx
		cwd
		test	cx, cx		;See if attempting division by zero.
		je	BadDivide
		idiv	cx

		mov	dx, cx		;Restore the munged register.
		pop	cx
		ret

BadDivide:	mov	ax, 8000h
		mov	dx, cx
		pop	cx
		ret
division	endp


; The following function computes the remainder if the symbol "DoMOD"
; is defined somewhere prior to this point.

		ifdef	DoMOD
modulo		proc	far
		push	cx

		mov	cx, dx
		cwd
		test	cx, cx		;See if attempting division by zero.
		je	BadDivide
		idiv	cx
		mov	ax, dx		;Need to put remainder in AX.
		mov	dx, cx		;Restore the munged registers.
		pop	cx
		ret

BadMod:		mov	ax, 8000h
		mov	dx, cx
		pop	cx
		ret
modulo		endp
		endif



; If you decide to extend the ResultArrays dope vector array, this is a good
; place to define the function for those new arrays.





; The main program that reads the data from the user, calls the appropriate
; routines, and then prints the results.

Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


; Prompt the user to enter the number of rows and columns:

GetRows:	print
		byte	"Enter the number of rows for the matrix:",0

		call	GetWholeNum
		mov	Rows, ax

; Okay, read each of the row values from the user:

		print
		char	"Enter values for the row (vertical) array",cr,lf,0

; Malloc allocates the number of bytes specified in the CX register.
; AX contains the number of array elements we want;  multiply this value
; by two since we want an array of words.  On return from malloc, es:di
; points at the array allocated on the "heap".  Save away this pointer in
; the "RowArray" variable.
;
; Note the use of the "wp" symbol. This is an equate to "word ptr" appearing
; in the "matrix.a" include file.  Also note the use of the address expression
; "RowArray+2" to access the segment portion of the double word pointer.

		mov	cx, ax
		shl	cx, 1
		malloc
		mov	wp RowArray, di
		mov	wp RowArray+2, es

; Okay, call "GetArray" to read "ax" input values from the user.
; GetArray expects the number of values to read in AX and a pointer
; to the base address of the array in es:di.

		print
		char	"Enter row data:",0

		mov	ax, Rows	;# of values to read.
		call	GetArray	;ES:DI still points at array.



; Okay, time to repeat this for the column (horizontal) array.

GetCols:	print
		byte	"Enter the number of columns for the matrix:",0

		call	GetWholeNum	;Get # of columns from the user.
		mov	Columns, ax	;Save away number of columns.


; Okay, read each of the column values from the user:

		print
		char	"Enter values for the column (horz.) array",cr,lf,0

; Malloc allocates the number of bytes specified in the CX register.
; AX contains the number of array elements we want;  multiply this value
; by two since we want an array of words.  On return from malloc, es:di
; points at the array allocated on the "heap".  Save away this pointer in
; the "RowArray" variable.

		mov	cx, ax			;Convert # Columns to # bytes
		shl	cx, 1			; by multiply by two.
		malloc				;Get the memory.
		mov	wp ColArray, di		;Save pointer to the
		mov	wp ColArray+2, es	; columns vector (array).

; Okay, call "GetArray" to read "ax" input values from the user.
; GetArray expects the number of values to read in AX and a pointer
; to the base address of the array in es:di.

		print
		char	"Enter Column data:",0

		mov	ax, Columns		;# of values to read.
		call	GetArray		;ES:DI points at column array.


; Okay, initialize the matrices that will hold the cross products.
; Generate RASize copies of the following code.
; The "repeat" macro repeats the statements between the "repeat" and the "endm"
; directives RASize times.  Note the use of the Item symbol to automatically
; generate different indexes for each repetition of the following code.
; The "Item = Item+1" statement ensures that Item will take on the values
; 0, 1, 2, ..., RASize on each repetition of this loop.
;
; Remember, the "repeat..endm" macro copies the statements multiple times
; within the source file, it does not execute a "repeat..until" loop at
; run time.  That is, the following macro is equivalent to making "RASize"
; copies of the code, substituting different values for Item for each
; copy.
;
; The nice thing about this code is that it automatically generates the
; proper amount of initialization code, regardless of the number of items
; placed in the ResultArrays array.


Item		=	0

		repeat	RASize

		mov	cx, Columns		;Compute the size, in bytes,
		imul	cx, Rows		; of the matrix and allocate
		add	cx, cx			; sufficient storage for the
		malloc				; array.

		mov	wp ResultArrays[Item * (sizeof DopeVec)].Data, di
		mov	wp ResultArrays[Item * (sizeof DopeVec)].Data+2, es

		mov	ax, Rows
		mov	ResultArrays[Item * (sizeof DopeVec)].Dim1, ax

		mov	ax, Columns
		mov	ResultArrays[Item * (sizeof DopeVec)].Dim2, ax

		mov	ResultArrays[Item * (sizeof DopeVec)].ESize, 2

Item		=	Item+1
		endm



; Okay, we've got the input values from the user,
; now let's compute the addition, subtraction, multiplication,
; and division tables.  Once again, a macro reduces the amount of
; typing we need to do at this point as well as automatically handling
; however many items are present in the ResultArrays array.

element		=	0

		repeat	RASize
		lfs	bp, RowArray		;Pointer to row data.
		lgs	bx, ColArray		;Pointer to column data.

		lea	cx, ResultArrays[element * (sizeof DopeVec)]
		call	CrossProduct

element		=	element+1
		endm


; Okay, print the arrays down here.  Once again, note the use of the
; repeat..endm macro to save typing and automatically handle additions
; to the ResultArrays array.


Item		=	0

		repeat	RASize
		mov	si, offset ResultArrays[item * (sizeof DopeVec)]
		call	PrintMat
Item		=	Item+1
		endm


; Technically, we don't have to free up the storage malloc'd for each
; of the arrays since the program is about to quit.  However, it's a
; good idea to get used to freeing up all your storage when you're done
; with it.  For example, were you to add code later at the end of this
; program, you would have that extra memory available to that new code.

		les	di, ColArray
		free
		les	di, RowArray
		free

Item		=	0
		repeat	RASize
		les	di, ResultArrays[Item * (sizeof DopeVec)].Data
		free
Item		=	Item+1
		endm


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
