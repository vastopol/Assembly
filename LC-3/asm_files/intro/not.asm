;Logical NOT
;========================

.ORIG x3000

;INSTRUCTIONS
;--------------------
LD R1, num_1        ; R1 <-- MEM[NUM_1] load R1 with num_1
AND R2,R1,R1        ; R2 <-- (R1)       copy num_1 from R1 to R2

NOT R2, R2          ; when R2 = #n before, after = -(#n+1)
ADD R2, R2, #1      ; finish 2's complement  
ADD R3, R1, R2      ; R3 = (R1 + R2) = 0

HALT

;DATA
;--------------------
num_1 .FILL #4

.END