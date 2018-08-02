.text
la $a0, myWord 		#address of myWord stored in $a0
li $a1, 14	        # the allowable number of characters to be input +1

# input a value in MIPSusing syscall 8
li $v0, 8
syscall

#output
li $v0, 4
syscall

li $v0, 10
syscall
.data
myWord: .space 20 #reserve 20 bytes of space for data
