/usr/hla/hlalibsrc/trunk/os_timer.a: \
	timer.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		timer.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

timer.o: timer.hla \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/timer.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  timer




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

