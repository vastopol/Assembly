;LOGICAL OPERATIONS
;Based on: NOT, AND
;==================

.ORIG x3000

;INSTRUCTIONS
;-----------------

LD R1, var_A    ;VALUE
LD R2, var_B    ;VALUE
LD R6, ptr      ;ADDRESS

STR R1, R6, #0  ; store: A
STR R2, R6, #1  ; store: B


;AND
AND R3, R1, R2
STR R3, R6, #2  ; store: A and B


;OR
NOT R4, R1      ; not(A)
NOT R5, R2      ; not(B)
AND R3, R4, R5  ; not(A) and not(B)
NOT R3, R3      ; not(not(A) and not(B))
STR R3, R6, #3  ; store: A or B


;XOR
AND R3, R1, R2  ; A and B
NOT R3, R3      ; not(A and B)
AND R4, R1, R3  ; A and not(A and B)
AND R5, R2, R3  ; B and not(A and B)
NOT R4, R4      ; not(A and not(A and B))
NOT R5, R5      ; not(B and not(A and B))
AND R3, R4, R5  ; not(A and not(A and B)) AND not(B and not(A and B))
NOT R3, R3      ; not(not(A and not(A and B)) AND not(B and not(A and B)))
STR R3, R6, #4  ; store: A xor B


;NOT(A)
NOT R4, R1      ; not(A)
STR R4, R6, #5  ; store: not(A)


;NOT(B)
NOT R5, R2      ; not(B)
STR R5, R6, #6  ; store: not(B)


;NAND
AND R3, R1, R2  ; A and B
NOT R3, R3      ; not(A and B)
STR R3, R6, #7  ; store: A nand B


;NOR
NOT R4, R1      ; not(A)
NOT R5, R2      ; not(B)
AND R3, R4, R5  ; not(A) and not(B)
NOT R3, R3      ; not(not(A) and not(B))
AND R4, R3, R3  ; not(not(A) and not(B)) and not(not(A) and not(B))
NOT R4, R4      ; not(not(not(A) and not(B)) and not(not(A) and not(B)))
STR R4, R6, #8  ; store: A nor B

 
;XNOR
AND R3, R1, R2  ; A and B
NOT R3, R3      ; not(A and B)
AND R4, R1, R3  ; A and not(A and B)
AND R5, R2, R3  ; B and not(A and B)
NOT R4, R4      ; not(A and not(A and B))
NOT R5, R5      ; not(B and not(A and B))
AND R3, R4, R5  ; not(A and not(A and B)) AND not(B and not(A and B))
;NOT R3, R3     ; not(not(not(A and not(A and B)) AND not(B and not(A and B))))
;NOT R3, R3     ; not(not(not(not(A and not(A and B)) AND not(B and not(A and B)))))
STR R3, R6, #9  ; store: A xnor B

;*** last two NOT on XNOR are redundant, still shown as comments

HALT

;DATA
;---------------------
var_A .FILL xC  ;1100
var_B .FILL xA  ;1010
ptr .FILL x4000 ; store answers as remote data in x4000's

.END


;IN MEMORY
;---------------------------------------------
;x4000 = A
;x4001 = B
;x4002 = A and B
;x4003 = A or B
;x4004 = A xor B
;x4005 = not(A)
;x4006 = not(B)
;x4007 = A nand B
;x4008 = A nor B
;x4009 = A xnor B
