#bubble sort

.data

A:
.word	2,6,8,10,87,16,55,34,13,22,11
N:
.word 11
message:
.asii "Done"

.text

# mips instructions (worst case) = 8+4*N+10*N*N 
# mips instructions (N =1e6) = 1E13

# time = instructions/instructions per sec = 1E13/2E9=5000sec=83min=1.3889hours
#sudo code:
#function (int *A, int N){
#	
#for(j=0,j < N, j +=1){
#
#	for(i=0,i < N-1, i +=1){
#		if(A[i] > A[i+1]){
#			temp = A[i]
#			A[i] = A[i+1]
#			A[i+1] = temp
#		}
#	}
#}
#}


BubbleSort:
la	$s0,A
lw 	$s1,N
move 	$t0,$zero
#t0 = outerloop counter i
#t1 = innerloop counter j
#t2 = A*
#t3 = A*+4
#t4 = N-1


#for i <N
OuterLoop:
beq 	$t0 $s1, END 	# branch to end if i=N
move 	$t1,$zero	#t1 reset innerloop counter j to 0
addi 	$t0,$t0,1	#t0 increment outerloop counter i 
la	$s0,A		#set pointer to start of array A
#for j <N-1
InnerLoop:
	lw	$t2, 0($s0)		#t2 = A* current element
	lw	$t3, 4($s0)		#t3 = A*+4 adjacent element
	bge	$t3,$t2,SkipSwap 	#branch if A*+4 >= A* i.e. dont swap
	#swap values in memory
	sw 	$t3, 0($s0)		#A* = $t3
	sw 	$t2, 4($s0)		#A*+4 = $t2
	
SkipSwap:
	addi 	$s0,$s0,4		#increment pointer A*+4
	addi 	$t1,$t1,1		#increment innerloop counter
	addi	$t4, $s1,-1		#t4 = N-1
	blt	$t1,$t4,InnerLoop	#continue loop if counter < N-1
	j	OuterLoop		#jump to outer loop when inner loop done


END:
	li 	$v0, 4
	la	$a0,message
	syscall

	li	$v0, 10
	syscall

