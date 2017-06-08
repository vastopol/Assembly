StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
; ISize- Returns the number of print positions required by an integer value.
;       On Input:
;                       AX: Integer to get the size of.
;
;       On Output:
;                       AX: Digit count for the integer.
;
		public  sl_ISize
sl_ISize	proc    far
		cmp     ax, 0
		jge     ISize2
		neg     ax
		call    GetUSize
		inc     ax
		ret
;
ISize2:         call    GetUSize
		ret
sl_ISize	endp
;
; USize- Same as above, except for unsigned numbers.
;
		public  sl_USize
sl_USize        proc    far
		call    GetUSize
		ret
sl_USize        endp
;
; GetUSize- Does the actual size comparison.
;
GetUSize        proc    near
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
GetUSize        endp
;
stdlib		ends
		end
