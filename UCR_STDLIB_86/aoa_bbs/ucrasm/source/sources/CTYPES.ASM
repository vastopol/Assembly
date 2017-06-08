StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
stddata		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:stdgrp
;
; IsAlNum- Checks al to see if it is alphanumeric.
;
		public	sl_IsAlNum
sl_IsAlNum	proc	far
		cmp	al, '0'
		jb	notan
		cmp	al, '9'
		jbe	isan
		cmp	al, 'A'
		jb	notan
		cmp	al, 'Z'
		jbe     isan
		cmp	al, 'a'
		jb	notan
		cmp	al, 'z'
		jbe	isan
notan:		cmp	al, 'a'			;Clears zero flag
		ret
isan:		cmp	al, al			;Sets zero flag
		ret
sl_IsAlNum	endp
;
;
; IsxDigit- Checks al to see if it is a hex digit.
;
		public	sl_IsxDigit
sl_IsxDigit	proc	far
		cmp	al, '0'
		jb	notah
		cmp	al, '9'
		jbe	isah
		cmp	al, 'A'
		jb	notah
		cmp	al, 'F'
		jbe     isah
		cmp	al, 'a'
		jb	notah
		cmp	al, 'f'
		jbe	isah
notah:		cmp	al, 'a'			;Clears zero flag
		ret
isah:		cmp	al, al			;Sets zero flag
		ret
sl_IsxDigit	endp
;
;
stdlib		ends
		end
