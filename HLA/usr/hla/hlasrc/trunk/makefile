# make				-- generates HLA compiler
# make clean		-- deletes unnecessary OBJ and EXE files.

release:  hlaparse hla
	cp hlaparse /usr/hla/hlaparse
	cp hla /usr/hla/hla


hla: hla.o 
	gcc -static -static-libgcc -Dlinux_c -O2 -o hla hla.o

hla.o: hla.c ratc.h debug.h
	gcc -static -static-libgcc -Dlinux_c -O2 -c hla.c

hlaparse:	hlaparse.o lex.yy.o symbol.o hlautils.o output.o oututils.o coerce.o	\
			funcs.o  hlaasm.o hlabe.linux.o
			
	gcc -o hlaparse hlaparse.o lex.yy.o symbol.o hlautils.o output.o oututils.o 	\
			coerce.o funcs.o hlaasm.o hlabe.linux.o /usr/hla/hlalib/hlalib.a

hlaparse.o: hlaparse.c symbol.h ratc.h common.h enums.h debug.h output.h
	 gcc -static -static-libgcc -Dlinux_c -c -O2 -o hlaparse.o hlaparse.c

#hlaparse.c: hlaparse.bsn
#	bison -d -o hlaparse.c hlaparse.bsn

lex.yy.o: hla.flx hlaparse.c debug.h
	flex -8 -i hla.flx
	gcc -static -static-libgcc -Dlinux_c -c -o lex.yy.o lex.yy.c

lex.yy2.o: hla.flx hlaparse.c debug.h
	flex -8 -i hla.flx
	gcc -static -static-libgcc -Dlinux_c -c -O2 -o lex.yy2.o lex.yy.c

symbol.o: symbol.c symbol.h common.h ratc.h debug.h enums.h
	gcc -static -static-libgcc -Dlinux_c -O2 -c -o symbol.o symbol.c

hlautils.o: hlautils.c symbol.h common.h ratc.h debug.h enums.h
	gcc -static -static-libgcc -Dlinux_c -O2 -c -o hlautils.o hlautils.c

oututils.o: oututils.c symbol.h common.h ratc.h debug.h enums.h output.h
	gcc -static -static-libgcc -Dlinux_c -O2 -c -o oututils.o oututils.c

output.o: output.c symbol.h common.h ratc.h debug.h enums.h
	gcc -static -static-libgcc -Dlinux_c -O2 -c -o output.o output.c

coerce.o: coerce.c symbol.h common.h ratc.h debug.h enums.h
	gcc -static -static-libgcc -Dlinux_c -O2 -c -o coerce.o coerce.c

funcs.o: funcs.c symbol.h common.h ratc.h debug.h enums.h
	gcc -static -static-libgcc -Dlinux_c -O2 -c -o funcs.o funcs.c
	
hlaasm.o:hlaasm.gas
	as -o hlaasm.o hlaasm.gas	


hlabe.linux.o:hlabe.linux.gas
	as -o hlabe.linux.o hlabe.linux.gas

clean:
	rm -f *.o
	rm -f *.asm
	rm -f *.bak
	rm -f *.link
	rm -f *.inc
	rm -f lex.yy.c
	








	 
