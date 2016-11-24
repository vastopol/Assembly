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
	
	cd hlabasic2
	make
	cd ..
	
	cd rpc
	make -f win32.mak
	cd ..
	
	cd rpc2
	make -f win32.mak
	cd ..
	
	cd rpc3
	make -f win32.mak
	cd ..
	
	cd rpc4
	make -f win32.mak
	cd ..
	
	
	

clean:
	del /Q /F *.exe	
	del /Q /F *.obj	
	del /Q /F *.o	
	del /Q /F *.link	
	del /Q /F *.ilk	
	del /Q /F *.pdb	
	del /Q /F *.asm
	del /Q /F temp\*	

	del /Q /F 99bottles
	del /Q /F ackGCLS
	del /Q /F AddHex
	del /Q /F arraysGCLS
	del /Q /F Basic
	del /Q /F BigArith
	del /Q /F bitcntdemo
	del /Q /F bm
	del /Q /F calc2
	del /Q /F caseDemo
	del /Q /F charFreq
	del /Q /F classdemo
	del /Q /F CmdLnDemo
	del /Q /F cntBits
	del /Q /F consoleTest
	del /Q /F convdemo
	del /Q /F cordemo
	del /Q /F count
	del /Q /F count2
	del /Q /F crc
	del /Q /F crcgen
	del /Q /F csetdemo
	del /Q /F ctStrFuncs
	del /Q /F DemoExtract
	del /Q /F DemoRandom
	del /Q /F dictGCLS
	del /Q /F dos2unix
	del /Q /F fib
	del /Q /F fibGCLS
	del /Q /F FileDemo
	del /Q /F fillMatrix
	del /Q /F FiveSamples
	del /Q /F for
	del /Q /F gcd
	del /Q /F hashGCLS
	del /Q /F heapsortGCLS
	del /Q /F Hexdump
	del /Q /F HexInput
	del /Q /F hllmacs
	del /Q /F JumpTables1
	del /Q /F JumpTables2
	del /Q /F JumpTables3
	del /Q /F keysort
	del /Q /F listDemo
	del /Q /F localLabels
	del /Q /F log
	del /Q /F LookupTables
	del /Q /F MakeRandomIDs
	del /Q /F matmulGCLS
	del /Q /F matrix
	del /Q /F memDemo
	del /Q /F mmapEx
	del /Q /F movinto
	del /Q /F NestedMatch
	del /Q /F NumericConvDemo
	del /Q /F NumericConvDemo2
	del /Q /F pattest
	del /Q /F preserve
	del /Q /F pwrsof2
	del /Q /F qsDemo
	del /Q /F RdLnDemo
	del /Q /F regexpGCLS
	del /Q /F regexTest
	del /Q /F rpn
	del /Q /F sse
	del /Q /F stdoutDemo
	del /Q /F strcatXX
	del /Q /F strDemo
	del /Q /F strIODemo
	del /Q /F strToBA
	del /Q /F SwapArray
	del /Q /F tabledemo
	del /Q /F testDate
	del /Q /F testexcepts
	del /Q /F testmath
	del /Q /F testNum
	del /Q /F testtimer
	del /Q /F tstencrypt
	del /Q /F tstfiles
	del /Q /F u32Expr
	del /Q /F unitdemomain unitdemounit
	del /Q /F usefpu
	del /Q /F uuencodeDemo
	del /Q /F VerseOfTheDay
	del /Q /F wc
	del /Q /F wcGCLS
	del /Q /F while
	del /Q /F x2p
	del /Q /F stldemo
	cd hlabasic2 
	make clean
	cd ..
	cd rpc
	make -f win32.mak clean
	cd ..
	cd rpc2
	make -f win32.mak clean
	cd ..
	cd rpc3
	make -f win32.mak clean
	cd ..
	
