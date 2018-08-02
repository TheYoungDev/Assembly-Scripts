#--------------------------------------------------------------------------
# 3DR4: FP_ADD function, Reading Week, Thurs, Feb-22, 2018
# Lets write an FP-ADD function using MIPS instructions :
#---------------------------------------------------------------------------

.data
	message0: .asciiz 	"\nEnter the multiplicand : "
	message1: .asciiz 	"\nEnter the multiplier: "
	message2: .asciiz 	"\nResult of MIPS instruction MUL.S is  : "
	message3: .asciiz 	"\nResult of 3DR4 FP-MP function is     : "	
	
	message4:  .asciiz	"\n1ST FP significand is : "
	message5:  .asciiz	"\n2ND FP significand is : "
	
	N1: 	.float 0	# multiplicand (replaced with user input)
	N2:	.float 10	# multiplier (replaced with user input)
	V: 	.word 130 	# store the base case exponent (hex 80)
.text
	.globl main
	
main:	
	
	#--- set 2 default FP numbers into registers $f0 and $f1 ----
	lwc1		$f1,N1 # multiplicand (replaced with user input)
	lwc1		$f2,N2 # multiplier (replaced with user input)
	lw		$s0, V # store the base case exponent (hex 80)
	
	#--- request user enter  multiplicand and multiplier---
	li $v0,4
	la $a0, message0	# dispaly msg
	syscall
	li $v0, 6 		# Request float store in f0
	syscall
	mov.s 	$f1,$f0 	# Move entered float to f1 from f0
	
	li $v0,4
	la $a0, message1	# dispaly msg
	syscall
	li $v0, 6		# Request float store in f0
	syscall
	mov.s 	$f2,$f0 	# Move entered float to f2 from f0
	
	#--- call MIPS ADD.S instruction for single-precision FP add ---
	mul.s		$f3,$f2,$f1	# fp-mul  f3 = f0 * f1 (single-precision)	
	
	#--- print result of MIPS ADD.s instruction ----
	li  		$v0,4		# first tell OS to print message
	la		$a0,message2
	syscall
	
	#--- print result of ADD.S instruction in $f10 ----
	li		$v0,2		# then tell OS to print FP # in $f12
	mov.s		$f12,$f3
	syscall
	
	#------ now call 3DR4 FP-ADD function --------
	# 2 FP arguments are in INT registers $a0 and $a1  
	# return FP result in INT register $v0
	#---------------------------------------------
	mfc1		$a0,$f2		# copy 1st argument into $a0  
	mfc1		$a1,$f1		# copy 2nd argument into $a1
	jal		FP_MUL		# call function, FP result returned in $v0
	
	mtc1		$v0,$f4		# copy FP result in $v0 to $f4
	
	#--- now print result of our FP-ADD function ----
	li  		$v0,4		# tells OS to print message
	la		$a0,message3
	syscall
	
	#--- print result of our FP-ADD function which is in $f4 ----
	li		$v0,2		# tell OS to print FP # in $f12
	mov.s		$f12,$f4
	syscall
	
done:	
	#--- terminate the program ----
	li		$v0,10	# tell OS we are done
	syscall

#------------------------------------------------------------
# define the 3DR4 FP_ADD function, 2 arguments:
# $a0 =  first 32-bit FP number
# $a1 = second 32-bit FP number
# $v0 = the returned result, a 32-bit FP number
# $s0 = store the base case exponent (hex 80)
# Assume both FP numbers are positive and > 0
#------------------------------------------------------------
# this code uses these registers, and works !  
# $t0  = exponent(0), 8 bits
# $t1  = exponent(1), 8 bits
# $t2  = significand(0), 23 bits plus leading '1'
# $t3  = significand(1), 23 bits plus leading '1'
# $t4  = flag set when comparing exponents
# $t5  = larger exponent (use for final answer)
# $t6  = sum of 2 significands (after smaller one is shifted right)
# $t7  = set to the difference between the largest exponent and the base case  
# $t8  = used to determine and store the sign of the multiplier
# $t9  = store the sign of resultant multiplcation  
#------------------------------------------------------------
.globl FP_MUL

FP_MUL:
	#--- extract exponents ---
	andi	$t0,$a0,0x7F800000	# extract exponent(0)
	andi	$t1,$a1,0x7F800000	# extract exponent(1)
	srl	$t0,$t0, 23		# shift exp(0) right, 23 bits
	srl	$t1,$t1, 23		# shift exp(1) right, 23 bits
	
	#--- extract sign ---
	andi   	$t8, $a0,0x80000000	# check sign (0)
	andi  	$t9, $a1,0x80000000	# check sign (1)
	xor 	$t9, $t9,$t8		# store the sign of resultant multiplcation XOR(Sign(1), Sign2) 
	
	#--- extract significand ---
	andi	$t2,$a0,0x007FFFFF	# extract significand(0), 23 bits
	andi	$t3,$a1,0x007FFFFF	# extract significand(1), 23 bits
		
	#---  lets add implied '1' in bit-24 of significands ---
	ori		$t2,$t2, 0x00800000	# set implied '1' bit in significand(0)
	ori		$t3,$t3, 0x00800000	# set implied '1' bit in significand(1)

	#---  lets compare the exponents ---
	slt		$t4,$t0,$t1		# set t4 if exp(0) < exp(1)	
	beq		$t4,$zero, EXP0_larger
	
EXP1_larger:
	#------- to get here, the exp(0) < exp(1)   ------------------
	# shift significand(0) in $t2 to become smaller (shift right)
	# multiply significands and store the result in $t6 (after shifting significand(0) left) 
	# set t7 to the difference in exponents and shift t6 left 10 bits.
	#-------------------------------------------------------------
	sub		$t5,$t1,$t0		# compute difference of exps
	srav		$t2,$t2,$t5		# shift significand(0) in t2 right, $t5 times
	mul  		$t6,$t2,$t3		# multply significands, t6 = t2 * t3
	mfhi		$t6			# move value stored in hi to t6
	sll 		$t6, $t6, 10 		# shift t6 to the correct bit location
	and		$t5,$t1,$t1		# t5 = original larger exponent(1) 
	sub  		$t7,$t1,$s0		# set t7 to the difference between base exp and exp(1)
	j 		CONTINUE
	
EXP0_larger:
	#-------  to get here, the exp(0) > exp(1)  ------------------
	# shift significand(1) in $t3 to become smaller (shift right)
	# multiply significands and store the result in $t6 (after shifting significand(0) left) 
	# set t7 to the difference in exponents and shift t6 left 10 bits.
	#-------------------------------------------------------------
	sub	$t5,$t1,$t0		# compute difference of exps
	sub	$t5,$t0,$t1		# compute difference of exponents
	srav	$t3,$t3,$t5		# shift significand(1) in t3 right, $t5 times
	mul  	$t6,$t3,$t2		# multply significands, t6 = t2 * t3 
	mfhi	$t6			# move value stored in hi to t6
	sll 	$t6, $t6, 10		# shift t6 to the correct bit location
	and  	$t5,$t0,$t0		# t5 = original larger exponent(0) 
	sub  	$t7,$t0,$s0		# t7 = to the difference between base exp and exp(0)

	#------  overflow occurs if sum of 2 significands exceeds 24 bits ------
	# we need a mask with a '1' followed by 24 zeros
	# 24 zeros are given by 6 hex digits 0x000000
	# our desired mask is   0x01000000
	# loop until there is no longer any overflow
	#-----------------------------------------------------------------------

CONTINUE:
	#------  overflow occurs if sum of 2 significands exceeds 24 bits ------
	# we need a mask with a '1' followed by 24 zeros
	# 24 zeros are given by 6 hex digits 0x000000
	# our desired mask is   0x01000000
	# loop until there is no longer any overflow
	#-----------------------------------------------------------------------
	sge		$t4, $t6, 0x01000000	# check for overflow
	beq		$t4, $zero, NO_OVERFLOW
	srl		$t6,$t6,1		# handle overflow, shift t6 down 4 bit  s
	addi		$t5,$t5,1		# increment exponent by 1
	sge		$t4, $t6, 0x01000000	# check for overflow
	bne 		$t4, $zero, CONTINUE	# loop if there is more overflow
	
	
	
NO_OVERFLOW:
	#-------- assume correct significand is in $t6 ----------
	# strip leading '1' from significand
	# add the difference between the exponents to the output exp 
	# add the sign to the final output 
	# return the final result
	#---------------------------------------------------------
	andi		$t6,$t6,0x007FFFFF	# remove leading `1'	
	add  		$t5,$t5,$t7		# add t7 to t5
	add		$t6,$t9,$t6		# add the sign to the final output
	sll		$t5,$t5,23		# shift exponent up 23 bits
	or		$v0,$t5,$t6		# OR exponent with significand
	jr		$ra			# return to caller
	
	
