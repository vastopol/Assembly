include  c:\stdlib\stdlib.a

;
; main :	A main() procedure suitable for use with Express.
;		Written by Michael A. Griffith.
;
; Modification List:
;
; 26 Oct 91  Michael A. Griffith 
;            Created.
;
;

_EXPRESSD		SEGMENT PARA PUBLIC 'CODE'
_EXPRESSD 		ENDS



_EXPRESSC		SEGMENT PARA PUBLIC 'CODE'
ASSUME ds:_EXPRESSD, cs:_EXPRESSC, ss:_EXPRESSS

Main			PROC
			public PSP
PSP			dw 	?
			int  	21h
Main			ENDP

_EXPRESSC		ENDS



_EXPRESSS		SEGMENT PARA STACK 'STACK'
Stack			DB 	256 DUP (?)
_EXPRESSS		ENDS


END
