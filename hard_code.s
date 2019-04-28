app_finish:
  lw      $t5, side
  beq     $t5, 1, right_side_moving
left_side_moving:
  li      $t5, 10
  sw      $t5, VELOCITY
  lw      $t6,BOT_Y
  blt     $t6,55,left_side_moving
  li      $t7,-90
  sw      $t7,ANGLE($zero)
  sw      $zero,ANGLE_CONTROL($zero)
keep_moving_left:
  li      $t5, 10
  sw      $t5, VELOCITY
  lw      $t6,BOT_X
  blt     $t6,30,keep_moving_left
  li      $t7,0
  sw      $t7, VELOCITY
  li      $a0, 150
  li      $a1, 200
  jal     findAngle
  j       infinite
right_side_moving:
  li      $t5, 10
  sw      $t5, VELOCITY
  lw      $t6, BOT_Y
  blt     $t6,55,right_side_moving
  li      $t7,180
  sw      $t7,ANGLE($zero)
  li      $t7, 1
  sw      $t7,ANGLE_CONTROL($zero)
keep_moving_right:
  li      $t5, 10
  sw      $t5, VELOCITY
  lw      $t6,BOT_X
  bgt     $t6, 270, keep_moving_right
  li      $t7,0
  sw      $t7, VELOCITY
  li      $a0, 150
  li      $a1, 200
  jal     findAngle
