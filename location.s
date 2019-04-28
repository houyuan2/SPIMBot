
#
#check appliance, return next location, $a0 food id  $a1 id of first appliance, $a2 id of the second appliance
location:

  lw  $t0,  side   #determine if left or right
  beq $t0, 1, right  #if side == 1, right spimbot

  #left
  bne $a0, 0, cheeseL #bread
  j   counter
cheeseL:
  bne $a0, 1, raw_meatL
  j   counter
raw_meatL:
  bne $a0, 2, meatL
  bne $a1, 4, u2o  #check u1 oven
  j   u1#return (2,2)
meatL:
  bne $a0, 3, unWashedTomatoL
  j   counter
unWashedTomatoL:
  bne $a0, 5, tomatoL #tomato
  bne $a1, 5, u2sink
  j   u1
tomatoL:
  bne $a0, 6, uncutOnionL
  j   counter
uncutOnionL:
  bne $a0, 7, onionL
  bne $a1, 6, u2chop
  j   u1
onionL:
  bne $a0, 8, unwahsedUnchoppedLettuceL
  j   counter
unwahsedUnchoppedLettuceL:
  bne $a0, 9, unwahsedLettuce
  bne $a1, 6, u2sink
  j   u1
unwahsedLettucelettuce:
  bne $a0, 10, lettuceL
  bne $a1, 5, u2chop
  j   u1
lettuceL:
  bne $a0, 11, counter
  jr  $ra
u2o:
  bne $a2, 4, counter
  j   u2
u2sink:
  bne $a2, 5, counter
  j   u2
u2chop:
  bne $a2, 6, counter
  j   u2
counter:
  li  $v0, 6  #x=7
  li  $v1, 7  #y=6
  sw  $0, location_switch
  jr  $ra
u1:
  li  $v0, 2
  li  $v1, 3
  li  $t0, 3
  sw  $t0, location_switch
  jr  $ra
u2:
  li  $v0, 5
  li  $v1, 3
  li  $t0, 3
  sw  $t0, location_switch
  jr  $ra
# right spimbot
right:
  bne $a0, 0, cheeseR #bread
  j   counterR
cheeseR:
  bne $a0, 1, raw_meatR #cheese
  j   counterR
raw_meatR:
  bne $a0, 2, meatR
  bne $a1, 4, u4o  #check u4 oven
  j   u3#return (2,2)
meatR:
  bne $a0, 3, unWashedTomatoR
  j   counterR
unWashedTomatoR:
  bne $a0, 5, tomatoR #tomato
  bne $a1, 5, u4sink
  j   u3
tomatoR:
  bne $a0, 6, uncutOnionR
  j   counterR
uncutOnionR:
  bne $a0, 7, onionR
  bne $a1, 6, u4chop
  j   u3
onionR:
  bne $a0, 8, unwahsedUnchoppedLettuceR
  j   counterR
unwahsedUnchoppedLettuceR:
  bne $a0, 9, unwahsedLettuceR
  bne $a1, 6, u4sink
  j   u3
unwahsedLettucelettuceR:
  bne $a0, 10, lettuceR
  bne $a1, 5, u4chop
  j   u3
lettuceR:
  bne $a0, 11, counterR
  jr  $ra
u4o:
  bne $a2, 4, counterR  #not oven, go to counter
  j   u4
u4sink:
  bne $a2, 5, counterR
  j   u4
u4chop:
  bne $a2, 6, counterR
  j   u4
counterR:
  li  $v0, 8  #x=7
  li  $v1, 7  #y=8
  sw  $0, location_switch
  jr  $ra
u3:
  li  $v0, 9
  li  $v1, 3
  li  $t0, 3
  sw  $t0, location_switch
  jr  $ra
u4:
  li  $v0, 12
  li  $v1, 3
  li  $t0, 3
  sw  $t0, location_switch
  jr  $ra
