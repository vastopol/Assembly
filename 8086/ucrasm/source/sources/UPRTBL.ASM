StdGrp		group	stdlib,stddata
stddata		segment	para public 'sldata'
;
		public	$uprtbl
;
; Output all chars up to the upper case letters here.
;
$uprtbl		equ	this byte
i		=	0
		rept	'a'
		db	i
i		=	i + 1
		endm
;
; Output uc for lc here
;
i		=	'A'
		rept	26
		db	i
i		=	i+1
		endm
;
; Output all other characters here.
;
i		=	'z'+1
		rept	255-'z'
		db	i
i		=	i+1
		endm
;
stddata		ends
;
stdlib		segment	para public 'slcode'
stdlib		ends
		end
