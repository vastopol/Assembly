





echo off
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³UCR Standard Library for 80x86 Assembly Language Programmers (v34)   ³
echo ³Written by Randall Hyde and others.  Submissions cheerfully accepted ³
echo ³This software is public domain and may be freely used for any purpose³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo If you are running this batch file, make sure you are currently in the
echo "STDLIB" subdirectory.  This file requires that LHA be in your execution
echo path.  If it is not, this batch file will bomb.  This batch file creates
echo several subdirectories in "STDLIB" including source, test, include,
echo examples, ibml, lib, and doc.  If these directories already exist, you
echo may want to save any data in them before proceeding as the unpacking
echo process may destroy data in these subdirectories.  IF YOU HAVE NOT YET
echo CREATED THE "STDLIB" DIRECTORY, QUIT THIS BATCH FILE AND DO SO NOW.  THE
echo BEST PLACE TO PUT "STDLIB" IS IN YOUR ROOT DIRECTORY.  Change to the
echo STDLIB directory after you create it and copy the distribution files to it
echo ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo ³                                                                     ³
echo ³ IS LHA IN YOUR EXECUTION PATH?  ARE YOU IN THE STDLIB DIRECTORY?    ³
echo ³   HAVE YOU COPIED THE DISTRIBUTION FILES TO THE STDLIB DIRECTORY?   ³
echo ³                                                                     ³
echo ³      Do not continue if the answer is "no" to any of the above      ³
echo ³                      (hit ctrl-C to abort)                          ³
echo ³                                                                     ³
echo ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pause
lha x ucrslv36.lzh
del ucrslv36.lzh
md source
copy ucrslsrc.lzh source
del ucrslsrc.lzh
cd source
lha x ucrslsrc.lzh
del ucrslsrc.lzh
cd ..
md test
copy test.lzh test
del test.lzh
cd test
lha x test.lzh
del test.lzh
cd ..
md include
copy include.lzh include
del include.lzh
cd include
lha x include.lzh
del include.lzh
cd ..
md examples
copy examples.lzh examples
del examples.lzh
cd examples
lha x examples.lzh
del examples.lzh
cd ..
md doc
copy doc.lzh doc
del doc.lzh
cd doc
lha x doc.lzh
del doc.lzh
cd ..
md ucrwin
copy ucrwin.lzh ucrwin
del ucrwin.lzh
cd ucrwin
lha x ucrwin.lzh
del ucrwin.lzh
cd ..
md lib
copy lib.lzh lib
del lib.lzh
cd lib
lha x lib.lzh
del lib.lzh
cd ..
md ibml
copy ibml.lzh ibml
del ibml.lzh
cd ibml
lha x ibml.lzh
del ibml.lzh
cd ..


