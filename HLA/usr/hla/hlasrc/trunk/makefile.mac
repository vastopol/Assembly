# make				-- generates HLA compiler
# make clean		-- deletes unnecessary OBJ and EXE files.

release:  hlaparse hla
	cp hlaparse /usr/hla/hlaparse
	cp hla /usr/hla/hla


hla: hla.o 
	gcc -march=i386 -m32 -DmacOS_c -O2 -o hla hla.o

hla.o: hla.c ratc.h debug.h
	gcc -march=i386 -m32 -DmacOS_c -O2 -c hla.c

hlaparse:	hlaparse.o lex.yy.o symbol.o hlautils.o output.o oututils.o coerce.o \
			funcs.o  hlaasm.o hlabe.o
	gcc -march=i386 -m32 -Xlinker -stack_size -Xlinker 0x1000000 -o hlaparse hlaparse.o lex.yy.o \
			symbol.o hlautils.o output.o oututils.o coerce.o funcs.o 			\
			hlaasm.o hlabe.o /usr/hla/hlalib/hlalib.a

hlaparse.o: hlaparse.c symbol.h ratc.h common.h enums.h debug.h output.h
	 gcc -march=i386 -m32 -DmacOS_c -c -O1 -o hlaparse.o hlaparse.c
#	 gcc -march=i386 -m32 -DmacOS_c -c -o hlaparse.o hlaparse.c

hlaparse.c: hlaparse.bsn
	bison -d -o hlaparse.c hlaparse.bsn

lex.yy.o: hla.flx  hlaparse.c debug.h
	flex -8 -i hla.flx
	gcc -march=i386 -m32 -DmacOS_c -c -o lex.yy.o lex.yy.c

lex.yy2.o: lex.yy.c hlaparse.c debug.h
#	flex -8 -i hla.flx
	gcc -march=i386 -m32 -DmacOS_c -c -O2 -o lex.yy2.o lex.yy.c

symbol.o: symbol.c symbol.h common.h ratc.h debug.h enums.h
	gcc -march=i386 -m32 -DmacOS_c -O2 -c -o symbol.o symbol.c

hlautils.o: hlautils.c symbol.h common.h ratc.h debug.h enums.h
	gcc -march=i386 -m32 -DmacOS_c -O2 -c -o hlautils.o hlautils.c

oututils.o: oututils.c symbol.h common.h ratc.h debug.h enums.h output.h
	gcc -march=i386 -m32 -DmacOS_c -O2 -c -o oututils.o oututils.c

output.o: output.c symbol.h common.h ratc.h debug.h enums.h
	gcc -march=i386 -m32 -DmacOS_c -O2 -c -o output.o output.c

coerce.o: coerce.c symbol.h common.h ratc.h debug.h enums.h
	gcc -march=i386 -m32 -DmacOS_c -O2 -c -o coerce.o coerce.c

funcs.o: funcs.c symbol.h common.h ratc.h debug.h enums.h
	gcc -march=i386 -m32 -DmacOS_c -O2 -c -o funcs.o funcs.c
	
hlaasm.o:hlaasm.gasx
	as -arch i386 -o hlaasm.o hlaasm.gasx

hlabe.o:hlabe.gasx
	as -arch i386 -o hlabe.o hlabe.gasx

	



clean:
	rm -f *.o
	rm -f *.asm
	rm -f *.bak
	rm -f *.link
	rm -f *.inc
	rm -f lex.yy.c
	








	 
