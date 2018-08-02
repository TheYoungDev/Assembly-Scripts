.text
main:
li $t0, 0x100
li $t1, 0x200

move $t2, $t0
move $t0, $t1
move $t1, $t2

syscall

