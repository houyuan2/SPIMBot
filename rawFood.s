rawFood:
  sub $sp, $sp, 4
  sw  $ra, 0($sp)
  la  $t1, counter
  lw  $t0, 8($t1)
  blt $t0, 4, unwahsedT
  li  $a0, 2
  lw  $a1, left_appliance
  lw  $a2, right_appliance
  jal appliance_location
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
end:
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
