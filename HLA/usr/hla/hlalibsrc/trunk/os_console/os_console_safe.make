/usr/hla/hlalibsrc/trunk/os_console_safe.a: \
	con_peekkey_safe.o \
	con_readkey_safe.o \
	con_insertLines_safe.o \
	con_insertLine_safe.o \
	con_deleteChar_safe.o \
	con_deleteChars_safe.o \
	con_nup_safe.o \
	con_utoa_safe.o \
	con_gotoxy_safe.o \
	con_insertChar_safe.o \
	con_down_safe.o \
	con_testkey_safe.o \
	con_scrollDn_safe.o \
	con_saveCursor_safe.o \
	con_left_safe.o \
	con_up_safe.o \
	con_deleteLines_safe.o \
	con_insertChars_safe.o \
	con_home_safe.o \
	con_clrln_safe.o \
	con_clreoscrn_safe.o \
	con_scrollUp_safe.o \
	con_clrtoeoln_safe.o \
	con_deleteLine_safe.o \
	con_setAttrs_safe.o \
	con_nright_safe.o \
	con_ndown_safe.o \
	con_right_safe.o \
	con_clrtoboln_safe.o \
	con_clrboscrn_safe.o \
	con_nleft_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		con_peekkey_safe.o \
		con_readkey_safe.o \
		con_insertLines_safe.o \
		con_insertLine_safe.o \
		con_deleteChar_safe.o \
		con_deleteChars_safe.o \
		con_nup_safe.o \
		con_utoa_safe.o \
		con_gotoxy_safe.o \
		con_insertChar_safe.o \
		con_down_safe.o \
		con_testkey_safe.o \
		con_scrollDn_safe.o \
		con_saveCursor_safe.o \
		con_left_safe.o \
		con_up_safe.o \
		con_deleteLines_safe.o \
		con_insertChars_safe.o \
		con_home_safe.o \
		con_clrln_safe.o \
		con_clreoscrn_safe.o \
		con_scrollUp_safe.o \
		con_clrtoeoln_safe.o \
		con_deleteLine_safe.o \
		con_setAttrs_safe.o \
		con_nright_safe.o \
		con_ndown_safe.o \
		con_right_safe.o \
		con_clrtoboln_safe.o \
		con_clrboscrn_safe.o \
		con_nleft_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

con_peekkey_safe.o: con_peekkey.hla \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:con_peekkey_safe  con_peekkey


con_readkey_safe.o: con_readkey.hla \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:con_readkey_safe  con_readkey


con_insertLines_safe.o: con_insertLines.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_insertLines_safe  con_insertLines


con_insertLine_safe.o: con_insertLine.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_insertLine_safe  con_insertLine


con_deleteChar_safe.o: con_deleteChar.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_deleteChar_safe  con_deleteChar


con_deleteChars_safe.o: con_deleteChars.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_deleteChars_safe  con_deleteChars


con_nup_safe.o: con_nup.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_nup_safe  con_nup


con_utoa_safe.o: con_utoa.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:con_utoa_safe  con_utoa


con_gotoxy_safe.o: con_gotoxy.hla \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:con_gotoxy_safe  con_gotoxy


con_insertChar_safe.o: con_insertChar.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_insertChar_safe  con_insertChar


con_down_safe.o: con_down.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_down_safe  con_down


con_testkey_safe.o: con_testkey.hla \
	/usr/hla/include/stdin.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/excepts.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:con_testkey_safe  con_testkey


con_scrollDn_safe.o: con_scrollDn.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_scrollDn_safe  con_scrollDn


con_saveCursor_safe.o: con_saveCursor.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_saveCursor_safe  con_saveCursor


con_left_safe.o: con_left.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_left_safe  con_left


con_up_safe.o: con_up.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_up_safe  con_up


con_deleteLines_safe.o: con_deleteLines.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_deleteLines_safe  con_deleteLines


con_insertChars_safe.o: con_insertChars.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_insertChars_safe  con_insertChars


con_home_safe.o: con_home.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_home_safe  con_home


con_clrln_safe.o: con_clrln.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_clrln_safe  con_clrln


con_clreoscrn_safe.o: con_clreoscrn.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_clreoscrn_safe  con_clreoscrn


con_scrollUp_safe.o: con_scrollUp.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_scrollUp_safe  con_scrollUp


con_clrtoeoln_safe.o: con_clrtoeoln.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_clrtoeoln_safe  con_clrtoeoln


con_deleteLine_safe.o: con_deleteLine.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_deleteLine_safe  con_deleteLine


con_setAttrs_safe.o: con_setAttrs.hla \
	/usr/hla/include/w.hhf \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_setAttrs_safe  con_setAttrs


con_nright_safe.o: con_nright.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_nright_safe  con_nright


con_ndown_safe.o: con_ndown.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_ndown_safe  con_ndown


con_right_safe.o: con_right.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_right_safe  con_right


con_clrtoboln_safe.o: con_clrtoboln.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_clrtoboln_safe  con_clrtoboln


con_clrboscrn_safe.o: con_clrboscrn.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_clrboscrn_safe  con_clrboscrn


con_nleft_safe.o: con_nleft.hla \
	/usr/hla/include/stdout.hhf \
	/usr/hla/include/console.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:con_nleft_safe  con_nleft




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

