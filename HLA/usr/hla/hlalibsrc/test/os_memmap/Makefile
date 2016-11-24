all:
	hla -@@ -p:temp -obj:temp -x:tMemmap.exe tMemmap.hla
	tMemmap.exe

thread:
	hla -@@ -thread -p:temp -obj:temp -x:tMemmap.exe tMemmap.hla
	tMemmap.exe

clean:
	delete mmcopy.hla
	delete temp
	delete .inc
	delete .o
	delete .obj
	delete .link
	delete .exe
	delete .asm
	delete .pdb
	delete .ilk
	
