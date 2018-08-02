#Recursive-factorial1-2018.asm - 1 - January 24, 2018 2:11 PM
 #-----------------------------------------------------------------------
 # 3DR4: Computer Organization, L8, Tues., Jan. 23, 2018, Prof. T. Szymanski
 # ---------------- a RECURSIVE FACTORIAL FUNCTION ----------------------
 # Shows how to push registers onto a stack when entering a function
 # Shows how to pop registers off the stack when leaving a function # this process frees up those registers, so that they can be used
 # Also PUSH and POP THE RETURN ADDRESSS REGISTER $RA onto/off the stack
 #-----------------------------------------------------------------------

 .data
 message1: .asciiz "Enter number : "
 message2: .asciiz "The Result is : "

 N: .word 0
 Answer: .word 0

 .text
 .globl main

 main: #--- ask user to enter number ---
 li $v0,4 # tell OS to print message
 la $a0, message1
 syscall

 #--- get number N from user ---
 li $v0,5 # tell OS to read word from user
 syscall # result is in v0
 sw $v0, N # copy result into memory (address N)

 #--- call the factorial function ---
 lw $a0,N # enter argument N into argument register a0
 jal Factorial
 sw $v0,Answer # store result in v0 to memory (with address Answer)

 #--- display result, message first ----
 li $v0,4 # tell OS to print message
 la $a0,message2
 syscall

 #--- display result, the number ---
 li $v0,1 # tell OS to print an integer
 lw $a0, Answer
 syscall

 #--- tell OS that we have reached end of program ---
 li $v0,10
 syscall

 #----------------------------------------------------------
 # define the factorial function, with 2 ARGUMENTS / PARAMETERS
 # $a0 stores the argument N
 # $v0 stores the returned result, ie answer
 # function will use $s0 internally, we must save $s0, before recursion
 #-----------------------------------------------------------
 .globl Factorial
 Factorial:
 #------------------------------------------------------
 # PUSH 2 REGISTERS onto STACK, to free them up ($ra, $s0)
 # NOTE: Push the RETURN ADDRESS REGISTER onto the stack, before recursion
 #-------------------------------------------------------
 addi $sp,$sp,-8 # make room on stack for 2 words (8 bytes)
 sw $ra,0($sp) # store return address $ra onto stack
 sw $s0,4($sp) # store $s0 onto stack, as we will use it internally

 #--- test for end case (argument == 0) to terminate recursion ----
#Recursive-factorial1-2018.asm - 2 - January 24, 2018 2:11 PM
 li $v0,1 # set result v0 == 1 (ie factorial(0) == 1)
 beq $a0,0,Done

 #--- else, find factorial(argument-1) and multiply by argument ---
 move $s0,$a0 # save a copy of current argument a0 in s0
 sub $a0,$a0,1 # decrement argument a0 and call function recursively
 jal Factorial # factorial(N-1) returned in register v0

 mul $v0,$s0,$v0 # multiply result (in v0) by current argument in s0

 Done:
 #-------------------------------------------------------
 # POP 2 REGISTERS from STACK, to restore their values
 # Pop the same registers from the stack, to retore their values
 # Pop the RETURN ADDRESS REGISTER from the stack, to restore its value
 #-------------------------------------------------------

 lw $ra,0($sp) # restore return address from stack
 lw $s0,4($sp) # restore register s0 to original value, from stack
 addi $sp,$sp,8 # restore stack pointer to original value

 jr $ra # return to caller

