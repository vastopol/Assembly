cseg		segment
Sample4Lst	proc
		push	ax
		mov	bx, 0
		add	ax, bx
		mov	bx, ax
		mov	ds:[1000h], ax
		pop	ax
		ret
Sample4Lst	endp
cseg		ends
		end
