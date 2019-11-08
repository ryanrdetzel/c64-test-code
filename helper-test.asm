!source "herlper.asm"

xpos = $1004
ypos = $1005
count = $1006

alpha = $1007
mode = $1008

first = $0400

*=$0801
    !byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$34,$00,$00,$00,$00
*=$0810
;     jsr clearscreen
;     lda #01
;     sta alpha
; main:
;     ldx #1
;     ldy #1
;     stx xpos
;     sty ypos
;     +paintChar xpos,ypos, alpha
;     +getChar xpos, ypos
;     jmp main

    jsr clearscreen
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
    +getChar xpos, ypos
    cmp alpha
    beq next  ; chars match
    lda #$02 ; change border color if it's wrong
    sta $d020
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
    lda #$03 ; Done set border
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
    +paintChar xpos,ypos,alpha

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
    lda #$1
    sta alpha
    ; change mode
    lda #$01
    sta mode
    lda #$01 ; change border color if it's wrong
    sta $d020
return:
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