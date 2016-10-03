' program to test button / magnetic switch
' this is currently a simply test program, however will latter be implimented into a transmission wrapper.
main:
	sertxd("napping",13,10)
	nap 6
	sertxd("out of nap",13,10)
	high 4
	sertxd("turned on pin 4",13,10)
	b0 = pin3
	sertxd("the state of pin 3 is ",#b0,13,10)
	low 4
goto main ' restart loop.