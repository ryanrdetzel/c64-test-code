;!source "herlper.asm"

xpos = $1004
ypos = $1005
count = $1006

alpha = $1007
old_alpha = $1009
mode = $1008

first = $0400

*=$0801
    !byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$34,$00,$00,$00,$00
*=$0810
;     jsr clearscreen
;     lda #01
;     sta alpha
;main:
;     ldx #2
;     ldy #2
;     stx xpos
;     sty ypos
;     ;+paintChar xpos,ypos, alpha
;     jsr printChar
;     ;+getChar xpos, ypos
;    jmp main

    ; mode
    lda #$0
    sta mode

    ; load char
    lda #01
    sta alpha

    lda #$1
    sta count

    ldx #40
    ldy #25
    stx xpos
    sty ypos

    jsr clearscreen
    jsr irq_init 
lpf
    jmp lpf

irq_handler
    dec $d019                       ; ack interrupt
    dec count
    bne keepgoing
    lda #$1
    sta count

    lda mode
    beq draw
    ; verify
    jsr verify
    jmp keepgoing
draw
    jsr redraw
keepgoing
    jmp $ea31               ; jump back to the system IRQ handler

verify:
    ;;;;+getChar xpos, ypos
    jsr getChar
    cmp alpha
    beq good  ; chars match
    ldx alpha ; save alpha char
    stx old_alpha
    lda #$23
    sta alpha
    jsr printChar
    lda old_alpha
    sta alpha ; end save char
    jmp next
    ;lda #$02 ; change border color if it's wrong
    ;sta $d020
good:
    ldx alpha ; save alpha char
    stx old_alpha
    lda #$20
    sta alpha
    jsr printChar
    lda old_alpha
    sta alpha ; end save char
next:
    inc alpha
    lda alpha
    sbc #26
    bne con2
    lda #$1
    sta alpha
con2:
    dec xpos
    bne verify_return
    ldx #40
    stx xpos
    dec ypos
    bne verify_return
    ; done
    lda #$06 ; Done set border
    sta $d020
    ldy #25
    sty ypos
    lda #$1
    sta alpha
    lda #$00
    sta mode ; start over
verify_return
    rts

redraw:
    jsr printChar

    inc alpha
    lda alpha
    sbc #26
    bne con
    lda #$1
    sta alpha
con:
    dec xpos
    bne return
    ldx #40
    stx xpos
    dec ypos
    bne return
    ; done drawing
    ;jsr clearscreen
    ; reset positions
    ldy #25
    sty ypos
    ldx #40
    stx xpos
    lda #$1
    sta alpha
    ; change mode
    lda #$01
    sta mode
    lda #$01 ; change border color if it's wrong
    sta $d020

    ;; fuck it up to verify it's working
    lda #$00 ; not the right character
    sta $0510
    sta $07e7
return:
    rts

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

!source "screen.asm"
!source "irq.asm"




;; TESATING

; http://www.retrogamescollector.com/the-bear-essentials-developing-a-commodore-64-game-part-2/
; update_debug_text:
;     sta $79A
;     txa
;     adc #$30 ; ascii start
;     sta $798
;     tya
;     adc #$30 ; ascii start
;     sta $799
;     rts

    ; test block for character
    ; for each y we add 40
    ; for each x we add 24
    ; 1024 + x + 40 * (24 - y)

    ; draw debug char