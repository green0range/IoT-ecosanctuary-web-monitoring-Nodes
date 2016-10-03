' Template sensor node progarm

' Declare variables
symbol keyx = b25
symbol keyy = b26
symbol LastValue = b24
symbol id = b23

'### Set keys here:
keyx = 1
keyy = 1
id = 17
' Main program loop
main:
	' sleep to conserve battery
	sleep 255
	' Wakes up, checks sensors
	b0 = pin3
	high 4
	readadc 1, LastValue
	debug
	gosub transmit
	'sertxd("hello ",#LastValue)
	low 4
	' go back to sleep.
goto main

transmit:
	' using manchesstor encoding, no handshake.
	
	'ecoding
	b15 = id
	gosub conM
	b17 = b15
	b18 = b16
	
	b15 = LastValue
	'sertxd("VALUE=",#b15," e")
	gosub conM
	b19 = b15
	b20 = b16
	
	b15 = LastValue*keyx
	b15 = b15 + id
	b15 = b15/keyy 
	'sertxd("c is ",#b15,". ")
	gosub conM
	b21 = b15
	b22 = b16
	
	' send
	'sertxd("done")
	serout 0,N2400,(85,85,85,85,85,85,":01",b17,b18,b19,b20,b21,b22)
	'sertxd("s ",#b17," ",#b18," ",#b19," ",#b20," ",#b21," ",#b22," end")
return

conM:
	' divides into bit array
	b0 = b15
	b8 = b0 % 2
	b0 = b0/2
	b7 = b0 % 2
	b0 = b0/2
	b6 = b0 % 2
	b0 = b0/2
	b5 = b0 % 2
	b0 = b0/2
	b4 = b0 % 2
	b0 = b0/2
	b3 = b0% 2
	b0 = b0/2
	b2 = b0 % 2
	b0 = b0/2
	b1 = b0 % 2
	' builds back up, adds the inverse of each bit.
	b0 = b1*128
	if b1 = 0 then {b0 = b0 + 64}endif
	b15 = b2*32
	b0 = b0+b15
	if b2 = 0 then {b0 = b0 + 16}endif
	b15 = b3*8
	b0 = b0+b15
	if b3 = 0 then {b0 = b0 + 4}endif
	b15 = b4*2
	b0 = b0+b15
	if b4 = 0 then {b0 = b0 + 1}endif
	b15 = b0
	
	b0 = b5*128
	if b5 = 0 then {b0 = b0 + 64}endif
	b16 = b6*32
	b0 = b0+b16
	if b6 = 0 then {b0 = b0 + 16}endif
	b16 = b7*8
	b0 = b0+b16
	if b7 = 0 then {b0 = b0 + 4}endif
	b16 = b8*2
	b0 = b16 +b0
	if b8 = 0 then {b0 = b0 + 1}endif
	b16 = b0
return
