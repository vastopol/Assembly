;
; Random number generator.
; Original author: unknown.  This code was pulled off one of the nets and
;		   added to the library.  Any information on the original
;		   author would be appreciated.
;
;		   Modified for use with UCR Standard library 10/24/91 rhyde
;
;

StdGrp		group	StdLib, StdData

StdData		segment	para public 'sldata'
;
; Note:  24 and 55 are not arbitrary.  They have been chosen so that the least
; significant bits in the sequence of pseudorandom integers have a period of
; length 2^55 - 1.  The sequence of pseudorandom numbers themselves have period
; 2^f*(2^55 - 1) where 0 <= f <= 16.  See Knuth's Volume 2 "Seminumerical
; Algorithms" of the second edition of the three volume set THE ART OF COMPUTER
; PROGRAMMING (pages 26 & 27).

j		dw	24 * 2		; multiply by 2 for word offsets
k		dw	55 * 2

; Array of 55 seed elements for the additive pseudorandom number generator.

add_array	dw	?	; this location (offset 0 word) is not used
		dw	7952,	42720,	56941,	47825,	52353,	4829,	32133
		dw	29787,	7028,	62292,	46128,	34856,	63646,	21032
		dw	62660,	61244,	35057,	36989,	43989,	46043,	48547
		dw	43704,	29749,	21898,	10279,	48252,	35578,	27916
		dw	3633,	50349,	33655,	36965,	48566,	43375,	15168
		dw	30425,	8425,	31783,	3625,	23789,	37438,	64887
		dw	19015,	43108,	61545,	24901,	58349,	52290,	62047
		dw	21173,	27055,	27851,	47955,	14377,	14434
StdData		ends

stdlib		segment	para public 'slcode'
		assume	cs:StdGrp, ds:StdGrp
;
;
		public	sl_randomize
;
sl_randomize	proc	far		; randomize the random number generator
		push	ds
		push	ax		; save
		push	bx
		push	cx
;
		mov	ax,40h		; set ds to BIOS data area
		mov	ds,ax
		mov	bx,6ch		; location of low word of 4-byte count
		mov	ax,[bx]		; get low word of 4-byte clock count
		mov	bx, StdGrp	; reset ds for code addressing
		mov	ds, bx
		mov	bx,offset add_array ; address array of seed elements
		add	bx,2		; offset 0 is not used
		mov	cx,55		; shall adjust all 55 seeds
set_seed:	add	[bx],ax		; randomize seed value with current time
		add	bx,2		; move to next one
		loop	set_seed
;
		pop	cx
		pop	bx
		pop	ax
		pop	ds
		ret
sl_randomize	endp
;
;
;
; sl_Random-	Returns random number in AX (random bit values).
;
		public	sl_Random
;
sl_random	proc	far		; generate pseudorandom number in ax
		push	bx		; save
		push	cx
		push	ds
;
		mov	bx, StdGrp
		mov	ds, bx
;
		mov	bx,j		; get j index
		mov	cx,add_array[bx]; and load array element into cx
		mov	bx,k		; get k index
		mov	ax,add_array[bx]; and load array element into ax
		add	ax,cx		; new element and return value to ax
		mov	add_array[bx],ax; store new element at location k
		sub	j,2		; move down one element
		sub	k,2		; move down one element
		cmp	j,0		; is j down to 0?
		jne	check_k		; no, check k
		mov	j,55 * 2	; set i to end of array
check_k:	cmp	k,0		; is k down to 0?
		jne	random_out	; no, leave
		mov	k,55 * 2	; set k to end of array
;
random_out:	pop	ds
		pop	cx		; restore
		pop	bx
		ret
sl_random	endp
;
StdLib		ends
		end
