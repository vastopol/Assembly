/usr/hla/hlalibsrc/trunk/chars.a: \
	ch_isgraphic.o \
	ch_isascii.o \
	ch_isspace.o \
	ch_isalphanum.o \
	ch_isxdigit.o \
	ch_isdigit.o \
	ch_toupper.o \
	ch_isctrl.o \
	ch_isupper.o \
	ch_tolower.o \
	ch_isalpha.o \
	ch_islower.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		ch_isgraphic.o \
		ch_isascii.o \
		ch_isspace.o \
		ch_isalphanum.o \
		ch_isxdigit.o \
		ch_isdigit.o \
		ch_toupper.o \
		ch_isctrl.o \
		ch_isupper.o \
		ch_tolower.o \
		ch_isalpha.o \
		ch_islower.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

ch_isgraphic.o: ch_isgraphic.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_isgraphic


ch_isascii.o: ch_isascii.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_isascii


ch_isspace.o: ch_isspace.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_isspace


ch_isalphanum.o: ch_isalphanum.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_isalphanum


ch_isxdigit.o: ch_isxdigit.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_isxdigit


ch_isdigit.o: ch_isdigit.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_isdigit


ch_toupper.o: ch_toupper.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_toupper


ch_isctrl.o: ch_isctrl.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_isctrl


ch_isupper.o: ch_isupper.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_isupper


ch_tolower.o: ch_tolower.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_tolower


ch_isalpha.o: ch_isalpha.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_isalpha


ch_islower.o: ch_islower.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ch_islower




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

