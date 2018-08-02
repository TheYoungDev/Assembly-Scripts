#---------------------------------------------------2:#3DR4-uploadedFri,Feb.2,20183:#4:#EXAMPLE:Cleararrayinmemorywithfunction-POINTERversion5:#6:#writeaword-valueVintoavectorA,Ntimes7:#---------------------------------------------------8:#storebase-addressofvectorAinaregister9:#storevalueNinaregister10:#storevalueVinaregister11:#12:#call-functionclear_memory(intA,intN,intV)13:#14:#tellOSthatwearefinishedrunning15:#andprintmessagetouser,'wearedone'16:#17:#functionclear_memory(intA[],intN,intV){18:#inti;19:#for(i=0;i<N;i++)20:#A[i]=v;21:#}22:#---------------------------------------------------23:24:.data25:26:A:.space32#reserve1KforvectorA[]27:28:N:.word8#N=6429:30:V:.word137#valueVtowritetomemory31:32:message1:.asciiz"We'redone!"33:34:.text35:36:main:37:#letsput'constants'in$s(saved)registers38:la$s0,A#$a0hasbaseaddressofarrayA,ie&A[0]39:lw$s1,N#$s1hasvalueN40:lw$s2,V#$s2hasvaluetowriteintomemory41:42:#letscallafunction,ituses$s0,$s1,$s243:jalclear_memory#callfunction,storesreturnaddressin$ra44:45:46:#-----someextracodetofinishoffcleanly-----------47:48:#displaydonemessagetouser49:li$v0,4#tellOStoprintmessage50:la$a0,message1#loadaddressofmessage51:syscall52:53:54:#tellOSthatwehavereachedendofprogram55:li$v0,1056:syscall57:58:#--------------------------------------------------------------59:#STARTofclear_memoryfunction,POINTERVERSION60:#functionclear_memory(intA[],intN,intV)61:#3ARGUMENTSareinregisters$s0,$s1,$s262:#$s0storesthebase-addressofA,ieaddressA[0]63:#$s1storesN,numberoftimestowritetomemory64:#$s2storesV,thevaluetowritetomemory65:#--------------------------------------------------------------1: #---------------------------------------------------
# 3DR4 - uploaded Fri, Feb. 2, 2018
#
#4: # EXAMPLE: Clear array in memory with function - POINTER version 5: #
#rite a word-value V into a vector A , N times
#---------------------------------------------------
#	store base-address of vector A in a register 9: #	store value N	in a register
 #	store value V	in a register 11: #
 #	call-function clear_memory(int A, int N, int V) 13: #
 #	tell OS that we are finished running 15: #	and print message to user, 'we are done' 16: #
 #	function clear_memory(int A[], int N,	int V)	{ 18: #	int	i;
 #	for (i = 0; i < N;	i++) 20: #		A[i] = v;
 #	}
 #---------------------------------------------------

 .data

 A: .space 32	# reserve 1K	for vector A[] 27:
 N: .word	8	# N = 64

 V: .word 137	# value V to write to memory 31:
 message1: .asciiz	"We're done !" 33:
 .text

 main:
	# lets put 'constants' in $s (saved) registers
	la	$s0, A	# $a0 has base address of array A, ie &A[0] 39:	lw	$s1, N	# $s1 has value N
	lw	$s2, V	# $s2 has value to write into memory 41:
	# lets call a function, it uses $s0, $s1, $s2
	jal	clear_memory	# call function, stores return address in $ra 44:

	#----- some extra code to finish off cleanly ----------- 47:
	# display done message to user
	li		$v0,4	# tell OS to print message 50:	la	$a0,message1	# load address of message 51:	syscall


	# tell OS that we have reached end of program 55:	li	$v0,10
	syscall

 #--------------------------------------------------------------
 # START of clear_memory function, POINTER VERSION 60: # function clear_memory(int A[], int N,	int V) 61: # 3 ARGUMENTS are in registers $s0, $s1, $s2
 # $s0 stores the base-address of A, ie address A[0] 63: # $s1 stores N, number of times to write to memory #--------------------------------------------------------------
 clear_memory:
	move		$t0,$s0 # store base-address of A, &A[0], in register t0 68:	sll	$t1,$s1,2	# multiply N by 4
	add	$t1,$t0,$t1 # find address of A[N], for termination 70: loop:
	sw	$s2,0($t0)	# write value V into memory A[i] 72:	addi		$t0,$t0,4	# increment pointer by 4 bytes 73:
	slt	$t2,$t0,$t1 # set $t3 = 1 if pointer < &A[N] 75:	bne	$t2,$zero,loop

	jr	$ra	# return address stored in $ra
