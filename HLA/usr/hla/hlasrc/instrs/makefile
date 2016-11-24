all: clearScrn clean disasmCmp.exe hla\maketest.exe
	cd hla
	..\maketest
	make


hla\maketest.exe: maketest.hla
	hla -p:tmp -masm -source maketest.hla


disasmCmp.exe: disasmCmp.hla
	hla -p:tmp -masm -source disasmCmp

clearScrn:
	cls






clean: 
	delete tmp\*
	delete hla\*
	delete *.obj
	delete *.exe
	delete *.link
	delete *.pdb

	

	