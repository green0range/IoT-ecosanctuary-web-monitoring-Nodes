' this is for testing hall effect sensor positions, it output the value to b0,
' chose the position with the greatest difference between positions

loopa:
	high 2
	readadc 4, b0
	debug
	low 2
goto loopa