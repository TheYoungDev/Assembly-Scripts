#---------------------------------------------------
# 3DR4 - Sunday. Feb. 4, 2018
#
# Create and then sort a random array of length N with the recursive Merge Sort algorithm
#
#---------------------------------------------------


.data

A: .space 16384 				# Define Space for Array A (unsorted Array) = 4*N

B: .space 16384 				# Define Space for Array B (Temp Array) = 4*N

N: .word 0						# Size of array

V: .word 200					# maximum value of random # set to 10 to more easily read numbers

message1: .asciiz   	"Enter Array Length (N):"	
message2: .asciiz   	"We're done !"	

.text
main:	
 	li $v0,4 			# tell OS to print message
 	la $a0, message1 	# Ask User to enter array length N
 	syscall

	#--- get number N from user ---
	li $v0,5 	# tell OS to read word from user
	syscall 	# result is in v0
 	sw $v0, N 	# copy result into memory (address N)

	# lets put 'constants' in $s (saved) registers
	la		$s0, A		# register $s0 has base address of array A, ie &A[0]
	la		$s3, B		# register $s3 has base address of array B, ie &B[0]
	lw		$s1, N		# register $s1 has value N
	lw		$s2, V		# register $s2 has max-value to write into memory	
	
	# Call functions to create random array and sort it
	jal  		write_random_memory	#call function to randomly asssign values to memory
	jal  		merge_sort			#call functio to sort the array of randomly assigned values


#--------------------------------------------------------------
# START of write_random_memory function
# function write_random_memory(int A[], int N,  int V)  
# The 3 ARGUEENTS are in registers $s0, $s1, $s2
# $s0 stores the base-address of vector A, ie address A[0]
# $s1 stores N, number of times to write to memory
# $s2 stores V, the maximum value to write to memory  
#--------------------------------------------------------------
#	(pseudo-code)
#
#	Define vector space for array A and B initialize length N, the maximum random value that can be assigned and 
#	store base-address of vector B in a register
#	store value N in a register
#	store value V  in a register, the max value of random #s
#
#	function write_random_memory(int A[], int N,  int V)  {
#	int  i;
#	for (i = 0; i < N;  i++)
#		A[i] = random-number()
#	}
#-------------------------------------------------------------

write_random_memory:
	move		$t0,$zero	# store index i in $t0, initially i = 0
	
loop:	
	sll		$t1,$t0, 2		# multiply index i by 4 to create address-offset in bytes, store in $t1
	add		$t2,$s0,$t1		# $t2 has address A[i] = base address + address-offset (all in bytes)
	
	li		$v0,42
	move	$a0,$zero
	addi	$a1,$zero,200
	syscall					# writes random # into $a0
	
	sw		$a0, 0($t2)		# write $a0 into memory A[i]
	
	addi	$t0,$t0,1		# increment index i by 1
	
	slt		$t3,$t0,$s1		# $t3 = 1 if index i < N
	
	bne		$t3,$zero,loop
	jr		$ra				# return address stored in $ra 

#--------------------------------------------------------------
# START of merge_sort
# Allocate space to store the low, middle, high, return address, and array address
# Call Sort using low and high
# Recursively call Sort using low and mid 
# If low < high then return 
# Recursively call Sort using mid+1 and high
# Call merge for low, mid, and high
# Set i, k to low and j to mid +1 
# loop while i < mid && j < high
# if A[i] < A[j] set B[k] = A[i] else set B[k] to A[j]
# loop while i < mid and set B[k] to A[i]
# loop while j < high and set B[k] to A[j]
# for i<k set B[i] to A[i]
#--------------------------------------------------------------

#--------------------------------------------------------------
#	(pseudo-code)
#
#	function MergeSort(int low, int high){    
#	if (low < high){
#        int mid = (low+high)/2;
#        # sort bottom half
#        MergeSort(low, mid);
#        # sort top half
#        MergeSort(mid+1, high)
#        # Merge 
#        Merge(low, mid, high)
#	}
#  }
#--------------------------------------------------------------
.globl merge_sort

merge_sort:
#Allocate space and store data that will be used.
   	addi 	$sp, $sp, -4       	# allocate 4 bytes in the stack  for return address
   	sw   	$ra, 0($sp)       	# store the return address in stack
   	la   	$a0, ($s3)       	# load temp array B address
   	la   	$a1, ($s0)      	# load unsorted array A address
   	add 	$a2, $zero, $s1     # Set $a2 to N
   	addi   	$sp, $sp, -16   	# allocate space on the stack
   	sw   	$ra, 0($sp)       	# store the return address in stack
   	sw   	$a1, 8($sp)       	# store array As address 
   	add   	$a2, $a2, -1       	# set $a2 to N - 1
   	sw   	$a2, 4($sp)       	# store the value of N-1
   	sw   	$a3, 0($sp)       	# store low 
   	jal   	sort           		# Call Sort low, high

end:	
	# invoke OS to display done message to user
	li  	$v0,4				# tell OS to print message
	la		$a0,message2		# load address of message
	syscall
	li 		$v0,10				# end of program
	syscall           	

sort:
   	addi 	$sp, $sp, -20      	# allocate space
   	sw 		$ra, 16($sp)        # store return address
   	sw 		$s1, 12($sp)        # store elements in array 
   	sw 		$s2, 8($sp)         # store size (High)
   	sw 		$s3, 4($sp)         # store low 
   	sw 		$s4, 0($sp)         # store mid
   	move	$s1,  $a1       	# set s1 to array address
   	move	$s2,  $a2       	# set s2 to array length - 1
   	move	$s3,  $a3       	# set s3 to the lower size
   	slt 	$t3, $s3, $s2       # check if low < high
   	beq 	$t3, $zero, return  # if low < high then  branch to return
   	add 	$s4, $s3, $s2       # add and store low + high in s4
   	div 	$s4, $s4, 2         # divide by 2 to get mid
   	move	$a2, $s4       		# mid
   	move	$a3, $s3       		# low
   	jal  	sort           		# recursively call Sort using low and mid

   	# Sort  mid+1, high
   	addi 	$t4, $s4, 1         # store mid+1 in t4
   	move	$a3, $t4       		# set low to mid+1 
   	move	$a2, $s2       		# set high to high
   	jal  	sort           		# recursively call Sort using mid+1 and high

   	#Merge data
   	move $a1, $s1       		# store the array address
   	move $a2, $s2       		# store high
   	move $a3, $s3       		# store low
   	move $a0, $s4       		# store mid
   	jal  merge           		# merge elements
  
return:        
   	lw   $ra,   16($sp)       	# load return address
   	lw   $s1,   12($sp)       	# load elements in array 
   	lw   $s2,   8($sp)       	# load size (High)
   	lw   $s3,   4($sp)       	# load low 
   	lw   $s4,   0($sp)       	# load mid
   	addi $sp,   $sp,20   		# clear stack
   	jr   $ra               		# return
	
#-------------------------------------------------------
#	(pseudo-code)
#
#	function Merge(int low,int mid, int high){
#	int i,j,k
#    	t1=i = low
#    	t2=j=mid+1
#    	t3=k=low
#    	while(i<=mid && j<=high){
#      		if(A[i] <= A[j]){
#      			B[k] = A[i]
#      			i++
#			k++
#       	}
#		else{
#     			B[k] =  A[j]
#     			j++
#			k++
#     		}
#       } 
#       while(i<=mid){
#       	B[k] = A[i]
#       	k++
#      		i++
#       }
#       while(j<=high){
#       	B[k] = A[j]
#       	k++
#      		i++
#       }
#	i = low 
#       for(i < k){
#       	A[i] = B[i]
#		i++
#       }
#      }  
#---------------------------------------------------	
merge:  
   	addi 	$sp, $sp, -20       # allocate space
   	sw 		$ra, 16($sp)        # store return address
   	sw 		$s1, 12($sp)        # store elements in array
   	sw 		$s2, 8($sp)         # store size (High)
   	sw 		$s3, 4($sp)         # store low
   	sw 		$s4, 0($sp)         # store mid
   	move 	$s1, $a1            # store array address in s1
   	move 	$s2, $a2       		# store high in s2
   	move 	$s3, $a3       		# store low in s3
   	move 	$s4, $a0       		# store mid in s4
   	move 	$t1, $s3       		# set t1 to i (low)
   	move 	$t2, $s4       		# set t2 to j (mid)
   	addi 	$t2, $t2, 1     	# add 1 to j (mid+1)
   	move	$t3, $a3       		# set t3 to k  (low)

#while i =< mid && j =< high
whileloop:
   	slt 	$t4, $s4, $t1       	# check if i > mid
   	bne 	$t4, $zero, whileloop2  # branch to whileloop2 if i > mid
   	slt 	$t5, $s2, $t2       	# check if high j > high 
   	bne 	$t5, $zero, whileloop2  # branch to whileloop2 if j > high
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s1, $t6   		# set t6 to the address A[i]
   	lw 		$s5, 0($t6)       		# load A[i] in S5
   	sll 	$t7, $t2, 2       		# j*4
   	add 	$t7, $s1, $t7   		# set t7 to the address A[j]
   	lw 		$s6, 0($t7)       		# load A[j] in S6
   	slt 	$t4, $s5, $s6       	# check if A[i] < A[j]
   	beq 	$t4, $zero, else   		# branch to Else1 if A[i] >= A[j]
   	sll 	$t8, $t3, 2       		# k*4
   	la 		$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 		$s5, 0($t8)       		# set B[k] to A[i]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t1, $t1, 1       		# increment i
   	j   	whileloop

else:
   	sll 	$t8, $t3, 2       		# i*4
   	la 		$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 		$s6, 0($t8)       		# set B[k] to A[j]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t2, $t2, 1       		# increment j
   	j   	whileloop

#while i <= mid
whileloop2: 
  	slt 	$t4, $s4, $t1       	# check if i > mid
   	bne 	$t4, $zero, whileloop3  # branch to whileloop3 if i> mid
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s1, $t6   		# set t6 to the address of A[i]
   	lw 		$s5, 0($t6)       		# set s5 to A[i]
   	sll 	$t8, $t3, 2       		# i*4
   	la 		$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 		$s5, 0($t8)       		# set B[k] to A[i]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t1, $t1, 1       		# increment i
   	j   	whileloop2

#while j < high
whileloop3: 
   	slt 	$t5, $s2, $t2       	# check if j >= high
   	bne 	$t5, $zero, reset   	# branch to loop if j>=high
   	sll 	$t7, $t2, 2       		# i*4
   	add 	$t7, $s1, $t7  			# set t7  to the address of A[j]
   	lw 		$s6, 0($t7)      		# set s6 to A[j]
   	sll 	$t8, $t3, 2       		# i*4
   	la 		$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 		$s6, 0($t8)       		# set B[k] to A[j]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t2, $t2, 1       		# increment j
   	j   	whileloop3

reset:
   	move 	$t1,  $s3   			# set i to low
 
 #for i<k
forloop:
   	slt 	$t5, $t1, $t3       	# check if i<k
   	beq 	$t5, $zero, return   	# branch if i=k
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s1, $t6   		# set t6 to the address of A[i]
   	sll 	$t8, $t1, 2       		# i*4
   	la 		$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8       	# set t8 to the address B[i]
   	lw 		$s7, 0($t8)       		# set A[i] to B[i]
   	sw 		$s7, 0($t6)       		# A[i]
   	addi 	$t1, $t1, 1       		# i++
   	j   	forloop
