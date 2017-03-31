; Pgm9_4.ASM
;
;	This program demonstrates how to pack and unpack
;	data types.  It reads in a month, day, and year value.
; 	It then packs these values into the format the textbook
;	presents in chapter two.  Finally, it unpacks this data
;	and calls the stdlib DTOA routine to print it as text.

		.xlist
		include 	stdlib.a
		includelib	stdlib.lib
		.list


dseg		segment	para public 'data'

Month		byte	?	;Holds month value (1-12)
Day		byte	?	;Holds day value (1-31)
Year		byte	?	;Holds year value (80-99)

Date		word	?	;Packed data goes in here.

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; GETI-	Reads an integer variable from the user and returns its
;	its value in the AX register.

geti		textequ	<call _geti>
_geti		proc
		push	es
		push	di

		getsm
		atoi
		free

		pop	di
		pop	es
		ret
_geti		endp


Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax
		meminit


		print
		byte	"Date Conversion Program",cr,lf
		byte	"-----------------------",cr,lf
		byte	lf,0


; Get the month value from the user.
; Do a simple check to make sure this value is in the range
; 1-12.  Make the user reenter the month if it is not.

GetMonth:	print
		byte	"Enter the month (1-12): ",0

		geti
		mov	Month, al
		cmp	ax, 0
		je	BadMonth
		cmp	ax, 12
		jbe	GoodMonth
BadMonth:	print
		byte	"Illegal month value, please re-enter",cr,lf,0
		jmp	GetMonth

GoodMonth:


; Okay, read the day from the user.  Again, do a simple
; check to see if the date is valid.  Note that this code
; only checks to see if the day value is in the range 1-31.
; It does not check those months that have 28, 29, or 30
; day months.

GetDay:		print
		byte	"Enter the day (1-31): ",0
		geti
		mov	Day, al
		cmp	ax, 0
		je	BadDay
		cmp	ax, 31
		jbe	GoodDay
BadDay:		print
		byte	"Illegal day value, please re-enter",cr,lf,0
		jmp	GetDay

GoodDay:


; Okay, get the year from the user.
; This check is slightly more sophisticated.  If the user
; enters a year in the range 1980-1999, it will automatically
; convert it to 80-99.  All other dates outside the range
; 80-99 are illegal.

GetYear:	print
		byte	"Enter the year (80-99): ",0
		geti
		cmp	ax, 1980
		jb	TestYear
		cmp	ax, 1999
		ja	BadYear

		sub	dx, dx		;Zero extend year to 32 bits.
		mov	bx, 100
		div	bx		;Compute year mod 100.
		mov	ax, dx
		jmp	GoodYear

TestYear:	cmp	ax, 80
		jb	BadYear
		cmp	ax, 99
		jbe	GoodYear

BadYear:	print
		byte	"Illegal year value.  Please re-enter",cr,lf,0
		jmp	GetYear

GoodYear:	mov	Year, al


; Okay, take these input values and pack them into the following
; 16-bit format:
;
;      bit 15     8 7      0
;          |      | |      |
;	   MMMMDDDD DYYYYYYY


		mov	ah, 0
		mov	bh, ah
		mov	al, Month	;Put Month into bit positions
		mov	cl, 4		; 12..15
		ror	ax, cl

		mov	bl, Day		;Put Day into bit positions
		mov	cl, 7		; 7..11.
		shl	bx, cl

		or	ax, bx		;Create MMMMDDDD D0000000
		or	al, Year	;Create MMMMDDDD DYYYYYYY
		mov	Date, ax	;Save away packed date.

; Print out the packed date (in hex):

		print
		byte	"Packed date = ",0
		putw
		putcr

; Okay, the following code demonstrates how to unpack this date
; and put it in a form the standard library's LDTOAM routine can
; use.

		mov	ax, Date	;First, extract Month
		mov	cl, 4
		shr	ah, cl
		mov	dh, ah		;LDTOAM needs month in DH.

		mov	ax, Date	;Next get the day.
		shl	ax, 1
		and	ah, 11111b
		mov	dl, ah		;Day needs to be in DL.

		mov	cx, Date	;Now process the year.
		and	cx, 7fh		;Strip all but year bits.

		print
		byte	"Date: ",0
		LDTOAM			;Convert to a string
		puts
		free
		putcr




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
