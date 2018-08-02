.data

Z:.space 4096	#Vector Z space = 4*N
#X:.space 4096	#Vector Y space = 4*N
#Y:.space 4096	#Vector X space = 4*N

X:
.word	1,2,3,4,5,6,7,8,9,10,12,11,13,14,15,16

Y:
.word	1,2,3,4,5,6,7,8,9,10,12,11,13,14,15,16

N: .word 16	#length N
a: .word 5	#constant a

msg: .ascii "done"
#sudo code
#function ( int a, int X[],int Y[],int Z[]){
#	for(i=0 i<N i++){
#		Z[i] = a*X[i] +Y[i]
#	}	
#}



#
#
#
#
#
#
#
#
#
#

.text
move $t0,$zero

la	$s0,X #Vector X
la	$s1,Y #Vector Y
la	$s2,Z #Vector Z
lw	$s3,N #length N
lw	$s4,a #constant
Loop:
		#Z[i] = a*X[i] +Y[i]
		beq $t0,$s3,END
		lw  $t1,0($s0) 	#X[i]
		mul  $t1,$t1,$s4 #a*X[i]
		lw  $t2,0($s1) 	#Y[i]
		add $t3,$t1,$t2 #Z[i] = a*X[i]+ Y[i]
		sw  $t3,0($s2) 	#X[i]
		add $t0,$t0,1	#i++
		add $s0,$s0,4 	#X*+4
		add $s1,$s1,4 	#Y*+4
		add $s2,$s2,4 	#Z*+4
		j Loop		#loop
	
	
END:
	li $v0,10
	la,$a0,msg
	syscall
	li $v0,4
	syscall