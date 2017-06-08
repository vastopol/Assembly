PAGE    80, 130
TITLE   CRC.ASM         Routines to calculate the CCCIT 16-bit CRC

.MODEL  small

GENPOLY EQU     1021h
main    EQU     < start >

.DATA?

EVEN
table   DW      256 DUP(?)      ; Private table for CRC precalculation

.CODE

;''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;       Procedure:      gencrctbl
;       Purpose:        Public function to build a table for CRC lookup.
;       Parameters:     none
;       Uses:           none
;............................................................................

ALIGN 4
PUBLIC  gencrctbl
gencrctbl       PROC    NEAR            ; void gencrctbl(void)

        push    ax
        push    bx
        push    cx
        push    dx
        push    di
        push    si

        mov     di, OFFSET table
        xor     dl, dl                  ; set counter to zero
        mov     si, GENPOLY             ; put divisor polynomial in a register
        xor     ch, ch

onebyte:

        xor     ax, ax                  ; initialize accumulator to zero
        mov     bl, dl                  ; pass counter as the 'data' argument
        mov     cl, 4

oddbit:

        mov     bh, ah
        shl     ax, 1
        xor     bh, bl
        jns     skipover
        xor     ax, si

skipover:

        shl     bl, 1

evenbit:

        mov     bh, ah
        shl     ax, 1
        xor     bh, bl
        jns     skiptwo
        xor     ax, si

skiptwo:

        shl     bl, 1
        loop    oddbit

        stosw                           ; save accumulator in table
        add     dl, 1                   ; counter++
        jnc     onebyte                 ; while( counter < 256 )

        pop     si
        pop     di
        pop     dx
        pop     cx
        pop     bx
        pop     ax

        ret

gencrctbl       ENDP

;''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
;       Procedure:      crcstring
;       Purpose:        Public function to compute a CRC on a string
;       Parameters:     AX-accm         returned
;                       CX-strlen       zeroed
;                       SI-strptr       altered
;............................................................................

ALIGN 4
PUBLIC  crcstring
crcstring       PROC    NEAR

        jcxz    nowork                  ; If CX is zero, then nothing to do

        push    bx
        push    di

        mov     di, OFFSET table        ; load constant in a register
        mov     bl, ah                  ; put high accm in BL
        mov     ah, al                  ; put low accm in AH

        inc     cx
        shr     cx, 1                   ; divide work by two
        jnc     oddbyte                 ; if original CX is odd, start on odd

ALIGN 4                                 ; frequently jumped-to location
evenbyte:

        lodsb                           ; datum to AL
        xor     bl, al                  ; base address = DATA xor OLDACCMHIGH
        xor     bh, bh                  ; make BX into an index using BL
        shl     bx, 1                   ; index to a word sized offset
        mov     bx, [bx+di]             ; lookup combine_value
        xchg    ah, bl                  ; put CVLOW into AH and OLDACCMLOW in BL
        xor     bl, bh                  ; NEWACCMHIGH = OLDACCMLOW xor CVHIGH

oddbyte:

        lodsb                           ; datum to AL
        xor     bl, al                  ; base address = DATA xor OLDACCMHIGH
        xor     bh, bh                  ; make BX into an index using BL
        shl     bx, 1                   ; index to a word sized offset
        mov     bx, [bx+di]             ; lookup combine_value
        xchg    ah, bl                  ; put CVLOW into AH and OLDACCMLOW in BL
        xor     bl, bh                  ; NEWACCMHIGH = OLDACCMLOW xor CVHIGH
        loop    evenbyte

        mov     al, ah                  ; Re-assemble accm for return in AX
        mov     ah, bl

        pop     di
        pop     bx

nowork:

        ret

crcstring       ENDP

; -------------------- TEST ROUTINES --------------------------------------

IFDEF   TESTGEN

.STACK  100h

.CODE

testgen         PROC    NEAR

        mov     ax, @DATA
        mov     ds, ax
        mov     es, ax
        call    gencrctbl
        mov     ax, 4C00h
        int     21h

testgen         ENDP

main    EQU     < testgen >

ENDIF


.STACK  100h

.CODE

testlookup        PROC    NEAR

        mov     ax, @DATA
        mov     ds, ax
        mov     es, ax
        call    gencrctbl
        mov     si, OFFSET teststr
        mov     cx, testlen
        xor     ax, ax
        call    crcstring

        mov     bx, ax
        mov     ax, 4C00h
        int     21h

        ret
testlookup        ENDP

.DATA

teststr DB      'CfyU'
;        DB      '12345'
;        DB      0B7h, 0BAh
testlen DW      ( $ - teststr )

        END     testlookup
