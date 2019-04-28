rawFood:
  sub $sp, $sp, 4
  sw  $ra, 0($sp)
  la  $t1, counter
  lw  $t0, 8($t1)  #raw meat
  blt $t0, 4, unwahsedT
  li  $a0, 2
  lw  $a1, left_appliance
  lw  $a2, right_appliance
  jal appliance_location
  lw  $t3, location_switch
  bne $t3, 3, unwahsedT
  li  $t2, 2
  sll $t2, $t2, 16
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
unwahsedT:
  lw  $t0, 20($t1)
  blt $t0, 4, uncutO
  li  $a0, 5
  lw  $a1, left_appliance
  lw  $a2, right_appliance
  jal appliance_location
  lw  $t3, location_switch
  bne $t3, 3, uncutO
  li  $t2, 3
  sll $t2, $t2, 16
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
uncutO:
  lw  $t0, 28($t1)
  blt $t0, 4, unWunCLettuce
  li  $a0, 7
  lw  $a1, left_appliance
  lw  $a2, right_appliance
  jal appliance_location
  lw  $t3, location_switch
  bne $t3, 3, unWunCLettuce
  li  $t2, 4
  sll $t2, $t2, 16
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
unWunCLettuce:
  lw  $t0, 36($t1)
  blt $t0, 4, UnchopL
  li  $a0, 9
  lw  $a1, left_appliance
  lw  $a2, right_appliance
  jal appliance_location
  lw  $t3, location_switch
  bne $t3, 3, UnchopL
  li  $t2, 5
  sll $t2, $t2, 16
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
UnchopL:
  lw  $t0, 40($t1)
  blt $t0, 4, end
  li  $a0, 10
  lw  $a1, left_appliance
  lw  $a2, right_appliance
  jal appliance_location
  lw  $t3, location_switch
  bne $t3, 3, end
  li  $t2, 5
  sll $t2, $t2, 16
  add $t2, $t2, 1
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  sw  $t2, PICKUP
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
end:
  li  $v0, -1
  li  $v1, -1
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
