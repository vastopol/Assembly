; LC-3 MATH LIBRARY
; 16-BIT 2'S COMPLIMENT INTEGERS
;===============================
 
; SUBROUTINE LOCATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; x6000 = SUBTRACT
; x6100 = MULTIPLY
; x6200 = DIVIDE
; x6300 = MODULO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.ORIG x6000
;==================================
; SUBROUTINE: SUBTRACT
;----------------------------

ST R7, bkup_sub_r7

AND R4, R4, #0

NOT R3, R3        ; R3 = n before, after = -(n+1)
ADD R3, R3, #1    ; finish 2's comp, R3 = -n
ADD R4, R2, R3    ; R4 = (R2 + R3)

LD R7, bkup_sub_r7
RET

; SUBROUTINE DATA
;----------------------------
bkup_sub_r7 .BLKW #1
;==================================


.ORIG x6100
;==================================
; SUBROUTINE: MULTIPLY
;----------------------------

ST R7, bkup_mul_r7

AND R4, R4, #0
AND R5, R5, #0
ADD R5, R3, #0    ; index
BRp LOOP_MUL
BRz _end_mul

st r3, flag_mul_neg
NOT R5, R5        ; R3 = -n
ADD R5, R5, #1    ; R3 = n

LOOP_MUL
  ADD R4, R4, R2
  ADD R5, R5, #-1
BRp LOOP_MUL

LD R5, flag_mul_neg
BRzp _end_mul

NOT R4, R4        ; R4 = -n
ADD R4, R4, #1    ; R4 = n

_end_mul

LD R7, bkup_mul_r7
RET

; SUBROUTINE DATA
;----------------------------
bkup_mul_r7 .BLKW #1
flag_mul_neg .BLKW #1
;==================================


.ORIG x6200
;==================================
; SUBROUTINE: DIVIDE
;----------------------------

ST R7, bkup_div_r7
ST R3, bkup_div_r3

AND R4, R4, #0
AND R5, R5, #0
ADD R5, R3, #0    ; val chk
BRp _begin_div
BRz _error_div

st r3, flag_div_neg
not r3, r3
add r3, r3, #1    ; catch and flag negs for later

_begin_div
AND R6, R6, #0    ; place for R3
ADD R6, R3, #0
NOT R6, R6        ; R6 = -n
ADD R6, R6, #1    ; R6 = n

AND R5, R5, #0
ADD R5, R5, R2    ; fill answer holder before div

LOOP_DIV
  ADD R4, R4, #1
  ADD R5, R5, R6
BRp LOOP_DIV
BRz _clr_div      ; clean division

add r4, r4, #-1   ; remainder left over, count--

_clr_div

and r5, r5, #0
LD R5, flag_div_neg
BRzp _end_div

NOT R4, R4        ; R4 = -n
ADD R4, R4, #1    ; R4 = n

_end_div

LD R3, bkup_div_r3
LD R7, bkup_div_r7
RET

_error_div
LEA R0, err_div_by_0
PUTS
BR _end_div

; SUBROUTINE DATA
;----------------------------
bkup_div_r7 .BLKW #1
bkup_div_r3 .BLKW #1
flag_div_neg .BLKW #1
err_div_by_0 .STRINGZ "ERROR: DIVIDE BY 0"
;==================================


.ORIG x6300
;==================================
; SUBROUTINE: MODULO
;----------------------------

ST R7, bkup_mod_r7
ST R3, bkup_mod_r3

AND R4, R4, #0
AND R5, R5, #0
ADD R5, R3, #0    ; val chk
BRp _begin_mod
BRz _error_mod

; fix negs for mod
not r3, r3
add r3, r3, #1

_begin_mod
AND R6, R6, #0    ; place for R3
ADD R6, R3, #0
NOT R6, R6        ; R6 = -n
ADD R6, R6, #1    ; R6 = n

AND R5, R5, #0
ADD R5, R5, R2    ; fill answer holder before mod

LOOP_MOD
  and r4, r4, #0
  ADD R4, R5, #0
  ADD R5, R5, R6
BRp LOOP_MOD
BRn _end_mod      ; r4 has remainder

AND r4, r4, #0    ; clean mod, remainder == 0

_end_mod

LD R3, bkup_mod_r3
LD R7, bkup_mod_r7
RET

_error_mod
LEA R0, err_mod_by_0
PUTS
BR _end_mod

; SUBROUTINE DATA
;----------------------------
bkup_mod_r7 .BLKW #1
bkup_mod_r3 .BLKW #1
err_mod_by_0 .STRINGZ "ERROR: MOD BY 0"
;==================================


.END