/usr/hla/hlalibsrc/trunk/rpc_safe.a: \
	rpcData_safe.o \
	rpcSend_safe.o \
	rpcGet_safe.o \
	rpcClientThread_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		rpcData_safe.o \
		rpcSend_safe.o \
		rpcGet_safe.o \
		rpcClientThread_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

rpcData_safe.o: rpcData.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/patterns.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/env.hhf \
	/usr/hla/include/stdlib.hhf \
	/usr/hla/include/dtClass.hhf \
	/usr/hla/include/misctypes.hhf \
	/usr/hla/include/tables.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/mmap.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/fileclass.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/rpc.hhf \
	/usr/hla/include/sockets.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/math.hhf \
	/usr/hla/include/blobs.hhf \
	/usr/hla/include/stdlibdata.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/rand.hhf \
	/usr/hla/include/x86.hhf \
	/usr/hla/include/coroutines.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/stderr.hhf \
	/usr/hla/include/timer.hhf \

	hla -thread -c -p:temp -b:rpcData_safe  rpcData


rpcSend_safe.o: rpcSend.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/patterns.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/env.hhf \
	/usr/hla/include/stdlib.hhf \
	/usr/hla/include/dtClass.hhf \
	/usr/hla/include/misctypes.hhf \
	/usr/hla/include/tables.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/mmap.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/fileclass.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/rpc.hhf \
	/usr/hla/include/sockets.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/math.hhf \
	/usr/hla/include/blobs.hhf \
	/usr/hla/include/stdlibdata.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/rand.hhf \
	/usr/hla/include/x86.hhf \
	/usr/hla/include/coroutines.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/filesys.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/lists.hhf \
	/usr/hla/include/stderr.hhf \
	/usr/hla/include/timer.hhf \

	hla -thread -c -p:temp -b:rpcSend_safe  rpcSend


rpcGet_safe.o: rpcGet.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/rpc.hhf \
	/usr/hla/include/sockets.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/blobs.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:rpcGet_safe  rpcGet


rpcClientThread_safe.o: rpcClientThread.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/fileio.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/rpc.hhf \
	/usr/hla/include/sockets.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/blobs.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:rpcClientThread_safe  rpcClientThread




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

