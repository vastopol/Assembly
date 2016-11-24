/usr/hla/hlalibsrc/trunk/random_safe.a: \
	rand_uniform_safe.o \
	rand_range_safe.o \
	rand_random_safe.o \
	rand_urange_safe.o \
	rand_deal_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		rand_uniform_safe.o \
		rand_range_safe.o \
		rand_random_safe.o \
		rand_urange_safe.o \
		rand_deal_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

rand_uniform_safe.o: rand_uniform.hla \
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

	hla -thread -c -p:temp -b:rand_uniform_safe  rand_uniform


rand_range_safe.o: rand_range.hla \
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

	hla -thread -c -p:temp -b:rand_range_safe  rand_range


rand_random_safe.o: rand_random.hla \
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

	hla -thread -c -p:temp -b:rand_random_safe  rand_random


rand_urange_safe.o: rand_urange.hla \
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

	hla -thread -c -p:temp -b:rand_urange_safe  rand_urange


rand_deal_safe.o: rand_deal.hla \
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

	hla -thread -c -p:temp -b:rand_deal_safe  rand_deal




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

