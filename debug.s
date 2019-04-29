    la $t0, order_0
    li $t1, 0
debug_loop:
  bge $t1, 12, debug_end
  mul $t3, $t1, 4
  add $t3, $t0, $t3
  lw	$t3, 0($t3)
  add $t1, $t1, 1
j debug_loop
  debug_end:
