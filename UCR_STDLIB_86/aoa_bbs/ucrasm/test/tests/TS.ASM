;****************************************************************************
;
; TS: 	A "Text Statistics" package which demonstrates the use of the UCR
;	Standard Library Package.
;
; Note:	The purpose of this program is not to demonstrate blazing fast
;	assembly code (it's not particularly fast) but rather to demonstrate
;	how easy it is to write assembly code using the standard library
;	and MASM 6.0.
;
; Randall Hyde
; 10/2/91
;
;***************************************************************************
;
;  The following include must be outside any segment and before the
;  ZZZZZZSEG segment.  It includes all the macro definitions for the
;  UCR Standard Library.
;
		include 	stdlib.a	;Links into the UCR Standard
		includelib	stdlib.lib	; Library package.
;
;
dseg		segment	para public 'data'
;
WordCount	dw	0		;Holds file word count value
LineCnt		dw	0		;Holds # of lines in file
ControlCnt	dw	0		;Counts # of control characters
Punct		dw      0		;Counts # of punctuation characters
AlphaCnt	dw	0		;Counts # of alphabetic characters
NumericCnt	dw	0		;Counts numeric digits in file
Other		dw	0		;Counts other chars in file
MemorySize	dw	0		;# of paragraphs of free memory
Chars		dw	0		;Total number of chars in file
TotalChars	dq	0.0		;FP version of the above
FileHandle	dw	0		;STDLIB file handle
Const100	dd	100.0
;
;
; Create some sets to use in this program:
;
		set	CharSet,Alphabetic,Punctuation,Control
;
;
; Character Counter array.  CharCnt [ch] contains the number of "ch"
; characters appearing in the file.
;
CharCnt		dw	256 dup (0)
;
; Boolean flag to denote in/not in a word:
;
InWord		db	0
;
dseg		ends
;
;
cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg
;
;
; LESI is a macro which loads a 32-bit immediate value into ES:DI.
;
lesi		macro	adrs
		mov     di, seg adrs
		mov	es, di
		lea	di, adrs
		endm
;
; ldxi loads a 32-bit immediate value into dx:si:
;
ldxi		macro	adrs
		mov     dx, seg adrs
		lea	si, adrs
		endm
;
;
;
;
; Some useful constants-
;
cr		equ	13
lf		equ	10
EOFError	equ	8
;
;
		public	PSP		;DOS Program Segment Prefix
PSP		dw	?		;Needed by StdLib MemInit routine
;
;
; Okay, here's the main program which does the job:
;
TS		proc
		mov	cs:PSP, es		;Save pgm seg prefix
		mov	ax, seg dseg		;Set up the segment registers
		mov	ds, ax
		mov	es, ax
;
; Initialize the memory manager, giving all free memory to the heap.
;
		mov	dx, 0
		meminit
		mov	MemorySize, cx		;Save # of available paragraphs.
;
; Set up the character sets:
;
;  First, build the Alphabetic set:
;
		mov	al, "A"
		mov	ah, "Z"
		lesi	Alphabetic
		RangeSet
		AddStrL
		db	"abcdefghijklmnopqrstuvwxyz",0
;
; Create the set with the punctuation characters:
;
		lesi	Punctuation
		AddStrL
		db	"!@#$%^&*()_-+={[}]|\':;<,>.?/~`", '"', 0
;
; Create the control character set:
;
		lesi	Control
		mov	al,0
		mov	ah, 1fh
		RangeSet
		mov	al, 7fh
		AddChar
;
;
; Print the amount of available memory.
;
		printf
		db	"Text Statistics Program",cr,lf
		db	"There are %d paragraphs of memory available",cr,lf,0
		dd	MemorySize
;
; Get the filename off the command line:
;
		argc
		cmp	cx, 1
		je	GoodCmdLine
		print
		db	cr,lf
		db	"Missing file name!",cr,lf
		db	"Usage: TS <filename>",cr,lf,0
		jmp	Return2DOS
;
GoodCmdLine:	mov	ax, 1
		argv				;Get the filename.
;
; Open the file.
;
		mov	al, 0			;Open for reading.
		fopen				;Open the file.
		jnc	GoodOpen
;
; If the carry flag comes back set, we've got an error, print an appropriate
; message and quit:
;
		print
		db	"DOS error #",0
		puti				;Error code is in AX.
		putcr
		jmp	Return2DOS
;
; If the carry flag comes back clear, we've successfully opened the file.
; AX contains the STDLIB filehandle, ES:DI still points at the filename
; allocated on the heap:
;
GoodOpen:	mov	FileHandle, AX		;Save STDLIB file handle.
		print
		db	"Computing text statistics for ",0
		puts				;Print filename
		free				;Dispose of space on heap
		putcr
		putcr
;
; The following loops check for transitions between words and delimiters.
; Each time we go from "not a word" -> "word" this code bumps up the word
; count by one.
;
		mov	ax, FileHandle
		fReadOn
;
TSLoop:		getc
		jnc	NoError
		jmp	ReadError
;
; See if the character is alphabetic
;
NoError:	lesi	Alphabetic 		;Set contains A-Z, a-z
		Member
		jz	NotAlphabetic
		inc	AlphaCnt
		jmp	StatDone
;
; See if the character is a digit:
;
NotAlphabetic:	cmp	al, "0"
		jb	NotNumeric
		cmp	al, "9"
		ja	NotNumeric
		inc	NumericCnt
		jmp	StatDone
;
; See if the character is a punctuation character
;
NotNumeric:	lesi	Punctuation
		Member
		jz	NotPunctuation
		inc	Punct
		jmp	StatDone
;
; See if this is a control character:
;
NotPunctuation:	lesi	Control
		Member
		jz	NotControl
		inc	ControlCnt
		jmp	StatDone
;
NotControl:	inc	Other
StatDone:       mov	bl, al		;Use char as index into CharCnt
		mov	bh, 0
		shl	bx, 1		;Convert word index to byte index
		inc	CharCnt [bx]
;
; Count lines and characters here:
;
		cmp	al, lf
		jne	NotNewLine
		inc	LineCnt
;
NotNewLine:     inc	Chars
;
; Count words down here
;
		cmp	InWord, 0		;See if we're in a word.
		je	NotInAWord
		cmp	al, " "
		ja	WCDone
		mov	InWord, 0		;Just left a word
		jmp	WCDone
;
NotInAWord:	cmp	al, " "
		jbe	WCDone
		mov	InWord, 1		;Just entered a word
		inc	WordCount
;
WCDone:
;
; Okay, or the current character into the character set so we can keep
; track of the characters which appear in this file.
;
		lesi	CharSet
		AddChar
		jmp	TSLoop
;
;
; Come down here on EOF or other read error.
;
ReadError:	cmp	ax, EOFError
		je	Quit
		print
		db	"DOS Error ",0
		puti
		putcr
		jmp	Return2DOS
;
; Return to DOS.
;
Quit:		freadoff
		mov	ax, FileHandle
		fclose
		printf
		db	cr,lf,lf
		db	"Number of words in this file is %d",cr,lf
		db	"Number of lines in this file is %d",cr,lf
		db	"Number of control characters is %d",cr,lf
		db	"Number of punctuation characters is %d",cr,lf
		db	"Number of alphabetic characters is %d",cr,lf
		db	"Number of numeric characters is %d",cr,lf
		db	"Number of other characters is %d",cr,lf
		db	"Total number of characters is %d",cr,lf
		db	lf, 0
		dd	WordCount,LineCnt,ControlCnt,Punct
		dd	AlphaCnt,NumericCnt,Other,Chars
;
; Print the characters that actually appeared in the file.
;
		lesi	CharSet
EC64:		mov	cx, 64			;Chars/line on output.
EachChar:	RmvItem
		cmp	al, 0
		je	CSDone
		cmp	al, " "
		jbe	EachChar
		putc
		loop	EachChar
		putcr
		jmp	EC64
;
CSDone:		print
		db	cr,lf,lf
		db	"Press any key to continue:",0
		getc
		putcr
		putcr
;
; Now print the statistics for each character:
;
		mov	ax, Chars		;Get character count,
		utof				; convert it to a floating
		lesi	TotalChars		; point value, and save this
		sdfpa				; value in "TotalChars".
;
; Print out each character, the number of occurrences, and the ratio of
; this character's count to the total number of characters.
;
		mov	bx, " "*2		;Start output with spaces.
ComputeRatios:	cmp	CharCnt[bx], 0
		je	SkipThisChar
		mov	ax, bx
		shr	ax, 1			;Convert index to character
		putc				; and print it.
		print
		db	" = ",0
		mov	ax, CharCnt [bx]
		mov	cx, 4
		putisize
		print
		db	"  Percentage of total is ",0
;
		utof
;
; Divide by the total number of characters in the file:
;
		lesi	TotalChars
		ldfpo
		fpdiv
;
; Multiply by 100 to get a percentage
;
		lesi	Const100
		lsfpo
		fpmul
;
; Print the ratio:
;
		mov	al, 7
		mov	ah, 3
		ftoam
		puts
		free
		print
		db	"%   ",cr,lf,0
;
SkipThisChar:	inc	bx
		inc	bx
		cmp	bx, 200h
		jb      ComputeRatios
		putcr
;
Return2DOS:	mov     ah, 4ch
		int     21h
;
;
TS		endp
;
;
;
cseg            ends
;
;
; Allocate a reasonable amount of space for the stack (2k).
;
sseg		segment	para stack 'stack'
stk		db	256 dup ("stack   ")
sseg		ends
;
;
;
; zzzzzzseg must be the last segment that gets loaded into memory!
; The UCR Standard Library package uses this segment to determine where
; the end of the program lies.
;
zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	TS
