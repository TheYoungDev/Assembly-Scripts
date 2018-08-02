.data
	A: .space 12 #4*3integers
.text
	addi $s0, $0, 4		#currently in registers 
	addi $s1, $0,8
	addi $s2, $0,4
	
	#to send to RAM
	#need an index(offset) use $t0
	
	addi $t0, $0, 0 #clear 0
	sw $s0, A($t0)
	addi $t0, $t0, 4
	sw $s1, A($t0)
	addi $t0, $t0, 4
	sw $s2, A($t0)
			
	#retrieve info 
	lw $t6, A($t0)
	
	li $v0, 1
	addi $a0, $t6,0
	syscall
	
	
