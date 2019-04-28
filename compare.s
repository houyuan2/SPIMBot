# return v0 = 1 if success else v0 = 0


Compare_current_order:
	la		$t0, order_success
	lw    $t0, 0($t0)
	beq   $t0, -1, compare_end
	beq   $t0, 0, copare_order_0
	beq   $t0, 1, copare_order_1
	beq   $t0, 2, copare_order_2
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
	jr    $ra
compare_end:
	li    $v0, 0
	jr    $ra
