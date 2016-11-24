build: bc.exe bd.exe be.exe


bc.exe: bc.hla basic.hhf
	hla -p:temp -obj:temp bc

bd.exe: bd.hla basic.hhf
	hla -p:temp -obj:temp bd

be.exe: bx.hla be.hla basic.hhf
	hla -p:temp -obj:temp be bx
	
	
clean:
	del /Q /F *.exe	
	del /Q /F *.obj	
	del /Q /F *.o	
	del /Q /F *.link	
	del /Q /F *.ilk	
	del /Q /F *.pdb	
	del /Q /F *.asm
	del /Q /F temp\*	
	
		 