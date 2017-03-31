;
		extrn	sl_strdup:far
		extrn	sl_free:far
		extrn	sl_strupr:far
		extrn	sl_strlen:far
;
StdGrp		group	StdLib, StdData
;
StdData		segment	para public 'sldata'
ZeroByte	db	0
StdData		ends
;
stdlib		segment	para public 'slcode'
		assume	cs:StdGrp,ds:nothing
;
;
; GetEnv-  On entry, ES:DI points at an environment variable name.
;	   This routine copies that string, converts it to upper case
;	   and then searches for that string in the environment space.
;
;	   Returns pointer to environment variable in ES:DI if it finds
;	   said variable.  Also returns carry clear in this case.
;	   Returns the carry set if it could not find the environment
;	   variable or if there was a memory allocation error.
;
		public	sl_GetEnv
sl_GetEnv	proc	far
		pushf
		push	ds
		push	si
		push	bp
		push	cx
		push	ax
		cld

; First, duplicate the string so we can play around with it:

		call	StdGrp:sl_strdup
		jc	BadGetEnv


; Now, convert all the characters in the string to upper case:

		call	StdGrp:sl_strupr

; Get the length of the string into cx:

		call	StdGrp:sl_strlen

; Save ptr to name in DS:SI for later use:

		mov	si, es
		mov	ds, si
		mov	si, di
;
; Get the address of the environment string space:
;
		mov	ah, 62h			;Get PSP value
		int	21h
		mov	es, bx
		mov	es, es:[2ch]		;Get adrs of env blk.

; Okay, search the environment string space for our string

		push	cx
		push	ds
		push	si
		mov	bp, sp
		xor	di, di			;Start at ES:[0]
		jcxz	NoMatch
CmpsLp:	repe	cmpsb				;Does this entry match?
		je	GotMatch

; The current entry did not match, try the next one:

		mov	cx, 8000h		;Save for next zero.
		mov	al, 0
	repne	scasb
		cmp	byte ptr es:[di], 0	;End of Env?
		je	GotMatch

		mov	si, 0[bp]
		mov	ds, 2[bp]
		mov	cx, 4[bp]
		jmp	CmpsLp


; If there are zero characters in the source string, just return a pointer
; to a zero byte.

NoMatch:	mov	ax, seg ZeroByte
		mov	es, ax
		mov	di, offset ZeroByte

; Return to the caller with carry clear if no error.

GotMatch:	mov	ax, es			;Save ptr to stuff after
		mov	cx, di			; the env string.

		pop	di			;Free up the string.
		pop	es
		add	sp, 2			;Pop other junk off stack.
		call	StdGrp:sl_free		

		mov	es, ax			;Restore pointer to the
		mov	di, cx			; environment string.
		clc
		pop	ax
		pop	cx
		pop	bp
		pop	si
		pop	ds
		popf
		ret

BadGetEnv:	pop	ax
		pop	cx
		pop	bp
		pop	si
		pop	ds
		popf
		stc
		ret
sl_getenv	endp

stdlib		ends
		end
