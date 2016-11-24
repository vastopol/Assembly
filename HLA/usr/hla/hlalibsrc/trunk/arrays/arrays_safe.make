/usr/hla/hlalibsrc/trunk/arrays_safe.a: \
	arrays_rtnEachElementR32_safe.o \
	array_rtnEachElement16_safe.o \
	array_rtnEachElementR64_safe.o \
	array_rtnEachElementR80_safe.o \
	array_rtnEachElement1_safe.o \
	array_rtnEachElement2_safe.o \
	array_rtnEachElement4_safe.o \
	array_rtnEachElement8_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		arrays_rtnEachElementR32_safe.o \
		array_rtnEachElement16_safe.o \
		array_rtnEachElementR64_safe.o \
		array_rtnEachElementR80_safe.o \
		array_rtnEachElement1_safe.o \
		array_rtnEachElement2_safe.o \
		array_rtnEachElement4_safe.o \
		array_rtnEachElement8_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

arrays_rtnEachElementR32_safe.o: arrays_rtnEachElementR32.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:arrays_rtnEachElementR32_safe  arrays_rtnEachElementR32


array_rtnEachElement16_safe.o: array_rtnEachElement16.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:array_rtnEachElement16_safe  array_rtnEachElement16


array_rtnEachElementR64_safe.o: array_rtnEachElementR64.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:array_rtnEachElementR64_safe  array_rtnEachElementR64


array_rtnEachElementR80_safe.o: array_rtnEachElementR80.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:array_rtnEachElementR80_safe  array_rtnEachElementR80


array_rtnEachElement1_safe.o: array_rtnEachElement1.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:array_rtnEachElement1_safe  array_rtnEachElement1


array_rtnEachElement2_safe.o: array_rtnEachElement2.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:array_rtnEachElement2_safe  array_rtnEachElement2


array_rtnEachElement4_safe.o: array_rtnEachElement4.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:array_rtnEachElement4_safe  array_rtnEachElement4


array_rtnEachElement8_safe.o: array_rtnEachElement8.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:array_rtnEachElement8_safe  array_rtnEachElement8




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

