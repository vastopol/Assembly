/usr/hla/hlalibsrc/trunk/random.a: \
	rand_uniform.o \
	rand_range.o \
	rand_random.o \
	rand_urange.o \
	rand_deal.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		rand_uniform.o \
		rand_range.o \
		rand_random.o \
		rand_urange.o \
		rand_deal.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

rand_uniform.o: rand_uniform.hla \
	../include/win32.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/random.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/rand.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  rand_uniform


rand_range.o: rand_range.hla \
	../include/win32.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/random.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/rand.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  rand_range


rand_random.o: rand_random.hla \
	../include/win32.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/random.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/rand.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  rand_random


rand_urange.o: rand_urange.hla \
	../include/win32.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/random.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/rand.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  rand_urange


rand_deal.o: rand_deal.hla \
	../include/win32.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/random.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/rand.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  rand_deal




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

