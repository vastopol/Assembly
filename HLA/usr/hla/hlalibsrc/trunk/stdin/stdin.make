/usr/hla/hlalibsrc/trunk/stdin.a: \
	si_getu128.o \
	si_geth8.o \
	si_geti8.o \
	si_peekc.o \
	si_geth128.o \
	si__geti_.o \
	si_getu8.o \
	si_getc.o \
	si_getf.o \
	si_gets.o \
	si_readln.o \
	si_a_gets.o \
	si__getu_.o \
	si__getx_.o \
	si_eoln.o \
	si_flushinput.o \
	si_getu16.o \
	si_getu32.o \
	si_getu64.o \
	si_geth16.o \
	si_geth32.o \
	si_geth64.o \
	si_stdinvars.o \
	si_geti128.o \
	si_geti16.o \
	si_eoln2.o \
	si_geti32.o \
	si_geti64.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		si_getu128.o \
		si_geth8.o \
		si_geti8.o \
		si_peekc.o \
		si_geth128.o \
		si__geti_.o \
		si_getu8.o \
		si_getc.o \
		si_getf.o \
		si_gets.o \
		si_readln.o \
		si_a_gets.o \
		si__getu_.o \
		si__getx_.o \
		si_eoln.o \
		si_flushinput.o \
		si_getu16.o \
		si_getu32.o \
		si_getu64.o \
		si_geth16.o \
		si_geth32.o \
		si_geth64.o \
		si_stdinvars.o \
		si_geti128.o \
		si_geti16.o \
		si_eoln2.o \
		si_geti32.o \
		si_geti64.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

si_getu128.o: si_getu128.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_getu128


si_geth8.o: si_geth8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geth8


si_geti8.o: si_geti8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geti8


si_peekc.o: si_peekc.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_peekc


si_geth128.o: si_geth128.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/stdlibdata.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geth128


si__geti_.o: si__geti_.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si__geti_


si_getu8.o: si_getu8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_getu8


si_getc.o: si_getc.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_getc


si_getf.o: si_getf.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_getf


si_gets.o: si_gets.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_gets


si_readln.o: si_readln.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_readln


si_a_gets.o: si_a_gets.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_a_gets


si__getu_.o: si__getu_.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si__getu_


si__getx_.o: si__getx_.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/stdlibdata.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si__getx_


si_eoln.o: si_eoln.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_eoln


si_flushinput.o: si_flushinput.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_flushinput


si_getu16.o: si_getu16.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_getu16


si_getu32.o: si_getu32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_getu32


si_getu64.o: si_getu64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_getu64


si_geth16.o: si_geth16.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geth16


si_geth32.o: si_geth32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geth32


si_geth64.o: si_geth64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geth64


si_stdinvars.o: si_stdinvars.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_stdinvars


si_geti128.o: si_geti128.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geti128


si_geti16.o: si_geti16.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geti16


si_eoln2.o: si_eoln2.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_eoln2


si_geti32.o: si_geti32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geti32


si_geti64.o: si_geti64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	../include/stdinunit.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  si_geti64




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

