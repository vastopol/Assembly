/usr/hla/hlalibsrc/trunk/os_dependent_safe.a: \
	date_utcDate_safe.o \
	so_gethandle_safe.o \
	rand_randomize_safe.o \
	si_gethandle_safe.o \
	mem_blkAlloc_safe.o \
	arg_cmdln_safe.o \
	os_sleep_safe.o \
	os_bkgnd_safe.o \
	se_gethandle_safe.o \
	time_curtime_safe.o \
	si_read_safe.o \
	os_system_safe.o \
	date_today_safe.o \
	arg_BuildArgv_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		date_utcDate_safe.o \
		so_gethandle_safe.o \
		rand_randomize_safe.o \
		si_gethandle_safe.o \
		mem_blkAlloc_safe.o \
		arg_cmdln_safe.o \
		os_sleep_safe.o \
		os_bkgnd_safe.o \
		se_gethandle_safe.o \
		time_curtime_safe.o \
		si_read_safe.o \
		os_system_safe.o \
		date_today_safe.o \
		arg_BuildArgv_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

date_utcDate_safe.o: date_utcDate.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:date_utcDate_safe  date_utcDate


so_gethandle_safe.o: so_gethandle.hla \
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

	hla -thread -c -p:temp -b:so_gethandle_safe  so_gethandle


rand_randomize_safe.o: rand_randomize.hla \
	../include/win32.hhf \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	../include/random.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	../include/thread_private.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/rand.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:rand_randomize_safe  rand_randomize


si_gethandle_safe.o: si_gethandle.hla \
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

	hla -thread -c -p:temp -b:si_gethandle_safe  si_gethandle


mem_blkAlloc_safe.o: mem_blkAlloc.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	../include/thread_private.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	../include/mem.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:mem_blkAlloc_safe  mem_blkAlloc


arg_cmdln_safe.o: arg_cmdln.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/conv.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	../include/osargs.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:arg_cmdln_safe  arg_cmdln


os_sleep_safe.o: os_sleep.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
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
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/sleep.hhf \

	hla -thread -c -p:temp -b:os_sleep_safe  os_sleep


os_bkgnd_safe.o: os_bkgnd.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -thread -c -p:temp -b:os_bkgnd_safe  os_bkgnd


se_gethandle_safe.o: se_gethandle.hla \
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

	hla -thread -c -p:temp -b:se_gethandle_safe  se_gethandle


time_curtime_safe.o: time_curtime.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:time_curtime_safe  time_curtime


si_read_safe.o: si_read.hla \
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

	hla -thread -c -p:temp -b:si_read_safe  si_read


os_system_safe.o: os_system.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/stderr.hhf \

	hla -thread -c -p:temp -b:os_system_safe  os_system


date_today_safe.o: date_today.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/w.hhf \
	/usr/hla/include/mac.hhf \
	/usr/hla/include/linux.hhf \
	/usr/hla/include/bsd.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:date_today_safe  date_today


arg_BuildArgv_safe.o: arg_BuildArgv.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/buf.hhf \
	../include/osargs.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:arg_BuildArgv_safe  arg_BuildArgv




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

