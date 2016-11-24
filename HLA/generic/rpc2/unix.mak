all:server client


server.exe:server.hla sc.hhf
	hla -thread server
	
client.exe:client.hla sc.hhf
	hla -thread client
	

clean:
	rm *.o
	rm *.link
	rm server
	rm client
	