/usr/hla/hlalibsrc/trunk/args_safe.a: \
	arg_a_cmdln_safe.o \
	arg_globalOptions_safe.o \
	arg_a_argv_safe.o \
	arg_localOptions_safe.o \
	arg_delete_safe.o \
	arg_destroy_safe.o \
	arg_argc_safe.o \
	arg_args_safe.o \
	arg_argv_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		arg_a_cmdln_safe.o \
		arg_globalOptions_safe.o \
		arg_a_argv_safe.o \
		arg_localOptions_safe.o \
		arg_delete_safe.o \
		arg_destroy_safe.o \
		arg_argc_safe.o \
		arg_args_safe.o \
		arg_argv_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

arg_a_cmdln_safe.o: arg_a_cmdln.hla \
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

	hla -thread -c -p:temp -b:arg_a_cmdln_safe  arg_a_cmdln


arg_globalOptions_safe.o: arg_globalOptions.hla \
	/usr/hla/include/cstdlib.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:arg_globalOptions_safe  arg_globalOptions


arg_a_argv_safe.o: arg_a_argv.hla \
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

	hla -thread -c -p:temp -b:arg_a_argv_safe  arg_a_argv


arg_localOptions_safe.o: arg_localOptions.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:arg_localOptions_safe  arg_localOptions


arg_delete_safe.o: arg_delete.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:arg_delete_safe  arg_delete


arg_destroy_safe.o: arg_destroy.hla \
	/usr/hla/include/cstdlib.hhf \
	../include/osargs.hhf \
	/usr/hla/include/memory.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:arg_destroy_safe  arg_destroy


arg_argc_safe.o: arg_argc.hla \
	/usr/hla/include/cstdlib.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:arg_argc_safe  arg_argc


arg_args_safe.o: arg_args.hla \
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

	hla -thread -c -p:temp -b:arg_args_safe  arg_args


arg_argv_safe.o: arg_argv.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	../include/osargs.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:arg_argv_safe  arg_argv




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

