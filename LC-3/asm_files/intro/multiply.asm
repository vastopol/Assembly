;Multiplication
;(a*b)
;========================

.ORIG x3000

;INSTRUCTIONS
;--------------------
LD R1, num_1
LD R2, num_2
ADD R4, R2, #0	  ; index, copy b to use as decrement index with a "loop"

LOOP_START
  ADD R3, R3, R1
  ADD R4, R4, #-1 ; index-- 
BRp LOOP_START    ; conditional branch to LOOP_START label if R4 contains a positive value

HALT

;DATA
;--------------------
num_1 .FILL #4    ; a
num_2 .FILL #5    ; b

.END