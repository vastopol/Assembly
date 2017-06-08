;
;
; lesi- macro to do a "les di, constant"
;
lesi		macro	adrs
		mov     di, seg adrs
		mov	es, di
		lea	di, adrs
		endm

;
; ldsi- macro to do a "lds si, constant" operation.
;

ldsi		macro 	adrs
		mov	si, seg adrs
		mov	ds, si
		lea	si, adrs
		endm


;
; ldxi- macro to do a "ldx si, constant" operation.
;

ldxi		macro	adrs
		mov	dx, seg adrs
		lea	si, adrs
		endm
