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

# flags:
# 0: puzzle is requested but not arrive
# 1: puzzle is there and has not start solving
# 2: puzzle is solving but not finish
# 3: puzzle is finished
puzzle_stage: .word 4

side: .word 4   # 0: left, 1: right

bonk_flag:  .word 4 #0: nothing, 1: just bonked

#arctan constants
three: 	.float  3.0
five:  .float  5.0
PI:    .float  3.141592
F180:  .float 180.0

layout: .word 225
left_applicance: .word 1
right_applicance: .word 1

order_fetch: .word 24
order_0: .word 48
order_1: .word 48
order_2: .word 48
process_0: .word 48
process_1: .word 48
process_2: .word 48
counter_fetch: .word 8
counter: .word 48
neededIngredient: .word 48

inventory: .word 16

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
    beq $t0, 0, spawn_left_app
    # set up spawn right app
    lb  $t2, 39($t1)
    sb  $t2, right_applicance
    lb  $t2, 42($t1)
    sb  $t2, left_applicance
    j app_finish
spawn_left_app:
    lb  $t2, 32($t1)
    sb  $t2, right_applicance
    lb  $t2, 35($t1)
    sb  $t2, left_applicance
app_finish:
    add $0, $0, $0  # place holder
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
	# li $a0, 60
	# li $a1, 90
	# jal findAngle

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
    la $a2, counter
    jal decode_request

    # clear neededIngredient
    li  $t0, 0
array_clean_loop:
    bge $t0, 12, array_clean_finish
    mul $t1, $t0, 4
    la  $t2, neededIngredient
    add $t2, $t2, $t1
    sw  $0, 0($t2)
    j array_clean_loop
array_clean_finish:

    lw    $ra, 0($sp)
	lw    $s0, 4($sp)
	lw    $s1, 8($sp)
	add   $sp, $sp, 12
	jr		$ra

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
	add   $t4, $t4, 9
	sw    $t4, VELOCITY
	lw    $ra, 0($sp)
	lw    $s0, 4($sp)
	lw    $s1, 8($sp)
	add   $sp, $sp, 12
	jr		$ra

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
