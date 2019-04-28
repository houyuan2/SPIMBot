Move_to_order_place:
  sub   $sp, $sp, 4
  sw    $ra, 0($sp)
  lw    $t0, order_success
  beq   $t0, -1, No_order
  beq   $t0, 0, move_to_order_0
  beq   $t0, 1, move_to_order_1
  beq   $t0, 2, move_to_order_2
move_to_order_0:
  lw    $t1, side
  beq   $t1, 1, right_side_order_0
  li    $a0, 40
  li    $a1, 280
  jal   findAngle
  j     No_order
right_side_order_0:
  li    $a0, 180
  li    $a1, 280
  jal   findAngle
  j     No_order
move_to_order_1:
  lw    $t1, side
  beq   $t1, 1, right_side_order_1
  li    $a0, 80
  li    $a1, 280
  jal   findAngle
  j     No_order
right_side_order_1:
  li    $a0, 220
  li    $a1, 280
  jal   findAngle
  j     No_order
move_to_order_2:
  lw    $t1, side
  beq   $t1, 1, right_side_order_2
  li    $a0, 120
  li    $a1, 280
  jal   findAngle
  j     No_order
right_side_order_1:
  li    $a0, 260
  li    $a1, 280
  jal   findAngle
  j     No_order
No_order:
  lw    $ra, 0($sp)
  add   $sp, $sp, 4
  jr    $ra
