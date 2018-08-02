.data
A:
	.word 3,5,4,8,7,2,1,6
N:
	.word 8
message1: .asciiz   	"We're done !"	
.text
	la $s0,A	#load A
	lw $s1,N	#N-1
	
	#srl $t0,$t0,1	# N/2
#N loop
loop1:	#outer loop
	move $t4,$s0 #pointer to A[0]
	move $t5,$zero #t5 =0 goes to N-1 (inner loop counter)
#n-1 loops
loop2:	#inner loop
	lw $t1, 0($t4)		#t1 = A[j] 
	lw $t2, 4($t4)		#t2 = A[j+1] 
	sub  $t3,$t1,$t2	#t3 = A[j]-A[j+1]
	bltz $t3,noswap		#branch if t3 less than 0
	#else swap
	sw   $t1,4($t4)		#A[j+1] = larger number
	sw   $t2,0($t4)		#A[j] = smaller number

noswap:
	addi $t4,$t4,4	#increment pointer 
	addi $t5,$t5,1	#inner loop counter 
	ble  $t5,$s1,loop2	#loop2 if t5>0
	
done2:  #done inner loop
	subi $t0,$t1,1	#decrement loop1 counter
	addi $t6,$t6,1	#outer loop counter
	bge $t6,$s1, end # end if counter2 > N
	bgtz $t1,loop1	#repeat loop1 if t1>0		
end:	
	# invoke OS to display done message to user
	li  	$v0,4				# tell OS to print message
	la		$a0,message1		# load address of message
	syscall
	li 		$v0,10			# end of program
	syscall        				
	
