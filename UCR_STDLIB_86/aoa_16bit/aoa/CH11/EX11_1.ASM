	ifndef	??version
?debug	macro
	endm
publicdll macro	name
	public	name
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	V 300h
	?debug	S "ex11_1.cpp"
	?debug	C E95B414D200A657831315F312E637070
_TEXT	segment byte public 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	int main()
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,4012
	push	si
	push	di
   ;	
   ;	{
   ;	    unsigned 	SaveScr[25][80];
   ;	
   ;	    int         dx,
   ;	                x,
   ;	                dy,
   ;	                y;
   ;	
   ;	    long        i;
   ;	
   ;	    unsigned    savex,
   ;	                savey;
   ;	
   ;	
   ;	
   ;	    GetXY(savex, savey);
   ;	
	push	ss
	lea	ax,word ptr [bp-12]
	push	ax
	push	ss
	lea	ax,word ptr [bp-10]
	push	ax
	call	near ptr _GetXY
	add	sp,8
   ;	
   ;	    Capture(SaveScr);
   ;	
	push	ss
	lea	ax,word ptr [bp-4012]
	push	ax
	call	near ptr _Capture
	pop	cx
	pop	cx
   ;	
   ;	    ClrScrn();
   ;	
	call	near ptr _ClrScrn
   ;	
   ;	
   ;	    GotoXY(24,0);
   ;	
	xor	ax,ax
	push	ax
	mov	ax,24
	push	ax
	call	near ptr _GotoXY
	pop	cx
	pop	cx
   ;	
   ;	    PutStr("Press any key to quit");
   ;	
	push	ds
	mov	ax,offset DGROUP:s@
	push	ax
	call	near ptr _PutStr
	pop	cx
	pop	cx
   ;	
   ;	
   ;	    dx = 1;
   ;	
	mov	word ptr [bp-2],1
   ;	
   ;	    dy = 1;
   ;	
	mov	word ptr [bp-4],1
   ;	
   ;	    x = 1;
   ;	
	mov	si,1
   ;	
   ;	    y = 1;
   ;	
	mov	di,1
	jmp	@1@422
@1@58:
   ;	
   ;	    while (!tstKbd())
   ;	    {
   ;	
   ;		GotoXY(y, x);
   ;	
	push	si
	push	di
	call	near ptr _GotoXY
	pop	cx
	pop	cx
   ;	
   ;	        PutChar('#');
   ;	
	mov	al,35
	push	ax
	call	near ptr _PutChar
	pop	cx
   ;	
   ;	
   ;	        for (i=0; i<500000; ++i);
   ;	
	mov	word ptr [bp-6],0
	mov	word ptr [bp-8],0
	jmp	short @1@114
@1@86:
	add	word ptr [bp-8],1
	adc	word ptr [bp-6],0
@1@114:
	cmp	word ptr [bp-6],7
	jl	short @1@86
	jne	short @1@198
	cmp	word ptr [bp-8],-24288
	jb	short @1@86
@1@198:
   ;	
   ;	
   ;	        GotoXY(y, x);
   ;	
	push	si
	push	di
	call	near ptr _GotoXY
	pop	cx
	pop	cx
   ;	
   ;	        PutChar(' ');
   ;	
	mov	al,32
	push	ax
	call	near ptr _PutChar
	pop	cx
   ;	
   ;	
   ;	
   ;	
   ;		x += dx;
   ;	
	add	si,word ptr [bp-2]
   ;	
   ;	        y += dy;
   ;	
	add	di,word ptr [bp-4]
   ;	
   ;	        if (x >= 79)
   ;	
	cmp	si,79
	jl	short @1@254
   ;	
   ;		{
   ;	            x = 78;
   ;	
	mov	si,78
   ;	
   ;	            dx = -1;
   ;	
	mov	word ptr [bp-2],-1
   ;	
   ;		}
   ;	
	jmp	short @1@310
@1@254:
   ;	
   ;	        else if (x <= 0)
   ;	
	or	si,si
	jg	short @1@310
   ;	
   ;		{
   ;	            x = 1;
   ;	
	mov	si,1
   ;	
   ;	            dx = 1;
   ;	
	mov	word ptr [bp-2],1
@1@310:
   ;	
   ;		}
   ;	
   ;	        if (y >= 24)
   ;	
	cmp	di,24
	jl	short @1@366
   ;	
   ;		{
   ;	            y = 23;
   ;	
	mov	di,23
   ;	
   ;	            dy = -1;
   ;	
	mov	word ptr [bp-4],-1
   ;	
   ;		}
   ;	
	jmp	short @1@422
@1@366:
   ;	
   ;	        else if (y <= 0)
   ;	
	or	di,di
	jg	short @1@422
   ;	
   ;		{
   ;	            y = 1;
   ;	
	mov	di,1
   ;	
   ;	            dy = 1;
   ;	
	mov	word ptr [bp-4],1
@1@422:
	call	near ptr _tstKbd
	or	ax,ax
	jne	@@0
	jmp	@1@58
@@0:
   ;	
   ;		}
   ;	
   ;	
   ;	    }
   ;	
   ;	    PutScr(SaveScr);
   ;	
	push	ss
	lea	ax,word ptr [bp-4012]
	push	ax
	call	near ptr _PutScr
	pop	cx
	pop	cx
   ;	
   ;	    GotoXY(savey, savex);
   ;	
	push	word ptr [bp-10]
	push	word ptr [bp-12]
	call	near ptr _GotoXY
	pop	cx
	pop	cx
   ;	
   ;	    return 0;
   ;	
	xor	ax,ax
	jmp	short @1@478
@1@478:
   ;	
   ;	}
   ;	
	pop	di
	pop	si
	mov	sp,bp
	pop	bp
	ret	
_main	endp
	?debug	C E9
	?debug	C FA00000000
_TEXT	ends
_DATA	segment word public 'DATA'
s@	label	byte
	db	'Press any key to quit'
	db	0
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_main
	extrn	_PutStr:near
	extrn	_PutChar:near
	extrn	_PutScr:near
	extrn	_Capture:near
	extrn	_tstKbd:near
	extrn	_ClrScrn:near
	extrn	_GetXY:near
	extrn	_GotoXY:near
_s@	equ	s@
	end
