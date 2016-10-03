pause 1000
DISCONNECT
' downlaoding config from the pi does not seem to work, so preset work around:
b23 = 1'key1
b24 = 1 ' key2
b25 = 45 'trans method
b26 = 0 ' handshaking?
serout 1,T2400,("Using default: ",#b23,#b24,#b25,#b26,10) 
goto main

setup:
	'To begin, the picaxe must get some config details from the pi.
	' The config is; 2 keys, used in verification, transmitt method (Parity or Manchesstor) and in handshaking is required or not.
	' Send SETup REquest
	serout 1,T2400,("SetRe",10)
	pause 900
	serin [500],4,T2400,("conf:"),b23, b24,b25,b26 ' key1, key2 , transmit method, handshake
	serout 1,T2400,("got conf",#b23,#b24,#b25,#b26,10)
	'if b26 = 1 then {high 2} else {low 2} endif '## Setting pin levels seems to crash picaxe, faulty?
	if b23 != 0 then {
		serout 1,T2400,("got conf",#b23,#b24,#b25,#b26,10) ' debuging
		goto main ' Once device has the config it can enter the main loop.
	} endif 
	goto setup ' loop back if don't have setup

main:
	'selects the transmisson method sub routine
	if b25 = 48 then{ ' P
		gosub rxp
	}elseif b25 = 45 then{ ' M
		gosub rxm
	}endif
'loop
goto main

rxm: ' rx /w manchestor
b17 = 0
serin [50],2,N2400,(":01"),b17,b18,b19,b20,b21,b22
'sertxd("s ",#b17," ",#b18," ",#b19," ",#b20," ",#b21," ",#b22," end")
if b17 != 0 then {
	' got data
	b15 = b17
	b16 = b18
	gosub bitarray
	b17 = b1*128
	b0 = b3*64
	b17 = b17+b0
	b0 = b5*32
	b17 = b17+ b0
	b0 = b7*16
	b17 = b0+b17
	b0 = b11*8
	b17 = b17+b0
	b0 = b12*4
	b17 = b17+b0 
	b0 = b13*2
	b17 = b17+b0
	b0=b14*1
	b17 = b17+b0 
	b15 = b19
	b16 = b20
	gosub bitarray
	b18 = b1*128
	b0 = b3*64
	b18 = b18+b0
	b0 = b5*32
	b18 = b18+ b0
	b0 = b7*16
	b18 = b0+b18
	b0 = b11*8
	b18 = b18+b0
	b0 = b12*4
	b18 = b18+b0 
	b0 = b13*2
	b18 = b18+b0
	b0=b14*1
	b18 = b18+b0 
	
	b15 = b21
	b16 = b22
	gosub bitarray
	b19 = b1*128
	b0 = b3*64
	b19 = b19+b0
	b0 = b5*32
	b19 = b19+ b0
	b0 = b7*16
	b19 = b0+b19
	b0 = b11*8
	b19 = b19+b0
	b0 = b12*4
	b19 = b19+b0 
	b0 = b13*2
	b19 = b19+b0
	b0=b14*1
	b19 = b19+b0
	'sertxd("b18 is ",#b18," end")
	' run checksum
	b20= b23*b18
	b20 = b17+b20
	b20 = b20/b24
	'send either 'a' or 'e' (acc or err)
	if b20 = b19 then {
		'serout 4,T2400,("correct checksum",10)
		if b26 = 1 then{
			serout 0,N2400,(85,85,85,85,85,85,":02",97, b17)
		} endif
		' round 254 to 255 so as not to be confused as 10
		if b17 = 254 then {b17 = 255} endif
		if b18 = 254 then {b18 = 255} endif
		if b19 = 254 then {b19 = 255} endif
		' convert 10's to 254, so they are not counted as \n by pi
		if b17 = 10 then {b17 = 254} endif
		if b18 = 10 then {b18 = 254} endif
		if b19 = 10 then {b19 = 254} endif
		serout 1,T2400,("DATA",b17,b18,b19,10)
		sertxd("DATAm",#b17,",",#b18,",",#b19,13,10)
	} endif
	if b20 != b19 then {
		serout 1,T2400,("incorrect checksum",10)
		if b26 = 1 then {
			serout 0,N2400,(85,85,85,85,85,85,":02",101, b17)
		} endif
	} endif
}endif
return


rxp: ' rx /w parity
b17 = 0
'serout 4,T2400,("going to do serin",10)
serin [50],2,N2400,(":01"),b17,b18,b19,b20,b21,b22
'serout 4,T2400,("did serin: ",b17,b18,b19,b20,b21,b22,10)
if b17 != 0 then{
	'serout 4,T2400,("Got data",10)
	'Parity fixes all data, stores fix in b17,18,19
	b15 = b17
	b16 = b18
	gosub bitarray
	gosub fix
	b17 = b15
	b15 = b19
	b16 = b20
	gosub bitarray
	gosub fix
	b18 = b15
	b15 = b21
	b16 = b22
	gosub bitarray
	gosub fix
	b19 = b15
	'serout 4,T2400,("Done parities",10)
	' run checksum
	b1= b23*b18
	b20 = b17+b1
	b20 = b20/b24
	'send either 'a' or 'e' (acc or err)
	if b20 = b19 then {
		'serout 4,T2400,("correct checksum",10)
		if b26 = 1 then{
			serout 0,N2400,(85,85,85,85,85,85,":02",97, b17)
		} endif
		' convert 10's to 254, so they are not counted as \n by pi
		if b17 = 10 then {b17 = 254} endif
		if b18 = 10 then {b18 = 254} endif
		if b19 = 10 then {b19 = 254} endif
		serout 1,T2400,("DATA",b17,b18,b19,10)
	} endif
	if b20 != b19 then {
		serout 1,T2400,("incorrect checksum",10)
		if b26 = 1 then {
			serout 0,N2400,(85,85,85,85,85,85,":02",101, b17)
		} endif
	} endif
}endif

return

bitarray:
' Sets up a bit array from byte in b15, b16
' Uses b1-8, b9-14 (second if parity bytes, of 6 bits)
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
if b25 = 48 then{
b0 = b16
b14 = b0 % 2
b0 = b0/2
b13 = b0 % 2
b0 = b0/2
b12 = b0 % 2
b0 = b0/2
b11 = b0 % 2
b0 = b0/2
b10 = b0 % 2
b0 = b0/2
b9 = b0% 2
}elseif b25 = 45 then{
b0 = b16
b0 = b0/2 
b14 = b0 % 2
b0 = b0/2
b0 = b0/2
b13 = b0 % 2
b0 = b0/2
b0 = b0/2
b12 = b0 % 2
b0 = b0/2
b0 = b0/2
b11 = b0 % 2
}endif

return


' This will fix flipped bits in b1-8 with parity b9-14 and place fixed in b15
' it uses b16 and b0 as a tmp variable
fix:
'rows
b0 = b1 + b2 + b9
b0 = b0 % 2
if b0 != 0 then {b16=1} endif
b0 = b3 + b4 + b5 + b10
b0 = b0 % 2
if b0 != 0 then {b16=b16+2} endif
b0 = b6 + b7 + b8 + b11
b0 = b0 % 2
if b0 != 0 then {b16=3} endif
'columns
b0 = b3 + b6 + b12
b0 = b0 % 2
if b0 != 0 then {b9=1} endif
b0 = b1 + b4 + b7 + b13
b0 = b0 % 2
if b0 != 0 then {b9=2} endif
b0 = b2 + b5 + b8 + b14
b0 = b0 % 2
if b0 != 0 then {b9=3} endif
'error checking
'row 1
if b16 = 1 then{
	if b9 =2 then{
		'b1 flipped
		if b1 = 1 then {b1=0} else {b1=1} endif
	}endif
	if b9 = 3 then{
		'b1 flipped
		if b2 = 1 then {b2=0} else {b2=1} endif
	}endif
}endif
'row 2
if b16 = 2 then{
	if b9 =1 then{
		'b1 flipped
		if b3 = 1 then {b3=0} else {b3=1} endif
	}endif
	if b9 = 2 then{
		'b1 flipped
		if b4 = 1 then {b4=0} else {b4=1} endif
	}endif
	if b9 = 3 then{
		'b1 flipped
		if b5 = 1 then {b5=0} else {b5=1} endif
	}endif
}endif
'row 3
if b16 =3 then{
	if b9 =1 then{
		'b1 flipped
		if b6 = 1 then {b6=0} else {b6=1} endif
	}endif
	if b9 = 2 then{
		'b1 flipped
		if b7 = 1 then {b7=0} else {b7=1} endif
	}endif
	if b9 = 3 then{
		'b1 flipped
		if b8 = 1 then {b8=0} else {b8=1} endif
	}endif
}endif
' Convert fixed back to single btye
b0 = b1
b0 = b0*2
b0 = b0+b2
b0 = b0*2
b0 = b0+b3
b0 = b0*2
b0 = b0+b4
b0 = b0*2
b0 = b0+b5
b0 = b0*2
b0 = b0+b6
b0 = b0*2
b0 = b0+b7
b0 = b0*2
b0 = b0+b8
b15 = b0

return

Ma:
' converts byte 15 to bit array
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
' at the inverse bit

b0 = b1
b0 = b0*2
if b1 = 1 then {b0=b0+1}endif
b0 = b0*2

b0 = b0+b2
b0 = b0*2
if b2 = 1 then {b0=b0+1}endif
b0 = b0*2

b0 = b0+b3
b0 = b0*2
if b3 = 1 then {b0=b0+1}endif
b0 = b0*2

b0 = b0+b4
b15 = b0

b0 = b0+b5
b0 = b0*2
if b5 = 1 then {b0=b0+1}endif
b0 = b0*2

b0 = b0+b6
b0 = b0*2
if b6 = 1 then {b0=b0+1}endif
b0 = b0*2

b0 = b0+b7
b0 = b0*2
if b7 = 1 then {b0=b0+1}endif
b0 = b0*2

b0 = b0+b8
b16 = b0

return
