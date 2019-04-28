#pass $a0 as order $a1 as process
compareOrder:
  sub $sp, $sp, 16
  sw  $s0, 0($sp)  #order
  sw  $s1, 4($sp)  #process
  sw  $s2, 8($sp)  #shared counter
  sw  $s3, 12($sp)
  #array from global

  #order_0
  move  $s0, $a0
  move  $s1, $a1
  la  $s2, counter
  la  $s3, neededIngredient
  li  $t0, 0
order0:
  bge $t0, 12, compare_0
  mul $t1, $t0, 4 #i*4
  add $t2, $s0, $t1 #order
  add $t3, $s1, $t1 #process
  add $t4, $s3, $t1 #ingredient
  lw  $t2, 0($t2)
  lw  $t3, 0($t3)
  sub $t5, $t2, $t3 #order - process
  sw  $t5, 0($t4)  #neededingredient[i]
  add $t0, $t0, 1
  j   order0
compare_0:
#bread 0
  lw  $t2, 0($s2) #counter
  lw  $t3, 0($s3) #needed
  bgt $t3, $t2, fail #needed > counter, fail
#cheese 1
  lw  $t2, 4($s2)
  lw  $t3, 4($t3)
  bgt $t3, $t2, fail
#meat 3
  lw  $t2, 12($s2)
  lw  $t3, 12($t3)
  bgt $t3, $t2, fail
#tomato
  lw  $t2, 24($s2)
  lw  $t3, 24($t3)
  bgt $t3, $t2, fail
#onion
  lw  $t2, 32($s2)
  lw  $t3, 32($t3)
  bgt $t3, $t2, fail
#lettuce
  lw  $t2, 44($s2)
  lw  $t3, 44($t3)
  bgt $t3, $t2, fail

  #order0 can be finished
  li  $t1, 0 #hold
  lw  $t3, 0($s3)  #needed bread
  beq $t3, 0, cheese0  #if bread needed = 0, go to cheese
  li  $t0, 0
  li  $t4, 0
  sll $t0, $t0, 16 #bread
pickBread0:
  bge $t4, $t3, cheese0
  sw  $t0, PICKUP
  add $t1, $t1, 1 #hold+=1
  add $t4, $t4, 1
  j   pickBread0
cheese0:
  lw  $t3, 4($s3) #cheese needed
  beq $t3, 0, meat0
  li  $t0, 1
  sll $t0, $t0, 16
  li  $t4, 0
pickCheese0:
  bge $t4, $t3, meat0
  sw  $t0, PICKUP
  add $t1, $t1, 1
  add $t4, $t4, 1
  beq $t1, 4, success
  j   pickCheese0
meat0:
  lw  $t3, 12($s3) #meat needed
  beq $t3, 0, tomato0
  li  $t0, 1
  sll $t0, $t0, 16
  add $t0, $t0, 1
  li  $t4, 0
pickMeat0:
  bge $t4, $t3, tomato0
  sw  $t0, PICKUP
  add $t1, $t1, 1
  add $t4, $t4, 1
  beq $t1, 4, success
  j   pickMeat0
tomato0:
  lw  $t3, 24($s3) #tomato needed
  beq $t3, 0, onion0
  li  $t0, 1
  sll $t0, $t0, 16
  add $t0, $t0, 1
  li  $t4, 0
pickTomato0:
  bge $t4, $t3, onion0
  sw  $t0, PICKUP
  add $t1, $t1, 1
  add $t4, $t4, 1
  beq $t1, 4, success
  j   pickTomato0
onion0:
  lw  $t3, 32($s3) #tomato needed
  beq $t3, 0, lettuce0
  li  $t0, 1
  sll $t0, $t0, 16
  add $t0, $t0, 1
  li  $t4, 0
pickOnion0:
  bge $t4, $t3, lettuce0
  sw  $t0, PICKUP
  add $t1, $t1, 1
  beq $t1, 4, success
  add $t4, $t4, 1
  j   pickOnion0
lettuce0:
  lw  $t3, 44($s3) #lettuce needed
  beq $t3, 0, success
  li  $t0, 1
  sll $t0, $t0, 16
  add $t0, $t0, 2
  li  $t4, 0
pickLettuce0:
  bge $t4, $t3, success
  sw  $t0, PICKUP
  add $t1, $t1, 1
  add $t4, $t4, 1
  beq $t1, 4, success
  j   pickLettuce0
success:
  li  $v0, 1
  lw  $s0, 0($sp)  #order
  lw  $s1, 4($sp)  #process
  lw  $s2, 8($sp)  #shared counter
  lw  $s3, 12($sp)
  add $sp, $sp, 16
  jr  $ra
fail:
  #flag = 0
  li  $v0, 0
  lw  $s0, 0($sp)  #order
  lw  $s1, 4($sp)  #process
  lw  $s2, 8($sp)  #shared counter
  lw  $s3, 12($sp)
  add $sp, $sp, 16
  jr  $ra


determineOrder:
  la  $a0, order_0
  la  $a1, process_0
  jal compareOrder
  #order_success
  bne $v0, 1, order1
  sw  $0, order_success
  jr  $ra
order1:
  la  $a0, order_1
  la  $a1, process_1
  jal compareOrder
  bne $v0, 1, order2
  li  $t0, 1
  sw  $t0, order_success
  jr  $ra
order2:
  la  $a0, order_2
  la  $a1, process_2
  jal compareOrder
  bne $v0, 2, noOrder
  li  $t0, 2
  sw  $t0, order_success
  jr  $ra
noOrder:
  li  $t0, -1
  sw  $t0, order_success
  jr  $ra
