.data
a: .space 256	#64 integers*4bytes per int
.text
	addi $t9,$t9,64
	addi $t8,$zero,0
storingloop:
	sub,$t9,$t9,1
	add $t6,$0,$t9
	sw $t6,a($t8)
	add $t8,$t8,4
	bgtz $t9,storingloop