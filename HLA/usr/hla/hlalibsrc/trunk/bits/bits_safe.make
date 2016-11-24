/usr/hla/hlalibsrc/trunk/bits_safe.a: \
	bit_merge16_safe.o \
	bit_merge32_safe.o \
	bit_merge8_safe.o \
	bit_distribute_safe.o \
	bit_reverse16_safe.o \
	bit_nibbles8_safe.o \
	bit_reverse32_safe.o \
	bit_reverse8_safe.o \
	bit_nibbles16_safe.o \
	bit_nibbles32_safe.o \
	bit_coalesce_safe.o \
	bit_cnt_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		bit_merge16_safe.o \
		bit_merge32_safe.o \
		bit_merge8_safe.o \
		bit_distribute_safe.o \
		bit_reverse16_safe.o \
		bit_nibbles8_safe.o \
		bit_reverse32_safe.o \
		bit_reverse8_safe.o \
		bit_nibbles16_safe.o \
		bit_nibbles32_safe.o \
		bit_coalesce_safe.o \
		bit_cnt_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

bit_merge16_safe.o: bit_merge16.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_merge16_safe  bit_merge16


bit_merge32_safe.o: bit_merge32.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_merge32_safe  bit_merge32


bit_merge8_safe.o: bit_merge8.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_merge8_safe  bit_merge8


bit_distribute_safe.o: bit_distribute.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_distribute_safe  bit_distribute


bit_reverse16_safe.o: bit_reverse16.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_reverse16_safe  bit_reverse16


bit_nibbles8_safe.o: bit_nibbles8.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_nibbles8_safe  bit_nibbles8


bit_reverse32_safe.o: bit_reverse32.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_reverse32_safe  bit_reverse32


bit_reverse8_safe.o: bit_reverse8.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_reverse8_safe  bit_reverse8


bit_nibbles16_safe.o: bit_nibbles16.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_nibbles16_safe  bit_nibbles16


bit_nibbles32_safe.o: bit_nibbles32.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_nibbles32_safe  bit_nibbles32


bit_coalesce_safe.o: bit_coalesce.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_coalesce_safe  bit_coalesce


bit_cnt_safe.o: bit_cnt.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:bit_cnt_safe  bit_cnt




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

