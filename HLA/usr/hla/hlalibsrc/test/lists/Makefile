all:
	hla -@@ -p:temp -obj:temp -x:tList.exe tList.hla
	tList.exe

	hla -@@ -p:temp -obj:temp -x:tvList.exe tvList.hla
	tvList.exe

thread:
	hla -@@ -thread -p:temp -obj:temp -x:tList.exe tList.hla
	tList.exe

	hla -@@ -thread -p:temp -obj:temp -x:tvList.exe tvList.hla
	tvList.exe

clean:
	delete temp
	delete .inc
	delete .o
	delete .obj
	delete .link
	delete .exe
	delete .asm
	delete .pdb
	delete .ilk
	