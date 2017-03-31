;=================================================
;LIBRARY HARNESS
;=================================================

;;;;;;;;;;;;;;;;;;;;;;
;INPUT TEST SEQUENCE
;;;;;;;;;;;;;;;;;;;;;
.ORIG x3000 

LD R1, PTR1 ; BINARY INPUT
JSRR R1
 
LD R1, PTR2 ; BINARY OUTPUT
JSRR R1
 
AND R0, R0, #0
ADD R0, R0, x0A ; \n
OUT

;---------------------------------

LD R1, PTR3 ; DECIMAL INPUT
JSRR R1

LD R1, PTR4 ; DECIMAL OUTPUT
JSRR R1

AND R0, R0, #0
ADD R0, R0, x0A ; \n
OUT

;---------------------------------

HALT

PTR1 .FILL x4000	; BINARY INPUT ROUTINE POINTER
PTR2 .FILL x4100	; BINARY OUTPUT ROUTINE POINTER
PTR3 .FILL x4200	; DECIMAL INPUT ROUTINE POINTER
PTR4 .FILL x4300	; DECIMAL OUTPUT ROUTINE POINTER
;;;;;;;;;;;;;;;;;;;;;;;;
;END TEST INPUT SEQUENCE
;;;;;;;;;;;;;;;;;;;;;;;;

.END

