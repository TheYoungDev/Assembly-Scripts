#convention for t and s registers 
# function can do whatever it wants to the t registers 
# convention says that using s reg in function u always have to save value from caller to stack
# meaning callee cant modify s registers

.data 
	newline: .asciiz "\n"

.text
main:
	addi $s0,$0,10
	
	jal increase_register
	
	li $v0,4
	la $a0,newline
	syscall
	
	li $v0,1
	move $a0,$s0
	syscall


	li $v0,10
	syscall

increase_register:
	addi $sp,$sp,-4		#allocate 4 bytes in stack, & negative bc it goes down 
				#-ve implies reserving space
				#+ve implies using space
	sw $s0,0($sp)
	#now can do what we want to do with s0
	addi $s0,$s0,30
	
	li $v0,1
	move $a0,$s0
	syscall
	
	#load old value from memory
	lw $s0,0($sp)
	addi $sp,$sp,4			#restore stack
	
	jr $ra