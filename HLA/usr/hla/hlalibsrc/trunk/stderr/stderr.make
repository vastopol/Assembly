/usr/hla/hlalibsrc/trunk/stderr.a: \
	stderrvars.o \
	se_puti64.o \
	se_puth128size.o \
	se_puth80size.o \
	se_puth8.o \
	se_puti8.o \
	se_putzSize.o \
	se_puti128size.o \
	se_putbool.o \
	se_putu16size.o \
	se_putb.o \
	se_putc.o \
	se_putd.o \
	se_putl.o \
	se_putq.o \
	se_puts.o \
	se_putw.o \
	se_putz.o \
	se_putbin8.o \
	se_putcset.o \
	se_putu8.o \
	se_putu64size.o \
	se_puttb.o \
	se_putr32.o \
	se_putcsize.o \
	se_putr64.o \
	se_putqsize.o \
	se_putr80.o \
	se_pute32.o \
	se_putu32size.o \
	se_putlsize.o \
	se_pute64.o \
	se_puti128.o \
	se_pute80.o \
	se_puti16size.o \
	se_putssize.o \
	se_puth8size.o \
	se_puti64size.o \
	se_puti32size.o \
	se_putu16.o \
	se_putu128.o \
	se_puttbsize.o \
	se_putbsize.o \
	se_putu32.o \
	se_puth16size.o \
	se_newln.o \
	se_putwsize.o \
	se_puti8size.o \
	se_putu64.o \
	se_puth16.o \
	se_putu8size.o \
	se_puth32.o \
	se_puth64size.o \
	se_puth128.o \
	se_putdsize.o \
	se_puth64.o \
	se_write.o \
	se_puth80.o \
	se_puti16.o \
	se_puth32size.o \
	se_putu128size.o \
	se_puti32.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		stderrvars.o \
		se_puti64.o \
		se_puth128size.o \
		se_puth80size.o \
		se_puth8.o \
		se_puti8.o \
		se_putzSize.o \
		se_puti128size.o \
		se_putbool.o \
		se_putu16size.o \
		se_putb.o \
		se_putc.o \
		se_putd.o \
		se_putl.o \
		se_putq.o \
		se_puts.o \
		se_putw.o \
		se_putz.o \
		se_putbin8.o \
		se_putcset.o \
		se_putu8.o \
		se_putu64size.o \
		se_puttb.o \
		se_putr32.o \
		se_putcsize.o \
		se_putr64.o \
		se_putqsize.o \
		se_putr80.o \
		se_pute32.o \
		se_putu32size.o \
		se_putlsize.o \
		se_pute64.o \
		se_puti128.o \
		se_pute80.o \
		se_puti16size.o \
		se_putssize.o \
		se_puth8size.o \
		se_puti64size.o \
		se_puti32size.o \
		se_putu16.o \
		se_putu128.o \
		se_puttbsize.o \
		se_putbsize.o \
		se_putu32.o \
		se_puth16size.o \
		se_newln.o \
		se_putwsize.o \
		se_puti8size.o \
		se_putu64.o \
		se_puth16.o \
		se_putu8size.o \
		se_puth32.o \
		se_puth64size.o \
		se_puth128.o \
		se_putdsize.o \
		se_puth64.o \
		se_write.o \
		se_puth80.o \
		se_puti16.o \
		se_puth32size.o \
		se_putu128size.o \
		se_puti32.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

stderrvars.o: stderrvars.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  stderrvars


se_puti64.o: se_puti64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti64


se_puth128size.o: se_puth128size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth128size


se_puth80size.o: se_puth80size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth80size


se_puth8.o: se_puth8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth8


se_puti8.o: se_puti8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti8


se_putzSize.o: se_putzSize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putzSize


se_puti128size.o: se_puti128size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti128size


se_putbool.o: se_putbool.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putbool


se_putu16size.o: se_putu16size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu16size


se_putb.o: se_putb.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putb


se_putc.o: se_putc.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putc


se_putd.o: se_putd.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putd


se_putl.o: se_putl.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putl


se_putq.o: se_putq.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putq


se_puts.o: se_puts.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puts


se_putw.o: se_putw.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putw


se_putz.o: se_putz.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putz


se_putbin8.o: se_putbin8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putbin8


se_putcset.o: se_putcset.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putcset


se_putu8.o: se_putu8.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu8


se_putu64size.o: se_putu64size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu64size


se_puttb.o: se_puttb.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puttb


se_putr32.o: se_putr32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putr32


se_putcsize.o: se_putcsize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putcsize


se_putr64.o: se_putr64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putr64


se_putqsize.o: se_putqsize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putqsize


se_putr80.o: se_putr80.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putr80


se_pute32.o: se_pute32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_pute32


se_putu32size.o: se_putu32size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu32size


se_putlsize.o: se_putlsize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putlsize


se_pute64.o: se_pute64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_pute64


se_puti128.o: se_puti128.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti128


se_pute80.o: se_pute80.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_pute80


se_puti16size.o: se_puti16size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti16size


se_putssize.o: se_putssize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putssize


se_puth8size.o: se_puth8size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth8size


se_puti64size.o: se_puti64size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti64size


se_puti32size.o: se_puti32size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti32size


se_putu16.o: se_putu16.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu16


se_putu128.o: se_putu128.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu128


se_puttbsize.o: se_puttbsize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puttbsize


se_putbsize.o: se_putbsize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putbsize


se_putu32.o: se_putu32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu32


se_puth16size.o: se_puth16size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth16size


se_newln.o: se_newln.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_newln


se_putwsize.o: se_putwsize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putwsize


se_puti8size.o: se_puti8size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti8size


se_putu64.o: se_putu64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu64


se_puth16.o: se_puth16.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth16


se_putu8size.o: se_putu8size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu8size


se_puth32.o: se_puth32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth32


se_puth64size.o: se_puth64size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth64size


se_puth128.o: se_puth128.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth128


se_putdsize.o: se_putdsize.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putdsize


se_puth64.o: se_puth64.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth64


se_write.o: se_write.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_write


se_puth80.o: se_puth80.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth80


se_puti16.o: se_puti16.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti16


se_puth32size.o: se_puth32size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puth32size


se_putu128size.o: se_putu128size.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_putu128size


se_puti32.o: se_puti32.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/stderrunit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -c -p:temp  se_puti32




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

