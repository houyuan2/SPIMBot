# SPIMBot
UIUC CS233 Spring 2019 SPIMBot

PREP stage:
  main: request puzzle
        solve puzzle
        move bot to the start location
        calculate action sequence, store in the array
        submit puzzle
        initialize all stage variables
        request puzzle
        call act

ACTION stage:
  act: 
       if puzzle is there and has not start solving, start solving puzzle 
       (at puzzle interrupt, raise flag saying puzzle has arrived; before exiting puzzle solving function, raise flag saying puzzle is finished)
       if puzzle is finished, submit puzzle and request new one, change puzzle flag
        
        check if bot is at the current stage position.
        if not, call move function, jump to act
        else: do corresponding things (pick up, drop off, cooking)
        if current stage is finished, move to next stage index, jump to act
 
 PUZZLE FLAG:
      0: puzzle is requested but not arrive
      1: puzzle is there and has not start solving
      2: puzzle is solving but not finish
      3: puzzle is finished
       
