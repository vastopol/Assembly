all:
	echo OS_MAC test suite must be run manually from Mac OSX using
	echo the command "make macosx" from the test/os_mac subdirectory
	echo or the command "make macosxthread" from the test/os_mac subdirectory
	
thread:
	echo OS_MAC test suite must be run manually from Mac OSX using
	echo the command "make macosx" from the test/os_mac subdirectory
	echo or the command "make macosxthread" from the test/os_mac subdirectory
	
macosx:
	hla -@@ -p:temp -obj:temp -x:chdir.exe chdir.hla
	./chdir.exe
	
	hla -@@ -p:temp -obj:temp -x:dirents.exe dirents.hla
	./dirents.exe
	
	hla -@@ -p:temp -obj:temp -x:exec.exe exec.hla
	./exec.exe
	
	hla -@@ -p:temp -obj:temp -x:fileio.exe fileio.hla
	./fileio.exe
	
	hla -@@ -p:temp -obj:temp -x:gettimeofday.exe gettimeofday.hla
	./gettimeofday.exe
	
	hla -@@ -p:temp -obj:temp -x:mmap.exe mmap.hla
	./mmap.exe
	
	hla -@@ -p:temp -obj:temp -x:stat.exe stat.hla
	./stat.exe
	

	
macosxthread:
	hla -@@ -thread -p:temp -obj:temp -x:chdir.exe chdir.hla
	./chdir.exe
	
	hla -@@ -thread -p:temp -obj:temp -x:dirents.exe dirents.hla
	./dirents.exe
	
	hla -@@ -thread -p:temp -obj:temp -x:exec.exe exec.hla
	./exec.exe
	
	hla -@@ -thread -p:temp -obj:temp -x:fileio.exe fileio.hla
	./fileio.exe
	
	hla -@@ -thread -p:temp -obj:temp -x:gettimeofday.exe gettimeofday.hla
	./gettimeofday.exe
	
	hla -@@ -thread -p:temp -obj:temp -x:mmap.exe mmap.hla
	./mmap.exe
	
	hla -@@ -thread -p:temp -obj:temp -x:stat.exe stat.hla
	./stat.exe
	

clean:
	delete temp
	delete .inc
	delete .o
	delete .obj
	delete .link
	delete .exe
	delete .asm
	