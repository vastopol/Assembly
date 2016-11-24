/usr/hla/hlalibsrc/trunk/data_safe.a: \
	reverseData_safe.o \
	hexConvTbl_safe.o \
	daysFromMonth_safe.o \
	shortMonths_safe.o \
	alphacset_safe.o \
	_utoevars_safe.o \
	digitcset_safe.o \
	wscset_safe.o \
	hexDigitsData_safe.o \
	alphanumcset_safe.o \
	uppercasecset_safe.o \
	ctrlcset_safe.o \
	hexTbL_safe.o \
	CmdLnDelimiters_safe.o \
	hexCSData_safe.o \
	_utoethvars_safe.o \
	lowercasecset_safe.o \
	mergeData_safe.o \
	daysInMonth_safe.o \
	staticvars_safe.o \
	hexdigitscset_safe.o \
	graphiccset_safe.o \
	daysToMonth_safe.o \
	months_safe.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib_safe.a \
		reverseData_safe.o \
		hexConvTbl_safe.o \
		daysFromMonth_safe.o \
		shortMonths_safe.o \
		alphacset_safe.o \
		_utoevars_safe.o \
		digitcset_safe.o \
		wscset_safe.o \
		hexDigitsData_safe.o \
		alphanumcset_safe.o \
		uppercasecset_safe.o \
		ctrlcset_safe.o \
		hexTbL_safe.o \
		CmdLnDelimiters_safe.o \
		hexCSData_safe.o \
		_utoethvars_safe.o \
		lowercasecset_safe.o \
		mergeData_safe.o \
		daysInMonth_safe.o \
		staticvars_safe.o \
		hexdigitscset_safe.o \
		graphiccset_safe.o \
		daysToMonth_safe.o \
		months_safe.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib_safe.a

reverseData_safe.o: reverseData.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:reverseData_safe  reverseData


hexConvTbl_safe.o: hexConvTbl.hla \
	/usr/hla/include/stdlibdata.hhf \

	hla -thread -c -p:temp -b:hexConvTbl_safe  hexConvTbl


daysFromMonth_safe.o: daysFromMonth.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:daysFromMonth_safe  daysFromMonth


shortMonths_safe.o: shortMonths.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:shortMonths_safe  shortMonths


alphacset_safe.o: alphacset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:alphacset_safe  alphacset


_utoevars_safe.o: _utoevars.hla \
	../include/conversions.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:_utoevars_safe  _utoevars


digitcset_safe.o: digitcset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:digitcset_safe  digitcset


wscset_safe.o: wscset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:wscset_safe  wscset


hexDigitsData_safe.o: hexDigitsData.hla \
	/usr/hla/include/stdlibdata.hhf \

	hla -thread -c -p:temp -b:hexDigitsData_safe  hexDigitsData


alphanumcset_safe.o: alphanumcset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:alphanumcset_safe  alphanumcset


uppercasecset_safe.o: uppercasecset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:uppercasecset_safe  uppercasecset


ctrlcset_safe.o: ctrlcset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:ctrlcset_safe  ctrlcset


hexTbL_safe.o: hexTbL.hla \
	/usr/hla/include/stdlibdata.hhf \

	hla -thread -c -p:temp -b:hexTbL_safe  hexTbL


CmdLnDelimiters_safe.o: CmdLnDelimiters.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:CmdLnDelimiters_safe  CmdLnDelimiters


hexCSData_safe.o: hexCSData.hla \
	../include/conversions.hhf \
	/usr/hla/include/stdlibdata.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:hexCSData_safe  hexCSData


_utoethvars_safe.o: _utoethvars.hla \
	../include/conversions.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:_utoethvars_safe  _utoethvars


lowercasecset_safe.o: lowercasecset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:lowercasecset_safe  lowercasecset


mergeData_safe.o: mergeData.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:mergeData_safe  mergeData


daysInMonth_safe.o: daysInMonth.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:daysInMonth_safe  daysInMonth


staticvars_safe.o: staticvars.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/patterns.hhf \
	../include/pat.hhf \
	/usr/hla/include/buf.hhf \
	../include/osargs.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/args.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:staticvars_safe  staticvars


hexdigitscset_safe.o: hexdigitscset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:hexdigitscset_safe  hexdigitscset


graphiccset_safe.o: graphiccset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -thread -c -p:temp -b:graphiccset_safe  graphiccset


daysToMonth_safe.o: daysToMonth.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:daysToMonth_safe  daysToMonth


months_safe.o: months.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -thread -c -p:temp -b:months_safe  months




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

