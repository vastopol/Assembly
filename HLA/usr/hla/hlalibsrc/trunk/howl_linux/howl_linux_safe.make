/usr/hla/hlalibsrc/trunk/howl_linux_safe.a: \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a



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
	delete .a
	delete .lib

