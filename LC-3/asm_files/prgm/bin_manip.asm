;===========================================
; BINARY MANIPULATION OPERATION
; must be linked to lib_bitwise.asm
; RUN: simpl bin_manip.asm lib_bitwise.asm lib_io.asm
;===========================================

.ORIG x3000
;INSRTUCTIONS
;-----------------
BR begin

; BUILD LIBRARY POINT LIST && need SOME vars upfront: 9-Bit pcoffset
ptr_subr_1   .FILL x4000  ; BINARY INPUT SEQUENCE
ptr_subr_2   .FILL x4100  ; BINARY OUTPUT SEQUENCE
sub_ptr_or   .fill x5000  ; BITWISE OR
sub_ptr_xor  .fill x5100  ; BITWISE XOR
sub_ptr_nor  .fill x5200  ; BITWISE NOR
sub_ptr_xnor .fill x5300  ; BITWISE XNOR

prompt .STRINGZ "1= NOT 2= AND 3= OR 4= XOR \n5= NAND 6= NOR 7= XNOR \n" 
prompt2 .STRINGZ "Choose op: "

begin  ;<<-------------------------------------------------START_HERE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LEA R0, nl        ; \n
PUTS
LEA R0, intro
PUTS
LEA R0, nl        ; \n
PUTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;choose operation [1-7]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LEA R0, prompt
PUTS
LEA R0, prompt2
PUTS

GETC
OUT

_check_NOT
LD R6, no_1
AND R1, R1, #0    ; CLEAR R1
ADD R1, R0, #0    ; COPY R1 <-- R0
ADD R1, R1, R6    ; CHECK
BRz _not
BR _check_AND     ; next check point
_not 
and r5, r5, #0
add r5, r5, #1    ; special flag val
st r5, op_ch
BR input_variables

_check_AND
LD R6, no_2
AND R1, R1, #0    ; CLEAR R1
ADD R1, R0, #0    ; COPY R1 <-- R0
ADD R1, R1, R6    ; CHECK
BRz _and
BR _check_OR      ; next check point
_and 
and r5, r5, #0
add r5, r5, #2    ; special flag val
st r5, op_ch
BR input_variables

_check_OR
LD R6, no_3
AND R1, R1, #0    ; CLEAR R1
ADD R1, R0, #0    ; COPY R1 <-- R0
ADD R1, R1, R6    ; CHECK
BRz _or
BR _check_XOR     ; next check point
_or 
ld r5, sub_ptr_or
st r5, op_ch
BR input_variables

_check_XOR
LD R6, no_4
AND R1, R1, #0      ; CLEAR R1
ADD R1, R0, #0      ; COPY R1 <-- R0
ADD R1, R1, R6      ; CHECK
BRz _xor
BR _check_NAND      ; next check point
_xor 
ld r5, sub_ptr_xor
st r5, op_ch
BR input_variables

_check_NAND
LD R6, no_5
AND R1, R1, #0      ; CLEAR R1
ADD R1, R0, #0      ; COPY R1 <-- R0
ADD R1, R1, R6      ; CHECK
BRz _nand
BR _check_NOR       ; next check point
_nand 
and r5, r5, #0
add r5, r5, #5      ; special flag val
st r5, op_ch
BR input_variables

_check_NOR
LD R6, no_6
AND R1, R1, #0      ; CLEAR R1
ADD R1, R0, #0      ; COPY R1 <-- R0
ADD R1, R1, R6      ; CHECK
BRz _nor
BR _check_XNOR      ; next check point
_nor 
ld r5, sub_ptr_nor
st r5, op_ch
BR input_variables

_check_XNOR
LD R6, no_7
AND R1, R1, #0      ; CLEAR R1
ADD R1, R0, #0      ; COPY R1 <-- R0
ADD R1, R1, R6      ; CHECK
BRz _xnor
BR errr             ; end check point
_xnor 
ld r5, sub_ptr_xnor
st r5, op_ch
BR input_variables

errr
LEA R0, nl          ; \n
PUTS
LEA R0, error       ; err
PUTS
BR die_now
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


input_variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LEA R0, nl          ; \n
PUTS

LD R1, ptr_subr_1   ; R2 <-- INPUT (var A)
JSRR R1

LD R1, ptr_remote   ; REMOTE DATA <-- R2  (var A)
STR R2, R1, #0

; flag check for 'NOT' *****
and r1, r1, #0
ld r1, op_ch        ; copy op 
and r6, r6, #0
add r6, r6, #-1
ADD R6, R1, R6      ; CHECK NOT
BRz operations      ; no need for var B


LD R1, ptr_subr_1   ; R2 <-- INPUT (var B)
JSRR R1

LD R1, ptr_remote   ; REMOTE DATA <-- R2  (var B)
STR R2, R1, #1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


operations
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LDI R2, ptr_remote  ; reload A
ld R3, ptr_remote	 
ldr r3, r3, #1      ; reload B
and r1, r1, #0
ld r1, op_ch        ; copy op ptr

; flag check*****
and r6, r6, #0
add r6, r6, #-1
ADD R6, R1, R6      ; CHECK NOT
BRz _special_not

and r6, r6, #0
add r6, r6, #-2
ADD R6, R1, R6      ; CHECK AND
BRz _special_and

and r6, r6, #0
add r6, r6, #-5
ADD R6, R1, R6      ; CHECK NAND
BRz _special_nand

jsrr r1             ; otherwise go to routine...

_savin

LD R1, ptr_remote   ; REMOTE DATA <-- RESULT(op)
STR R4, R1, #2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;display_results
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
and r0, r0, #0
add r0, r0, #10     ; \n
out

LDI R2, ptr_remote
LD R1, ptr_subr_2   ; PRINT A
JSRR R1

; flag check for 'NOT' *****
and r1, r1, #0
ld r1, op_ch        ; copy op 
and r6, r6, #0
add r6, r6, #-1
ADD R6, R1, R6      ; CHECK NOT
BRz _rezult         ; no need for var B

LD R2, ptr_remote
ldr R2, R2, #1
LD R1, ptr_subr_2   ; PRINT B
JSRR R1

_rezult

LD R2, ptr_remote
LDR R2, R2, #2
LD R1, ptr_subr_2   ; PRINT RESULT
JSRR R1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
die_now

LEA R0, run_again
PUTS
GETC
OUT
and r6, r6, #0
ld r6, no_1
add r6, r6, r0
BRz begin

HALT

;helper for simple bitwise
;---------------------------
_special_not
not r4, r2
BR _savin
 
_special_and
and r4, r2, r3
BR _savin

_special_nand
and r4, r2, r3
not r4, r4
BR _savin

;LOCAL DATA
;-----------------
no_1	.FILL #-49  ; negative values of numeric ascii for the checks
no_2	.FILL #-50
no_3	.FILL #-51
no_4	.FILL #-52
no_5	.FILL #-53
no_6	.FILL #-54
no_7	.FILL #-55
op_ch .BLKW #1    ; operation holder

nl .STRINGZ "\n"
intro .STRINGZ "Bitwise operations on 2's comp 16-bit binary \n"
error .STRINGZ "ERROR: UNDEF INPUT\n"
run_again .STRINGZ "Again? y=1 n=0\n"

ptr_remote .FILL x3500	; DATA STORAGE
;=============================================================

;=============================================================
.ORIG x3500
;REMOTE DATA
;----------------
vals .BLKW #3
;=============================================================

.END