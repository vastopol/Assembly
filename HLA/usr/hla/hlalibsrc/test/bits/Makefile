all:
	hla -@@ -p:temp -obj:temp -x:tBitcnt.exe tBitcnt.hla
	tBitcnt.exe
	hla -@@ -p:temp -obj:temp -x:tCoalesce.exe tCoalesce.hla
	tCoalesce.exe
	hla -@@ -p:temp -obj:temp -x:tDistribute.exe tDistribute.hla
	tDistribute.exe
	hla -@@ -p:temp -obj:temp -x:tMerge.exe tMerge.hla
	tMerge.exe

thread:
	hla -@@ -p:temp -obj:temp -x:tBitcnt.exe -thread tBitcnt.hla
	tBitcnt.exe
	hla -@@ -p:temp -obj:temp -x:tCoalesce.exe -thread tCoalesce.hla
	tCoalesce.exe
	hla -@@ -p:temp -obj:temp -x:tDistribute.exe -thread tDistribute.hla
	tDistribute.exe
	hla -@@ -p:temp -obj:temp -x:tMerge.exe -thread tMerge.hla
	tMerge.exe

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
	