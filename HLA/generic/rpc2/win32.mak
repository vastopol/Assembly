all:server.exe client.exe


server.exe:server.hla sc.hhf
	hla -thread server
	
client.exe:client.hla sc.hhf
	hla -thread client
	

clean:
	del /Q /F *.obj
	del /Q /F *.link
	del /Q /F *.exe
	