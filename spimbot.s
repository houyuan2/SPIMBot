.data
# syscall constants
PRINT_STRING            = 4
PRINT_CHAR              = 11
PRINT_INT               = 1

# memory-mapped I/O
VELOCITY                = 0xffff0010
ANGLE                   = 0xffff0014
ANGLE_CONTROL           = 0xffff0018

BOT_X                   = 0xffff0020
BOT_Y                   = 0xffff0024

TIMER                   = 0xffff001c

SUBMIT_ORDER 			= 0xffff00b0
DROPOFF 				= 0xffff00c0
PICKUP 					= 0xffff00e0
GET_TILE_INFO			= 0xffff0050
SET_TILE				= 0xffff0058

REQUEST_PUZZLE          = 0xffff00d0
SUBMIT_SOLUTION         = 0xffff00d4

BONK_INT_MASK           = 0x1000
BONK_ACK                = 0xffff0060

TIMER_INT_MASK          = 0x8000
TIMER_ACK               = 0xffff006c

REQUEST_PUZZLE_INT_MASK = 0x800
REQUEST_PUZZLE_ACK      = 0xffff00d8

GET_MONEY               = 0xffff00e4
GET_LAYOUT 				= 0xffff00ec
SET_REQUEST 			= 0xffff00f0
GET_REQUEST 			= 0xffff00f4

GET_INVENTORY 			= 0xffff0040
GET_TURNIN_ORDER 		= 0xffff0044
GET_TURNIN_USERS		= 0xffff0048
GET_SHARED 				= 0xffff004c

GET_BOOST 				= 0xffff0070
GET_INGREDIENT_INSTANT 	= 0xffff0074
FINISH_APPLIANCE_INSTANT = 0xffff0078

PRINT_INT_ADDR = 0xffff0080

puzzle:      .word 0:452
.align 4
# flags:
# 0: puzzle is requested but not arrive
# 1: puzzle is there and has not start solving
# 2: puzzle is solving but not finish
# 3: puzzle is finished
puzzle_stage: .space 4

side: .space 4   # 0: left, 1: right

bonk_flag:  .space 4 #0: nothing, 1: just bonked

location_switch: .space 4  #0: counter, #1: order, #2: food, #3 appliance

order_success: .space 4  # -1: nothing success

foodbin_stage: .space 4  # 0: top
.align 4

#arctan constants
three: 	.float  3.0
five:  .float  5.0
PI:    .float  3.141592
F180:  .float 180.0

.align 4
left_appliance: .space 4
right_appliance: .space 4

order_fetch: .space 24
order_0: .space 48
order_1: .space 48
order_2: .space 48
process_0: .space 48
process_1: .space 48
process_2: .space 48
counter_fetch: .space 8
shared_counter: .space 48
neededIngredient: .space 48

inventory: .space 16
.align 4
layout: .space 225
.align 4

.text
main:
	# Construct interrupt mask
  li      $t4, 0
	or      $t4, $t4, BONK_INT_MASK # request bonk
	or      $t4, $t4, REQUEST_PUZZLE_INT_MASK	        # puzzle interrupt bit
	or      $t4, $t4, 1 # global enable
	mtc0    $t4, $12

	#Fill in your code here
  la $t1, puzzle
  sw $t1, REQUEST_PUZZLE

  sw $0, puzzle_stage # set puzzle stage to 0

  # set bonk_flag to 0
  sw  $0, bonk_flag

  # set location flag
  sw  $0, location_switch # next position: counter

  # set order flag
  li  $t0, -1
  sw  $t0, order_success

  # set foodbin flag
  sw  $0, foodbin_stage

  # set up left or right flag
  lw  $t0, BOT_X
  blt $t0, 140, spawn_left
  li, $t0, 1
  sw  $t0, side   # set side flag to 1
  j   side_finish
spawn_left:
  sw  $0, side   # set side flag to 0
side_finish:
  # set up appliance tag, offset: 32, 35, 39, 42
  la  $t1, layout
  sw  $t1, GET_LAYOUT
  lw  $t0, side
  beq $t0, 0, spawn_left_app
  # set up spawn right app
  lb  $t2, 39($t1)
  sw  $t2, left_appliance
  lb  $t2, 42($t1)
  sw  $t2, right_appliance
  j app_finish
spawn_left_app:
  # set up spawn left app
  lb  $t2, 32($t1)
  sw  $t2, left_appliance
  lb  $t2, 35($t1)
  sw  $t2, right_appliance
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

infinite:
  jal mission_control
	j infinite

mission_control:
  sub $sp, $sp, 20
  sw  $ra, 0($sp)
  sw  $s0, 4($sp)
  sw  $s1, 8($sp)
  sw  $s2, 12($sp)
  sw  $s3, 16($sp)

    lw $s0, puzzle_stage # get puzzle stage
    beq $s0, 0, movement
    beq $s0, 1, puzzle_1
    beq $s0, 2, puzzle_2
    beq $s0, 3, puzzle_3

puzzle_1:
    li $t1, 2
    sw $t1, puzzle_stage # set puzzle stage to 2
    la  $a0, puzzle
    jal islandfill       # start solving puzzle
    j movement

puzzle_2:   # puzzle is not finished, do nothing
    j movement

puzzle_3:   # submit puzzle and request new one
    la $t0, puzzle
    sw $t0, SUBMIT_SOLUTION
    sw $t0, REQUEST_PUZZLE
    sw $0, puzzle_stage # set puzzle stage to 0

movement:
    lw  $t0, bonk_flag
    beq $t0, 0, mission_control_end # do nothing if not bonked
    sw  $0, bonk_flag   # set bonk flag back to 0
    jal update

    lw  $t0, location_switch
    beq $t0, 0, counter_movement
    beq $t0, 1, order_movement
    beq $t0, 2, food_movement
    beq $t0, 3, appliance_movement
counter_movement:
    li  $t0, 1
    li  $t1, 2
    li  $t2, 3
    sw  $0, DROPOFF
    sw  $t0, DROPOFF
    sw  $t1, DROPOFF
    sw  $t2, DROPOFF
    # order
    # j counter_raw_food
    jal determineOrder
    lw  $t0, order_success
		# sw  $t0, PRINT_INT_ADDR
    beq $t0, -1, counter_raw_food
    li  $t0, 1
    sw  $t0, location_switch  # set location flag to 1
    jal Move_to_order_place
    j mission_control_end
    # counter raw food
counter_raw_food:
    jal rawFood
    beq $v0, -1, counter_food_bin # rawfood fails
    move $a0, $v0
    move $a1, $v1
    jal findAngle
    j mission_control_end
    # food bin
counter_food_bin:
    jal foodbin_switch
    li  $t0, 2
    sw  $t0, location_switch  # set location flag to 2
    j mission_control_end
order_movement:
    jal Compare_current_order
    beq $v0, 0, order_movement_end  # do nothing if compare fails
    # submit order if success
    sw  $0, SUBMIT_ORDER
    li  $t0, -1
    sw  $t0, order_success  # reset order success
order_movement_end:
    li  $a0, 140
    li  $a1, 240
    jal findAngle # moveback to counter
    sw  $0, location_switch # go back to counter after order
    j mission_control_end
food_movement:
    jal foodbin_todo  # location flag in the appliance location
    j mission_control_end
appliance_movement:  # finish
    jal appliance_todo
    sw  $0, location_switch # go back to counter after appliance
    j mission_control_end

mission_control_end:
    lw  $ra, 0($sp)
    lw	$s0, 4($sp)
    lw  $s1, 8($sp)
    lw  $s2, 12($sp)
    lw  $s3, 16($sp)
    add $sp, $sp, 20
    jr $ra

update:
    sub   $sp, $sp, 12
	  sw    $ra, 0($sp)
	  sw    $s0, 4($sp)
	  sw    $s1, 8($sp)

    # update order infor
    la $s0, order_fetch
    sw $s0, GET_TURNIN_ORDER

    lw $a0, 0($s0)
    lw $a1, 4($s0)
    la $a2, order_0
    jal decode_request

    lw $a0, 8($s0)
    lw $a1, 12($s0)
    la $a2, order_1
    jal decode_request

    lw $a0, 16($s0)
    lw $a1, 20($s0)
    la $a2, order_2
    jal decode_request

    # update process infor
    la $s0, order_fetch
    sw $s0, GET_TURNIN_USERS

    lw $a0, 0($s0)
    lw $a1, 4($s0)
    la $a2, process_0
    jal decode_request

    lw $a0, 8($s0)
    lw $a1, 12($s0)
    la $a2, process_1
    jal decode_request

    lw $a0, 16($s0)
    lw $a1, 20($s0)
    la $a2, process_2
    jal decode_request

    # update counter
    la $s0, counter_fetch
    sw $s0, GET_SHARED

    lw $a0, 0($s0)
    lw $a1, 4($s0)
    la $a2, shared_counter
    jal decode_request

    # clear neededIngredient
    li  $t0, 0
    la  $t2, neededIngredient
array_clean_loop:
    bge $t0, 12, array_clean_finish
    mul $t1, $t0, 4
    add $t1, $t2, $t1
    sw  $0, 0($t1)

    add $t0, $t0, 1
    j array_clean_loop
array_clean_finish:

  lw    $ra, 0($sp)
	lw    $s0, 4($sp)
	lw    $s1, 8($sp)
	add   $sp, $sp, 12
	jr		$ra

#
#check appliance, return next location, $a0 food id  $a1 id of first appliance, $a2 id of the second appliance
appliance_location:

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
  bne $a0, 9, unwahsedLettuceL
  bne $a1, 5, u2sink
  j   u1
unwahsedLettuceL:
  bne $a0, 10, lettuceL
  bne $a1, 6, u2chop
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
  li  $v0, 120  #x=7
  li  $v1, 140  #y=6
  sw  $0, location_switch
  jr  $ra
u1:
  li  $v0, 50
  li  $v1, 60
  li  $t0, 3
  sw  $t0, location_switch
  jr  $ra
u2:
  li  $v0, 100
  li  $v1, 60
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
  bne $a1, 5, u4sink
  j   u3
unwahsedLettuceR:
  bne $a0, 10, lettuceR
  bne $a1, 6, u4chop
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
  li  $v0, 160  #x=7
  li  $v1, 140  #y=8
  sw  $0, location_switch
  jr  $ra
u3:
  li  $v0, 180
  li  $v1, 60
  li  $t0, 3
  sw  $t0, location_switch
  jr  $ra
u4:
  li  $v0, 240
  li  $v1, 60
  li  $t0, 3
  sw  $t0, location_switch
  jr  $ra

findAngle:
	sub   $sp, $sp, 12
	sw    $ra, 0($sp)
	sw    $s0, 4($sp)
	sw    $s1, 8($sp)
	move  	$s0, $a0 			# s0 = a0
	move  	$s1, $a1			# s1 = a1
	lw		$t0, BOT_X		# t0 = BOT_X x    a0 = x1 targetX
	lw    $t1, BOT_Y        # t1 = BOT_Y y		a1 = y1 targetY
	bne   $t0, $s0, not_same
	bne   $t1, $s1, not_same
	sw    $zero, VELOCITY
	lw    $ra, 0($sp)
	lw    $s0, 4($sp)
	lw    $s1, 8($sp)
	add   $sp, $sp, 12
	jr		$ra
not_same:
	sub   $t2, $s0, $t0		# t2 = x
	sub   $t3, $s1, $t1   # t3 = y
	move  $a0, $t2
	move  $a1, $t3
	jal   sb_arctan
	sw    $v0, ANGLE
	# sw    $v0, PRINT_INT_ADDR
	li    $t4, 1
	sw    $t4, ANGLE_CONTROL
	add   $t4, $t4, 2
	sw    $t4, VELOCITY
	lw    $ra, 0($sp)
	lw    $s0, 4($sp)
	lw    $s1, 8($sp)
	add   $sp, $sp, 12
	jr		$ra

Compare_current_order:
	sub   $sp, $sp, 4
	sw    $ra, 0($sp)
	la		$t0, order_success
	lw    $t0, 0($t0)
	beq   $t0, -1, compare_end
	beq   $t0, 0, compare_order_0
	beq   $t0, 1, compare_order_1
	beq   $t0, 2, compare_order_2
compare_order_0:
	la 		$t0, order_fetch
	sw 		$t0, GET_TURNIN_ORDER
	lw 		$a0, 0($t0)
	lw 		$a1, 4($t0)
	la 		$a2, order_0
	jal 	decode_request
	la 		$t0, order_fetch
	sw 		$t0, GET_TURNIN_USERS
	lw 		$a0, 0($t0)
	lw 		$a1, 4($t0)
	la 		$a2, process_0
	jal 	decode_request
	la    $t0, order_0
	la    $t1, process_0
	li    $t2, 0
	j     compare_loop
compare_order_1:
	la 		$t0, order_fetch
	sw 		$t0, GET_TURNIN_ORDER
	lw 		$a0, 0($t0)
	lw 		$a1, 4($t0)
	la 		$a2, order_1
	jal 	decode_request
	la 		$t0, order_fetch
	sw 		$t0, GET_TURNIN_USERS
	lw 		$a0, 0($t0)
	lw 		$a1, 4($t0)
	la 		$a2, process_1
	jal 	decode_request
	la    $t0, order_1
	la    $t1, process_1
	li    $t2, 0
	j     compare_loop
compare_order_2:
	la 		$t0, order_fetch
	sw 		$t0, GET_TURNIN_ORDER
	lw 		$a0, 0($t0)
	lw 		$a1, 4($t0)
	la 		$a2, order_2
	jal 	decode_request
	la 		$t0, order_fetch
	sw 		$t0, GET_TURNIN_USERS
	lw 		$a0, 0($t0)
	lw 		$a1, 4($t0)
	la 		$a2, process_2
	jal 	decode_request
	la    $t0, order_2
	la    $t1, process_2
	li    $t2, 0
compare_loop:
	bge   $t2, 12, compare_pass
	mul   $t3, $t2, 4
	add   $t4, $t3, $t0
	add   $t5, $t3, $t1
	lw    $t4, 0($t4)
	lw    $t5, 0($t5)
	add   $t2, $t2, 1
	bne   $t4, $t5, compare_end
	j     compare_loop
compare_pass:
	li    $v0, 1
	lw    $ra, 0($sp)
	add   $sp, $sp, 4
	jr    $ra
compare_end:
	li    $v0, 0
	lw    $ra, 0($sp)
	add   $sp, $sp, 4
	jr    $ra

foodbin_todo:
  sub $sp, $sp, 4
	sw  $ra, 0($sp)
  sw  $0,  PICKUP
  sw  $0,  PICKUP
  sw  $0,  PICKUP
  sw  $0,  PICKUP

  la  $t0, inventory
  sw  $t0, GET_INVENTORY

  lw  $t0, 0($t0) # first food
  and $t1, $t0, 0xffff0000
  srl $t1, $t1, 16 # food id
  and $t2, $t0, 0x00000001 # process level

  lw  $a1, left_appliance
  lw  $a2, right_appliance

  beq $t1, 0, foodbin_bread
  beq $t1, 1, foodbin_cheese
  beq $t1, 2, foodbin_meat
  beq $t1, 3, foodbin_tomato
  beq $t1, 4, foodbin_onion
  beq $t1, 5, foodbin_lettuce
  j   foodbin_end
foodbin_bread:
    li  $a0, 0
    jal appliance_location
    j foodbin_end
foodbin_cheese:
    li  $a0, 1
    jal appliance_location
    j foodbin_end
foodbin_meat:
    li  $a0, 2
    jal appliance_location
    j foodbin_end
foodbin_tomato:
    li  $a0, 5
    jal appliance_location
    j foodbin_end
foodbin_onion:
    li  $a0, 7
    jal appliance_location
    j foodbin_end
foodbin_lettuce:
    beq $t2, 1, foodbin_lettuce_uncut
    li  $a0, 9
    jal appliance_location
    j foodbin_end
foodbin_lettuce_uncut:
    li  $a0, 10
    jal appliance_location
    j foodbin_end
foodbin_end:
    move $a0, $v0
    move $a1, $v1
    jal findAngle

    lw  $ra, 0($sp)
    add $sp, $sp, 4
    jr  $ra

appliance_todo:
  sub $sp, $sp, 4
	sw  $ra, 0($sp)

    li $t0, 270
    li $t1, 1
    sw $t0, ANGLE
    sw $t1, ANGLE_CONTROL
    jal cook

    la  $t0, inventory
    sw  $t0, GET_INVENTORY

    lw  $t0, 0($t0) # first food
    and $t1, $t0, 0xffff0000
    srl $t1, $t1, 16 # food id
    and $t2, $t0, 0x00000001 # process level

    lw  $a1, left_appliance
    lw  $a2, right_appliance

    beq $t1, 0, appliance_bread
    beq $t1, 1, appliance_cheese
    beq $t1, 2, appliance_meat
    beq $t1, 3, appliance_tomato
    beq $t1, 4, appliance_onion
    beq $t1, 5, appliance_lettuce
    j   appliance_end
appliance_bread:
    li  $a0, 0
    jal appliance_location
    j appliance_end
appliance_cheese:
    li  $a0, 1
    jal appliance_location
    j appliance_end
appliance_meat:
    li  $a0, 2
    jal appliance_location
    j appliance_end
appliance_tomato:
    li  $a0, 5
    jal appliance_location
    j appliance_end
appliance_onion:
    li  $a0, 7
    jal appliance_location
    j appliance_end
appliance_lettuce:
    beq $t2, 1, appliance_lettuce_uncut
    li  $a0, 9
    jal appliance_location
    j appliance_end  
appliance_lettuce_uncut:  
    li  $a0, 10
    jal appliance_location
    j appliance_end 
appliance_end:
    move $a0, $v0
    move $a1, $v1
    jal findAngle

    lw  $ra, 0($sp)
    add $sp, $sp, 4
    jr  $ra

  #pass $a0 as order $a1 as process
compareOrder:
  sub $sp, $sp, 20
  sw  $s0, 0($sp)  #order
  sw  $s1, 4($sp)  #process
  sw  $s2, 8($sp)  #shared counter
  sw  $s3, 12($sp)
	sw  $ra, 16($sp)
  #array from global

  #order_0
  move  $s0, $a0  #order
  move  $s1, $a1  #process
  la  $s2, counter
  la  $s3, neededIngredient
  li  $t0, 0
order0:
  bge $t0, 12, compare_0  #0<12
  mul $t1, $t0, 4 #i*4
  add $t2, $s0, $t1 #order
  add $t3, $s1, $t1 #process
  add $t4, $s3, $t1 #ingredient
  lw  $t2, 0($t2)   #order[i]
  lw  $t3, 0($t3)   #process[i]
  sub $t5, $t2, $t3 #order[i] - process[i]
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
  lw  $t3, 4($s3)
  bgt $t3, $t2, fail
#meat 3
  lw  $t2, 12($s2)
  lw  $t3, 12($s3)
  bgt $t3, $t2, fail
#tomato
  lw  $t2, 24($s2)
  lw  $t3, 24($s3)
  bgt $t3, $t2, fail
#onion
  lw  $t2, 32($s2)
  lw  $t3, 32($s3)
  bgt $t3, $t2, fail
#lettuce
  lw  $t2, 44($s2)
  lw  $t3, 44($s3)
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
	lw  $ra, 16($sp)
  add $sp, $sp, 20
  jr  $ra
fail:
  li  $v0, 0
  lw  $s0, 0($sp)  #order
  lw  $s1, 4($sp)  #process
  lw  $s2, 8($sp)  #shared counter
  lw  $s3, 12($sp)
	lw  $ra, 16($sp)
  add $sp, $sp, 20
  jr  $ra

determineOrder:
  sub $sp, $sp, 4
  sw  $ra, 0($sp)
  la  $a0, order_0
  la  $a1, process_0
  jal compareOrder
  #order_success
  bne $v0, 1, order1
  sw  $0, order_success
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
order1:
  la  $a0, order_1
  la  $a1, process_1
  jal compareOrder
  bne $v0, 1, order2
  li  $t0, 1
  sw  $t0, order_success
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
order2:
  la  $a0, order_2
  la  $a1, process_2
  jal compareOrder
  bne $v0, 1, noOrder
  li  $t0, 2
  sw  $t0, order_success
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra
noOrder:
  li  $t0, -1
  sw  $t0, order_success
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra

rawFood:
  sub $sp, $sp, 4
  sw  $ra, 0($sp)
  la  $t1, shared_counter
  lw  $t0, 8($t1)  #raw meat
  blt $t0, 4, unwahsedT
  li  $a0, 2
  lw  $a1, left_appliance
  lw  $a2, left_appliance
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
  blt $t0, 4, rawFood_end
  li  $a0, 10
  lw  $a1, left_appliance
  lw  $a2, right_appliance
  jal appliance_location
  lw  $t3, location_switch
  bne $t3, 3, rawFood_end
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
rawFood_end:
  li  $v0, -1
  li  $v1, -1
  lw  $ra, 0($sp)
  add $sp, $sp, 4
  jr  $ra

foodbin_switch:
    sub $sp, $sp, 4
    sw  $ra, 0($sp)

    lw  $t0, side
    lw  $t1, foodbin_stage
    beq $t0, 1, foodbin_right
    # left side
    beq $t1, 0, foodbin_left_0
    beq $t1, 1, foodbin_left_1
    beq $t1, 2, foodbin_left_2
foodbin_left_0:
    li  $a0, 10
    li  $a1, 70
    li  $t2, 1
    sw  $t2, foodbin_stage
    jal findAngle
    j   foodbin_switch_end
foodbin_left_1:
    li  $a0, 10
    li  $a1, 150
    li  $t2, 2
    sw  $t2, foodbin_stage
    jal findAngle
    j   foodbin_switch_end
foodbin_left_2:
    li  $a0, 10
    li  $a1, 230
    li  $t2, 0
    sw  $t2, foodbin_stage
    jal findAngle
    j   foodbin_switch_end
foodbin_right:
    # right side
    beq $t1, 0, foodbin_right_0
    beq $t1, 1, foodbin_right_1
    beq $t1, 2, foodbin_right_2
foodbin_right_0:
    li  $a0, 290
    li  $a1, 70
    li  $t2, 1
    sw  $t2, foodbin_stage
    jal findAngle
    j   foodbin_switch_end
foodbin_right_1:
    li  $a0, 290
    li  $a1, 150
    li  $t2, 2
    sw  $t2, foodbin_stage
    jal findAngle
    j   foodbin_switch_end
foodbin_right_2:
    li  $a0, 290
    li  $a1, 230
    li  $t2, 0
    sw  $t2, foodbin_stage
    jal findAngle
    j   foodbin_switch_end
foodbin_switch_end:
    lw  $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra

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
right_side_order_2:
  li    $a0, 260
  li    $a1, 280
  jal   findAngle
  j     No_order
No_order:
  lw    $ra, 0($sp)
  add   $sp, $sp, 4
  jr    $ra

cook:
  li      $t0, 0
drop_loop:
  bge     $t0, 4, appliance_done
  sw      $t0, DROPOFF
  lw      $t3, BOT_X
  ble     $t3, 75, first_appliance
  ble     $t3, 135, second_appliance
  ble     $t3, 215, third_appliance
  ble     $t3, 275, forth_appliance
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
  add     $t2, $t1, 1
appliance_loop:
  lw      $t1, GET_TILE_INFO
  bne     $t1, $t2, appliance_loop
  sw      $zero, PICKUP
  add     $t0, $t0, 1
  j       drop_loop
appliance_done:
  jr      $ra


# puzzle_solver
floodfill:

#       if (row < 0 || col < 0) {
#             return marker;
#       }
#       if (row >= puzzle->NUM_ROWS || col >= puzzle->NUM_COLS) {
#               return marker;
#       }
    slt     $t0, $a2, 0
    slt     $t1, $a3, 0
    or      $t0, $t1, $t0
    beq     $t0, 0, f_end_if1
    move    $v0, $a1
    jr      $ra
f_end_if1:

    lw      $t0, 0($a0)
    lw      $t1, 4($a0)
    sge     $t0, $a2, $t0
    sge     $t1, $a3, $t1
    or      $t0, $t1, $t0

    beq     $t0, 0, f_end_if2
    move    $v0, $a1
    jr      $ra
f_end_if2:

#       char board[][] = puzzle->board;
#       if (board[row][col] != ’#’) {
#               return marker;
#       }
    lw      $t0, 0($a0)
    lw      $t1, 4($a0)
    mul     $t2, $a2, $t1
    add     $t2, $t2, $a3
    add     $t2, $t2, $a0
    add     $t2, $t2, 8
    lb      $t3, 0($t2)

    beq     $t3, '#', f_endif_3
    move    $v0, $a1
    jr      $ra
f_endif_3:

f_recur:
    sub     $sp, $sp, 88
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)
    sw      $s2, 12($sp)
    sw      $s3, 16($sp)
    sw      $t3, 48($sp)
    sw      $t4, 52($sp)
    sw      $t5, 56($sp)
    sw      $t6, 60($sp)
    sw      $t7, 64($sp)
    sw      $t8, 68($sp)
    sw      $t9, 72($sp)
    sw      $s4, 20($sp)
    sw      $s5, 24($sp)
    sw      $s6, 28($sp)
    sw      $s7, 32($sp)
    sw      $t0, 36($sp)
    sw      $t1, 40($sp)
    sw      $t2, 44($sp)
    sw      $a0, 76($sp)
    sw      $a1, 80($sp)
    sw      $a2, 84($sp)

#       board[row][col] = marker;
    sb      $a1, 0($t2)

    move    $s0, $a0
    move    $s1, $a1
    move    $s2, $a2
    move    $s3, $a3

#       floodfill(puzzle, marker, row + 1, col + 1);
    move    $a0, $s0
    move    $a1, $s1
    add     $a2, $s2, 1
    add     $a3, $s3, 1
    jal     floodfill

#       floodfill(puzzle, marker, row + 1, col + 0);
    move    $a0, $s0
    move    $a1, $s1
    add     $a2, $s2, 1
    add     $a3, $s3, 0
    jal     floodfill
#       floodfill(puzzle, marker, row + 1, col - 1);
    move    $a0, $s0
    move    $a1, $s1
    add     $a2, $s2, 1
    add     $a3, $s3, -1
    jal     floodfill
#       floodfill(puzzle, marker, row, col + 1);
    move    $a0, $s0
    move    $a1, $s1
    add     $a2, $s2, 0
    add     $a3, $s3, 1
    jal     floodfill
#       floodfill(puzzle, marker, row, col - 1);
    move    $a0, $s0
    move    $a1, $s1
    add     $a2, $s2, 0
    add     $a3, $s3, -1
    jal     floodfill
#       floodfill(puzzle, marker, row - 1, col + 1);
    move    $a0, $s0
    move    $a1, $s1
    add     $a2, $s2, -1
    add     $a3, $s3, 1
    jal     floodfill
#       floodfill(puzzle, marker, row - 1, col + 0);
    move    $a0, $s0
    move    $a1, $s1
    add     $a2, $s2, -1
    add     $a3, $s3, 0
    jal     floodfill
#       floodfill(puzzle, marker, row - 1, col - 1);
    move    $a0, $s0
    move    $a1, $s1
    add     $a2, $s2, -1
    add     $a3, $s3, -1
    jal     floodfill
#       return marker + 1;
    add     $v0, $a1, 1
f_done:
    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    lw      $s2, 12($sp)
    lw      $s3, 16($sp)
    lw      $s4, 20($sp)
    lw      $s5, 24($sp)
    lw      $s6, 28($sp)
    lw      $s7, 32($sp)

    lw      $t0, 36($sp)
    lw      $t1, 40($sp)
    lw      $t2, 44($sp)
    lw      $t3, 48($sp)
    lw      $t4, 52($sp)
    lw      $t5, 56($sp)
    lw      $t6, 60($sp)
    lw      $t7, 64($sp)
    lw      $t8, 68($sp)
    lw      $t9, 72($sp)

    lw      $a0, 76($sp)
    lw      $a1, 80($sp)
    lw      $a2, 84($sp)
    add     $sp, $sp, 88

    jr      $ra

# void islandfill(Puzzle* puzzle) {
#       char marker = ’A’;
#       for (int i = 0; i < puzzle->NUM_ROWS; i++) {
#             for (int j = 0; j < puzzle->NUM_COLS; j++) {
#                     marker = floodfill(puzzle,marker,i,j);
#             }
#       }
# }

islandfill:
    sub     $sp, $sp, 88
    sw      $ra, 0($sp)
    sw      $s0, 4($sp)
    sw      $s1, 8($sp)
    sw      $s2, 12($sp)
    sw      $s3, 16($sp)
    sw      $s4, 20($sp)
    sw      $s5, 24($sp)
    sw      $s6, 28($sp)
    sw      $s7, 32($sp)
    sw      $t0, 36($sp)
    sw      $t1, 40($sp)
    sw      $t2, 44($sp)
    sw      $t3, 48($sp)
    sw      $t4, 52($sp)
    sw      $t5, 56($sp)
    sw      $t6, 60($sp)
    sw      $t7, 64($sp)
    sw      $t8, 68($sp)
    sw      $t9, 72($sp)
    sw      $a0, 76($sp)
    sw      $a1, 80($sp)
    sw      $a2, 84($sp)

    move    $s0, $a0
    li      $s1, 'A'
    li      $s2, 0

    lw      $s4, 0($a0)
    lw      $s5, 4($a0)

i_outer_loop:
    bge     $s2, $s4, i_outer_end

    li      $s3, 0
i_inner_loop:
    bge     $s3, $s5, i_inner_end

    # marker = floodfill(puzzle,marker,i,j);
    move    $a0, $s0
    move    $a1, $s1
    move    $a2, $s2
    move    $a3, $s3
    jal     floodfill
    move    $s1, $v0

    # move    $a0, $s0
    # jal     print_board

    add     $s3, $s3, 1
    j       i_inner_loop
i_inner_end:

    add     $s2, $s2, 1

    jal mission_control #switch to movement

    j       i_outer_loop
i_outer_end:
    li      $t0, 3
    sw      $t0, puzzle_stage # set puzzle stage to 3

    lw      $ra, 0($sp)
    lw      $s0, 4($sp)
    lw      $s1, 8($sp)
    lw      $s2, 12($sp)
    lw      $s3, 16($sp)
    lw      $s4, 20($sp)
    lw      $s5, 24($sp)
    lw      $s6, 28($sp)
    lw      $s7, 32($sp)

    lw      $t0, 36($sp)
    lw      $t1, 40($sp)
    lw      $t2, 44($sp)
    lw      $t3, 48($sp)
    lw      $t4, 52($sp)
    lw      $t5, 56($sp)
    lw      $t6, 60($sp)
    lw      $t7, 64($sp)
    lw      $t8, 68($sp)
    lw      $t9, 72($sp)

    lw      $a0, 76($sp)
    lw      $a1, 80($sp)
    lw      $a2, 84($sp)
    add     $sp, $sp, 88
    jr      $ra

decode_request:
	sub		$sp, $sp, 4
	sw		$ra, 0($sp)		# save $ra on stack

	li		$t0, 0

first_loop:
	bge 	$t0, 6, intermediate_bits	#for (int i = 0; i < 6; ++i)
	and		$t1, $a0, 0x1f	#array[i] = lo & 0x0000001f;
	mul		$t2, $t0, 4		#Calculate array[i]
	add		$t3, $a2, $t2
	sw		$t1, 0($t3)		#Save array[i]
	srl		$a0, $a0, 5		#lo = lo >> 5;
	add		$t0, $t0, 1
	j first_loop

intermediate_bits:
	sll		$t0, $a1, 2		#unsigned upper_three_bits = (hi << 2) & 0x0000001f;
	and		$t0, $t0, 0x1f
	or		$t0, $t0, $a0	#array[6] = upper_three_bits | lo;
	sw		$t0, 24($a2)
	srl		$a1, $a1, 3		#hi = hi >> 3;

	li		$t0, 7

second_loop:
	bge 	$t0, 12, end	#for (int i = 7; i < 12; ++i)
	and		$t1, $a1, 0x1f	#array[i] = hi & 0x0000001f;
	mul		$t2, $t0, 4		#Calculate array[i]
	add		$t3, $a2, $t2
	sw		$t1, 0($t3)		#Save array[i]
	srl		$a1, $a1, 5		#hi = hi >> 5;
	add		$t0, $t0, 1
	j second_loop

end:
	lw		$ra, 0($sp)
	add		$sp, $sp, 4
	jr		$ra

sb_arctan:
    li      $v0, 0           # angle = 0;

    abs     $t0, $a0         # get absolute values
    abs     $t1, $a1
    ble     $t1, $t0, no_TURN_90

    ## if (abs(y) > abs(x)) { rotate 90 degrees }
    move    $t0, $a1         # int temp = y;
    neg     $a1, $a0         # y = -x;
    move    $a0, $t0         # x = temp;
    li      $v0, 90          # angle = 90;

no_TURN_90:
    bgez    $a0, pos_x       # skip if (x >= 0)

    ## if (x < 0)
    add     $v0, $v0, 180    # angle += 180;

pos_x:
    mtc1    $a0, $f0
    mtc1    $a1, $f1
    cvt.s.w $f0, $f0         # convert from ints to floats
    cvt.s.w $f1, $f1

    div.s   $f0, $f1, $f0    # float v = (float) y / (float) x;

    mul.s   $f1, $f0, $f0    # v^^2
    mul.s   $f2, $f1, $f0    # v^^3
    l.s     $f3, three       # load 3.0
    div.s   $f3, $f2, $f3    # v^^3/3
    sub.s   $f6, $f0, $f3    # v - v^^3/3

    mul.s   $f4, $f1, $f2    # v^^5
    l.s     $f5, five        # load 5.0
    div.s   $f5, $f4, $f5    # v^^5/5
    add.s   $f6, $f6, $f5    # value = v - v^^3/3 + v^^5/5

    l.s     $f8, PI          # load PI
    div.s   $f6, $f6, $f8    # value / PI
    l.s     $f7, F180        # load 180.0
    mul.s   $f6, $f6, $f7    # 180.0 * value / PI

    cvt.w.s $f6, $f6         # convert "delta" back to integer
    mfc1    $t0, $f6
    add     $v0, $v0, $t0    # angle += delta

    bge     $v0, 0, sb_arc_tan_end
    # negative value received.
    li      $t0, 360
    add     $v0, $t0, $v0

sb_arc_tan_end:
    jr      $ra

.kdata
chunkIH:    .space 32
non_intrpt_str:    .asciiz "Non-interrupt exception\n"
unhandled_str:    .asciiz "Unhandled interrupt type\n"
.ktext 0x80000180
interrupt_handler:
.set noat
    move      $k1, $at        # Save $at
.set at
    la        $k0, chunkIH
    sw        $a0, 0($k0)        # Get some free registers
    sw        $v0, 4($k0)        # by storing them to a global variable
    sw        $t0, 8($k0)
    sw        $t1, 12($k0)
    sw        $t2, 16($k0)
    sw        $t3, 20($k0)
	sw $t4, 24($k0)
	sw $t5, 28($k0)

    mfc0      $k0, $13             # Get Cause register
    srl       $a0, $k0, 2
    and       $a0, $a0, 0xf        # ExcCode field
    bne       $a0, 0, non_intrpt



interrupt_dispatch:            # Interrupt:
    mfc0       $k0, $13        # Get Cause register, again
    beq        $k0, 0, done        # handled all outstanding interrupts

    and        $a0, $k0, BONK_INT_MASK    # is there a bonk interrupt?
    bne        $a0, 0, bonk_interrupt

    and        $a0, $k0, TIMER_INT_MASK    # is there a timer interrupt?
    bne        $a0, 0, timer_interrupt

	and 	$a0, $k0, REQUEST_PUZZLE_INT_MASK
	bne 	$a0, 0, request_puzzle_interrupt

    li        $v0, PRINT_STRING    # Unhandled interrupt types
    la        $a0, unhandled_str
    syscall
    j    done

bonk_interrupt:
	sw 		$0, BONK_ACK
  #Fill in your code here
  li      $t1, 1
  sw      $t1, bonk_flag
  j       interrupt_dispatch    # see if other interrupts are waiting

request_puzzle_interrupt:
	sw 		$0, REQUEST_PUZZLE_ACK
	#Fill in your code here
    li      $t1, 1
    sw      $t1, puzzle_stage   # set puzzle stage to 1
	j	interrupt_dispatch

timer_interrupt:
	sw 		$0, TIMER_ACK
	#Fill in your code here
    j        interrupt_dispatch    # see if other interrupts are waiting

non_intrpt:                # was some non-interrupt
    li        $v0, PRINT_STRING
    la        $a0, non_intrpt_str
    syscall                # print out an error message
    # fall through to done

done:
    la      $k0, chunkIH
    lw      $a0, 0($k0)        # Restore saved registers
    lw      $v0, 4($k0)
	lw      $t0, 8($k0)
    lw      $t1, 12($k0)
    lw      $t2, 16($k0)
    lw      $t3, 20($k0)
	lw $t4, 24($k0)
	lw $t5, 28($k0)
.set noat
    move    $at, $k1        # Restore $at
.set at
    eret
