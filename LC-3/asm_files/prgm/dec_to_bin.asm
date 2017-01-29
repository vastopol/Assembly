;========================================
; I/O conversion of base systems
;========================================

.ORIG x3000		; Program begins here
;-------------
;Instructions
;-------------

;INPUT
LD R1, ptr_subr_1
JSRR R1

;PRINT
LD R1, ptr_subr_2	
JSRR R1

HALT

; R1 = SUBROUTINE POINTER
; R2 = USER VALUE

ptr_subr_1 .FILL x5000	; INPUT::DEC
ptr_subr_2 .FILL x5500	; PRINT::BIN
;================================================


;REMOTE DATA
;--------------
.ORIG x4000
;---------------
intro .STRINGZ	"Input a positive or negative decimal number (max 5 digits), followed by ENTER\n"
;---------------
.ORIG x4100	
error_mes .STRINGZ	"ERROR INVALID INPUT\n"
;================================================


.ORIG x5000
;SUBROUTINE #1 :: SIGNED 5 DIGIT DECIMAL INPUT
;---------------------------------------------
;r1 pointer
;r2 convert ascii
;r3  
;r4 look for \n
;r5 ANSWER
;r6 counter 5

;--------------------------------
ST R7, backup_R7        ; SAVE RETURN ADDRESS

BRnzp go

BAD_LOOP                ; ERROR CHECKING
  and r0, r0, #0
  add r0, r0, #10       ;\n
  out

  LD R0, errorMessage  ;Output Error Message
  PUTS

  and r0, r0, #0        ;flag reset
  ST R0, flag


go			; <--------  ******************  START HERE  **********************

LD R0, introMessage  	;Output Intro Message
PUTS

AND R5, R5, #0        ; clear R5

LD R6, counter5       ; COUNTER GET 5 NUMS
LD R2, conv           ; ASCII CONVERT

;get input first num || sign
GETC
OUT

;if \n: BR BAD_LOOP
and r4, r4, #0
ADD R4, R4, #-10
ADD R4, R4, R0        ; BREAK ON \n
BRz BAD_LOOP


;if +: BR LOOP_1_START
and r4, r4, #0
LD R4, plus
ADD R4, R4, R0
BRz LOOP_1_START

;if -: then store fact and 2's comp later && BR LOOP_1_START
and r4, r4, #0
LD R4, minus
ADD R4, R4, R0
BRz makro

;if was number: BR special_goto
and r4, r4, #0
LD R4, conv
ADD R4, R4, R0        ; check nan < 0
BRn BAD_LOOP

and r4, r4, #0
LD R4, NANmore9
ADD R4, R4, R0        ; check nan > 9
BRp BAD_LOOP


BRnzp special_goto

makro
  and r0, r0, #0
  add r0, r0, #1
  ST R0, flag         ; set negative sign flag for later


;//////////////////////
; main input sequence
;//////////////////////

LOOP_1_START
  GETC                ; GET INPUTs
  OUT

  and r4, r4, #0
  ADD R4, R4, #-10
  ADD R4, R4, R0      ; BREAK ON \n
  BRz LOOP_1_END

  and r4, r4, #0
  LD R4, conv
  ADD R4, R4, R0      ; check nan < 0
  BRn BAD_LOOP

  and r4, r4, #0
  LD R4, NANmore9
  ADD R4, R4, R0      ; check nan > 9
  BRp BAD_LOOP
  

  special_goto        ;MULTIPLY CURRENT BY 10, THEN ADD USER INPUT

      ADD R0, R0, R2	; CONVERT R0 TO decimal val

      and r4, r4, #0
      LD R4, counter10

      AND R3, R3, #0

      LOOP_SUB
	ADD R3, R3, R5    ; OLD *10

	ADD R4, R4, #-1   ; DECREMENT
      BRzp LOOP_SUB

      ; ADD INPUT + OLD
      ; COPY RESULT TO R5

      and r5, r5, #0
      add r5, r3, r0

ADD R6, R6, #-1     ; DECREMENT OUTER LOOP
BRp LOOP_1_START

and r0, r0, #0
add r0, r0, #10     ;\n   extra?
out

LOOP_1_END

;check if r5 is empty --> e.g. Sign only and no nums after
; BR BAD_LOOP

add r0, r0, #0
ADD R5, R5, #0		;DUMMY INSTRUCTION
BRz BAD_LOOP

;if flag == 1 take 2's comp
and r4, r4, #0
ld r4, flag
add r4, r4, #-1
BRz bit_shifter

bop

AND R2, R2, #0		; NOW R5 HAS VAL, COPY TO R2
ADD R2, R5, #0		; print routines use R2


LD R7, backup_R7	
RET               ; RETURN FROM SUBROUTINE


bit_shifter       ;HELPER
  not r5, r5
  add r5, r5, #1
  BRnzp bop

;---------------	
; SUBROUTINE DATA
;---------------
introMessage .FILL x4000
errorMessage .FILL x4100

counter5 .FILL #5
conv .FILL #-48
NANmore9 .FILL #-57

minus .fill #-45
plus .fill #-43

counter10 .FILL #9  ;10 TIMES for mul * 10 part

flag .BLKW #1       ; FLAG FOR NEGATIVE SIGN

backup_R7 .BLKW #1
;=====================================================

.ORIG x5500
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
ld R4, num_4        ;WORD SPACING_INDEX RESET IN l3

and r3, r3, #0
ld R3, num_4        ; number of spaces = 3

LOOP_START
  ADD R2, R2, #0    ; DUMMY INSTRUCTION TO REPRESENT R2
  BRzp poz
  BRn  neg

  neg
    LD R0, num_01   ;OUT '1'
    OUT
    BR gggg

  poz
    LD R0, num_00   ;OUT '0'
    OUT

  gggg
    
    ADD R4, R4, #-1	; SPACE HANDLE
    BRz helper
    return_zone

    ADD R2, R2, R2	; LEFT SHIFT BITS

    ADD R5, R5, #-1	; DECREMENT INNER LOOP
  BRp LOOP_START

AND R0, R0, #0      ;\n
ADD R0, R0, #10
OUT

LD R7, backup2_R7	
RET                 ; RETURN FROM SUBROUTINE

  ; HELPER_CODE
  ;--------------------------------------------
  helper
      ADD R3, R3, #-1	;NUM SPACE HANDLER
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

num_xx .FILL #16  ;INDEX BITS
num_4  .FILL #4   ;INDEX SPACES

backup2_R7 .BLKW #1
;=============================================================

;---------------
;END of PROGRAM
;---------------
.END
