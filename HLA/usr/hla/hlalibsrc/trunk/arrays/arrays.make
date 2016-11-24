/usr/hla/hlalibsrc/trunk/arrays.a: \
	arrays_rtnEachElementR32.o \
	array_rtnEachElement16.o \
	array_rtnEachElementR64.o \
	array_rtnEachElementR80.o \
	array_rtnEachElement1.o \
	array_rtnEachElement2.o \
	array_rtnEachElement4.o \
	array_rtnEachElement8.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		arrays_rtnEachElementR32.o \
		array_rtnEachElement16.o \
		array_rtnEachElementR64.o \
		array_rtnEachElementR80.o \
		array_rtnEachElement1.o \
		array_rtnEachElement2.o \
		array_rtnEachElement4.o \
		array_rtnEachElement8.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

arrays_rtnEachElementR32.o: arrays_rtnEachElementR32.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  arrays_rtnEachElementR32


array_rtnEachElement16.o: array_rtnEachElement16.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  array_rtnEachElement16


array_rtnEachElementR64.o: array_rtnEachElementR64.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  array_rtnEachElementR64


array_rtnEachElementR80.o: array_rtnEachElementR80.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  array_rtnEachElementR80


array_rtnEachElement1.o: array_rtnEachElement1.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  array_rtnEachElement1


array_rtnEachElement2.o: array_rtnEachElement2.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  array_rtnEachElement2


array_rtnEachElement4.o: array_rtnEachElement4.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  array_rtnEachElement4


array_rtnEachElement8.o: array_rtnEachElement8.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  array_rtnEachElement8




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

