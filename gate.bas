pause 10
disconnect

symbol keyx = b25
symbol keyy = b26
symbol LastValue = b24
symbol id = b23
symbol id_battery = b10
symbol id_setup_closed = b11
symbol id_setup_unlatched = b12
symbol closedreading = b27
symbol notlatchedreading = b9

'### Set keys here:
keyx = 1
keyy = 1
id = 0
id_battery = 4
id_setup_closed = 2
id_setup_unlatched = 3

b0 = 0

' hold button during power up to activate setup mode
if pin3 = 1 then{
	sleep 2
	goto setup
}else{
	goto main
}endif

setup:
	' this is to set presets
	
	'quick flash
	pause 1000
	high 1
	nap 1
	low 1
	
	if pin3 = 1 then{
		if b0 = 0 then {
			high 1
			pause 2000
			high 2
			readadc 4, closedreading
			 
			low 2
			b0 = 1
			pause 2000
			low 1
		}else if b0 = 1 then{
			high 1
			pause 2000
			high 2
			readadc 4, notlatchedreading
			 
			low 2
			b0 = 1
			pause 2000
			low 1
			goto send_threshold
		}endif
	}endif
goto setup

send_threshold:
	' using manchesstor encoding, no handshake.
	for b13 = 0 to 20
		'encoding
		b15 = id_setup_closed
		gosub conM
		b17 = b15
		b18 = b16
		b15 = closedreading
		'sertxd("VALUE=",#b15," e")
		gosub conM
		b19 = b15
		b20 = b16
		b15 = LastValue*keyx
		b15 = b15 + id_setup_closed
		b15 = b15/keyy 
		'sertxd("c is ",#b15,". ")
		gosub conM
		b21 = b15
		b22 = b16
		' send
		'sertxd("done")
		serout 0,N2400,(85,85,85,85,85,85,":01",b17,b18,b19,b20,b21,b22)
		'sertxd("done tx",13,10)
		'sertxd("s ",#b17," ",#b18," ",#b19," ",#b20," ",#b21," ",#b22," end")
		'encoding
		b15 = id_setup_unlatched
		gosub conM
		b17 = b15
		b18 = b16
		b15 = notlatchedreading
		'sertxd("VALUE=",#b15," e")
		gosub conM
		b19 = b15
		b20 = b16
		b15 = LastValue*keyx
		b15 = b15 + id_setup_unlatched
		b15 = b15/keyy 
		'sertxd("c is ",#b15,". ")
		gosub conM
		b21 = b15
		b22 = b16
		' send
		'sertxd("done")
		serout 0,N2400,(85,85,85,85,85,85,":01",b17,b18,b19,b20,b21,b22)
		'sertxd("done tx",13,10)
		'sertxd("s ",#b17," ",#b18," ",#b19," ",#b20," ",#b21," ",#b22," end")
		b0 = b13 / 5
		nap 5
		debug
	next
	goto main

' Main program loop
main:
	' because of nap, time does not icriment fast enough
	disabletime
	let time = time + 1
	enabletime
	b0 = time % 10
	' sleep to conserve battery
	nap 6
	' Wakes up, checks sensors
	high 2 ' pin 4 is connected to pin 3 though HES.
	 b0 = pin4
	 if b0 = 1 then {
	 	low 1
	 }else{
	 	high 1
	 }endif
	if b0 != LastValue then{
		' values have changed, inform collector
		LastValue = b0
		gosub handleChange
	}endif
	' check urgency of pending messages
		if time > 5 then{ ' not just changed.
			' get more and more urgent as time goes past, hoping at least 1 makes it.
			if time = 10 then{gosub transmit}endif 
			if time = 20 then{gosub transmit}endif 
			if time = 30 then{gosub transmit}endif 
			if time = 35 then{gosub transmit}endif
			if time = 40 then{gosub transmit}endif 
			if time = 45 then{gosub transmit}endif 
			if time = 50 then{gosub transmit}endif 
			if time = 55 then{gosub transmit}endif
			if time = 60 then{gosub transmit}endif
			if time = 255 then{gosub transbattery}endif
		}endif
	low 2
	' go back to sleep.
goto main

handleChange:
	disabletime
	let time = 0
	enabletime
	sertxd("hc",13,10)
	gosub transmit
return

transbattery:
	
	'ecoding
	b15 = id_battery
	gosub conM
	b17 = b15
	b18 = b16
	
	calibadc10 b15
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
	sertxd("done tx",13,10)
	'sertxd("s ",#b17," ",#b18," ",#b19," ",#b20," ",#b21," ",#b22," end")
return

transmit:
	' using manchesstor encoding, no handshake.
	
	'ecoding
	b15 = id
	gosub conM
	b17 = b15
	b18 = b16
	
	b15 = LastValue
	'sertxd("VALUE=",#b15,13,10)
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
	sertxd("done tx ",#b17,#b18,#b19,#b20,#b21,#b22,13,10)
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
