To_which_order:
  sub   $sp, $sp, 4
  sw    $ra, 0($sp)
  la    $t0, shared_counter     # t0 = address of counter
  li    $t2, 0                  # for(int i = 0; i < 3; i++)
determine_order_loop:
  beq   $t2, 0, load_order_0
  beq   $t2, 1, load_order_1
  beq   $t2, 2, load_order_2
  j     pick_up_done
load_order_0:
  la    $t1, order_0            # t1 = address of order_0
  li    $t3, 0
  j     pick_up_loop
load_order_1:
  la    $t1, order_1            # t1 = address of order_1
  li    $t3, 0
  j     pick_up_loop
load_order_2:
  la    $t1, order_2            # t1 = address of order_2
  li    $t3, 0                  # for(int j = 0; j < 12; j++)
  j     pick_up_loop
pick_up_loop:
  bge   $t3, 12, determine_next_order
  mul   $t4, $t3, 4
  add   $t5, $t4, $t1           # t5 = address of order[j]
  add   $t6, $t4, $t0           # t6 = address of shared_counter[j]
  lw    $t7, 0($t5)             # t7 = order[j]
  lw    $t6, 0($t6)             # t6 = shared_counter[j]
  ble   $t7, $t6, pick_order
  add   $t3, $t3, 1
  j     pick_up_loop
determine_next_order:
  add   $t2, $t2, 1
  j     determine_order_loop
pick_order:
  bge   $t7, 4, up_to_four
pick_up_less_than_four:
  # pick up one time
  # only one sw instruction here
  sub   $t7, $t7, 1
  bgt   $t7, 0, pick_up_less_than_four
  sw    $zero, 0($t5)
  j     pick_up_done
up_to_four:
  # pick up 4 times here
  # should be 4 sw instructions here
  sub   $t7, $t7, 4
  sw    $t7, 0($t5)
pick_up_done:
  lw    $ra, 0($sp)
  add   $sp, $sp, 4
  jr    $ra
