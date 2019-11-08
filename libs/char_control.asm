
;;;;;;;;;;;;;;
;; Print char
; ======================
printChar:
    ; xpos, ypos, alpha
    ; initial position
    lda #$00
    sta $02
    lda #$04
    sta $03 ; for each row (ypos) add 40
    ldx ypos
    dex ; we want it zero indexed
add40:
    beq xpart
    clc				; clear carry
	lda $02
	adc #$28 ; 40 dec
    sta $02
	lda $03
	adc #$00
    sta $03
    dex
    jmp add40 
xpart: ; add in the xpos
    clc				; clear carry
	lda $02
    dec xpos
	adc xpos ; fucking hack
    inc xpos
    sta $02
	lda $03
	adc #$00
    sta $03
    ; render
    ldy #$00
    lda alpha ; character code
    sta ($02),y
    rts

; ============
; xpos, ypos
; A = character
getChar:
    ; initial position
    lda #$00
    sta $02
    lda #$04
    sta $03 
; for each row (ypos) add 40
    ldx ypos
    dex ; we want it zero indexed
add40ss:
    beq xpartss
    clc				; clear carry
	lda $02
	adc #$28 ; 40 dec
    sta $02
	lda $03
	adc #$00
    sta $03
    dex
    jmp add40ss 
xpartss:
    ; add in the xpos
    clc				; clear carry
	lda $02
    dec xpos
	adc xpos ; fucking hack
    inc xpos
    sta $02
	lda $03
	adc #$00
    sta $03
    ; render
    ldy #$00
    lda ($02),y
    rts