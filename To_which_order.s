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
  move  $a0, $t3
  jal   Food_id_decoder
  sw    $v0, PICKUP
  sub   $t7, $t7, 1
  bgt   $t7, 0, pick_up_less_than_four
  sw    $zero, 0($t5)
  sw    $t2, order_move
  j     pick_up_done
up_to_four:
  # pick up 4 times here
  # should be 4 sw instructions here
  move  $a0, $t3
  jal   Food_id_decoder
  sw    $v0, PICKUP
  sw    $v0, PICKUP
  sw    $v0, PICKUP
  sw    $v0, PICKUP
  sub   $t7, $t7, 4
  sw    $t7, 0($t5)
  sw    $t2, order_move
pick_up_done:
  lw    $ra, 0($sp)
  add   $sp, $sp, 4
  jr    $ra


Food_id_decoder:
  # a0 = index of food in 12
  sub   $sp, $sp, 4
  sw    $ra, 0($sp)
  beq   $a0, 0, lettuce_pickup_code
  beq   $a0, 3, onion_pickup_code
  beq   $a0, 5, tomato_pickup_code
  beq   $a0, 8, meat_pickup_code
  beq   $a0, 10, cheese_pickup_code
  beq   $a0, 11, bread_pickup_code
decoder_done:
  lw    $ra, 0($sp)
  add   $sp, $sp, 4
  jr    $ra
lettuce_pickup_code:
  li    $t0, 5
  sll   $t0, $t0, 16
  add   $t0, $t0, 2
  move  $v0, $t0
  j     decoder_done
onion_pickup_code:
  li    $t0, 4
  sll   $t0, $t0, 16
  add   $t0, $t0, 1
  move  $v0, $t0
  j     decoder_done
tomato_pickup_code:
  li    $t0, 3
  sll   $t0, $t0, 16
  add   $t0, $t0, 1
  move  $v0, $t0
  j     decoder_done
meat_pickup_code:
  li    $t0, 2
  sll   $t0, $t0, 16
  add   $t0, $t0, 1
  move  $v0, $t0
  j     decoder_done
cheese_pickup_code:
  li    $t0, 1
  sll   $t0, $t0, 16
  move  $v0, $t0
  j     decoder_done
bread_pickup_code:
  li    $v0, 0
  j     decoder_done
