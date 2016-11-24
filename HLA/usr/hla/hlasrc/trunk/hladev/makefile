
all:	hlaasm.masm hlaasm.gas hlaasm.gasx

hlaasm.masm:	
	hla -sourcemode -s -masm -sourcemode hlaasm.hla
	copy hlaasm.asm ..\hlaasm.masm
	ml -c -coff -Cp hlaasm.asm
	copy hlaasm.obj ..\hlaasm.obj
	
	
hlaasm.gas:
	hla -sourcemode -s -gas -sourcemode -dunix hlaasm.hla
	copy hlaasm.asm ..\hlaasm.gas
	
	
hlaasm.gasx:
	hla -macos -sourcemode -s -gasx -sourcemode -dmacosx hlaasm.hla
	copy hlaasm.asm ..\hlaasm.gasx
		
	
clean:
	delete *.obj
	delete *.asm
	delete *.bak
	delete *.link
	delete *.inc
	delete *.masm
	delete *.gas
	delete *.gasx

