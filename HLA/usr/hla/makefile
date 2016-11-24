
makeHLA:
	rm -f -R /usr/hla/hlalibsrc/*
	rm -f -R /usr/hla/include/*
	cp -R hlalibsrc/* /usr/hla/hlalibsrc
	cp -R include/* /usr/hla/include
	cd hlasrc; make -f makefile.linux
	cd /usr/hla/hlalibsrc; hla delete
	cd /usr/hla/hlalibsrc/mkMake; make -f makefile.unix; mkMake ; make clean
	cd /usr/hla/hlalibsrc; make; make clean
	tar cvf linux.tar /usr/hla/*
	rm -f linux.tar.gz
	gzip linux.tar
	cd /w/bsd; rm -f bsd.tar.gz; gzip bsd.tar
	
	
	
	
	








	 
