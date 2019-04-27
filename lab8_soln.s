#struct puzzle {
#	unsigned num_rows;
#	unsigned num_cols;
#   unsigned char unsolved_puzzle[num_rows][num_cols];
#   unsigned char puzzle_bitmap[num_rows][ceil(num_cols/8)];
#} puzzle;

# char floodfill (Puzzle* puzzle, char marker, int row, int col) {
#       if (row < 0 || col < 0) {
#             return marker;
#       }
#       if (row >= puzzle->NUM_ROWS || col >= puzzle->NUM_COLS) {
#               return marker;
#       }
#       char ** board = puzzle->board;
#       if (board[row][col] != ’#’) {
#               return marker;
#       }
#       board[row][col] = marker;
#       floodfill(puzzle, marker, row + 1, col + 1);
#       floodfill(puzzle, marker, row + 1, col + 0);
#       floodfill(puzzle, marker, row + 1, col - 1);
#       floodfill(puzzle, marker, row, col + 1);
#       floodfill(puzzle, marker, row, col - 1);
#       floodfill(puzzle, marker, row - 1, col + 1);
#       floodfill(puzzle, marker, row - 1, col + 0);
#       floodfill(puzzle, marker, row - 1, col - 1);
#       return marker + 1;
# }
# void islandfill(Puzzle* puzzle) {
#       char marker = ’A’;
#       for (int i = 0; i < puzzle->NUM_ROWS; i++) {
#             for (int j = 0; j < puzzle->NUM_COLS; j++) {
#                     marker = floodfill(puzzle,marker,i,j);
#             }
#       }
# }

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

        #                     marker = floodfill(puzzle,marker,i,j);
        move    $a0, $s0
        move    $a1, $s1
        move    $a2, $s2
        move    $a3, $s3
        jal     floodfill
        move    $s1, $v0

        move    $a0, $s0
        jal     print_board

        add     $s3, $s3, 1
        j       i_inner_loop
i_inner_end:

        add     $s2, $s2, 1
        j       i_outer_loop
i_outer_end:
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


# print board ##################################################
#
# argument $a0: board to print
.globl print_board
print_board:
    sub         $sp, $sp, 20
    sw          $ra, 0($sp)     # save $ra and free up 4 $s registers for
    sw          $s0, 4($sp)     # i
    sw          $s1, 8($sp)     # j
    sw          $s2, 12($sp)    # the address
    sw          $s3, 16($sp)    # the line number
    move        $s2, $a0
    li          $s0, 0          # i
pb_loop1:
    li          $s1, 0          # j
pb_loop2:

    lw          $t0, 0($s2)     # NUM_ROWS
    lw          $t1, 4($s2)     # NUM_COLS

    mul         $t2, $s0, $t1   # i * NUM_COLS
    add         $t2, $t2, $s1   # i * NUM_COLS + j
    add         $t2, $t2, 8
    add         $t2, $t2, $s2


    lb          $a0, 0($t2)     # num = &board[i][j]
    li          $v0, 11
    syscall
    j           pb_cont
pb_cont:
    add         $s1, $s1, 1     # j++
    blt         $s1, 8, pb_loop2
    li          $v0, 11         # at the end of a line, print a newline char.
    li          $a0, '\n'
    syscall

    add         $s0, $s0, 1     # i++
    blt         $s0, 8, pb_loop1
    lw          $ra, 0($sp)     # restore registers and return
    lw          $s0, 4($sp)
    lw          $s1, 8($sp)
    lw          $s2, 12($sp)
    lw          $s3, 16($sp)
    add         $sp, $sp, 20
    jr          $ra