; datepat.asm
;
; This program converts dates of various formats to a three integer
; component value- month, day, and year.

		.xlist
		.286
		include 	stdlib.a
		includelib	stdlib.lib
		matchfuncs
		.list
		.lall


dseg		segment	para public 'data'

; The following three variables hold the result of the conversion.

month		word	0
day		word	0
year		word	0

; StrPtr is a double word value that points at the string under test.
; The output routines use this variable.  It is declared as two word
; values so it is easier to store es:di into it.

strptr		word	0,0

; Value is a generic variable the ConvertInt routine uses

value		word	0



; Number of valid days in each month (Feb is handled specially)

DaysInMonth	byte	31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31



; Some sample strings to test the date conversion routines.

Str0		byte	"Feb 4, 1956",0
Str1		byte	"July 20, 1960",0
Str2		byte	"Jul 8, 1964",0
Str3		byte	"1/1/97",0
Str4		byte	"1-1-1997",0
Str5		byte	"12-25-74",0
Str6		byte	"3/28/1981",0
Str7		byte	"January 1, 1999",0
Str8		byte	"Feb 29, 1996",0
Str9		byte	"30 June, 1990",0
Str10		byte	"August 7, 1945",0
Str11		byte	"30 September, 1992",0
Str12		byte	"Feb 29, 1990",0
Str13		byte	"29 Feb, 1992",0



; The following grammar is what we use to process the dates
;
; Date	->	EngMon Integer Integer
;	|	Integer EngMon Integer
;	|	Integer "/" Integer "/" Integer
;	|	Integer "-" Integer "-" Integer
;
; EngMon->	Jan | January | Feb | February | ... | Dec | December
; Integer->	digit integer | digit
; digit	->	0 | 1 | ... | 9
;
; Some semantic rules this code has to check:
;
; If the year is in the range 0-99, this code has to add 1900 to it.
; If the year is not in the range 0-99 or 1900-1999 then return an error.
; The month must be in the range 1-12, else return an error.
; The day must be between one and 28, 29, 30, or 31.  The exact maximum
; day depends on the month.


separators	pattern	{spancset, delimiters}


; DatePat processes dates of the form  "MonInEnglish  Day  Year"

DatePat		pattern	{sl_match2, EngMon, DatePat2, DayYear}
DayYear		pattern	{sl_match2, DayInteger, 0, YearPat}
YearPat		pattern	{sl_match2, YearInteger}

; DatePat2 processes dates of the form "Day MonInEng Year"

DatePat2	pattern	{sl_match2, DayInteger, DatePat3, MonthYear}
MonthYear	pattern	{sl_match2, EngMon, 0, YearPat}

; DatePat3 processes dates of the form "mm-dd-yy"

DatePat3	pattern	{sl_match2, MonInteger, DatePat4, DatePat3a}
DatePat3a	pattern	{sl_match2, separators, DatePat3b, DatePat3b}
DatePat3b	pattern	{matchchar, '-', 0, DatePat3c}
DatePat3c	pattern	{sl_match2, DayInteger, 0, DatePat3d}
DatePat3d	pattern	{sl_match2, separators, DatePat3e, DatePat3e}
DatePat3e	pattern	{matchchar, '-', 0, DatePat3f}
DatePat3f	pattern	{sl_match2, YearInteger}

; DatePat4 processes dates of the form "mm/dd/yy"

DatePat4	pattern	{sl_match2, MonInteger, 0, DatePat4a}
DatePat4a	pattern	{sl_match2, separators, DatePat4b, DatePat4b}
DatePat4b	pattern	{matchchar, '/', 0, DatePat4c}
DatePat4c	pattern	{sl_match2, DayInteger, 0, DatePat4d}
DatePat4d	pattern	{sl_match2, separators, DatePat4e, DatePat4e}
DatePat4e	pattern	{matchchar, '/', 0, DatePat4f}
DatePat4f	pattern	{sl_match2, YearInteger}


; DayInteger matches an decimal string, converts it to an integer, and
; stores the result away in the Day variable.

DayInteger	pattern	{sl_match2, Integer, 0, SetDayPat}
SetDayPat	pattern	{SetDay}

; MonInteger matches an decimal string, converts it to an integer, and
; stores the result away in the Month variable.

MonInteger	pattern	{sl_match2, Integer, 0, SetMonPat}
SetMonPat	pattern	{SetMon}

; YearInteger matches an decimal string, converts it to an integer, and
; stores the result away in the Year variable.


YearInteger	pattern	{sl_match2, Integer, 0, SetYearPat}
SetYearPat	pattern	{SetYear}


; Integer skips any leading delimiter characters and then matches a
; decimal string.  The Integer0 pattern matches exactly the decimal
; characters; the code does a patgrab on Integer0 when converting
; this string to an integer.

Integer		pattern	{sl_match2, separators, 0, Integer0}
Integer0	pattern	{sl_match2, number, 0, Convert2Int}
number		pattern	{anycset, digits, 0, number2}
number2		pattern	{spancset, digits}
Convert2Int	pattern	{ConvertInt}




; A macro to make it easy to declare each of the 24 English month
; patterns (24 because we allow the full month name and an
; abbreviation).

MoPat		macro	name, next, str, str2, value
		local   SetMo, string, full, short, string2, doMon

name		pattern	{sl_match2, short, next}
short		pattern	{matchistr, string2, full, SetMo}
full		pattern	{matchistr, string, 0, SetMo}

string		byte    str
		byte	0

string2		byte	str2
		byte	0

SetMo		pattern	{MonthVal, value}
		endm


; EngMon is a chain of patterns that match one of the strings
; JAN, JANUARY, FEB, FEBRUARY, etc.  The last parameter to the
; MoPat macro is the month number.

EngMon		pattern {sl_match2, separators, jan, jan}
		MoPat	jan, feb, "JAN", "JANUARY", 1
		MoPat	feb, mar, "FEB", "FEBRUARY", 2
		MoPat	mar, apr, "MAR", "MARCH", 3
		MoPat	apr, may, "APR", "APRIL", 4
		MoPat	may, jun, "MAY", "MAY", 5
		MoPat	jun, jul, "JUN", "JUNE", 6
		MoPat	jul, aug, "JUL", "JULY", 7
		MoPat	aug, sep, "AUG", "AUGUST", 8
		MoPat	sep, oct, "SEP", "SEPTEMBER", 9
		MoPat	oct, nov, "OCT", "OCTOBER", 10
		MoPat	nov, decem, "NOV", "NOVEMBER", 11
		MoPat	decem, 0, "DEC", "DECEMBER", 12




; We use the "digits" and "delimiters" sets from the standard library.

		include	stdsets.a

dseg		ends



cseg		segment	para public 'code'
		assume	cs:cseg, ds:dseg


; ConvertInt-	Matches a sequence of digits and converts them to an integer.

ConvertInt	proc	far
		push	ds
		push	es
		push	di
		mov	ax, dseg
		mov	ds, ax

		lesi    Integer0	;Integer0 contains the decimal
		patgrab			; string we matched, grab that
		atou			; string and convert it to an
		mov	Value, ax	; integer and save the result.
		free			;Free mem allocated by patgrab.

		pop	di
		mov	ax, di		;Required by sl_match.
		pop	es
		pop	ds
		stc			;Always succeed.
		ret

ConvertInt	endp


; SetDay, SetMon, and SetYear simply copy value to the appropriate
; variable.

SetDay		proc	far
		push	ds
		mov	ax, dseg
		mov	ds, ax
		mov	ax, value
		mov	day, ax
		mov	ax, di
		pop	ds
		stc
		ret
SetDay		endp


SetMon		proc	far
		push	ds
		mov	ax, dseg
		mov	ds, ax
		mov	ax, value
		mov	Month, ax
		mov	ax, di
		pop	ds
		stc
		ret
SetMon		endp


SetYear		proc	far
		push	ds
		mov	ax, dseg
		mov	ds, ax
		mov	ax, value
		mov	Year, ax
		mov	ax, di
		pop	ds
		stc
		ret
SetYear		endp


; MonthVal is a pattern used by the English month patterns.
; This pattern function simply copies the matchparm field to
; the month variable (the matchparm field is passed in si).

MonthVal	proc	far
		push	ds
		mov	ax, dseg
		mov	ds, ax
		mov	Month, si
		mov	ax, di
		pop	ds
		stc
		ret
MonthVal	endp



; ChkDate-	Checks a date to see if it is valid.  Returns with the
;		carry flag set if it is, clear if not.

ChkDate		proc	far
		push	ds
		push	ax
		push	bx

		mov	ax, dseg
		mov	ds, ax

; If the year is in the range 0-99, add 1900 to it.
; Then check to see if it's in the range 1900-1999.

		cmp	Year, 100
		ja	Notb100
		add	Year, 1900
Notb100:	cmp	Year, 2000
		jae	BadDate
		cmp	Year, 1900
		jb	BadDate

; Okay, make sure the month is in the range 1-12

		cmp	Month, 12
		ja	BadDate
		cmp	Month, 1
		jb	BadDate

; See if the number of days is correct for all months except Feb:

		mov	bx, Month
		mov	ax, Day			;Make sure Day <> 0.
		test	ax, ax
		je	BadDate
		cmp	ah, 0			;Make sure Day < 256.
		jne	BadDate

		cmp	bx, 2			;Handle Feb elsewhere.
		je	DoFeb
		cmp	al, DaysInMonth[bx-1]	;Check against max val.
		ja	BadDate
		jmp	GoodDate

; Kludge to handle leap years.  Note that 1900 is *not* a leap year.

DoFeb:          cmp	ax, 29			;Only applies if day is
		jb	GoodDate		; equal to 29.
		ja	BadDate			;Error if Day > 29.
		mov	bx, Year		;1900 is not a leap year
		cmp	bx, 1900		; so handle that here.
		je	BadDate
		and	bx, 11b			;Else, Year mod 4 is a
		jne	BadDate			; leap year.

GoodDate:	pop	bx
		pop	ax
		pop	ds
		stc
		ret

BadDate:	pop	bx
		pop	ax
		pop	ds
		clc
		ret
ChkDate		endp


; ConvertDate-	ES:DI contains a pointer to a string containing a valid
;		date.  This routine converts that date to the three
;		integer values found in the Month, Day, and Year
;		variables.  Then it prints them to verify the pattern
;		matching routine.

ConvertDate	proc	near

		ldxi	DatePat
		xor	cx, cx
		match
		jnc	NoMatch

		mov	strptr, di		;Save string pointer for
		mov	strptr+2, es		; use by printf

		call	ChkDate			;Validate the date.
		jnc	NoMatch

		printf
		byte	"%-20^s = Month: %2d    Day:   %2d   Year:  %4d\n",0
		dword	strptr, Month, Day, Year
		jmp	Done

NoMatch:	printf
		byte	"Illegal date ('%^s')",cr,lf,0
		dword	strptr

Done:		ret
ConvertDate	endp




Main		proc
		mov	ax, dseg
		mov	ds, ax
		mov	es, ax

		meminit				;Init memory manager.

; Call ConvertDate to test several different date strings.

		lesi	Str0
		call	ConvertDate
		lesi	Str1
		call	ConvertDate
		lesi	Str2
		call	ConvertDate
		lesi	Str3
		call	ConvertDate
		lesi	Str4
		call	ConvertDate
		lesi	Str5
		call	ConvertDate
		lesi	Str6
		call	ConvertDate
		lesi	Str7
		call	ConvertDate
		lesi	Str8
		call	ConvertDate
		lesi	Str9
		call	ConvertDate
		lesi	Str10
		call	ConvertDate
		lesi	Str11
		call	ConvertDate
		lesi	Str12
		call	ConvertDate
		lesi	Str13
		call	ConvertDate


Quit:		ExitPgm
Main		endp

cseg		ends

sseg		segment	para stack 'stack'
stk		db	1024 dup ("stack   ")
sseg		ends

zzzzzzseg	segment	para public 'zzzzzz'
LastBytes	db	16 dup (?)
zzzzzzseg	ends
		end	Main
