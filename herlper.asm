;!source "math.asm"

!macro paintChar xpos, ypos {
;final = $1000
    ; initial position
    lda #$00
    sta $02
    lda #$04
    sta $03 
; for each row (ypos) add 40
    ldx ypos
add40:
    beq xpart
    clc				; clear carry
	lda $02
	adc #$28 ; 40 dec
    ;tay
    sta $02
	lda $03
	adc #$00
    sta $03
    dex
    jmp add40 
xpart:
    ; add in the xpos
    clc				; clear carry
	lda $02
	adc xpos
    ;tay
    sta $02
	lda $03
	adc #$00
    sta $03
    ; render
    ldy #$00
    lda #$03 ; A
    sta ($02),y
}

!macro getChar xpos, ypos {
;final = $1000
    ; initial position
    lda #$00
    sta $02
    lda #$04
    sta $03
; for each row (ypos) add 40
    ldx ypos
add40s:
    beq xparts
    clc				; clear carry
	lda $02
	adc #$28 ; 40 dec
    ;tay
    sta $02
	lda $03
	adc #$00
    sta $03
    dex
    jmp add40s
xparts:
    ; add in the xpos
    clc				; clear carry
	lda $02
	adc xpos
    ;tay
    sta $02
	lda $03
	adc #$00
    sta $03
    ; render
    ldy #$00
    ;lda #$03 ; A
    lda ($02),y
}
