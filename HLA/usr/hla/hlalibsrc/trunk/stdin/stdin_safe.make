/usr/hla/hlalibsrc/trunk/stdin_safe.a: \
	si_getu128_safe.o \
	si_geth8_safe.o \
	si_geti8_safe.o \
	si_peekc_safe.o \
	si_geth128_safe.o \
	si__geti__safe.o \
	si_getu8_safe.o \
	si_getc_safe.o \
	si_getf_safe.o \
	si_gets_safe.o \
	si_readln_safe.o \
	si_a_gets_safe.o \
	si__getu__safe.o \
	si__getx__safe.o \
	si_eoln_safe.o \
	si_flushinput_safe.o \
	si_getu16_safe.o \
	si_getu32_safe.o \
	si_getu64_safe.o \
	si_geth16_safe.o \
	si_geth32_safe.o \
	si_geth64_safe.o \
	si_stdinvars_safe.o \
	si_geti128_safe.o \
	si_geti16_safe.o \
	si_eoln2_safe.o \
	si_geti32_safe.o \
	si_geti64_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		si_getu128_safe.o \
		si_geth8_safe.o \
		si_geti8_safe.o \
		si_peekc_safe.o \
		si_geth128_safe.o \
		si__geti__safe.o \
		si_getu8_safe.o \
		si_getc_safe.o \
		si_getf_safe.o \
		si_gets_safe.o \
		si_readln_safe.o \
		si_a_gets_safe.o \
		si__getu__safe.o \
		si__getx__safe.o \
		si_eoln_safe.o \
		si_flushinput_safe.o \
		si_getu16_safe.o \
		si_getu32_safe.o \
		si_getu64_safe.o \
		si_geth16_safe.o \
		si_geth32_safe.o \
		si_geth64_safe.o \
		si_stdinvars_safe.o \
		si_geti128_safe.o \
		si_geti16_safe.o \
		si_eoln2_safe.o \
		si_geti32_safe.o \
		si_geti64_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

si_getu128_safe.o: si_getu128.hla \
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

	hla -thread -c -p:temp -b:si_getu128_safe  si_getu128


si_geth8_safe.o: si_geth8.hla \
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

	hla -thread -c -p:temp -b:si_geth8_safe  si_geth8


si_geti8_safe.o: si_geti8.hla \
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

	hla -thread -c -p:temp -b:si_geti8_safe  si_geti8


si_peekc_safe.o: si_peekc.hla \
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

	hla -thread -c -p:temp -b:si_peekc_safe  si_peekc


si_geth128_safe.o: si_geth128.hla \
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

	hla -thread -c -p:temp -b:si_geth128_safe  si_geth128


si__geti__safe.o: si__geti_.hla \
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

	hla -thread -c -p:temp -b:si__geti__safe  si__geti_


si_getu8_safe.o: si_getu8.hla \
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

	hla -thread -c -p:temp -b:si_getu8_safe  si_getu8


si_getc_safe.o: si_getc.hla \
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

	hla -thread -c -p:temp -b:si_getc_safe  si_getc


si_getf_safe.o: si_getf.hla \
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

	hla -thread -c -p:temp -b:si_getf_safe  si_getf


si_gets_safe.o: si_gets.hla \
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

	hla -thread -c -p:temp -b:si_gets_safe  si_gets


si_readln_safe.o: si_readln.hla \
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

	hla -thread -c -p:temp -b:si_readln_safe  si_readln


si_a_gets_safe.o: si_a_gets.hla \
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

	hla -thread -c -p:temp -b:si_a_gets_safe  si_a_gets


si__getu__safe.o: si__getu_.hla \
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

	hla -thread -c -p:temp -b:si__getu__safe  si__getu_


si__getx__safe.o: si__getx_.hla \
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

	hla -thread -c -p:temp -b:si__getx__safe  si__getx_


si_eoln_safe.o: si_eoln.hla \
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

	hla -thread -c -p:temp -b:si_eoln_safe  si_eoln


si_flushinput_safe.o: si_flushinput.hla \
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

	hla -thread -c -p:temp -b:si_flushinput_safe  si_flushinput


si_getu16_safe.o: si_getu16.hla \
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

	hla -thread -c -p:temp -b:si_getu16_safe  si_getu16


si_getu32_safe.o: si_getu32.hla \
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

	hla -thread -c -p:temp -b:si_getu32_safe  si_getu32


si_getu64_safe.o: si_getu64.hla \
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

	hla -thread -c -p:temp -b:si_getu64_safe  si_getu64


si_geth16_safe.o: si_geth16.hla \
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

	hla -thread -c -p:temp -b:si_geth16_safe  si_geth16


si_geth32_safe.o: si_geth32.hla \
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

	hla -thread -c -p:temp -b:si_geth32_safe  si_geth32


si_geth64_safe.o: si_geth64.hla \
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

	hla -thread -c -p:temp -b:si_geth64_safe  si_geth64


si_stdinvars_safe.o: si_stdinvars.hla \
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

	hla -thread -c -p:temp -b:si_stdinvars_safe  si_stdinvars


si_geti128_safe.o: si_geti128.hla \
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

	hla -thread -c -p:temp -b:si_geti128_safe  si_geti128


si_geti16_safe.o: si_geti16.hla \
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

	hla -thread -c -p:temp -b:si_geti16_safe  si_geti16


si_eoln2_safe.o: si_eoln2.hla \
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

	hla -thread -c -p:temp -b:si_eoln2_safe  si_eoln2


si_geti32_safe.o: si_geti32.hla \
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

	hla -thread -c -p:temp -b:si_geti32_safe  si_geti32


si_geti64_safe.o: si_geti64.hla \
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

	hla -thread -c -p:temp -b:si_geti64_safe  si_geti64




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

