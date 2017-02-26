; LC-3 BITWISE OPERATION LIBRARY
;===============================

; SUBROUTINE LOCATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; x5000 = BITWISE OR
; x5100 = BITWISE XOR
; x5200 = BITWISE NOR
; x5300 = BITWISE XNOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.ORIG x5000
;=================================================
; SUBROUTINE: BITWISE OR
;---------------------------

ST R7, bkup_r7_or

NOT R4, R2      ; not(A)
NOT R5, R3      ; not(B)
AND R6, R4, R5  ; not(A) and not(B)
NOT R4, R6      ; not(not(A) and not(B)) == OR

LD R7, bkup_r7_or
RET

;SUBROUTINE DATA
;--------------------------
bkup_r7_or .BLKW #1
;=================================================


.ORIG x5100
;=================================================
; SUBROUTINE: BITWISE XOR
;---------------------------

ST R7, bkup_r7_xor

AND R4, R2, R3  ; A and B
NOT R4, R4      ; not(A and B)
AND R5, R2, R4  ; A and not(A and B)
AND R6, R3, R4  ; B and not(A and B)
NOT R5, R5      ; not(A and not(A and B))
NOT R6, R6      ; not(B and not(A and B))
AND R4, R5, R6  ; not(A and not(A and B)) AND not(B and not(A and B))
NOT R4, R4      ; not(not(A and not(A and B)) AND not(B and not(A and B)))

LD R7, bkup_r7_xor
RET

;SUBROUTINE DATA
;--------------------------
bkup_r7_xor .BLKW #1
;=================================================


.ORIG x5200
;=================================================
; SUBROUTINE: BITWISE NOR
;---------------------------

ST R7, bkup_r7_nor

NOT R4, R2      ; not(A)
NOT R5, R3      ; not(B)
AND R6, R4, R5  ; not(A) and not(B)
NOT R4, R6      ; not(not(A) and not(B)) == OR
AND R5, R4, R4  ; not(not(A) and not(B)) and not(not(A) and not(B))
NOT R4, R5      ; not(not(not(A) and not(B)) and not(not(A) and not(B)))

LD R7, bkup_r7_nor
RET

;SUBROUTINE DATA
;--------------------------
bkup_r7_nor .BLKW #1
;=================================================


.ORIG x5300
;=================================================
; SUBROUTINE: BITWISE XNOR
;---------------------------

ST R7, bkup_r7_xnor

AND R4, R2, R3  ; A and B
NOT R4, R4      ; not(A and B)
AND R5, R2, R4  ; A and not(A and B)
AND R6, R3, R4  ; B and not(A and B)
NOT R5, R5      ; not(A and not(A and B))
NOT R6, R6      ; not(B and not(A and B))
AND R4, R5, R6  ; not(A and not(A and B)) AND not(B and not(A and B))

LD R7, bkup_r7_xnor
RET

;SUBROUTINE DATA
;--------------------------
bkup_r7_xnor .BLKW #1
;=================================================

.END
