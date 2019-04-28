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

    lw  $a1, left_applicance
    lw  $a2, right_applicance

    beq $t1, 0, foodbin_bread
    beq $t1, 1, foodbin_cheese
    beq $t1, 2, foodbin_meat
    beq $t1, 3, foodbin_tomato
    beq $t1, 4, foodbin_onion
    beq $t1, 5, foodbin_lettuce
    j   foodbin_end
foodbin_bread:
    lw  $a0, 0
    jal applicance_location
    j foodbin_end
foodbin_cheese:
    lw  $a0, 1
    jal applicance_location
    j foodbin_end
foodbin_meat:
    lw  $a0, 2
    jal applicance_location
    j foodbin_end
foodbin_tomato:
    lw  $a0, 5
    jal applicance_location
    j foodbin_end
foodbin_onion:
    lw  $a0, 7
    jal applicance_location
    j foodbin_end
foodbin_lettuce:
    beq $t2, 1, foodbin_lettuce_uncut
    lw  $a0, 9
    jal applicance_location
    j foodbin_end  
foodbin_lettuce_uncut:  
    lw  $a0, 10
    jal applicance_location
    j foodbin_end 
foodbin_end:
    lw  $ra, 0($sp)
    add $sp, $sp, 4
    jr  $ra