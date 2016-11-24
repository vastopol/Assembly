/usr/hla/hlalibsrc/trunk/data.a: \
	reverseData.o \
	hexConvTbl.o \
	daysFromMonth.o \
	shortMonths.o \
	alphacset.o \
	_utoevars.o \
	digitcset.o \
	wscset.o \
	hexDigitsData.o \
	alphanumcset.o \
	uppercasecset.o \
	ctrlcset.o \
	hexTbL.o \
	CmdLnDelimiters.o \
	hexCSData.o \
	_utoethvars.o \
	lowercasecset.o \
	mergeData.o \
	daysInMonth.o \
	staticvars.o \
	hexdigitscset.o \
	graphiccset.o \
	daysToMonth.o \
	months.o \

	ar rc /usr/hla/hlalibsrc/trunk/hlalib.a \
		reverseData.o \
		hexConvTbl.o \
		daysFromMonth.o \
		shortMonths.o \
		alphacset.o \
		_utoevars.o \
		digitcset.o \
		wscset.o \
		hexDigitsData.o \
		alphanumcset.o \
		uppercasecset.o \
		ctrlcset.o \
		hexTbL.o \
		CmdLnDelimiters.o \
		hexCSData.o \
		_utoethvars.o \
		lowercasecset.o \
		mergeData.o \
		daysInMonth.o \
		staticvars.o \
		hexdigitscset.o \
		graphiccset.o \
		daysToMonth.o \
		months.o \

	ar s /usr/hla/hlalibsrc/trunk/hlalib.a

reverseData.o: reverseData.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  reverseData


hexConvTbl.o: hexConvTbl.hla \
	/usr/hla/include/stdlibdata.hhf \

	hla -c -p:temp  hexConvTbl


daysFromMonth.o: daysFromMonth.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  daysFromMonth


shortMonths.o: shortMonths.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  shortMonths


alphacset.o: alphacset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  alphacset


_utoevars.o: _utoevars.hla \
	../include/conversions.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  _utoevars


digitcset.o: digitcset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  digitcset


wscset.o: wscset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  wscset


hexDigitsData.o: hexDigitsData.hla \
	/usr/hla/include/stdlibdata.hhf \

	hla -c -p:temp  hexDigitsData


alphanumcset.o: alphanumcset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  alphanumcset


uppercasecset.o: uppercasecset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  uppercasecset


ctrlcset.o: ctrlcset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  ctrlcset


hexTbL.o: hexTbL.hla \
	/usr/hla/include/stdlibdata.hhf \

	hla -c -p:temp  hexTbL


CmdLnDelimiters.o: CmdLnDelimiters.hla \
	/usr/hla/include/zstrings.hhf \
	/usr/hla/include/stdio.hhf \
	/usr/hla/include/buf.hhf \
	/usr/hla/include/overload.hhf \
	/usr/hla/include/strings.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  CmdLnDelimiters


hexCSData.o: hexCSData.hla \
	../include/conversions.hhf \
	/usr/hla/include/stdlibdata.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  hexCSData


_utoethvars.o: _utoethvars.hla \
	../include/conversions.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  _utoethvars


lowercasecset.o: lowercasecset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  lowercasecset


mergeData.o: mergeData.hla \
	/usr/hla/include/bits.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  mergeData


daysInMonth.o: daysInMonth.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  daysInMonth


staticvars.o: staticvars.hla \
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

	hla -c -p:temp  staticvars


hexdigitscset.o: hexdigitscset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  hexdigitscset


graphiccset.o: graphiccset.hla \
	/usr/hla/include/chars.hhf \
	/usr/hla/include/os.hhf \
	/usr/hla/include/_hla.hhf \

	hla -c -p:temp  graphiccset


daysToMonth.o: daysToMonth.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  daysToMonth


months.o: months.hla \
	/usr/hla/include/datetime.hhf \
	/usr/hla/include/cstdlib.hhf \
	/usr/hla/include/hla.hhf \
	/usr/hla/include/_hla.hhf \
	/usr/hla/include/os.hhf \

	hla -c -p:temp  months




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

