/usr/hla/hlalibsrc/trunk/bits.a: \
	bit_merge16.o \
	bit_merge32.o \
	bit_merge8.o \
	bit_distribute.o \
	bit_reverse16.o \
	bit_nibbles8.o \
	bit_reverse32.o \
	bit_reverse8.o \
	bit_nibbles16.o \
	bit_nibbles32.o \
	bit_coalesce.o \
	bit_cnt.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		bit_merge16.o \
		bit_merge32.o \
		bit_merge8.o \
		bit_distribute.o \
		bit_reverse16.o \
		bit_nibbles8.o \
		bit_reverse32.o \
		bit_reverse8.o \
		bit_nibbles16.o \
		bit_nibbles32.o \
		bit_coalesce.o \
		bit_cnt.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

bit_merge16.o: bit_merge16.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_merge16


bit_merge32.o: bit_merge32.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_merge32


bit_merge8.o: bit_merge8.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_merge8


bit_distribute.o: bit_distribute.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_distribute


bit_reverse16.o: bit_reverse16.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_reverse16


bit_nibbles8.o: bit_nibbles8.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_nibbles8


bit_reverse32.o: bit_reverse32.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_reverse32


bit_reverse8.o: bit_reverse8.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_reverse8


bit_nibbles16.o: bit_nibbles16.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_nibbles16


bit_nibbles32.o: bit_nibbles32.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_nibbles32


bit_coalesce.o: bit_coalesce.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_coalesce


bit_cnt.o: bit_cnt.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  bit_cnt




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

