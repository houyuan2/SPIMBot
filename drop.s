cook:
  li      $t0, 0
drop_loop:
  bge     $t0, 4, appliance_done
  sw      $t0, DROPOFF
  lw      $t3, BOT_X
  blt     $t3, 75, first_appliance
  blt     $t3, 135, second_appliance
  blt     $t3, 215, third_appliance
  blt     $t3, 275, forth_appliance
first_appliance:
  li 			$t4, 0x00020002
  sw 			$t4, SET_TILE
  j       get_level
second_appliance:
  li 			$t4, 0x00020005
  sw 			$t4, SET_TILE
  j       get_level
third_appliance:
  li 			$t4, 0x00020009
  sw 			$t4, SET_TILE
  j       get_level
forth_appliance:
  li 			$t4, 0x0002000c
  sw 			$t4, SET_TILE
get_level:
  lw      $t1, GET_TILE_INFO
  add     $t2, $t1, 9
appliance_loop:
  lw      $t1, GET_TILE_INFO
  bne     $t1, $t2, appliance_loop
  sw      $zero, PICKUP
  add     $t0, $t0, 1
  j       drop_loop
appliance_done:
  jr      $ra
