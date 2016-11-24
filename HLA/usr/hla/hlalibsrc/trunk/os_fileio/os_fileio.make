/usr/hla/hlalibsrc/trunk/os_fileio.a: \
	fileio_opennew.o \
	fileio_close.o \
	fileio_eof.o \
	fileio_position.o \
	fileio_newln.o \
	fileio_gets.o \
	fileio_write.o \
	fileio_seek.o \
	fileio_eoln.o \
	fileio_open.o \
	fileio_flush.o \
	fileio_truncate.o \
	fileio_read.o \
	fileio_readln.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		fileio_opennew.o \
		fileio_close.o \
		fileio_eof.o \
		fileio_position.o \
		fileio_newln.o \
		fileio_gets.o \
		fileio_write.o \
		fileio_seek.o \
		fileio_eoln.o \
		fileio_open.o \
		fileio_flush.o \
		fileio_truncate.o \
		fileio_read.o \
		fileio_readln.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

fileio_opennew.o: fileio_opennew.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_opennew


fileio_close.o: fileio_close.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_close


fileio_eof.o: fileio_eof.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_eof


fileio_position.o: fileio_position.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_position


fileio_newln.o: fileio_newln.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_newln


fileio_gets.o: fileio_gets.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/patterns.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/env.hhf \
	/usr/hla/include/stdlib.hhf \
	/usr/hla/include/dtClass.hhf \
	/usr/hla/include/misctypes.hhf \
	/usr/hla/include/tables.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/mmap.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/fileclass.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/math.hhf \
	/usr/hla/include/blobs.hhf \
	/usr/hla/include/stdlibdata.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/rand.hhf \
	/usr/hla/include/x86.hhf \
	/usr/hla/include/coroutines.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/stderr.hhf \
	/usr/hla/include/timer.hhf \

	hla -c -p:temp  fileio_gets


fileio_write.o: fileio_write.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_write


fileio_seek.o: fileio_seek.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_seek


fileio_eoln.o: fileio_eoln.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_eoln


fileio_open.o: fileio_open.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_open


fileio_flush.o: fileio_flush.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_flush


fileio_truncate.o: fileio_truncate.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_truncate


fileio_read.o: fileio_read.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_read


fileio_readln.o: fileio_readln.hla \
	/usr/hla/include/zstrings.hhf \
	../include/win32.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	../include/fileiounit.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  fileio_readln




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

