 #---------------------------------------------------
# 3DR4 - Thurs, Feb 1, 2018
# EXAMPLE: String Copy function from class notes
#---------------------------------------------------
#	(C pseudo-code) #
#	void strcpy ( char	x[], char	y[] ) # {
#	int i;
 #	i = 0;
 #	while ((x[i] = y[i]) != ‘\0’) 12: #	i +=1;
 # }
 #---------------------------------------------------
 # base address of string x in $a0 16: # base address of string y in $a1
 # internal variable i will be stored in register $t0 18: #--------------------------------------------------
 .data

 y:	.asciiz	"Hello!!"	# this message has 8 bytes = 2 words
 x:	.space	16		# reserve space (16 words) for string x being written 23: message1:	.asciiz	"We are done !!"

 .text

 main:
	# lets put addresses in $a (argument) registers
     la     $a0, x     # $a0 has base address of string x, ie &x[0] 30:     la     $a1, y     # $a1 has base address of string y, ie &y[0] 31:
	# lets call our function, it uses $s0, $s1, $s2
	jal	STRCPY	# call function, stores return address in $ra 34:
	#----- some extra code to finish off cleanly ----------- 36:
	# display done message to user
	li		$v0,4	# tell OS to print message 39:	la	$a0,message1	# load address of message 40:	syscall


	# tell OS that we have reached end of program 44:	li	$v0,10
	syscall

 #--------------------------------------------------------------
 # function STRCPY(char x[], char y[]) 49: # 2 ARGUMENTS are in registers $a0, $a1
 # $a0 stores the base-address of x, ie address x[0] 51: # $a1 stores the base-address of y, ie address y[0]
 # $s0 used internally, so it must be saved on entry, restored on exit 53: #--------------------------------------------------------------
 STRCPY:
	addi	$sp,$sp,-4
	sw	$s0,0($sp)	# push register $s0 onto stack
	add	$s0, $zero, $zero	# clear register $s0, ($s0 = index or address-offs et)

 L1:	add	$t1,$s0,$a1		# create address Y[i] 60:	lbu		$t2, 0($t1)	# read one byte Y[i]
	add	$t3,$s0,$a0	# create address X[i] 62:	sb	$t2, 0($t3)	# copy one byte to X[i]
	beq	$t2, $zero, L2	# Copied last byte? Yes, go to L2
	addi	$s0, $s0, 4	# increment address-offset BY 1 BYTE !!
	j L1

 L2:		lw	$s0,0($sp)	# pop register $s0 from stack 68:	addi	$sp,$sp,4
	jr	$ra
