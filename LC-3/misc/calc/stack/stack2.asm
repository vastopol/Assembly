;=================================================
; Name: 
; Email:  
; 
; Lab: lab 9 ex 3
; Lab section: 
; TA: 
;=================================================
; stack at: xA001 to xA005
; base: xA000,
; max:  xA005

.ORIG x3000

; INIT STACK
LD R4, BASE	; BASE PTR
LD R5, MAX	; MAX VAL
LD R6, BASE	; TOS PTR

LD R1, CONVAB	; ASCII TO BIN

LEA R0, P1	; PROMPT NUM
PUTS
GETC		; GET CHAR
OUT		; ECHO
ADD R0, R0, R1  ; CONVERT TO BINARY
JSR PUSH	; PUSH NUM 1

AND R0, R0, #0
ADD R0, R0, x0A
OUT		; \n

LEA R0, P1	; PROMPT NUM
PUTS
GETC		; GET CHAR
OUT		; ECHO
ADD R0, R0, R1  ; CONVERT TO BINARY
JSR PUSH	; PUSH NUM 2

AND R0, R0, #0
ADD R0, R0, x0A
OUT		; \n

LEA R0, P2	; PROMPT OP
PUTS
GETC
OUT
JSR RPN_MUL

AND R0, R0, #0
ADD R0, R0, x0A
OUT		; \n

LEA R0, P3
PUTS
LDR R2, R6, #0

JSR PNUM	; PRINT NUMBER

AND R0, R0, #0
ADD R0, R0, x0A
OUT		; \n

HALT		; FIN

; LOCAL DATA
BASE .FILL xA000
MAX  .FILL xA005
CONVAB .FILL #-48 ; ASCII TO BIN
CONVBA .FILL x30  ; BIN TO ASCII
P1 .STRINGZ "ENTER DIGIT\n"
P2 .STRINGZ "ENTER OP\n"
P3 .STRINGZ "RESULT\n"
;-------------------------


;------------------------------------------------------------------------------------------
; Subroutine: SUB_STACK_PUSH
; Parameter (R0): The value to push onto the stack
; Parameter (R4): BASE: A pointer to the base (​one less than​ the lowest availableaddress) of the stack
; Parameter (R5): MAX: The "highest" available address in the stack
; Parameter (R6): TOS (Top of Stack): A pointer to the ​current top of the stack
; Postcondition: The subroutine has pushed (R0) onto the stack (i.e to address TOS+1).
;	If the stack was already full (TOS = MAX), the subroutine has printed an
; 	overflow error message and terminated.
; Return Value: R6 ← updated TOS
;------------------------------------------------------------------------------------------
PUSH

ST R7, PUSH_SAVER7

AND R2, R2, #0
ADD R2, R2, R5	; R2 = MAX
NOT R2, R2
ADD R2, R2, #1  ; R2 = -MAX
ADD R2, R2, R6
BRzp FULLSTACK  ; CHECK IF FULL

ADD R6, R6, #1  ; INCREMENT TOS
STR R0, R6, #0	; STORE VAL

LD R7, PUSH_SAVER7
RET

FULLSTACK
LEA R0, OFERR
PUTS
LD R7, PUSH_SAVER7
RET

; PUSH DATA
PUSH_SAVER7 .BLKW #1 ; RETURN ADDRESS
OFERR .STRINGZ "OVERFLOW ERROR: STACK FULL\n"
;------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------
; Subroutine: SUB_STACK_POP
; Parameter (R4): BASE: A pointer to the base (​one less than​ the lowest available address) of the stack
; Parameter (R5): MAX: The "highest" available address in the stack
; Parameter (R6): TOS (Top of Stack): A pointer to the ​current top of the stack
; Postcondition: The subroutine has popped MEM[top] off of the stack.
; 		 If the stack was already empty (TOS = BASE), the subroutine has printed
;		 an underflow error message and terminated.
; Return Value: R0 ← value popped off of the stack
;		R6 ← updated TOS
;------------------------------------------------------------------------------------------
POP

ST R7, POP_SAVER7

AND R2, R2, #0
ADD R2, R2, R4	; R2 = BASE
NOT R2, R2
ADD R2, R2, #1  ; R2 = -BASE
ADD R2, R2, R6
BRnz EMPTYSTACK  ; CHECK IF EMPTY

LDR R0, R6, #0   ; POP VAL TO R0
ADD R6, R6, #-1  ; DECREMENT TOS

LD R7, POP_SAVER7
RET

EMPTYSTACK
LEA R0, UFERR
PUTS
LD R7, POP_SAVER7
RET

; POP DATA
POP_SAVER7 .BLKW #1
UFERR .STRINGZ "UNDERFLOW ERROR: STACK EMPTY\n"
;------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------
; Subroutine: SUB_RPN_MULTIPLY
; Parameter (R4): BASE: A pointer to the base (​one less than​ the lowest available address) of the stack
; Parameter (R5): MAX: The "highest" available address in the stack
; Parameter (R6): TOS (Top of Stack): A pointer to the ​current top of the stack
; Postcondition: The subroutine has popped off the top two values of the stack,
; 	multiplied them together, and pushed the resulting value back onto the stack.
; Return Value: R6 ← updated top value
;------------------------------------------------------------------------------------------
RPN_MUL

ST R7, RPN_SAVER7

JSR POP
AND R1, R1, #0
ADD R1, R1, R0	; GET FIRST VAL

JSR POP
AND R2, R2, #0
ADD R2, R2, R0	; GET SECOND VAL

AND R3, R3, #0 ; EMPTY FOR RESULT

AND R1, R1, R1	; CHECK IF EITHER IS ZERO, SKIP MUL
BRz _OVERDER
AND R2, R2, R2
BRz _OVERDER

; USE R2 AS COUNTER, ADD R1 TO R3,  R2 TIMES
MUL_LOOP
  ADD R3, R3, R1
  ADD R2, R2,#-1  ; DECREMENT NUM2
BRp MUL_LOOP

_OVERDER	; SKIP MUL IF ZERO

AND R0, R0, #0
ADD R0, R0, R3	; COPY MUL RESULT TO R0

JSR PUSH

LD R7, RPN_SAVER7
RET

; SUB DATA
RPN_SAVER7 .BLKW #1
;-------------------------------------------------------------------------------------------


;========================
; EXPECT NUMBER IN R2

; R1 - TEMP
; R2 - CONVERT TO ASCII
; R3 - COUNTER
; R4 - ANTI ASCII #-48
; R5 - VAL
; R6 CHECKER REG FOR NO LEAD 0'S
;========================

PNUM

ST R2, O_D_BACKUP_R2	; SAVE R2
ST R7, O_D_BACKUP_R7	; SAVE R7

AND R5, R5, #0
ADD R5, R2, #0		; MOVE VAL TO R5

ADD R5, R5, #0		; DUMMY TO CHECK IF + || - NUMBER
BRzp _POZNUM		; IF POSITIVE GO TO PRINT NUMBER
LD R0, NEGSIN
OUT
NOT R5, R5
ADD R5, R5, #1		; TAKES 2'S COMP OF NEG #

_POZNUM

LD R4, ASCIINO
ADD R1, R5, #0		; COPY VAL IN R5 TO R0

_BEGIN10000	LD R2, ASCIIGO  ;BEGIN PRINTING
		LD R3, NEG10000
_LOOP10000	ADD R1, R1, R3
		BRn _END10000	; END LOOP
		ADD R2, R2, #1
		BR _LOOP10000	; LOOP AGAIN
_END10000	AND R6, R6,#0
		ADD R6, R2, R4	; CHECK IF 0 FOR SKIP
		BRz _SKIP10000
		ADD R0, R2, #0	; MOVE COUNT TO R0 FOR OUTPUT
		OUT
		_SKIP10000	; SKIP TO
		LD R3, POS10000
 		ADD R1, R1, R3	; RESTORE LAST SUBTRACT

_BEGIN1000	LD R2, ASCIIGO
		LD R3, NEG1000
_LOOP1000	ADD R1, R1, R3
		BRn _END1000	; END LOOP
		ADD R2, R2, #1
		BR _LOOP1000	; LOOP AGAIN
_END1000	AND R6, R6,#0
		ADD R6, R2, R4	; CHECK IF 0 FOR SKIP
		BRz _SKIP1000
		ADD R0, R2, #0	; MOVE COUNT TO R0 FOR OUTPUT
		OUT
		_SKIP1000	; SKIP TO
		LD R3, POS1000
 		ADD R1, R1, R3	; RESTORE LAST SUBTRACT

_BEGIN100	LD R2, ASCIIGO
		LD R3, NEG100
_LOOP100	ADD R1, R1, R3
		BRn _END100	; END LOOP
		ADD R2, R2, #1
		BR _LOOP100	; LOOP AGAIN
_END100		AND R6, R6,#0
		ADD R6, R2, R4	; CHECK IF 0 FOR SKIP
		BRz _SKIP100
		ADD R0, R2, #0	; MOVE COUNT TO R0 FOR OUTPUT
		OUT
		_SKIP100	; SKIP TO
		LD R3, POS100
 		ADD R1, R1, R3	; RESTORE LAST SUBTRACT

_BEGIN10	LD R2, ASCIIGO
		LD R3, NEG10
_LOOP10 	ADD R1, R1, R3
		BRn _END10	; END LOOP
		ADD R2, R2, #1
		BR _LOOP10	; LOOP AGAIN
_END10  	AND R6, R6,#0
		ADD R6, R2, R4	; CHECK IF 0 FOR SKIP
		BRz _SKIP10
		ADD R0, R2, #0	; MOVE COUNT TO R0 FOR OUTPUT
		OUT
		_SKIP10		; SKIP TO
		LD R3, POS10
		ADD R1, R1, R3	; RESTORE LAST SUBTRACT

		LD R2, ASCIIGO  ; LAST OUTPUT
		ADD R0, R1, R2
		OUT

		AND R0, R0, #0
		ADD R0, R0, x0A ; \n
		OUT

LD R2, O_D_BACKUP_R2	; RELOAD R2
LD R7, O_D_BACKUP_R7	; RELOAD R7
RET

;ROUTINE DATA
;-----------------------
O_D_BACKUP_R7 .BLKW #1
O_D_BACKUP_R2 .BLKW #1
NEGSIN .STRINGZ "-"

ASCIINO  .FILL #-48
ASCIIGO  .FILL x30
NEG10000 .FILL xD8F0
NEG1000  .FILL xFC18
NEG100   .FILL xFF9C
NEG10    .FILL xFFF6
POS10000 .FILL #10000
POS1000  .FILL #1000
POS100	 .FILL #100
POS10	 .FILL #10
;===================================================


.END