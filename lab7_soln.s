.text

##// Sets the values of the array to the corresponding values in the request
##void decode_request(unsigned long int request, int* array) { 
##  // The hi and lo values are already given to you, so you don't have to
##  // perform these shifting operations. They are included so that this
##  // code functions in C. The lo value is $a0 and the hi value is $a1.
##  unsigned lo = (unsigned)((request << 32) >> 32);
##  unsigned hi = (unsigned)(request >> 32);
##
##  for (int i = 0; i < 6; ++i) {
##    array[i] = lo & 0x0000001f;
##    lo = lo >> 5;
##  }
##  unsigned upper_three_bits = (hi << 2) & 0x0000001f;
##  array[6] = upper_three_bits | lo;
##  hi = hi >> 3;
##  for (int i = 7; i < 12; ++i) {
##    array[i] = hi & 0x0000001f;
##    hi = hi >> 5;
##  }
##}

.globl decode_request
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
	
	
	
##// Returns a long int message given the decoded message in
##// the array.
##long int create_request(int* array) {
##  unsigned lo = ((array[6] << 30) >> 30);
##  for (int i = 5; i >= 0; --i) {
##    lo = lo << 5;
##    lo |= array[i];
##  }
##  
##  unsigned hi = 0;
##  for (int i = 12; i > 7; --i) {
##   hi |= array[i];
##    hi = hi << 5;
##  }
##  hi |= array[7];
##  hi = hi << 3;
##  hi |= (array[6] >> 2);
##
##  //Because you can't store long int values in a register, the
##  //following code is not necessary to implement in MIPS. It
##  //is included so that this code functions in C.
##
##  unsigned long int request = (unsigned long int)hi << 32;
##  request |= (unsigned long int)lo; 
##  return request;
##}

.globl create_request
create_request:
	sub		$sp, $sp, 4
	sw		$ra, 0($sp)		# save $ra on stack
	
	lw		$v0, 24($a0)	#unsigned lo = ((array[6] << 30) >> 30);
	sll		$v0, $v0, 30
	srl		$v0, $v0, 30
	
	li		$t0, 5
first_loop:
	blt 	$t0, 0, second_loop_start	#for (int i = 5; i >= 0; --i) {
	sll		$v0, $v0, 5		#lo = lo << 5;
	mul		$t1, $t0, 4		#Calculate array[i]
	add		$t2, $a0, $t1	
	lw		$t1, 0($t2)		#Load array[i]
	or		$v0, $v0, $t1	#lo |= array[i];
	sub		$t0, $t0, 1
	j first_loop
	
second_loop_start:
	li		$t0, 12
	li		$v1, 0
	
second_loop:
	ble 	$t0, 7, intermediate_bits	#  for (int i = 12; i > 7; --i) {
	mul		$t1, $t0, 4		#Calculate array[i]
	add		$t2, $a0, $t1	
	lw		$t1, 0($t2)		#Load array[i]
	or		$v1, $v1, $t1	#hi |= array[i];
	sll		$v1, $v1, 5		#hi = hi << 5;
	
	sub		$t0, $t0, 1
	j second_loop
	
intermediate_bits:	
	lw		$t1, 28($a0)	#Load array[7]
	or		$v1, $v1, $t1	#hi |= array[i];
	sll		$v1, $v1, 3		#hi = hi << 3;
	lw		$t1, 24($a0)	#Load array[6]
	srl		$t1, $t1, 2		#(array[6] >> 2)
	or		$v1, $v1, $t1	#hi |= (array[6] >> 2);
	
end:
	lw		$ra, 0($sp)
	add		$sp, $sp, 4
	jr		$ra