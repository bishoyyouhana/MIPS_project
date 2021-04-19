#First stage of MP4 Program for ECE 201
#Bishoy Baher Youhana
#4/13/2021 

	.data
	
m:		.word 0x01094820	, 0x012a5020	, 0x022a9020 	, 0x01094820, 0x012a5020 	, 0x024a9820 	, 0x01094820 	, 0x012a5020 	, 0x026aa020 	, 0x01094820 	, 0x012a5020 	,0x028aa820 	, 0x1000ffff
space:  .byte ' '

.align 2
r:		.space 128

#for traceout " ir=" " a=" " b=" " aluout=" "\n" " v0=" " a0=" " a1=" " t1=" " t2=" " t4=" "\n"
# " s1=" " s2="  " s3=" " s4=" " s5=" "\n"
pc:   .asciiz "pc= " 
ir:   .asciiz " ir= "
a:   .asciiz " a= "
b1:   .asciiz " b= "
alout:   .asciiz " aluout= "  #"\n"
v0:   .asciiz "          v0= "
a0:   .asciiz " a0= "
a1:   .asciiz " a1= "
t1:   .asciiz " t1= "
t2:   .asciiz " t2= "
t4:   .asciiz " t4= " #"\n"
s1:   .asciiz "          s1= "
s2:   .asciiz " s2= "
s3:   .asciiz " s3= "
s4:   .asciiz " s4= "
s5:   .asciiz " s5= " #"\n"
newLine:	.asciiz "\n" 
reached: .asciiz "reached"

	.text
	.globl main
main:
	la $s0, m
	la $s3, r
	
	addi $t0, $zero, 6
	sw $t0 ,32($s3)
	
	addi $t0, $zero, 1
	sw $t0 ,40($s3)
	sw $t0 ,68($s3)
	
	addi $s1, $zero, 0 #pc
	#addi $s2, $zero, 0 #ir
	lw $s2, 0($s0) #ir
	
	loop:
		beq $s2, 0x1000FFFF, exit
		#a = r[extract(ir,25,21)];
		addi $a0, $s2, 0
		addi $a1, $zero, 25
		addi $a2, $zero, 21
		jal extract
		#v1 = extract(ir,25,21) use t8 to get r[extract(ir,25,21)]
		sll $t8, $v1, 2
		add $t1, $t8, $s3
		lw $s4, 0($t1)
		
		#b = r[extract(ir,20,16)];
		addi $a0, $s2, 0
		addi $a1, $zero, 20
		addi $a2, $zero, 16
		jal extract
		#v1 = extract(ir,20,16) use t8 to get r[extract(ir,20,16)]
		sll $t8, $v1, 2
		add $t1, $t8, $s3
		lw $s5, 0($t1)
		
		jal tracecout
		
		#opcode = extract(ir,31,26);
		addi $a0, $s2, 0
		addi $a1, $zero, 31
		addi $a2, $zero, 26
		jal extract
		addi $s6, $v1, 0
		
		#if (opcode == 0){ 
		bne $s6, $zero, ifN0
		
		#aluout = alufunc(a, b, extract(ir, 10, 0));
		addi $a0, $s2, 0
		addi $a1, $zero, 10
		addi $a2, $zero, 0
		jal extract
		addi $t8, $v1, 0
		
		addi $a0, $s4, 0
		addi $a1, $s5, 0
		addi $a2, $t8, 0
		jal Aluout
		addi $s7, $v1, 0
		
		#if (extract(ir, 15, 11) != 0){
		addi $a0, $s2, 0
		addi $a1, $zero, 15
		addi $a2, $zero, 11
		jal extract
		addi $t8, $v1, 0
		
		beq $t8, $zero, ifN0
		
		#r[extract(ir, 15, 11)] = aluout which is ($s7);
		#extract(ir, 15, 11)
		addi $a0, $s2, 0
		addi $a1, $zero, 15
		addi $a2, $zero, 11
		jal extract
		
		sll $v1, $v1, 2 
		add $t8, $s3, $v1  #r[$t8]
		sw $s7, 0($t8) #r[extract(ir, 15, 11)] = aluout which is ($s7);
		
		ifN0:
		addi $s1, $s1, 4
		add $t0, $s1, $s0
		lw $s2, 0($t0)
		
		j loop
	exit:
		jal tracecout #last traceout
		#jr $ra 
	
	# end 
	li $v0, 10
	syscall

#long extract(long x, int left, int right) x is $a0, left is $a1
#right is $a2, return value saved in $v1. 
extract:
	addi $sp, $sp, -4
	sw $s2, 0($sp)
	
	addi $t2, $zero, 1
	bne $a1, 31, fElse #if (left == 31)
	addi $t2, $zero, 0xFFFFFFFF # mask = 0xFFFFFFFF
	j continue
	fElse: 
		#mask = (mask << (left+1)) - 1;
		addi $t3, $a1, 1
		sllv $t2, $t2, $t3
		addi $t2, $t2, -1
	continue:
	and $t4, $a0, $t2 #result = (x & mask)
	beq $a2, 0, ifBranch
	srlv $t4, $t4, $a2
	ifBranch: 
	addi $v1, $t4, 0 #return (result);
	
	lw $s2, 0($sp)
	addi $sp, $sp, 4
	jr $ra

#alufunc(long a, long b, int func) a is $a0, b is $a1, func is &a2
#return value stored in $v1
Aluout:
	addi $sp, $sp, -8
	sw $s4, 0($sp)
	sw $s5, 4($sp)
	
	beq $a2, 32, branchAdd
	beq $a2, 34, branchSub
	beq $a2, 36, branchAnd
	beq $a2, 37, branchOr
	beq $a2, 39, branchNor
	beq $a2, 42, branchSlt
	
	branchAdd:
		add $t5,$a0, $a1
		j returnVal
	branchSub:
		sub $t5, $a0, $a1
		j returnVal
	branchAnd:
		and $t5, $a0, $a1
		j returnVal
	branchOr:
		or $t5, $a0, $a1
		j returnVal
	branchNor:
		nor $t5, $a0, $a1
		j returnVal
	branchSlt:
		slt $t5, $a0, $a1
		j returnVal
		
	returnVal: addi $v1, $t5, 0 #return (result);
	
	lw $s4, 0($sp)
	lw $s5, 4($sp)
	addi $sp, $sp, 8
	jr $ra

#Print one hexadecimal char '0' .. '9' or 'A' .. 'F'
#input: $a0, not return
hexdig:
	sltiu $t6, $a0, 10
	beq $t6, $zero, equal
	li $v0, 1
	syscall
    jr $ra #return
	
	equal: 
	li $v0, 11
	addi $a0, $a0, 55		
	syscall
	jr $ra
	
#input $a0, no return 
printhex:
	addi $sp, $sp, -8
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	
	addi $t9, $a0, 0 #t9 has initial a0
	
	addi $a1, $zero, 31
	addi $a2, $zero, 28
	jal extract
	
	addi $a0, $v1, 0
	jal hexdig
	#--------------------------------------
	addi $a0, $t9, 0
	addi $a1, $zero, 27
	addi $a2, $zero, 24
	jal extract
	
	addi $a0, $v1, 0
	jal hexdig
	#--------------------------------------
	addi $a0, $t9, 0
	addi $a1, $zero, 23
	addi $a2, $zero, 20
	jal extract
	
	addi $a0, $v1, 0
	jal hexdig
	#--------------------------------------
	addi $a0, $t9, 0
	addi $a1, $zero, 19
	addi $a2, $zero, 16
	jal extract
	
	addi $a0, $v1, 0
	jal hexdig
	#--------------------------------------
	addi $a0, $t9, 0
	addi $a1, $zero, 15
	addi $a2, $zero, 12
	jal extract
	
	addi $a0, $v1, 0
	jal hexdig
	#--------------------------------------
	addi $a0, $t9, 0
	addi $a1, $zero, 11
	addi $a2, $zero, 8
	jal extract
	
	addi $a0, $v1, 0
	jal hexdig
	#--------------------------------------
	addi $a0, $t9, 0
	addi $a1, $zero, 7
	addi $a2, $zero, 4
	jal extract
	
	addi $a0, $v1, 0
	jal hexdig
	#--------------------------------------
	addi $a0, $t9, 0
	addi $a1, $zero, 3
	addi $a2, $zero, 0
	jal extract
	
	addi $a0, $v1, 0
	jal hexdig
	#--------------------------------------
	
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	jr $ra

tracecout:
	addi $sp, $sp, -4
	sw $ra, 0($sp)	

	#pc, print label
	la $t6, pc 
	addi $a0, $t6, 0
	li $v0, 4           
    syscall
	
	addi $a0, $s1, 0
	jal printhex #print value
	#-------------------------------------- 
	
	#ir, print label
	la $a0, ir
	li $v0, 4           
    syscall
	
	addi $a0, $s2, 0
	jal printhex
	#--------------------------------------
	
	#a, print label
	la $a0, a
	li $v0, 4           
    syscall
	
	addi $a0, $s4, 0
	jal printhex
	#--------------------------------------
	
	#b, print label
	la $a0, b1
	li $v0, 4           
    syscall
	
	addi $a0, $s5, 0
	jal printhex
	#--------------------------------------
	
	#alout, print label
	la $a0, alout
	addi $a0, $a0, 0
	li $v0, 4           
    syscall
	
	addi $a0, $s7, 0
	jal printhex
	#--------------------------------------
	
	#newline
	la $a0, newLine
	li $v0, 4           
    syscall
	#--------------------------------------
	
	#v0, print label
	la $a0, v0
	li $v0, 4           
    syscall
	
	#r[2]
	lw $a0, 8($s3)
	jal printhex
	#--------------------------------------
	
	#a0, print label
	la $a0, a0
	li $v0, 4           
    syscall
	
	#r[4]
	lw $a0, 16($s3)
	jal printhex
	#--------------------------------------
	
	#a1, print label
	la $a0, a1
	li $v0, 4           
    syscall
	
	#r[5]
	lw $a0, 20($s3)
	jal printhex
	#--------------------------------------
	
	#t1, print label
	la $a0, t1
	li $v0, 4           
    syscall
	
	#r[9]
	lw $a0, 36($s3)
	jal printhex
	#--------------------------------------
	
	#t2, print label
	la $a0, t2
	li $v0, 4           
    syscall
	
	#r[10]
	lw $a0, 40($s3)
	jal printhex
	#--------------------------------------
	
	#t4, print label
	la $a0, t4
	li $v0, 4           
    syscall
	
	#r[12]
	lw $a0, 48($s3)
	jal printhex
	#--------------------------------------
	
	la $a0, newLine
	li $v0, 4           
    syscall
	#--------------------------------------
	
	#s1, print label
	la $a0, s1
	li $v0, 4           
    syscall
	
	#r[17]
	lw $a0, 68($s3)
	jal printhex
	#--------------------------------------
	
	#s2, print label
	la $a0, s2
	li $v0, 4           
    syscall
	
	#r[18]
	lw $a0, 72($s3)
	jal printhex
	#--------------------------------------
	
	#s3, print label
	la $a0, s3
	li $v0, 4           
    syscall
	
	#r[19]
	lw $a0, 76($s3)
	jal printhex
	#--------------------------------------
	
	#s4, print label
	la $a0, s4
	li $v0, 4           
    syscall
	
	#r[20]
	lw $a0, 80($s3)
	jal printhex
	#--------------------------------------
	
	#s5, print label
	la $a0, s5
	li $v0, 4           
    syscall
	
	#r[21]
	lw $a0, 84($s3)
	jal printhex
	#--------------------------------------
	
	la $a0, newLine
	li $v0, 4           
    syscall
	#--------------------------------------
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
