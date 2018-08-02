.data

Z:.space 4096	#Vector Z space = 4*N
#X:.space 4096	#Vector Y space = 4*N
#Y:.space 4096	#Vector X space = 4*N

X: #for testing
.float	1.1,2,3,4,5,6,7,8,9,10,12,11,13,14,15,16

Y:#for testing
.float	1,2,3,4,5,6,7,8,9,10,12,11,13,14,15,16

N: .word 16	#length N
#a: .word 5	#constant a
a:  .float 5.5	# constant a
msg: .ascii "done"
#sudo code
#function ( int a, int X[],int Y[],int Z[]){
#	for(i=0 i<N i++){
#		Z[i] = a*X[i] +Y[i]
#	}	
#}
#
#t0 = counter
.text
move $t0,$zero

la	$s0,X #Vector X
la	$s1,Y #Vector Y
la	$s2,Z #Vector Z
lw	$s3,N #length N
lwc1 	$f2,a #constant
Loop:
		#Z[i] = a*X[i] +Y[i]
		beq $t0,$s3,END
		lwc1  $f1,0($s0) 	#X[i]
		mul.s  $f1,$f1,$f2 	#a*X[i]
		lwc1  $f3,0($s1) 	#Y[i]
		add.s $f4,$f1,$f3 	#Z[i] = a*X[i]+ Y[i]
		swc1  $f4,0($s2) 	# set &Z[i] to a*X[i]+ Y[i]
		add $t0,$t0,1		#i++
		add $s0,$s0,4 		#X*+4
		add $s1,$s1,4 		#Y*+4
		add $s2,$s2,4 		#Z*+4
		j Loop			#loop
	
	
END:
	li $v0,10	#get rdy to print msg
	la,$a0,msg	#print msg
	syscall
	li $v0,4
	syscall
