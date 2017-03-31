StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
; LSize- Returns the number of print positions required by an integer value.
;       On Input:
;                       DX:AX- Integer to get the size of.
;
;       On Output:
;                       AX: Digit count for the integer.
;
		public  sl_LSize
sl_LSize        proc    far
		push    dx
		cmp     dx, 0
		jge     LSize2
;
; Negate DX:AX
;
		neg     dx
		neg     ax
		sbb     dx, 0
;
		call    GetULSize
		inc     ax
		pop     dx
		ret
;
LSize2:         call    GetULSize
		pop     dx
		ret
sl_LSize        endp
;
; ULSize- Same as above, except for unsigned numbers.
;
		public  sl_ULSize
sl_ULSize       proc    far
		call    GetULSize
		ret
sl_ULSize       endp
;
; GetUSize- Does the actual size comparison.
;
GetULSize       proc    near
		cmp     dx, 0
		jne     GUSA
;
		cmp     ax, 10
		jae     GUS1
		mov     ax, 1
		ret
;
GUS1:           cmp     ax, 100
		jae     GUS2
		mov     ax, 2
		ret
;
GUS2:           cmp     ax, 1000
		jae     GUS3
		mov     ax, 3
		ret
GUS3:           cmp     ax, 10000
		jae     GUS4
		mov     ax, 4
		ret
;
GUS4:           mov     ax, 5
		ret
;
GUSA:           push	dx
		cmp     ax, 86a0h               ;Low (100,000)
		sbb     dx, 1                   ;High(100,000)
		pop	dx
		jb      GUS5
		push	dx
		cmp     ax, 0bba0h              ;Low (900,000)
		sbb     dx, 0dh                 ;High(900,000)
		pop	dx
		jb      GUS6
		push	dx
		cmp     ax, 5440h               ;low (9,000,000)
		sbb     dx, 89h                 ;high(9,000,000)
		pop	dx
		jb      GUS7
		push	dx
		cmp     ax, 4a80h               ;low (90,000,000)
		sbb     dx, 55dh                ;high(90,000,000)
		pop	dx
		jb      GUS8
		push	dx
		cmp     ax, 0e900h              ;low (900,000,000)
		sbb     dx, 35a4h               ;high(900,000,000)
		pop	dx
		jb      GUS9
		mov     ax, 10
		ret
;
GUS5:           mov     ax, 5
		ret
;
GUS6:           mov     ax, 6
		ret
;
GUS7:           mov     ax, 7
		ret
;
GUS8:           mov     ax, 8
		ret
;
GUS9:           mov     ax, 9
		ret
;
GetULSize       endp
;
stdlib		ends
		end
