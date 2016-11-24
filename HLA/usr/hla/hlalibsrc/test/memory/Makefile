all:
	hla -@@ -p:temp -obj:temp -x:tAllocFree.exe tAllocFree
	tAllocFree.exe
	hla -@@ -p:temp -obj:temp -x:tBlkInHeap.exe tBlkInHeap
	tBlkInHeap.exe
	hla -@@ -p:temp -obj:temp -x:tMemUtils.exe tMemUtils
	tMemUtils.exe
	hla -@@ -p:temp -obj:temp -x:tReZalloc.exe tReZalloc
	tReZalloc.exe
	hla -@@ -p:temp -obj:temp -x:tStrAlloc.exe tStrAlloc
	tStrAlloc.exe

thread:
	hla -@@ -thread -p:temp -obj:temp -x:tAllocFree.exe tAllocFree
	tAllocFree.exe
	hla -@@ -thread -p:temp -obj:temp -x:tBlkInHeap.exe tBlkInHeap
	tBlkInHeap.exe
	hla -@@ -thread -p:temp -obj:temp -x:tMemUtils.exe tMemUtils
	tMemUtils.exe
	hla -@@ -thread -p:temp -obj:temp -x:tReZalloc.exe tReZalloc
	tReZalloc.exe
	hla -@@ -thread -p:temp -obj:temp -x:tStrAlloc.exe tStrAlloc
	tStrAlloc.exe

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
