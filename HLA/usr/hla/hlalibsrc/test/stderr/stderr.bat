hla -p:temp -obj:temp puthex		  
puthex 2>puthex.txt				  
hlacmp puthex.data puthex.txt  
if errorlevel 1	exit 1			  
									  
hla -p:temp -obj:temp putu			  
putu 2>putu.txt					  
hlacmp putu.data putu.txt	  
if errorlevel 1	exit 1			  
									  
hla -p:temp -obj:temp puti			  
puti 2>puti.txt					  
hlacmp puti.data puti.txt	  
if errorlevel 1	exit 1			  
									  
hla -p:temp -obj:temp putbool		  
putbool	2>putbool.txt			  
hlacmp putbool.data putbool.txt
if errorlevel 1	exit 1			  
									  
hla -p:temp -obj:temp putcset		  
putcset	2>putcset.txt			  
hlacmp putcset.data putcset.txt
if errorlevel 1	exit 1			  
									  
hla -p:temp -obj:temp pute			  
pute 2>pute.txt					  
hlacmp pute.data pute.txt	  
if errorlevel 1	exit 1			  
									  
hla -p:temp -obj:temp putr			  
putr 2>putr.txt					  
hlacmp putr.data putr.txt	  
if errorlevel 1	exit 1			  
