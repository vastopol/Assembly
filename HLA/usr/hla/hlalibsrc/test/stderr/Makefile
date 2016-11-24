unittests:
	hla -@@ -p:temp -obj:temp -x:buildTestScript.exe buildTestScript
	buildTestScript.exe
	stderr.bat
	  
thread:
	hla -@@ -thread -p:temp -obj:temp -x:buildTestScript2.exe buildTestScript2
	buildTestScript2.exe
	stderr2.bat
	  
clean:
	delete temp
	delete .inc
	delete .o
	delete .obj
	delete .link
	delete .exe
	delete .asm
	delete .txt
	delete .pdb
	delete .ilk
	