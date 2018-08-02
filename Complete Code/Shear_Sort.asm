#---------------------------------------------------
# 3DR4 - Sunday. Feb. 22, 2018
# By; Marc St. Aubin, Adam Rose
# Create and then sort a random array of length R*C with the shear-sort algorithm
#
#---------------------------------------------------


.data

A: .space 16384 				# Define Space for Array A (unsorted Array) = 4*N

B: .space 16384 				# Define Space for Array B (Temp Array) = 4*N

C: .space 16384 				# Define Space for Array B (Temp Array) = 4*N

reg: .space 4 				# Define Space for Array B (Temp Array) = 4*N

N: .word 0						# Size of array

R: .word 8						# # of rows/columns

V: .word 200					# maximum value of random # set to 10 to more easily read numbers

message1: .asciiz   	"Enter the number of rows/columns (R=C):"	
message2: .asciiz   	"We're done !"	

.text
main:	
 	li $v0,4 			# tell OS to print message
 	la $a0, message1 	# Ask User to enter array length N
 	syscall

	#--- get number N from user ---
	li $v0,5 	# tell OS to read word from user
	syscall 	# result is in v0
 	sw $v0, R 	# copy result into memory (address N)
 	
	# lets put 'constants' in $s (saved) registers
	la		$s0, A		# register $s0 has base address of array A, ie &A[0]
	la		$s3, B		# register $s3 has base address of array B, ie &B[0]
	la		$s7, C		# register $s7 has base address of array C, ie &C[0]
	la		$s6,reg		# used as a register
	#lw		$s1, N		# register $s1 has value N
	lw		$s2, V		# register $s2 has max-value to write into memory	
	lw		$t9, R		# register $s2 has max-value to write into memory	
	mulu 		$s1,$t9,$t9	#set S1 to N

	# Call functions to create random array and sort it
	jal  		write_random_memory	#call function to randomly asssign values to memory
	jal		shear_sort



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
	move		$a0,$zero
	addi		$a1,$zero,200
	syscall					# writes random # into $a0
	
	sw		$a0, 0($t2)		# write $a0 into memory A[i]
	
	addi		$t0,$t0,1		# increment index i by 1
	
	slt		$t3,$t0,$s1		# $t3 = 1 if index i < N
	
	bne		$t3,$zero,loop
	jr		$ra			# return address stored in $ra 



#--------------------------------------------------------------
#	(pseudo-code)
#
#	function shear_sort(array A, length N==R*C){    
#	for(k < log(R)){
#        for(i < R/2){
#        	for(j < R){
#			EvenRow_mergesort(0,2,R-2)#Sort all even rows
#		}
#	}	
#        for(i < R/2){
#        	for(j < R){
#			oddRows_mergesort(1,3,R-1)#Sort all odd rows in descending order
#		}
#	}
#        for(i < R){
#        	for(j < R){
#			col_mergesort(0,1,2,C-1) #Sort all columns
#		}
#	}
#  }
#--------------------------------------------------------------# 
.globl shear_sort

shear_sort:

#for k<log(R)
shear_loop:

#set index registers
move		$t0,$zero	# store index i in $t0, initially i = 0
move		$t1,$zero	# store index j in $t0, initially j = 0
move		$k0,$zero	# even odd or column
move		$k1,$zero	# address index
#t9 == R == C
#Reg == k 
#k0 = counter for even odd and col

 #for i < R/2  k0 goes from 0 to R/2
evenShearloop1:
	divu 	$t3 $t9 2			#set t3 to R/2
   	slt  	$t4, $k0, $t3       		# check if i<=R/2 ***
   	beq 	$t4, $zero, oddShearloopsetup  	# branch if i>R/2  (switch to odd row section)
   	addi 	$k0, $k0, 1       		# i++
   	bnez 	$t4, evenShearloop2   		# branch if i<R/2
   	
 #for j < R	
evenShearloop2:  	
	slt  	$t4, $t1, $t9      	# check if j<R ***
   	beq 	$t4, $zero, evenSortC  	# branch if j=R	
   	sll 	$t6, $k1, 2       	# i*4
   	la 	$a1, C       		# load array C address
   	add 	$t6, $a1, $t6   	# set t6 to the address of C[i]
   	sll 	$t8, $k1, 2       	# i*4
   	la 	$a0, A       		# load array A address
   	add 	$t8, $a0, $t8       	# set t8 to the address A[i]
   	lw 	$s6, 0($t8)       	# set C[i] to A[i]
   	sw 	$s6, 0($t6)       	# C[i]
   	addi 	$k1, $k1, 1       	# address index++
   	addi 	$t1, $t1, 1       	# j++
   	j   	evenShearloop2
   	
#Reset k1 for 1st iteration of odd row section
oddShearloopsetup:
	move		$k1,$zero	# address index
	j		Increment2	#increment to the next row
	
 #for i < R/2 k0 goes from R/2 to R
oddShearloop3:
	#divu 	$t3 $t9 2
   	slt  	$t4, $k0, $t9       	# check if k0<=R 
   	beq 	$t4, $zero, Setup1   # branch if k0>R
   	addi 	$k0,$k0,1
   	bnez 	$t4, oddShearloop4   	# branch if k0<R
   	
 #for j < R	
oddShearloop4:  	
	slt  	$t4, $t1, $t9      	# check if j<R ***
   	beq 	$t4, $zero, oddSortC  	# branch if j=R	
   	sll 	$t6, $k1, 2       	# i*4
   	la 	$a1, C       		# load array C address
   	add 	$t6, $a1, $t6   	# set t6 to the address of C[i]
   	sll 	$t8, $k1, 2       	# i*4
   	la 	$a0, A       		# load array A address
   	add 	$t8, $a0, $t8       	# set t8 to the address A[i]
   	lw 	$s6, 0($t8)       	# set C[i] to A[i]
   	sw 	$s6, 0($t6)       	# C[i]
   	addi 	$k1, $k1, 1       	# address index++
   	addi 	$t1, $t1, 1       	# j++
   	j   	oddShearloop4

#Reset k1 and set t2 to N for 1st iteration of col row section
ColumnSetup:
	move		$k1,$zero	# address index
	mulu  		$t2,$t9,$t9 	# set t2 to N = t9*t9=R*C 
	j		Increment3
	
 #for i < R k0 goes from R to 2*R
colShearloop5:
   	sll 	$t3,$t9,1
   	slt  	$t4, $k0, $t3       	# check if k0<R*2
   	beq 	$t4, $zero, ResetShear  # branch if k0>R*2
   	addi 	$k0,$k0,1		#k0 ++
   	bnez 	$t4,  colShearloop6   	# branch if k0<R*2
   	
 #for j < R	
colShearloop6:  	
	slt  	$t4, $t1, $t9      	# check if j<R ***
   	beq 	$t4, $zero, colSortC  	# branch if j=R	 ColSortC
   	sll 	$t6, $t2, 2       	# i*4
   	la 	$a1, C       		# load array A address
   	add 	$t6, $a1, $t6   	# set t6 to the address of C[i]
   	sll 	$t8, $k1, 2       	# i*4
   	la 	$a0, C       		# load array A address
   	add 	$t8, $a0, $t8       	# set t8 to the address A[i]
   	lw 	$s6, 0($t8)       	# set C[i] to A[i]
   	sw 	$s6, 0($t6)       	# C[i]
   	add 	$k1, $k1, $t9       	# k1+=R 
   	addi 	$t1, $t1, 1       	# j++	
	addi 	$t2, $t2, 1       	# t2++	
	j   	colShearloop6
	
 #call mergesort for even rows  		
evenSortC:	
	move 	$s1,$t9		#set s1 to R
	jal	merge_sort	#same as other merge sorts except the end function is different from the others
	
 #call mergesort for odd rows  
oddSortC:
	
	move 	$s1,$t9		#set s1 to R
	jal	oddmerge_sort	#same as merge sort except the end function

#call mergesort for columns  
colSortC:
	move 	$s1,$t9		#set s1 to R
	jal	colmerge_sort 	#same as merge sort except the end function

#check where the next branch should be. This is branched to in mergesort.
Setup1: 
	#If column loop complete
	mulu 	$t3,$t9,2		# t3 =2*R
   	slt  	$t4, $k0, $t3       	# check if k0<=R*2 
   	beq 	$t4, $zero, ResetShear   # branch if  k0>R*2 
 	
 	#If column:
   	slt  	$t4, $k0, $t9       	# check if k0<=R
   	beq 	$t4, $zero, ColumnSetup   # branch if k0>R
 	
 	#If ODD:
 	#1st odd:
 	divu 	$t3 $t9 2
   	sne    	$t4, $k0, $t3       	# check if k0==R/2 
   	beq 	$t4, $zero, oddShearloopsetup  # branch if k0==R/2
 	
 	#rest of the odd loops:
 	divu 	$t3 $t9 2
   	slt  	$t4, $k0, $t3       	# check if k0<=R/2 ***
   	beq 	$t4, $zero, Increment2  # branch if k0>R/2
 	
 	#If Even:
	j   	Increment1		#jump to even 
   	

# increment to the next row that will be sorted (for even only)
 Increment1: 
 	slt  	$t4, $t2, $t9      	# check if l<=R 
   	beq 	$t4, $zero, next1  	# branch if l>R	
   	sll 	$t6, $k1, 2       	# k1*4
   	sll 	$t8, $k1, 2       	# k1*4
   	la 	$s7, C       		# load array C address
   	add 	$t8, $s7, $t8       	# set t8 to the address C[i]
   	addi 	$t2, $t2, 1       	# l++
   	addi 	$k1, $k1, 1       	# k1++
   	move 	$s7,$t8			#set s7 to the address in t8
   	j   	Increment1

#(for even only) set the new address in s7
next1:
	move 	$a0,$zero
	addi 	$a0, $a0, 1       	# = 1
	sll 	$t8, $a0, 2       	# + 4
	add 	$t8, $s7, $t8       	# set t8 to the address s7 + 4
   	move 	$s7,$t8			# set S7 to t8
	j   	evenShearloop1

# increment to the next row that will be sorted (for odd only)
 Increment2:
 	slt  	$t4, $t2, $t9      	# check if l<=R 
   	beq 	$t4, $zero, next2  	# branch if l>R		
   	sll 	$t6, $k1, 2       	# k1*4
   	sll 	$t8, $k1, 2       	# k1*4
   	la 	$s7, C       		# load array A address
   	add 	$t8, $s7, $t8       	# set t8 to the address C[i]
   	addi 	$t2, $t2, 1       	# l++
   	addi 	$k1, $k1, 1       	# k1++****
   	move 	$s7,$t8			#set s7 to the address in t8
   	j   	Increment2
   	
next2:
	move 	$a0,$zero
	addi 	$a0, $a0, 1       	# = 1
	sll 	$t8, $a0, 2       	# + 4
	add 	$t8, $s7, $t8       	# set t8 to the address s7 + 4
   	move 	$s7,$t8			# set S7 to t8
	j   	oddShearloop3
	
# increment to the next row that will be sorted (for col only)
Increment3:
	mulu 	$t6,$t9,$t9		#t6=R*R
	la 	$a1, C       		# load array C address
	sll 	$t6, $t6, 2       	# R*R*4
	add 	$t8, $t6, $a1       	# set t8 to the address C[i]
   	move 	$s7,$t8			# set S7 to t8
	j   	colShearloop5

#Flip the odd values to be decending	
Flip:  	
	move $t7 , $zero		#set to 0
	move $t5 , $k1			#set t5 to k1
	move $t3 , $t9			#set t3 to R
	subi $t3 , $t3,1		#t3--
	sub  $t5, $t5, $t9       	#index -R

#loop to swap outer values with inner values	
Fliploop:
	slt  	$t4, $t7, $t9      	# check if j<R 
   	beq 	$t4, $zero, Setup1  	# branch if j=R	
   	sll 	$t6, $t5, 2       	# index*4
   	la 	$a1, C       		# load array C address
   	add 	$t6, $a1, $t6   	# set t6 to the address of C[i]
   	sll 	$t8, $t3, 2       	# index*4
   	la 	$a0, B       		# load array B address
   	add 	$t8, $a0, $t8       	# set t8 to the address B[i]
   	lw 	$s6, 0($t8)       	# set C[i] to B[i]
   	sw 	$s6, 0($t6)       	# C[i]
   	addi 	$t5, $t5, 1       	# t5++ (left side)
   	addi 	$t7, $t7, 1       	# j++
   	subi	$t3,$t3,1		#R-1 -- (right side)
   	j   	Fliploop

#use to set the column values in C to the correct values stored in B
colFlip:  	
	move $t7 , $zero	#j=0	
	move $t5 , $k0		#t5 =k0
	subu $t5,$t5,$t9	#t5=k0-R
   	subi $t5,$t5,1		#t5=k0-R-1
   	
#loop used to set the column values in C to the correct values stored in B	
colFliploop:
	slt  	$t4, $t7, $t9      	# check if j<R 
   	beq 	$t4, $zero, colFlipDone  # branch if j=R	
   	sll 	$t6, $t5, 2       	# index*4
   	la 	$a1, C       		# load array C address
   	add 	$t6, $a1, $t6   	# set t6 to the address of C[i]
   	sll 	$t8, $t7, 2       	# index*4
   	la 	$a0, B       		# load array B address
   	add 	$t8, $a0, $t8       	# set t8 to the address B[i]
   	lw 	$s6, 0($t8)       	# set C[i] to B[i]
   	sw 	$s6, 0($t6)       	# C[i]
   	addu 	$t5, $t5, $t9       	# t5+R
   	addi 	$t7, $t7, 1       	# j++
   	j   	colFliploop

#clean up after the column has been copied over 	
colFlipDone:
	move 	$t5 , $k0		#t5 = k0
	subu 	$t5,$t5,$t9		#t5 = k0-R
   	move 	$k1, $zero		#k1 =0
	addu 	$k1, $k1, $t5       	#k1=1
	mulu  	$t2,$t9,$t9		#set t2 to the last index N to check for end of column sorting
	j colShearloop5
	
#reset everything check if the sorting is complete branched to when col sort is complete
ResetLoop:
#set A to the data in C
	slt  	$t4, $t1, $t2    	# check if j<R*R
   	beq 	$t4, $zero, shear_loop  # branch if j=R*R	
   	sll 	$t6, $t1, 2       	# index*4
   	la 	$a1, A       		# load array A address
   	add 	$t6, $a1, $t6   	# set t6 to the address of A[i]
   	sll 	$t8, $t1, 2       	# index*4
   	la 	$a0, C       		# load array C address
   	add 	$t8, $a0, $t8       	# set t8 to the address C[i]
   	lw 	$s6, 0($t8)       	# set A[i] to C[i]
   	sw 	$s6, 0($t6)       	# C[i]
   	addi 	$t1, $t1, 1       	# i++
   	j   	ResetLoop

#Reset values	
ResetShear:
	la	$s7, C		#Reset address location
	move 	$k0, $zero	#Reset to 0
	move 	$t0, $zero	#used to calc log(r)
	addi 	$t0, $t0, 1     #set t0 to 1
	move 	$t1, $zero	#Reset to 0
	move 	$t2, $zero	#Reset to 0
	move 	$t3, $zero	#Reset to 0
	move 	$t5, $t9	#Set t5 to R this will be used to find log of R
	mulu 	$t2,$t9,$t9	#set t2 to R*R
   	la 	$a1, reg       	# load reg address t
   	lw  	$t6, 0($a1)  	# set t6 to the contents of reg
	addi 	$t6, $t6, 1	#Increment counter K
	sw 	$t6, 0($a1) 	#save counter K
	j	Log2Calc	#calculate log2(R)

#calculate Log(R)
Log2Calc:
	slt   	$t4, $t0, $t5    	#check if $t5= 2
   	beq 	$t4, $zero, CheckLog  	#branch if log(r) found	
	addi 	$t3, $t3, 1       	#counter
	srl  	$t5,$t5,1		#shift t5 by 1 bit to the right (t5/2)
   	j   	Log2Calc		#loop

#check if Log(R) loops have been completed	
CheckLog:
	addi 	$t3, $t3, 1		#Run log(R) times
	addi 	$t3, $t3, 1		#Run log(R) times
	slt   	$t4, $t6, $t3      	#check if k<log(R) 
   	beq 	$t4, $zero, ShearEnd 	#branch if k=log(R)	
	j ResetLoop


#end the program
ShearEnd:
	# invoke OS to display done message to user
	li  		$v0,4			# tell OS to print message
	la		$a0,message2		# load address of message
	syscall
	li 		$v0,10			# end of program
	syscall           	

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
#R=C=sqrt(N)
#for j-1 to LO(R)
#mergesort (even rows) ascending order
# for i to C/2
	#for j to R
		# Temp array C = 0,2,4,6,8...
	#end
	#increment R indexs
	#mergesort(c)
#end
	
#mergesort(odd rows) descending order
# for i to C/2
	#for j to R
		# Temp array C = 1,3,5,7...
	#end
	#increment R indexs
	#mergesort(c)
#end
#flip(c)
#mergesort(columns) ascending order
# for i to R
	#for j to C
		# Temp array C = 0,1,2,3..C
	#end
	#mergesort(c)
	#increment index by 1
#end
.globl merge_sort

merge_sort:
#Allocate space and store data that will be used.
   	addi 	$sp, $sp, -4       	# allocate 4 bytes in the stack  for return address
   	sw   	$ra, 0($sp)       	# store the return address in stack
   	la   	$a0, ($s3)       	# load temp array B address
   	la   	$a1, ($s0)      	# load unsorted array A address
   	add 	$a2, $zero, $t9     	# Set $a2 to N
   	addi   	$sp, $sp, -16   	# allocate space on the stack
   	sw   	$ra, 0($sp)       	# store the return address in stack
   	sw   	$a1, 8($sp)       	# store array As address 
   	add   	$a2, $a2, -1       	# set $a2 to N - 1
   	sw   	$a2, 4($sp)       	# store the value of N-1
   	sw   	$a3, 0($sp)       	# store low 
   	jal   	sort           		# Call Sort low, high

end:	
	move	$t0,$zero	# store index i in $t0, initially i = 0
	move	$t1,$zero	# store index j in $t0, initially j = 0
	move	$t2,$zero	# store index i in $t0, initially i = 0

	jal 	Setup1
	# invoke OS to display done message to user
	#li  	$v0,4				# tell OS to print message
	#la		$a0,message2		# load address of message
	#syscall
	#li 		$v0,10				# end of program
	#syscall           	

sort:
   	addi 	$sp, $sp, -20      	# allocate space
   	sw 	$ra, 16($sp)        # store return address
   	sw 	$s1, 12($sp)        # store elements in array 
   	sw 	$s2, 8($sp)         # store size (High)
   	sw 	$s3, 4($sp)         # store low 
   	sw 	$s4, 0($sp)         # store mid
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
   	sw 	$ra, 16($sp)        # store return address
   	sw 	$s1, 12($sp)        # store elements in array
   	sw 	$s2, 8($sp)         # store size (High)
   	sw 	$s3, 4($sp)         # store low
   	sw 	$s4, 0($sp)         # store mid
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
   	add 	$t6, $s7, $t6   		# set t6 to the address A[i]
   	lw 	$s5, 0($t6)       		# load A[i] in S5
   	sll 	$t7, $t2, 2       		# j*4
   	add 	$t7, $s7, $t7   		# set t7 to the address A[j]
   	lw 	$s6, 0($t7)       		# load A[j] in S6
   	slt 	$t4, $s5, $s6       	# check if A[i] < A[j]
   	beq 	$t4, $zero, else   		# branch to Else1 if A[i] >= A[j]
   	sll 	$t8, $t3, 2       		# k*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw $s5, 0($t8)       		# set B[k] to A[i]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t1, $t1, 1       		# increment i
   	j   	whileloop

else:
   	sll 	$t8, $t3, 2       		# i*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 	$s6, 0($t8)       		# set B[k] to A[j]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t2, $t2, 1       		# increment j
   	j   	whileloop

#while i <= mid
whileloop2: 
  	slt 	$t4, $s4, $t1       	# check if i > mid
   	bne 	$t4, $zero, whileloop3  # branch to whileloop3 if i> mid
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s7, $t6   		# set t6 to the address of A[i]
   	lw 	$s5, 0($t6)       		# set s5 to A[i]
   	sll 	$t8, $t3, 2       		# i*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 	$s5, 0($t8)       		# set B[k] to A[i]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t1, $t1, 1       		# increment i
   	j   	whileloop2

#while j < high
whileloop3: 
   	slt 	$t5, $s2, $t2       	# check if j >= high
   	bne 	$t5, $zero, reset   	# branch to loop if j>=high
   	sll 	$t7, $t2, 2       		# i*4
   	add 	$t7, $s7, $t7  			# set t7  to the address of A[j]
   	lw 	$s6, 0($t7)      		# set s6 to A[j]
   	sll 	$t8, $t3, 2       		# i*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 	$s6, 0($t8)       		# set B[k] to A[j]
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
   	add 	$t6, $s7, $t6   		# set t6 to the address of A[i]

   	sll 	$t8, $t1, 2       		# i*4
   	la 		$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8       	# set t8 to the address B[i]
   	lw 		$s6, 0($t8)       		# set A[i] to B[i]
   	sw 		$s6, 0($t6)       		# A[i]
   	addi 	$t1, $t1, 1       		# i++
   	j   	forloop


.globl oddmerge_sort

oddmerge_sort:
#Allocate space and store data that will be used.
   	addi 	$sp, $sp, -4       	# allocate 4 bytes in the stack  for return address
   	sw   	$ra, 0($sp)       	# store the return address in stack
   	la   	$a0, ($s3)       	# load temp array B address
   	la   	$a1, ($s0)      	# load unsorted array A address
   	add 	$a2, $zero, $t9     	# Set $a2 to N
   	addi   	$sp, $sp, -16   	# allocate space on the stack
   	sw   	$ra, 0($sp)       	# store the return address in stack
   	sw   	$a1, 8($sp)       	# store array As address 
   	add   	$a2, $a2, -1       	# set $a2 to N - 1
   	sw   	$a2, 4($sp)       	# store the value of N-1
   	sw   	$a3, 0($sp)       	# store low 
   	jal   	oddsort           		# Call Sort low, high

oddend:	
	move	$t0,$zero	# store index i in $t0, initially i = 0
	move	$t1,$zero	# store index j in $t0, initially j = 0
	move	$t2,$zero	# store index i in $t0, initially i = 0

	jal 	Flip
	# invoke OS to display done message to user
	#li  	$v0,4				# tell OS to print message
	#la		$a0,message2		# load address of message
	#syscall
	#li 		$v0,10				# end of program
	#syscall           	

oddsort:
   	addi 	$sp, $sp, -20      	# allocate space
   	sw 	$ra, 16($sp)        # store return address
   	sw 	$s1, 12($sp)        # store elements in array 
   	sw 	$s2, 8($sp)         # store size (High)
   	sw 	$s3, 4($sp)         # store low 
   	sw 	$s4, 0($sp)         # store mid
   	move	$s1,  $a1       	# set s1 to array address
   	move	$s2,  $a2       	# set s2 to array length - 1
   	move	$s3,  $a3       	# set s3 to the lower size
   	slt 	$t3, $s3, $s2       # check if low < high
   	beq 	$t3, $zero, oddreturn  # if low < high then  branch to return
   	add 	$s4, $s3, $s2       # add and store low + high in s4
   	div 	$s4, $s4, 2         # divide by 2 to get mid
   	move	$a2, $s4       		# mid
   	move	$a3, $s3       		# low
   	jal  	oddsort           		# recursively call Sort using low and mid

   	# Sort  mid+1, high
   	addi 	$t4, $s4, 1         # store mid+1 in t4
   	move	$a3, $t4       		# set low to mid+1 
   	move	$a2, $s2       		# set high to high
   	jal  	oddsort           		# recursively call Sort using mid+1 and high

   	#Merge data
   	move $a1, $s1       		# store the array address
   	move $a2, $s2       		# store high
   	move $a3, $s3       		# store low
   	move $a0, $s4       		# store mid
   	jal  oddmerge           		# merge elements
  
oddreturn:        
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
oddmerge:  
   	addi 	$sp, $sp, -20       # allocate space
   	sw 	$ra, 16($sp)        # store return address
   	sw 	$s1, 12($sp)        # store elements in array
   	sw 	$s2, 8($sp)         # store size (High)
   	sw 	$s3, 4($sp)         # store low
   	sw 	$s4, 0($sp)         # store mid
   	move 	$s1, $a1            # store array address in s1
   	move 	$s2, $a2       		# store high in s2
   	move 	$s3, $a3       		# store low in s3
   	move 	$s4, $a0       		# store mid in s4
   	move 	$t1, $s3       		# set t1 to i (low)
   	move 	$t2, $s4       		# set t2 to j (mid)
   	addi 	$t2, $t2, 1     	# add 1 to j (mid+1)
   	move	$t3, $a3       		# set t3 to k  (low)

#while i =< mid && j =< high
oddwhileloop:
   	slt 	$t4, $s4, $t1       	# check if i > mid
   	bne 	$t4, $zero, oddwhileloop2  # branch to whileloop2 if i > mid
   	slt 	$t5, $s2, $t2       	# check if high j > high 
   	bne 	$t5, $zero, oddwhileloop2  # branch to whileloop2 if j > high
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s7, $t6   		# set t6 to the address A[i]
   	lw 	$s5, 0($t6)       		# load A[i] in S5
   	sll 	$t7, $t2, 2       		# j*4
   	add 	$t7, $s7, $t7   		# set t7 to the address A[j]
   	lw 	$s6, 0($t7)       		# load A[j] in S6
   	slt 	$t4, $s5, $s6       	# check if A[i] < A[j]
   	beq 	$t4, $zero, oddelse   		# branch to Else1 if A[i] >= A[j]
   	sll 	$t8, $t3, 2       		# k*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw $s5, 0($t8)       		# set B[k] to A[i]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t1, $t1, 1       		# increment i
   	j   	oddwhileloop

oddelse:
   	sll 	$t8, $t3, 2       		# i*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 	$s6, 0($t8)       		# set B[k] to A[j]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t2, $t2, 1       		# increment j
   	j   	oddwhileloop

#while i <= mid
oddwhileloop2: 
  	slt 	$t4, $s4, $t1       	# check if i > mid
   	bne 	$t4, $zero, oddwhileloop3  # branch to whileloop3 if i> mid
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s7, $t6   		# set t6 to the address of A[i]
   	lw 	$s5, 0($t6)       		# set s5 to A[i]
   	sll 	$t8, $t3, 2       		# i*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 	$s5, 0($t8)       		# set B[k] to A[i]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t1, $t1, 1       		# increment i
   	j   	oddwhileloop2

#while j < high
oddwhileloop3: 
   	slt 	$t5, $s2, $t2       	# check if j >= high
   	bne 	$t5, $zero, oddreset   	# branch to loop if j>=high
   	sll 	$t7, $t2, 2       		# i*4
   	add 	$t7, $s7, $t7  			# set t7  to the address of A[j]
   	lw 	$s6, 0($t7)      		# set s6 to A[j]
   	sll 	$t8, $t3, 2       		# i*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 	$s6, 0($t8)       		# set B[k] to A[j]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t2, $t2, 1       		# increment j
   	j   	oddwhileloop3

oddreset:
   	move 	$t1,  $s3   			# set i to low
 
 #for i<k
oddforloop:
   	slt 	$t5, $t1, $t3       	# check if i<k
   	beq 	$t5, $zero, oddreturn   	# branch if i=k
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s7, $t6   		# set t6 to the address of A[i]
   	sll 	$t8, $t1, 2       		# i*4
   	la 		$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8       	# set t8 to the address B[i]
   	lw 		$s6, 0($t8)       		# set A[i] to B[i]
   	sw 		$s6, 0($t6)       		# A[i]
   	addi 	$t1, $t1, 1       		# i++
   	j   	oddforloop

.globl colmerge_sort

colmerge_sort:
#Allocate space and store data that will be used.
   	addi 	$sp, $sp, -4       	# allocate 4 bytes in the stack  for return address
   	sw   	$ra, 0($sp)       	# store the return address in stack
   	la   	$a0, ($s3)       	# load temp array B address
   	la   	$a1, ($s0)      	# load unsorted array A address

   	add 	$a2, $zero, $t9     	# Set $a2 to N
   	addi   	$sp, $sp, -16   	# allocate space on the stack
   	sw   	$ra, 0($sp)       	# store the return address in stack
   	sw   	$a1, 8($sp)       	# store array As address 
   	add   	$a2, $a2, -1       	# set $a2 to N - 1
   	sw   	$a2, 4($sp)       	# store the value of N-1
   	sw   	$a3, 0($sp)       	# store low 
   	jal   	colsort           		# Call Sort low, high

colend:	
	move	$t0,$zero	# store index i in $t0, initially i = 0
	move	$t1,$zero	# store index j in $t0, initially j = 0
	move	$t2,$zero	# store index i in $t0, initially i = 0

	jal 	colFlip
   	

colsort:
   	addi 	$sp, $sp, -20      	# allocate space
   	sw 	$ra, 16($sp)        # store return address
   	sw 	$s1, 12($sp)        # store elements in array 
   	sw 	$s2, 8($sp)         # store size (High)
   	sw 	$s3, 4($sp)         # store low 
   	sw 	$s4, 0($sp)         # store mid
   	move	$s1,  $a1       	# set s1 to array address
   	move	$s2,  $a2       	# set s2 to array length - 1
   	move	$s3,  $a3       	# set s3 to the lower size
   	slt 	$t3, $s3, $s2       # check if low < high
   	beq 	$t3, $zero, colreturn  # if low < high then  branch to return
   	add 	$s4, $s3, $s2       # add and store low + high in s4
   	div 	$s4, $s4, 2         # divide by 2 to get mid
   	move	$a2, $s4       		# mid
   	move	$a3, $s3       		# low
   	jal  	colsort           		# recursively call Sort using low and mid

   	# Sort  mid+1, high
   	addi 	$t4, $s4, 1         # store mid+1 in t4
   	move	$a3, $t4       		# set low to mid+1 
   	move	$a2, $s2       		# set high to high
   	jal  	colsort           		# recursively call Sort using mid+1 and high

   	#Merge data
   	move $a1, $s1       		# store the array address
   	move $a2, $s2       		# store high
   	move $a3, $s3       		# store low
   	move $a0, $s4       		# store mid
   	jal  colmerge           		# merge elements
  
colreturn:        
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
colmerge:  
   	addi 	$sp, $sp, -20       # allocate space
   	sw 	$ra, 16($sp)        # store return address
   	sw 	$s1, 12($sp)        # store elements in array
   	sw 	$s2, 8($sp)         # store size (High)
   	sw 	$s3, 4($sp)         # store low
   	sw 	$s4, 0($sp)         # store mid
   	move 	$s1, $a1            # store array address in s1
   	move 	$s2, $a2       		# store high in s2
   	move 	$s3, $a3       		# store low in s3
   	move 	$s4, $a0       		# store mid in s4
   	move 	$t1, $s3       		# set t1 to i (low)
   	move 	$t2, $s4       		# set t2 to j (mid)
   	addi 	$t2, $t2, 1     	# add 1 to j (mid+1)
   	move	$t3, $a3       		# set t3 to k  (low)

#while i =< mid && j =< high
colwhileloop:
   	slt 	$t4, $s4, $t1       	# check if i > mid
   	bne 	$t4, $zero, colwhileloop2  # branch to whileloop2 if i > mid
   	slt 	$t5, $s2, $t2       	# check if high j > high 
   	bne 	$t5, $zero, colwhileloop2  # branch to whileloop2 if j > high
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s7, $t6   		# set t6 to the address A[i]
   	lw 	$s5, 0($t6)       		# load A[i] in S5
   	sll 	$t7, $t2, 2       		# j*4
   	add 	$t7, $s7, $t7   		# set t7 to the address A[j]
   	lw 	$s6, 0($t7)       		# load A[j] in S6
   	slt 	$t4, $s5, $s6       	# check if A[i] < A[j]
   	beq 	$t4, $zero, colelse   		# branch to Else1 if A[i] >= A[j]
   	sll 	$t8, $t3, 2       		# k*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw $s5, 0($t8)       		# set B[k] to A[i]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t1, $t1, 1       		# increment i
   	j   	colwhileloop

colelse:
   	sll 	$t8, $t3, 2       		# i*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 	$s6, 0($t8)       		# set B[k] to A[j]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t2, $t2, 1       		# increment j
   	j   	colwhileloop

#while i <= mid
colwhileloop2: 
  	slt 	$t4, $s4, $t1       	# check if i > mid
   	bne 	$t4, $zero, colwhileloop3  # branch to whileloop3 if i> mid
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s7, $t6   		# set t6 to the address of A[i]
   	lw 	$s5, 0($t6)       		# set s5 to A[i]
   	sll 	$t8, $t3, 2       		# i*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 	$s5, 0($t8)       		# set B[k] to A[i]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t1, $t1, 1       		# increment i
   	j   	colwhileloop2

#while j < high
colwhileloop3: 
   	slt 	$t5, $s2, $t2       	# check if j >= high
   	bne 	$t5, $zero, colreset   	# branch to loop if j>=high
   	sll 	$t7, $t2, 2       		# i*4
   	add 	$t7, $s7, $t7  			# set t7  to the address of A[j]
   	lw 	$s6, 0($t7)      		# set s6 to A[j]
   	sll 	$t8, $t3, 2       		# i*4
   	la 	$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8   		# set t8 to the address B[k]
   	sw 	$s6, 0($t8)       		# set B[k] to A[j]
   	addi 	$t3, $t3, 1       		# increment k
   	addi 	$t2, $t2, 1       		# increment j
   	j   	colwhileloop3

colreset:
   	move 	$t1,  $s3   			# set i to low
 
 #for i<k
colforloop:
   	slt 	$t5, $t1, $t3       	# check if i<k
   	beq 	$t5, $zero, colreturn   	# branch if i=k
   	sll 	$t6, $t1, 2       		# i*4
   	add 	$t6, $s7, $t6   		# set t6 to the address of A[i]
   	sll 	$t8, $t1, 2       		# i*4
   	la 		$a0, B       			# load temp array B address
   	add 	$t8, $a0, $t8       	# set t8 to the address B[i]
   	lw 		$s6, 0($t8)       		# set A[i] to B[i]
   	sw 		$s6, 0($t6)       		# A[i]
   	addi 	$t1, $t1, 1       		# i++
   	j   	colforloop


	

	
