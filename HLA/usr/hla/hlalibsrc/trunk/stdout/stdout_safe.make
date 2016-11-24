/usr/hla/hlalibsrc/trunk/stdout_safe.a: \
	so_puth64_safe.o \
	so_puti16size_safe.o \
	so_puth80_safe.o \
	so_putu128size_safe.o \
	so_puth64Size_safe.o \
	so_puti16_safe.o \
	so_puth8size_safe.o \
	so_puti32_safe.o \
	so_newln_safe.o \
	so_puth128size_safe.o \
	so_puti64_safe.o \
	so_putu128_safe.o \
	so_puti32size_safe.o \
	so_write_safe.o \
	so_puti128size_safe.o \
	stdoutvars_safe.o \
	so_puth16size_safe.o \
	so_puth80Size_safe.o \
	so_puth128_safe.o \
	so_puti8size_safe.o \
	so_putu8size_safe.o \
	so_putr32_safe.o \
	so_puth8_safe.o \
	so_putr64_safe.o \
	so_puti8_safe.o \
	so_putr80_safe.o \
	so_puth32size_safe.o \
	so_pute32_safe.o \
	so_putzSize_safe.o \
	so_pute64_safe.o \
	so_pute80_safe.o \
	so_putu8_safe.o \
	so_putbool_safe.o \
	so_puttb_safe.o \
	so_putb_safe.o \
	so_putc_safe.o \
	so_putd_safe.o \
	so_putl_safe.o \
	so_putq_safe.o \
	so_puts_safe.o \
	so_putw_safe.o \
	so_putz_safe.o \
	so_putbin8_safe.o \
	so_putcset_safe.o \
	so_putu16size_safe.o \
	so_puti64Size_safe.o \
	so_putu64size_safe.o \
	so_putu16_safe.o \
	so_putu32_safe.o \
	so_putu64_safe.o \
	so_puti128_safe.o \
	so_puth16_safe.o \
	so_putu32size_safe.o \
	so_puth32_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		so_puth64_safe.o \
		so_puti16size_safe.o \
		so_puth80_safe.o \
		so_putu128size_safe.o \
		so_puth64Size_safe.o \
		so_puti16_safe.o \
		so_puth8size_safe.o \
		so_puti32_safe.o \
		so_newln_safe.o \
		so_puth128size_safe.o \
		so_puti64_safe.o \
		so_putu128_safe.o \
		so_puti32size_safe.o \
		so_write_safe.o \
		so_puti128size_safe.o \
		stdoutvars_safe.o \
		so_puth16size_safe.o \
		so_puth80Size_safe.o \
		so_puth128_safe.o \
		so_puti8size_safe.o \
		so_putu8size_safe.o \
		so_putr32_safe.o \
		so_puth8_safe.o \
		so_putr64_safe.o \
		so_puti8_safe.o \
		so_putr80_safe.o \
		so_puth32size_safe.o \
		so_pute32_safe.o \
		so_putzSize_safe.o \
		so_pute64_safe.o \
		so_pute80_safe.o \
		so_putu8_safe.o \
		so_putbool_safe.o \
		so_puttb_safe.o \
		so_putb_safe.o \
		so_putc_safe.o \
		so_putd_safe.o \
		so_putl_safe.o \
		so_putq_safe.o \
		so_puts_safe.o \
		so_putw_safe.o \
		so_putz_safe.o \
		so_putbin8_safe.o \
		so_putcset_safe.o \
		so_putu16size_safe.o \
		so_puti64Size_safe.o \
		so_putu64size_safe.o \
		so_putu16_safe.o \
		so_putu32_safe.o \
		so_putu64_safe.o \
		so_puti128_safe.o \
		so_puth16_safe.o \
		so_putu32size_safe.o \
		so_puth32_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

so_puth64_safe.o: so_puth64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth64_safe  so_puth64


so_puti16size_safe.o: so_puti16size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti16size_safe  so_puti16size


so_puth80_safe.o: so_puth80.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth80_safe  so_puth80


so_putu128size_safe.o: so_putu128size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu128size_safe  so_putu128size


so_puth64Size_safe.o: so_puth64Size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth64Size_safe  so_puth64Size


so_puti16_safe.o: so_puti16.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti16_safe  so_puti16


so_puth8size_safe.o: so_puth8size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth8size_safe  so_puth8size


so_puti32_safe.o: so_puti32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti32_safe  so_puti32


so_newln_safe.o: so_newln.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_newln_safe  so_newln


so_puth128size_safe.o: so_puth128size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth128size_safe  so_puth128size


so_puti64_safe.o: so_puti64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti64_safe  so_puti64


so_putu128_safe.o: so_putu128.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu128_safe  so_putu128


so_puti32size_safe.o: so_puti32size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti32size_safe  so_puti32size


so_write_safe.o: so_write.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_write_safe  so_write


so_puti128size_safe.o: so_puti128size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti128size_safe  so_puti128size


stdoutvars_safe.o: stdoutvars.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:stdoutvars_safe  stdoutvars


so_puth16size_safe.o: so_puth16size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth16size_safe  so_puth16size


so_puth80Size_safe.o: so_puth80Size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth80Size_safe  so_puth80Size


so_puth128_safe.o: so_puth128.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth128_safe  so_puth128


so_puti8size_safe.o: so_puti8size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti8size_safe  so_puti8size


so_putu8size_safe.o: so_putu8size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu8size_safe  so_putu8size


so_putr32_safe.o: so_putr32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putr32_safe  so_putr32


so_puth8_safe.o: so_puth8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth8_safe  so_puth8


so_putr64_safe.o: so_putr64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putr64_safe  so_putr64


so_puti8_safe.o: so_puti8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti8_safe  so_puti8


so_putr80_safe.o: so_putr80.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putr80_safe  so_putr80


so_puth32size_safe.o: so_puth32size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth32size_safe  so_puth32size


so_pute32_safe.o: so_pute32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_pute32_safe  so_pute32


so_putzSize_safe.o: so_putzSize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putzSize_safe  so_putzSize


so_pute64_safe.o: so_pute64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_pute64_safe  so_pute64


so_pute80_safe.o: so_pute80.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_pute80_safe  so_pute80


so_putu8_safe.o: so_putu8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu8_safe  so_putu8


so_putbool_safe.o: so_putbool.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putbool_safe  so_putbool


so_puttb_safe.o: so_puttb.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puttb_safe  so_puttb


so_putb_safe.o: so_putb.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putb_safe  so_putb


so_putc_safe.o: so_putc.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putc_safe  so_putc


so_putd_safe.o: so_putd.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putd_safe  so_putd


so_putl_safe.o: so_putl.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putl_safe  so_putl


so_putq_safe.o: so_putq.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putq_safe  so_putq


so_puts_safe.o: so_puts.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puts_safe  so_puts


so_putw_safe.o: so_putw.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putw_safe  so_putw


so_putz_safe.o: so_putz.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putz_safe  so_putz


so_putbin8_safe.o: so_putbin8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putbin8_safe  so_putbin8


so_putcset_safe.o: so_putcset.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putcset_safe  so_putcset


so_putu16size_safe.o: so_putu16size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu16size_safe  so_putu16size


so_puti64Size_safe.o: so_puti64Size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti64Size_safe  so_puti64Size


so_putu64size_safe.o: so_putu64size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu64size_safe  so_putu64size


so_putu16_safe.o: so_putu16.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu16_safe  so_putu16


so_putu32_safe.o: so_putu32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu32_safe  so_putu32


so_putu64_safe.o: so_putu64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu64_safe  so_putu64


so_puti128_safe.o: so_puti128.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puti128_safe  so_puti128


so_puth16_safe.o: so_puth16.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth16_safe  so_puth16


so_putu32size_safe.o: so_putu32size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_putu32size_safe  so_putu32size


so_puth32_safe.o: so_puth32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	../include/stdoutunit.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:so_puth32_safe  so_puth32




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

