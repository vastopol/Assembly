stdData		segment	para public 'sldata'
;
;
;
		public	$lwrtbl
;
; Output all chars up to the upper case letters here.
;
$lwrtbl		equ	this byte
i		=	0
		rept	'A'
		db	i
i		=	i + 1
		endm
;
; Output uc for lc here
;
i		=	'a'
		rept	26
		db	i
i		=	i+1
		endm
;
; Output all other characters here.
;
i		=	'Z'+1
		rept	255-'Z'
		db	i
i		=	i+1
		endm
;
stdData		ends
		end
