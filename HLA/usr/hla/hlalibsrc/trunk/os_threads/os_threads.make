/usr/hla/hlalibsrc/trunk/os_threads.a: \
	hla_get_set_argc.o \
	hla_get_set_argv.o \
	hla_get_set_OutputUnderscores.o \
	threadCS.o \
	hla_get_set_ExceptionPtr.o \
	th_deleteEvent.o \
	th_waitForEvent.o \
	th_createEvent.o \
	th_create.o \
	th_deleteCriticalSection.o \
	hla_get_Delimiters.o \
	hla_get_set_CommandLine.o \
	th_waitSemaphore.o \
	th_leaveCriticalSection.o \
	th_getTLS.o \
	th_getThreadHandle.o \
	hla_get_set_NeedsCmdLn.o \
	th_createCriticalSection.o \
	hla_get_set_TimeFmt.o \
	th_setTLS.o \
	th_enterCriticalSection.o \
	th_releaseSemaphore.o \
	th_waitForEventTimeout.o \
	hla_get_set_DateSep.o \
	th_deleteSemaphore.o \
	hla_get_set_DateFmt.o \
	hla_setMainPgmCoroutinePtr.o \
	th_signalEvent.o \
	th_createTLS.o \
	th_createSemaphore.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		hla_get_set_argc.o \
		hla_get_set_argv.o \
		hla_get_set_OutputUnderscores.o \
		threadCS.o \
		hla_get_set_ExceptionPtr.o \
		th_deleteEvent.o \
		th_waitForEvent.o \
		th_createEvent.o \
		th_create.o \
		th_deleteCriticalSection.o \
		hla_get_Delimiters.o \
		hla_get_set_CommandLine.o \
		th_waitSemaphore.o \
		th_leaveCriticalSection.o \
		th_getTLS.o \
		th_getThreadHandle.o \
		hla_get_set_NeedsCmdLn.o \
		th_createCriticalSection.o \
		hla_get_set_TimeFmt.o \
		th_setTLS.o \
		th_enterCriticalSection.o \
		th_releaseSemaphore.o \
		th_waitForEventTimeout.o \
		hla_get_set_DateSep.o \
		th_deleteSemaphore.o \
		hla_get_set_DateFmt.o \
		hla_setMainPgmCoroutinePtr.o \
		th_signalEvent.o \
		th_createTLS.o \
		th_createSemaphore.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

hla_get_set_argc.o: hla_get_set_argc.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  hla_get_set_argc


hla_get_set_argv.o: hla_get_set_argv.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  hla_get_set_argv


hla_get_set_OutputUnderscores.o: hla_get_set_OutputUnderscores.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  hla_get_set_OutputUnderscores


threadCS.o: threadCS.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  threadCS


hla_get_set_ExceptionPtr.o: hla_get_set_ExceptionPtr.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  hla_get_set_ExceptionPtr


th_deleteEvent.o: th_deleteEvent.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_deleteEvent


th_waitForEvent.o: th_waitForEvent.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_waitForEvent


th_createEvent.o: th_createEvent.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_createEvent


th_create.o: th_create.hla \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	../include/datetime_private.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/sleep.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_create


th_deleteCriticalSection.o: th_deleteCriticalSection.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_deleteCriticalSection


hla_get_Delimiters.o: hla_get_Delimiters.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/conversions.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  hla_get_Delimiters


hla_get_set_CommandLine.o: hla_get_set_CommandLine.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  hla_get_set_CommandLine


th_waitSemaphore.o: th_waitSemaphore.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_waitSemaphore


th_leaveCriticalSection.o: th_leaveCriticalSection.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_leaveCriticalSection


th_getTLS.o: th_getTLS.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_getTLS


th_getThreadHandle.o: th_getThreadHandle.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_getThreadHandle


hla_get_set_NeedsCmdLn.o: hla_get_set_NeedsCmdLn.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  hla_get_set_NeedsCmdLn


th_createCriticalSection.o: th_createCriticalSection.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_createCriticalSection


hla_get_set_TimeFmt.o: hla_get_set_TimeFmt.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/datetime_private.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  hla_get_set_TimeFmt


th_setTLS.o: th_setTLS.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_setTLS


th_enterCriticalSection.o: th_enterCriticalSection.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_enterCriticalSection


th_releaseSemaphore.o: th_releaseSemaphore.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_releaseSemaphore


th_waitForEventTimeout.o: th_waitForEventTimeout.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/stdio.hhf \
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
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/arrays.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/mmap.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/fileclass.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/cset.hhf \
	/usr/hla/include/math.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/strings.hhf \
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

	hla -c -p:temp  th_waitForEventTimeout


hla_get_set_DateSep.o: hla_get_set_DateSep.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/datetime_private.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  hla_get_set_DateSep


th_deleteSemaphore.o: th_deleteSemaphore.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_deleteSemaphore


hla_get_set_DateFmt.o: hla_get_set_DateFmt.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/datetime_private.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  hla_get_set_DateFmt


hla_setMainPgmCoroutinePtr.o: hla_setMainPgmCoroutinePtr.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/coroutines.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  hla_setMainPgmCoroutinePtr


th_signalEvent.o: th_signalEvent.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_signalEvent


th_createTLS.o: th_createTLS.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_createTLS


th_createSemaphore.o: th_createSemaphore.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/threads.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	../include/thread_private.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	../include/osargs.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  th_createSemaphore




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

