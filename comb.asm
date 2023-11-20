######################################################################## 
# Function Name: int comb()
######################################################################## 
# Functional Description:
# This routine gets the input of n and r and checks if they are in the 
# valid range. Then if n equals r return 1 for the function. If not
# recursively call comb(n,r) = comb(n-1,r) + comb(n-1,r-1). Then it will
# display the answer for the function.
# ######################################################################## 
# Register Usage in the Function:
# $a0 holds n for the recursive function. It is one of the arguments
# $a1 holds r for the recursive function. It is one of the arguments
# it is going to be useful to counter the loop
# $sp holds the values for the stack
# 0($sp) holds the return value
# 4($sp) holds n
# 8($sp) holds r
# 12($sp) holds sum
# 16($sp) holds a temporary sum
# $v0 ultimately used to store the value of the final value returned from
# our function
# ######################################################################## 
# Algorithmic Description in Pseudocode:
# 1. Ask user to enter n and r
# 2. checkR and checkN check if n and r are in the correct range, if so
#    store them in $a0 and $a1
# 3. Call comb function which first checks the conditions to return 1. If
#    meets the conditions call to end function and return 1.
# 4. If not then prepare the stack  
# 5. Enter into loop phase, calculate comb(n-1,r) and comb(n-1,r-1). Then
#    add them together with temp stack value. So add them to saved sum stack
#    value.
# 6. At end of loop phase check if we need to loop again. Recursion ends when
#    r = 0. So if r doesn't equal 0 keep looping. 
# 7. When finished looping store sum 12($sp) into $v0. 
# 8. Store $v0 into combResult so that we can print it after we print
#    combTellingResult which helps display combResult in a fancy way.
# 9. Terminate function. 
# ########################################################################

.data
	askForN: .asciiz "Enter the value for n: \n"
	askForR: .asciiz "\nEnter the value for r: \n"
	promptCorrectR: .asciiz "You entered wrong value for r, please make sure you enter a positive integer: \n"
	promptCorrectN: .asciiz "You entered wrong value for n, please make sure you enter a positive integer and make sure it is greater than r: \n"
	combTellingResult: .asciiz "The value for the combination is: "
	newLine: .asciiz "\n"
	displayR: .asciiz "The value of r is: "
	displayN: .asciiz "The value of n is: "
	combResult: .word 0 #The result of the comb method will be here
	n: .word 0 #declaring int n
	r: .word 0 #declaring int r
	.align 2
	.globl main
.text 

main:	
#Asking for n
	li $v0, 4 #getting and confirming r variable
	la $a0, askForR
	syscall
	jal checkR
	
	li $v0, 4 #getting and confirming n variable
	la $a0, askForN
	syscall
	jal checkN
	
	#displaying r
	li $v0, 4
	la $a0, displayR
	syscall
	li $v0, 1
	lw $a0, r
	syscall
	li $v0, 4
	la $a0, newLine 
	syscall
	
	#displaying n
	li $v0, 4
	la $a0, displayN
	syscall
	li $v0, 1
	lw $a0, n
	syscall
	li $v0, 4
	la $a0, newLine 
	syscall
	
	lw $a0, n
	lw $a1, r

	jal comb
	sw $v0, combResult #storing result in combResult
	li $v0, 4
	la $a0, combTellingResult #Getting ready to display result
	syscall
	
	li $v0, 1
	lw $a0, combResult #displaying result
	syscall
	
	li $v0, 10 #ending the program
	syscall
	
comb:
	li $v0, 1 #base case
	beq $a0, $a1, done #recheck later
	beq $a1, $zero, done
	
	#setup stack
	addiu $sp, $sp, -20
	sw $ra, 0($sp) #return value
	sw $a0, 4($sp) #n
	sw $a1, 8($sp) #r
	sw $zero, 12($sp) #sum. 16($sp) is temp
	
	loop: 
		#comb(n-1, r)
		lw $a0, 4($sp)
		addi $a0, $a0, -1
		jal comb
		sw $v0, 16($sp)
		
		#comb(n-1, r-1), keep in $v0 I hope
		lw $a0, 4($sp)
		lw $a1, 8($sp)
		addi $a0, $a0, -1
		addi $a1, $a1, -1
		jal comb
		
		#add the statements
		lw $a0, 16($sp)
		add $a0, $v0, $a0
		
		#add to sum
		lw $v0, 12($sp)
		add $v0, $v0, $a0
		sw $v0, 12($sp)
		
		#loop counter
		bne $a1, $zero, loop
		
		#Done, get sum
		lw $v0, 12($sp) #store sum into $v0
		lw $ra, 0($sp) 
		addiu $sp, $sp, 20 #clean up stack
	done: jr $ra
		
		



checkR: #check if r meets conditions, also loading r
	li $v0, 5
	syscall 
	sw $v0, r #storing input into variable r
	lw $a0, r
	lw $a1, r #so I can compare with n for check n subroutine
	blt $a0, $zero, wrongValueR #if less than zero go to subroutine to say error
	jr $ra
checkN: #loading and checking n
	li $v0, 5
	syscall 
	sw $v0, n #storing input into variable n
	lw $a0, n
	blt $a0, $zero, wrongValueN
	blt $a0, $a1, wrongValueN #n has to be greater than r
	jr $ra
wrongValueR:
	li $v0, 4
	la $a0, promptCorrectR
	syscall
	j checkR #jump to ask for r again
wrongValueN:
	li $v0, 4
	la $a0, promptCorrectN
	syscall
	j checkN
	
	