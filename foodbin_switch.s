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
    jal findAngle
    j   foodbin_switch_end
foodbin_left_1:
    li  $a0, 10
    li  $a1, 150
    jal findAngle
    j   foodbin_switch_end
foodbin_left_2:
    li  $a0, 10
    li  $a1, 230
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
    jal findAngle
    j   foodbin_switch_end
foodbin_right_1:
    li  $a0, 290
    li  $a1, 150
    jal findAngle
    j   foodbin_switch_end
foodbin_right_2:
    li  $a0, 290
    li  $a1, 230
    jal findAngle
    j   foodbin_switch_end
foodbin_switch_end:
    lw  $ra, 0($sp)
    add $sp, $sp, 4
    jr $ra