all:server client


server:server.hla sc.hhf
	hla -thread server
	
client:client.hla sc.hhf
	hla -thread client
	

clean:
	rm *.o
	rm *.link
	rm server
	rm client
	