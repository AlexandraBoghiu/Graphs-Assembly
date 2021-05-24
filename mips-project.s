.data
	queue: .space 4000
	visited: .space 4000
	v: .space 4000
	roles: .space 4000
	mesaj: .space 800
	sp: .asciiz " "
	host: .asciiz "host index "
	switch: .asciiz "switch index "
	switch_malitios: .asciiz "switch malitios index "
	controller_logic: .asciiz "controller index "
	pv: .asciiz "; "
	newline: .asciiz "\n"
	yes: .asciiz "Yes"
	no: .asciiz "No"
	dp: .asciiz ": "


.text

main:
	li $v0, 5  #citim numarul de noduri
	syscall
	move $t0, $v0  #salvam numarul de noduri in $t0
	
	li $v0, 5  #citim numarul de legaturi
	syscall
	move $t1, $v0  #salvam numarul de legaturi in $t1
	
	mul $t2, $t0, $t0 #nr de elemente din matrice
	
	li $t3, 0 #contor obisnuit
	li $t4, 0 #creste din 4 in 4
	
matrix_creare:
	bge $t3, $t2, contor
	
	li $t6, 0
	sb $t6, v($t4)
	
	addi $t3, $t3, 1
	addi $t4, $t4, 4
	j matrix_creare


contor:
 	li $t3, 0

citire:
	bge $t3, $t1, roluri
	li $v0, 5  #citim prima legatura
	syscall
	move $t8, $v0  #salvam prima legatura
	
	li $v0, 5  #citim a doua legatura
	syscall
	move $t9, $v0  #salvam a doua legatura

j_loop_constr:
	mul $t5, $t8, $t0 # $t5 = nr noduri * i
	add $t5, $t5, $t9 # $t5 = nr noduri * i + j
	mul $t5, $t5, 4   # $t5 = 4 * (nr noduri * i + j)
	
	li $t7, 1
	sb $t7, v($t5) # ii dam elementului valoarea 1
	
	mul $t5, $t9, $t0 # $t5 = nr noduri * j
	add $t5, $t5, $t8 # $t5 = nr noduri * j + i
	mul $t5, $t5, 4   # $t5 = 4 * (nr noduri * j + i)
	
	li $t7, 1
	sb $t7, v($t5) # ii dam elementului valoarea 1

	addi $t3, $t3, 1
	j citire
	
roluri:
	li $t3, 0  #contor obisnuit
	li $t8, 0  #contor din 4 in 4
	
loop_citire_roluri:
	bge $t3, $t0, cerinta
	
	li $v0, 5 # citim rolurile
	syscall
	move $t7, $v0
	sw $t7, roles($t8)
	
	addi $t3, $t3, 1
	addi $t8, $t8, 4
	j loop_citire_roluri 
cerinta:
	li $v0, 5 #citim numarul cerintei
	syscall
	move $s0, $v0
	
	li $s1, 1
	beq $s1, $s0, parcurgere
	
	li $s1, 2
	beq $s1, $s0, vector_nul
	
	li $s1, 3
	beq $s1, $s0, citire_host_mesaj
	
parcurgere:
	li $t3, 0 #contor obisnuit
	li $t8, 0 #contor din 4 in 4
	
parcurgere_roluri:
	bge $t3, $t0, exit
	li $t7, 3
	li $t9, 0 #contor pentru j
	li $t6, 0 #contor din 4 in 4 pt j
	
	lw $t4, roles($t8)
	beq $t7, $t4, afisare_malitios
	addi $t3, $t3, 1
	addi $t8, $t8, 4
	j parcurgere_roluri
	
afisare_malitios:
	la $a0, switch_malitios
	li $v0, 4
	syscall
	
	move $a0, $t3
	li $v0, 1
	syscall 
	
	la $a0, dp
	li $v0, 4
	syscall 
	j verificare
verificare:
	
	bge $t9, $t0, adunare
	mul $t5, $t3, $t0 # $t5 = nr noduri * i
	add $t5, $t5, $t9 # $t5 = nr noduri * i + j
	mul $t5, $t5, 4   # $t5 = 4 * (nr noduri * i + j)
	
	lb $t1, v($t5)
	li $t7, 1
	beq $t7, $t1, verificare_rol

	addi $t9, $t9, 1
	addi $t6, $t6, 4
	j verificare
verificare_rol:

	li $t7, 1
	lw $t1, roles($t6)
	beq $t7, $t1, este_host
	
	li $t7, 2
	lw $t1, roles($t6)
	beq $t7, $t1, este_switch
	
	li $t7, 3
	lw $t1, roles($t6)
	beq $t7, $t1, este_switch_malitios
	
	li $t7, 4
	lw $t1, roles($t6)
	beq $t7, $t1, este_controller
	
adunare:
	la $a0, newline
	li $v0, 4
	syscall
	addi $t3, $t3, 1
	addi $t8, $t8, 4
	j parcurgere_roluri
adunare_j:
	addi $t6, $t6, 4
	addi $t9, $t9, 1
	j verificare
	
este_host:
	la $a0, host
	li $v0, 4
	syscall
	
	move $a0, $t9
	li $v0, 1
	syscall 
	
	la $a0, pv
	li $v0, 4
	syscall 
	j adunare_j
este_switch:
	la $a0, switch
	li $v0, 4
	syscall
	move $a0, $t9
	li $v0, 1
	syscall 
	la $a0, pv
	li $v0, 4
	syscall 
	j adunare_j
	
este_switch_malitios:
	la $a0, switch_malitios
	li $v0, 4
	syscall
	move $a0, $t9
	li $v0, 1
	syscall 
	la $a0, pv
	li $v0, 4
	syscall 
	j adunare_j
	
este_controller:
	la $a0, controller_logic
	li $v0, 4
	syscall
	move $a0, $t9
	li $v0, 1
	syscall 
	la $a0, pv
	li $v0, 4
	syscall 
	j adunare_j
	
vector_nul:
	li $t9, 0
	li $t8, 0
	j init
init:
	bge $t9, $t0, bfs_1
	
	sw $zero, visited($t8)
	
	addi $t8, $t8, 4
	addi $t9, $t9, 1
	j init
bfs_1:
	li $t9, 0 #stanga
	li $t1, 0 #stanga din 4 in 4
	li $t8, 0 #dreapta din 4 in 4
	li $t6, 0 #dreapta din 1 in 1
	li $t7, 0 
	li $t4, 0 #contor i din 4 in 4 din for
	li $t2, 0 #contor i din 1 in 1
	sw $t7, queue($t6) #queue(0) = 0
	li $t9, 1
	sw $t9, visited($t7) #visited(0) = 1
	li $t9, 0
	

stanga_dreapta:
	bgt $t9, $t6, verificare_lungime #cat timp coada nu e vida st<=dr

	lw $t5, queue($t1) # k  preiau un element din coada

	mul $s3, $t5, 4
	lw $t3, roles($s3) #roles(k)
	beq $t3, 1, afisare_nod #if roles[k] == 1
	
for:	
	bge $t2, $t0, creste_st
	
	mul $t3, $t5, $t0 # $t5 = nr noduri * k
	add $t3, $t3, $t2 # $t5 = nr noduri * k + i
	mul $t3, $t3, 4   # $t5 = 4 * (nr noduri * k + i)

	lw $s0, v($t3)
	beq $s0, $zero, creste_i
	
	lw $s1, visited($t4)
	bne $s1, $zero, creste_i
	
	li $s2, 1
	sw $s2, visited($t4)
	
	
	addi $t8, $t8, 4 #creste dr 
	addi $t6, $t6, 1
	
	sw $t2, queue($t8) # queue(dr) = i
	
	j creste_i
	
creste_i:
	addi $t4, $t4, 4 #contor i din 4 in 4 din for
	addi $t2, $t2, 1 #contor i din 1 in 1
	j for
	
creste_st:
	li $t4, 0 #contor i din 4 in 4 din for
	li $t2, 0 #contor i din 1 in 1
	
	addi $t1, $t1, 4
	addi $t9, $t9, 1
	j stanga_dreapta

afisare_nod:
	la $a0, host
	li $v0, 4
	syscall
	
	move $a0, $t5
	li $v0, 1
	syscall 
	
	la $a0, pv
	li $v0, 4
	syscall 
	
	j creste_i
	
verificare_lungime:
	la $a0, newline
	li $v0, 4
	syscall
	
	addi $t6, $t6, 1
		
	
	beq $t0, $t6, da
	bne $t0, $t6, nu
nu:
	la $a0, no
	li $v0, 4
	syscall
	j exit
	
da:
	la $a0, yes
	li $v0, 4
	syscall
	j exit
	
citire_host_mesaj:
	li $v0, 5
	syscall
	move $s4, $v0 #citim primul host
	
	li $v0, 5
	syscall
	move $s5, $v0 #citim al doilea host
	
	li $v0, 8
	li $a1, 101
	la $a0, mesaj # citim mesajul
	syscall

bfs_3:
	li $t9, 0 #stanga
	li $t1, 0 #stanga din 4 in 4
	li $t8, 0 #dreapta din 4 in 4
	li $t6, 0 #dreapta din 1 in 1
	li $t7, 0 
	li $t4, 0 #contor i din 4 in 4 din for
	li $t2, 0 #contor i din 1 in 1
	
	sw $s4, queue($t6) #queue(0) = $s4, primul host
	li $t9, 1
	mul $t7, $s4, 4
	sw $t9, visited($t7) #visited($s4) = 1, am vizitat primul host
	li $t7, 0
	li $t9, 0
	
stanga_dreapta_3:
	bgt $t9, $t6, verificare_host2 #cat timp coada nu e vida st<=dr

	lw $t5, queue($t1) # k  preiau un element din coada
	
for_3:	
	bge $t2, $t0, creste_st_3
	
	mul $t3, $t5, $t0 # $t5 = nr noduri * k
	add $t3, $t3, $t2 # $t5 = nr noduri * k + i
	mul $t3, $t3, 4   # $t5 = 4 * (nr noduri * k + i)

	mul $s3, $t5, 4
	lw $s6, roles($s3) #roles(k)
	beq $s6, 3, creste_i_3 #if roles[k] == 3 , sarim peste el
	
	lw $s0, v($t3)
	beq $s0, $zero, creste_i_3
	
	lw $s1, visited($t4)
	bne $s1, $zero, creste_i_3
	
	li $s2, 1
	sw $s2, visited($t4)
	
	addi $t8, $t8, 4 #creste dr 
	addi $t6, $t6, 1
	
	
	sw $t2, queue($t8) # queue(dr) = i
	
	j creste_i_3
	
creste_i_3:
	addi $t4, $t4, 4 #contor i din 4 in 4 din for
	addi $t2, $t2, 1 #contor i din 1 in 1
	j for_3
	
creste_st_3:
	li $t4, 0 #contor i din 4 in 4 din for
	li $t2, 0 #contor i din 1 in 1
	
	addi $t1, $t1, 4
	addi $t9, $t9, 1
	j stanga_dreapta_3

afisare_nod_3:
	la $a0, host
	li $v0, 4
	syscall
	
	move $a0, $t5
	li $v0, 1
	syscall 
	
	la $a0, pv
	li $v0, 4
	syscall 
	
	j creste_i_3
	
verificare_host2:
	mul $t7, $s5, 4
	lw $t9, visited($t7)
	beq $t9, 1, drum_sigur
	j drum_nesigur
	
drum_nesigur:
	
	li $t9, 0 #contor din 1 in 1
	lb $t8, mesaj($t9)  #byte ul curent din sir
	add $t8, $t8, -10
	blt $t8, 97, adunare_26
	sb $t8, mesaj($t9)
		
drum_nesigur_cont:
	beqz $t8, drum_sigur
	addi $t9, $t9, 1
	lb $t8, mesaj($t9)
	add $t8, $t8, -10
	
	beqz $t8, drum_sigur
	blt $t8, 97, adunare_26

	sb $t8, mesaj($t9)
		

	j drum_nesigur_cont
	
adunare_26:
	add $t8, $t8, 26
	sb $t8, mesaj($t9)
	
	j drum_nesigur_cont

drum_sigur:
	li $t0, 0 #$t0 sare din 1 in 1 pe locatiile din memorie

	lb $a0, mesaj($t0)
	li $v0, 11
	syscall	
	j drum_sigur_cont

	
drum_sigur_cont:

	beqz $t1, exit

	addi $t0, $t0, 1
	
	lb $a0, mesaj($t0)
	li $v0, 11
	syscall
	
	lb $t1, mesaj($t0)
	j drum_sigur_cont

afisare_caracter:
	lb $a0, mesaj($t0)
	li $v0, 11
	syscall	
	j drum_sigur_cont
	
exit:
	li $v0, 10
	syscall

