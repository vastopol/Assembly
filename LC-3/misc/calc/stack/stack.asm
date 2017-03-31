; stack implementation
; subroutines for PUSH and POP functions
; works with a stack if memory from: (BASE) x3FFF to (MAX) x3FFB
; R0 is used for the push/pop
; R6 is the stack pointer
; R5 is a flag to indicate success/failure
; R1 and R2 are temporarily used
;------------------------------------------------------------------

;---------------------
.ORIG x3000
; MAIN GOES HERE ...
HALT
;---------------------

.ORIG x3500
_POP
ST R7, POP_SAVER7
ST R2, POP_SAVER2
ST R1, POP_SAVER1
LD R1, POP_BASE		; BASE -x3FFF
ADD R1, R1, #-1 	; COMPARE STACK POINTER TO -x4000
BRz _POP_FAIL		; BRANCH IF STACK EMPTY (ERROR)
LDR R0, R6, #0  	; ACTUAL "POP"
ADD R6, R6, #1  	; ADJUST STACK POINTER
LD R1, POP_SAVER1
LD R2, POP_SAVER2
LD R7, POP_SAVER7
AND R5, R5, #0		; SUCCESS EXIT
RET
_POP_FAIL		; (ERROR)
LD R1, POP_SAVER1
LD R2, POP_SAVER2
LD R7, POP_SAVER7
AND R5, R5, #0
ADD R5, R5, #1		; FAIL EXIT
RET
;DATA
POP_SAVER1 .BLKW #1
POP_SAVER2 .BLKW #1
POP_SAVER7 .BLKW #1
POP_BASE   .FILL xC001 ; -x3FFF
;-------------------------------------------------
.ORIG x3550
_PUSH
ST R7, PUSH_SAVER7
ST R2, PUSH_SAVER2
ST R1, PUSH_SAVER1
LD R1, PUSH_MAX		; MAX -x3FFB
ADD R2, R6, R1		; COMPARE STACK POINTER TO -x3FFB
BRz _PUSH_FAIL		; BRANCH IF STACK IS FULL (ERROR)
ADD R6, R6, #-1 	; ADJUST STACK POINTER
STR R0, R6, #0		; ACTUAL "PUSH"
LD R1, PUSH_SAVER1
LD R2, PUSH_SAVER2
LD R7, PUSH_SAVER7
AND R5, R5, #0		; SUCCESS EXIT
RET
_PUSH_FAIL		; (ERROR)
LD R1, PUSH_SAVER1
LD R2, PUSH_SAVER2
LD R7, PUSH_SAVER7
AND R5, R5, #0
ADD R5, R5, #1		; FAIL EXIT
RET
; DATA
PUSH_SAVER1 .BLKW #1
PUSH_SAVER2 .BLKW #1
PUSH_SAVER7 .BLKW #1
PUSH_MAX    .FILL xC005 ;-x3FFB
;---------------------------------------------------

.END