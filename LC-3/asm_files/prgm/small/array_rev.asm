; PROGRAM: REVERSE ARRAY CONTENT
;----------------------------------------------------
; INPUT
;   R1 has pointer to storage block word @ x3200
;   R2 has 2's comp of x0A to check if user entered '\n'
;   R3 is used to actually check for '\n'
;   R4 used as a character counter
;   R5 used for checking 
; REVERSE
;   R1 has pointer to block word end
;   R2 has pointer to block word begin
;   R3 temp store
;   R4 temp store
;   R5 index crossover check
;----------------------------------------------------

; START   <<<<***************************************************************************
;----------------------------------------------------
.ORIG x3000
LEA R0, INFO	  ; LOAD & OUTPUT PROMPT
PUTS

LD R1, VPTR	  ; LOAD R1 POINTER TO BLOCK WORD

LD R2, NEWL	  ; LOAD R2 <- x0A aka '\n'
NOT R2, R2	  ; INVERT BITS
ADD R2, R2, #1	  ; 2'S COMP

AND R4, R4, #0    ; CLEAR REG, SET COUNT TO 0
AND R5, R5, #0	  ; CLEAR REG
;----------------------------------------------------

; GET USER INPUT
;----------------------------------------------------
_INPUT_LOOP
  GETC		  ; GET INPUT
  OUT		  ; ECHO INPUT

  AND R3, R3, #0  ; CLEAR REG FOR CHECK
  ADD R3, R2, R0  ; IF R3 = 0 THEN R0 = x0A aka '\n'
  BRz _THERE2	  ; BREAK OUT OF LOOP (NEWLINE)

  ADD R4, R4, #1  ; INCREMENT WORD COUNT

  LD R5, SXTN	  ; LOAD #-16
  ADD R5, R5, R4  ; ADDING CURRENT COUNT TO LIMIT
  BRz _THERE1	  ; BREAKOUT OF LOOP (MAX CHARS)

  STR R0, R1, #0  ; STORE INPUT TO BLOCK
  ADD R1, R1, #1  ; INCREMENT POINTER
BR _INPUT_LOOP    ; GOTO START OF LOOP 
;-----------------------------------------------------

_THERE1
;   
STR R0, R1, #0    ; STORE LAST INPUT TO BLOCK
LD R0, NEWL
OUT		  ; PRINT NEWLINE

_THERE2
;
LD R1, VPTR	  ; LOAD R1 POINTER TO BLOCK WORD
LD R2, VCTR	  ; LOAD R2 POINTER TO COUNTER
STR R4, R2, #0	  ; STORE #COUNT TO COUNTER
AND R2, R2, #0    ; CLEAR REG
ADD R2, R4, #0	  ; COPY CHAR COUNT
AND R4, R4, #0	  ; CLEAR REG
AND R5, R5, #0	  ; CLEAR REG
AND R3, R3, #0	  ; CLEAR REG

ADD R2, R2, #0    ; IF == 0 THEN SKIP TO END
BRz _FINAL	  ; GOTO HALT

ADD R2, R2, #-1	  ; DECREMENT COUNT BY 1 FOR ZERO INDEX BLKW
ADD R1, R1, R2	  ; POINTER TO END CHAR
LD R2, VPTR	  ; POINTER TO FRONT CHAR

; REVERSE ARRAY
;-----------------------------------------------------
_REV_LOOP
  LDR R3, R1, #0   ; TEMP1 = LAST
  LDR R4, R2, #0   ; TEMP2 = FIRST
  STR R4, R1, #0   ; LAST = TEMP2
  STR R3, R2, #0   ; FIRST = TEMP1
  ADD R1, R1, #-1  ; DECREMENT POINTER TO END
  ADD R2, R2, #1   ; INCREMENT POINTER TO BEGIN
  
  NOT R5, R2	   ; INVERT BEGIN POINT
  ADD R5, R5, #1   ; 2'S COMP
  ADD R5, R5, R1   ; CHECK END - BEGIN
BRzp _REV_LOOP     ; IF NEGATIVE BREAK LOOP
;-----------------------------------------------------

LD R1, VPTR	  ; LOAD R1 POINTER TO BLOCK WORD
LDI R2, VCTR	  ; LOAD R2 COUNTER
ADD R2, R2, #-1   ; DECREMENT BY 1 FOR ZERO INDEX

; PRINT ARRAY
;-----------------------------------------------------
_PRINT_LOOP
  LDR R0, R1, #0   ; LOAD CHAR
  OUT		   ; PRINT CHAR
  ADD R1, R1, #1   ; INCREMENT POINTER
  ADD R2, R2, #-1  ; DECREMENT COUNTER
BRzp _PRINT_LOOP
;-----------------------------------------------------

_FINAL   ; <<<<***************************************************************************
;-------------
LD R0, NEWL
OUT		  ; PRINT NEWLINE
HALT		  ; END PROGRAM
;-------------

; LOCAL DATA
;-----------------------------------------------------
SXTN .FILL #-16  ; DECIMAL -16
NEWL .FILL x0A   ; ASCII '\n'
VPTR .FILL x3200 ; POINTER TO BLOCK WORD
VCTR .FILL x3210 ; POINTER TO WORD COUNT
INFO .STRINGZ "Enter up to 16 char, end with newline\n"
;-----------------------------------------------------

; REMOTE DATA
;-----------------------------------------------------
.ORIG x3200
VECT .BLKW #16   ; STORAGE FOR CHAR @ x3200 - x320F
CNTR .BLKW #1	 ; COUNTER FOR CHAR @ x3210
;-----------------------------------------------------

.END

