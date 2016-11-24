/usr/hla/hlalibsrc/trunk/args.a: \
	arg_a_cmdln.o \
	arg_globalOptions.o \
	arg_a_argv.o \
	arg_localOptions.o \
	arg_delete.o \
	arg_destroy.o \
	arg_argc.o \
	arg_args.o \
	arg_argv.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		arg_a_cmdln.o \
		arg_globalOptions.o \
		arg_a_argv.o \
		arg_localOptions.o \
		arg_delete.o \
		arg_destroy.o \
		arg_argc.o \
		arg_args.o \
		arg_argv.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

arg_a_cmdln.o: arg_a_cmdln.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/buf.hhf \
	../include/osargs.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  arg_a_cmdln


arg_globalOptions.o: arg_globalOptions.hla \
	/usr/hla/include/cstdlib.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  arg_globalOptions


arg_a_argv.o: arg_a_argv.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/buf.hhf \
	../include/osargs.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  arg_a_argv


arg_localOptions.o: arg_localOptions.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  arg_localOptions


arg_delete.o: arg_delete.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  arg_delete


arg_destroy.o: arg_destroy.hla \
	/usr/hla/include/cstdlib.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  arg_destroy


arg_argc.o: arg_argc.hla \
	/usr/hla/include/cstdlib.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  arg_argc


arg_args.o: arg_args.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/buf.hhf \
	../include/osargs.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  arg_args


arg_argv.o: arg_argv.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  arg_argv




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

