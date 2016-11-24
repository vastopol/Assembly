all:
	hla -@@ -p:temp -obj:temp -x:tChars.exe tChars
	tChars.exe
	hla -@@ -p:temp -obj:temp -x:tiChars.exe tiChars
	tiChars.exe
	hla -@@ -p:temp -obj:temp -x:tStrs.exe tStrs
	tStrs.exe
	hla -@@ -p:temp -obj:temp -x:tMisc.exe tMisc
	tMisc.exe
	hla -@@ -p:temp -obj:temp -x:tPat.exe tPat
	tPat.exe
	
	
thread:
	hla -@@ -thread -p:temp -obj:temp -x:tChars.exe tChars
	tChars.exe
	hla -@@ -thread -p:temp -obj:temp -x:tiChars.exe tiChars
	tiChars.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrs.exe tStrs
	tStrs.exe
	hla -@@ -thread -p:temp -obj:temp -x:tMisc.exe tMisc
	tMisc.exe
	hla -@@ -thread -p:temp -obj:temp -x:tPat.exe tPat
	tPat.exe
	
	
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
	