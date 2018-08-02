.data
	message: .asciiz "greater\n"
	message2: .asciiz "less"
.text
	main:
		addi $s0, $0, 14
		addi $s1, $0, 10
	
		bgt $s0, $s1, display
		blt $s1, $s0, display2
		
		#finish
		li $v0,10
		syscall
	
	display:
		li $v0,4
		la $a0,message
		syscall
		b main
	display2:
		li $v0,4
		la $a0,message2
		syscall
		b main
