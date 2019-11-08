
; -------------------------
; printChar: Prints a character on the screen
; args: xpos, ypos, alpha
; returns: nothing
; -------------------------
printChar:
    jsr getChar
    lda alpha ; character code we want to write
    sta ($02),y

; -------------------------
; getChar: returns the character at a certain location
; args: xpos, ypos
; returns: character in A reg
; -------------------------
getChar:
    lda #$00
    sta $02
    lda #$04
    sta $03 
    ldx ypos
    dex ; we want it zero indexed but row/col are passed in 1 indexed
-:
    beq +
    clc				; clear carry
	lda $02
	adc #$28 ; 40 dec
    sta $02
	lda $03
	adc #$00
    sta $03
    dex
    jmp -
+:
    ; add in the xpos
    clc				; clear carry
	lda $02
    dec xpos
	adc xpos ; hack since we're sharing the memory space
    inc xpos
    sta $02
	lda $03
	adc #$00
    sta $03
    ldy #$00
    lda ($02),y
    rts