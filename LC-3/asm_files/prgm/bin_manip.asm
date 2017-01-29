;===========================================
; BINARY MANIPULATION OPERATION
; must be linked to lib_bitwise.asm
; RUN: simpl bin_manip.asm lib_bitwise.asm
;===========================================

.ORIG x3000
;INSRTUCTIONS
;-----------------
BR begin

; BUILD LIBRARY POINT LIST && need vars upfront: 9-Bit pcoffset
sub_ptr_or .fill x5100    ; BITWISE OR
sub_ptr_xor .fill x5200   ; BITWISE XOR
sub_ptr_nor .fill x5300   ; BITWISE NOR
sub_ptr_xnor .fill x5400  ; BITWISE XNOR

no_1	.FILL #-49  ; numerics ascii for the checks
no_2	.FILL #-50
no_3	.FILL #-51
no_4	.FILL #-52
no_5	.FILL #-53
no_6	.FILL #-54
no_7	.FILL #-55
op_ch .BLKW #1    ; operation holder
nl .STRINGZ "\n"
intro .STRINGZ "Bitwise operations on 2's comp 16-bit binary \n"

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
LEA R0, prompt3
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
prompt .STRINGZ "1= NOT 2= AND 3= OR 4= XOR \n" 
prompt2 .STRINGZ "5= NAND 6= NOR 7= XNOR \n"
prompt3 .STRINGZ "Choose op: "
error .STRINGZ "ERROR: UNDEF INPUT\n"
run_again .STRINGZ "Again? y=1 n=0\n"

ptr_remote .FILL x3500	; DATA STORAGE
ptr_subr_1 .FILL x4000	; INPUT SEQUENCE
ptr_subr_2 .FILL x4500	; OUTPUT SEQUENCE
;=============================================================

.ORIG x3500
;REMOTE DATA
;----------------
vals .BLKW #3

;x4000 :: A
;x4001 :: B
;x4002 :: RESULT
;=============================================================

.ORIG x4000
;SUBROUTINE #1 : INPUT_SEQUENCE_BIN, end on \n
;---------------------------------------------
; MOD: R1, R2, R6
; R1: INPUT CHECK
; R2: FINAL USER VALUE
; R6: CHECK AGAINST VALUE
; R4: conversion factor
; R5: looping index

ST R7, backup_R7      ; SAVE RETURN ADDRESS

LEA R0, msg           ; DISPLAY MESSAGE
PUTS

and r2, r2, #0        ; init binary sum = 0

and r5, r5, #0
ld r5, indx           ; LOOP index
ld r4, nt_0

INPUT_LOOP            ; ONLY ACCEPT { '0', '1', ' '}
  GETC
  OUT                 ; CAPTURE AND ECHO INPUT

  ;check SPACE 
  LD R6, nt_spc
  AND R1, R1, #0      ; CLEAR R1
  ADD R1, R0, #0      ; COPY R1 <-- R0
  ADD R1, R1, R6      ; CHECK
  BRz INPUT_LOOP      ; GO START AGAIN

  ;check 0
  LD R6, nt_0
  AND R1, R1, #0      ; CLEAR R1
  ADD R1, R0, #0      ; COPY R1 <-- R0
  ADD R1, R1, R6      ; CHECK
  BRz GOOD_INPUT_VAL

  ;check 1
  LD R6, nt_1
  AND R1, R1, #0      ; CLEAR R1
  ADD R1, R0, #0      ; COPY R1 <-- R0
  ADD R1, R1, R6      ; CHECK
  BRz GOOD_INPUT_VAL

  ;check \n
  LD R6, convert_nl
  AND R1, R1, #0      ; CLEAR R1
  ADD R1, R0, #0      ; COPY R1 <-- R0
  ADD R1, R1, R6      ; CHECK
  BRz END_INPUT_LOOP  ; END ON newline
   
    LEA R0, err       ; INPUT ERROR
    PUTS
    BR INPUT_LOOP     ; GO START AGAIN
  
  GOOD_INPUT_VAL

  ADD R2, R2, R2      ; LEFT SHIFT R2
  add r0, r0, r4      ; convert from ascii to numeric value of digit
  ADD R2, R2, R0      ; ADD NEW VAL TO EXISTING VAL

  add r5, r5, #-1
  BRz END_INPUT_LOOP  ; max input of 16 bit

BR INPUT_LOOP
END_INPUT_LOOP        ; R2 CONTAINS USER INPUT

AND R0, R0, #0
ADD R0, R0, #10       ; OUTPUT \n
OUT

AND R6, R6, #0        ; REG CLEAN 
and r4, r4, #0        ; REG CLEAN 
and r5, r5, #0        ; REG CLEAN 

LD R7, backup_R7
RET                   ;RETURN FROM SUBROUTINE

;LOCAL DATA :: SUBROUTINE #1
;-------------------
msg .STRINGZ "ENTER MAX 16-BITS, STOPS ON newline\n"
err .STRINGZ "\n ERROR: NOT '0' , '1' , OR 'space' \n "

convert_nl .FILL #-10
nt_spc	.FILL #-32
nt_0	.FILL #-48
nt_1	.FILL #-49

indx .fill #16

backup_R7 .BLKW #1
;=============================================================

.ORIG x4500
;SUBROUTINE #2: PRINT_SEQUENCE_BIN
;----------------------------------
; MOD: R2, R3, R4, R5
; R2: USER INPUT
; R3: # OF SPACES COUNTER
; R4: SPACING INDEX
; R5: LOOP INDEX

ST R7, backup2_R7   ; SAVE RETURN ADDRESS

LD R5, num_xx       ; INDEX LOOP LOAD

and r4, r4, #0
ld R4, num_4        ; WORD SPACING_INDEX RESET IN l3

and r3, r3, #0
ld R3, num_4        ; number of spaces = 3

LOOP_START
  ADD R2, R2, #0    ; DUMMY INSTRUCTION TO REPRESENT R2
  BRzp poz
  BRn  neg

  neg
    LD R0, num_01   ; OUT '1'
    OUT
    BR gggg

  poz
    LD R0, num_00	  ; OUT '0'
    OUT

  gggg
    
    ADD R4, R4, #-1 ; SPACE HANDLE
    BRz helper
    return_zone

    ADD R2, R2, R2  ; LEFT SHIFT BITS

    ADD R5, R5, #-1 ; DECREMENT INNER LOOP
  BRp LOOP_START

AND R0, R0, #0      ;\n
ADD R0, R0, #10
OUT

AND R6, R6, #0      ; REG CLEAN 

LD R7, backup2_R7	
RET                 ; RETURN FROM SUBROUTINE

  
  ; HELPER_CODE
  ;--------------------------------------------
  helper
      ADD R3, R3, #-1 ;NUM SPACE HANDLER
      BRz return_zone
    LD R0, space
    OUT
    ADD R4, R4, #4    ;WORD SPACING_INDEX RESET IN l3
  BR return_zone
  

;LOCAL DATA :: SUBROUTINE #2
;-------------------
num_00 .FILL #48    ; 0
num_01 .FILL #49    ; 1
space  .STRINGZ " " ; ' '

num_xx .FILL #16    ;INDEX BITS
num_4  .FILL #4     ;INDEX SPACES

backup2_R7 .BLKW #1
;=============================================================

.END