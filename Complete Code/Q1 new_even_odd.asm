.data

A: # array A
.word	2,6,8,10,87,16,55,34,13,22,11
#3,5,4,8,7,2,1,6 
N:# array length N
.word 11

.text
# mips instructions (worst case) = 3+4*outerloop+9*evenloop*outerloop  + 3*outerloop +10*oddloop *outerloop +2
# mips instructions (worst case) = 5+4*N+9*N/2*N  + 3*N +10*N/2 *N +2 = 5+7*N+9.5*N*N
# mips instructions (N =8) = 669
# mips reports ~684 for N =8 
# time = instructions/instructions per sec = 9.5E12/2E9=4750sec=79min=1.319hours
#sudo code:
#function (int *A, int N){
#	
#for(j=0,j < N, j +=1){
#	for(i=0,i < N, i +=2){
#		if(A[i] > A[i+1]){
#			temp = A[i]
#			A[i] = A[i+1]
#			A[i+1] = temp
#		}
#	}
#
#	for(i=1,i < N-1, i +=2){
#		if(A[i] > A[i+1]){
#			temp = A[i]
#			A[i] = A[i+1]
#			A[i+1] = temp
#		}
#	}
#}
#}



#s0= Current address of A*
#s1= N = length of A
#t4 = if check less A[i] than A[i+1]
#t0 = outerloop counter i
#t1 = innerloop counter j
#t2 = A[i]
#t3 = A[i+1]
#t4 =  N-1

la $s0, A	#load address of A
lw $s1, N	#load N in s1
move $t0, $zero	#set outer counter to 0	
addi $t5,$t5,4		# increment outerloop counter $t0
# loop N times
OuterLoop:
beq $t0,$s1, End 	# branch if outerloop looped N times
addi $t0,$t0,1		# increment outerloop counter $t0
la $s0, A		#s0 = start of array A
move $t1, $zero		#set inner loop counter j to 0


EvenLoop:
	lw $t2,0($s0) 		#t2 = current pointer value (current element in array)
	lw $t3,4($s0)		#t3 = current pointer value + 4 (next element in array)
	ble $t2,$t3, EvenEnd	# branch if t2 <= t3 (skip swap)
	#swap otherwise
	sw $t3,0($s0)		#A* = $t3
	sw $t2,4($s0)		#A*+4 = $t2
		
EvenEnd:
	addi $t1,$t1,2		# increment counter j by 2 
	addi $s0,$s0,8		# increment pointer by 8 = 2 words
	#check if j <  N
	addi	$t4, $s1,-1	#t4 = N-1
	blt $t1,$t4 EvenLoop	#branch if $t1 < N (continue to loop)

#init settings for odd loop
la $s0, A			#s0 = start address of A		
add $s0,$s0,4			#s0 = start address of A +4
addi $t1, $zero,1		#t1= inner loop counter j to 1

#same cooments as even
OddLoop:
	lw $t2,0($s0)		#t2 = current pointer value (current element in array)
	lw $t3,4($s0)		#t3 = current pointer value + 4 (next element in array)
	ble $t2,$t3,OddEnd	# branch if t2 <= t3 (skip swap)
	#swap otherwise
	sw $t3,0($s0)		#A* = $t3
	sw $t2,4($s0)		#A*+4 = $t2
OddEnd:
	addi $t1,$t1,2		# increment counter j by 2 
	addi $s0,$s0,8		# increment pointer by 8 = 2 words
	#check if j <  N-1
	addi $t4, $s1,-1	#t4 = N-1
	blt $t1,$t4 OddLoop	#branch if $t1 < N (continue to loop)
	j OuterLoop		#loop back to outer loop


End:
	li 	$v0,10		# end of program
	syscall        				
	
	

