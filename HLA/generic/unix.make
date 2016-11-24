all:
	hla -@@ -p:temp -obj:temp 99bottles.hla
	hla -@@ -p:temp -obj:temp ackGCLS.hla
	hla -@@ -p:temp -obj:temp AddHex.hla
	hla -@@ -p:temp -obj:temp arraysGCLS.hla
	hla -@@ -p:temp -obj:temp BigArith.hla
	hla -@@ -p:temp -obj:temp bitcntdemo.hla
	hla -@@ -p:temp -obj:temp bm.hla
	hla -@@ -p:temp -obj:temp calc2.hla
	hla -@@ -p:temp -obj:temp caseDemo.hla
	hla -@@ -p:temp -obj:temp charFreq.hla
	hla -@@ -p:temp -obj:temp classdemo.hla
	hla -@@ -p:temp -obj:temp CmdLnDemo.hla
	hla -@@ -p:temp -obj:temp cntBits.hla
	hla -@@ -p:temp -obj:temp consoleTest.hla
	hla -@@ -p:temp -obj:temp convdemo.hla
	hla -@@ -p:temp -obj:temp cordemo.hla
	hla -@@ -p:temp -obj:temp count.hla
	hla -@@ -p:temp -obj:temp count2.hla
	hla -@@ -p:temp -obj:temp crc.hla
	hla -@@ -p:temp -obj:temp crcgen.hla
	hla -@@ -p:temp -obj:temp csetdemo.hla
	hla -@@ -p:temp -obj:temp ctStrFuncs.hla
	hla -@@ -p:temp -obj:temp DemoExtract.hla
	hla -@@ -p:temp -obj:temp DemoRandom.hla
	hla -@@ -p:temp -obj:temp dictGCLS.hla
	hla -@@ -p:temp -obj:temp dos2unix.hla
	hla -@@ -p:temp -obj:temp fib.hla
	hla -@@ -p:temp -obj:temp fibGCLS.hla
	hla -@@ -p:temp -obj:temp FileDemo.hla
	hla -@@ -p:temp -obj:temp fillMatrix.hla
	hla -@@ -p:temp -obj:temp FiveSamples.hla
	hla -@@ -p:temp -obj:temp for.hla
	hla -@@ -p:temp -obj:temp gcd.hla
	hla -@@ -p:temp -obj:temp hashGCLS.hla
	hla -@@ -p:temp -obj:temp heapsortGCLS.hla
	hla -@@ -p:temp -obj:temp Hexdump.hla
	hla -@@ -p:temp -obj:temp HexInput.hla
	hla -@@ -p:temp -obj:temp hllmacs.hla
	hla -@@ -p:temp -obj:temp JumpTables1.hla
	hla -@@ -p:temp -obj:temp JumpTables2.hla
	hla -@@ -p:temp -obj:temp JumpTables3.hla
	hla -@@ -p:temp -obj:temp keysort.hla
	hla -@@ -p:temp -obj:temp listDemo.hla
	hla -@@ -p:temp -obj:temp localLabels.hla
	hla -@@ -p:temp -obj:temp log.hla
	hla -@@ -p:temp -obj:temp LookupTables.hla
	hla -@@ -p:temp -obj:temp MakeRandomIDs.hla
	hla -@@ -p:temp -obj:temp matmulGCLS.hla
	hla -@@ -p:temp -obj:temp matrix.hla
	hla -@@ -p:temp -obj:temp memDemo.hla
	hla -@@ -p:temp -obj:temp mmapEx.hla
	hla -@@ -p:temp -obj:temp movinto.hla
	hla -@@ -p:temp -obj:temp NestedMatch.hla
	hla -@@ -p:temp -obj:temp NumericConvDemo.hla
	hla -@@ -p:temp -obj:temp NumericConvDemo2.hla
	hla -@@ -p:temp -obj:temp pattest.hla
	hla -@@ -p:temp -obj:temp preserve.hla
	hla -@@ -p:temp -obj:temp pwrsof2.hla
	hla -@@ -p:temp -obj:temp qsDemo.hla
	hla -@@ -p:temp -obj:temp RdLnDemo.hla
	hla -@@ -p:temp -obj:temp regexpGCLS.hla
	hla -@@ -p:temp -obj:temp regexTest.hla
	hla -@@ -p:temp -obj:temp rpn.hla
	hla -@@ -p:temp -obj:temp sse.hla
	hla -@@ -p:temp -obj:temp stdoutDemo.hla
	hla -@@ -p:temp -obj:temp strcatXX.hla
	hla -@@ -p:temp -obj:temp strDemo.hla
	hla -@@ -p:temp -obj:temp strIODemo.hla
	hla -@@ -p:temp -obj:temp strToBA.hla
	hla -@@ -p:temp -obj:temp SwapArray.hla
	hla -@@ -p:temp -obj:temp tabledemo.hla
	hla -@@ -p:temp -obj:temp testDate.hla
	hla -@@ -p:temp -obj:temp testexcepts.hla
	hla -@@ -p:temp -obj:temp testmath.hla
	hla -@@ -p:temp -obj:temp testNum.hla
	hla -@@ -p:temp -obj:temp testtimer.hla
	hla -@@ -p:temp -obj:temp tstencrypt.hla
	hla -@@ -p:temp -obj:temp tstfiles.hla
	hla -@@ -p:temp -obj:temp u32Expr.hla
	hla -@@ -p:temp -obj:temp unitdemomain.hla unitdemounit.hla
	hla -@@ -p:temp -obj:temp usefpu.hla
	hla -@@ -p:temp -obj:temp uuencodeDemo.hla
	hla -@@ -p:temp -obj:temp VerseOfTheDay.hla
	hla -@@ -p:temp -obj:temp wc.hla
	hla -@@ -p:temp -obj:temp wcGCLS.hla
	hla -@@ -p:temp -obj:temp while.hla
	hla -@@ -p:temp -obj:temp x2p.hla
	
	hla -@@ -p:temp -obj:temp stldemo.hla
	cd rpc; make -f unix.mak
	cd rpc2; make -f unix.mak
	cd rpc3; make -f unix.mak
	cd HLABasic2; make -f makefile.unix
	

clean:
	rm *.exe	
	rm *.obj	
	rm *.o	
	rm *.link	
	rm *.ilk	
	rm *.pdb	
	rm *.asm
	rm temp/*	
	rm 99bottles
	rm ackGCLS
	rm AddHex
	rm arraysGCLS
	rm Basic
	rm BigArith
	rm bitcntdemo
	rm bm
	rm calc2
	rm caseDemo
	rm charFreq
	rm classdemo
	rm CmdLnDemo
	rm cntBits
	rm consoleTest
	rm convdemo
	rm cordemo
	rm count
	rm count2
	rm crc
	rm crcgen
	rm csetdemo
	rm ctStrFuncs
	rm DemoExtract
	rm DemoRandom
	rm dictGCLS
	rm dos2unix
	rm fib
	rm fibGCLS
	rm FileDemo
	rm fillMatrix
	rm FiveSamples
	rm for
	rm gcd
	rm hashGCLS
	rm heapsortGCLS
	rm Hexdump
	rm HexInput
	rm hllmacs
	rm JumpTables1
	rm JumpTables2
	rm JumpTables3
	rm keysort
	rm listDemo
	rm localLabels
	rm log
	rm LookupTables
	rm MakeRandomIDs
	rm matmulGCLS
	rm matrix
	rm memDemo
	rm mmapEx
	rm movinto
	rm NestedMatch
	rm NumericConvDemo
	rm NumericConvDemo2
	rm pattest
	rm preserve
	rm pwrsof2
	rm qsDemo
	rm RdLnDemo
	rm regexpGCLS
	rm regexTest
	rm rpn
	rm sse
	rm stdoutDemo
	rm strcatXX
	rm strDemo
	rm strIODemo
	rm strToBA
	rm SwapArray
	rm tabledemo
	rm testDate
	rm testexcepts
	rm testmath
	rm testNum
	rm testtimer
	rm tstencrypt
	rm tstfiles
	rm u32Expr
	rm unitdemomain unitdemounit
	rm usefpu
	rm uuencodeDemo
	rm VerseOfTheDay
	rm wc
	rm wcGCLS
	rm while
	rm x2p
	
	rm stldemo
	
	cd rpc; make -f unix.mak clean
	cd rpc2; make -f unix.mak clean
	cd rpc3; make -f unix.mak clean
	cd HLABasic2; make -f makefile.unix clean
