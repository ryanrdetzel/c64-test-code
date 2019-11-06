
; testing
xpos = $1004
ypos = $1005
    lda #39
    sta xpos
    lda #10
    sta ypos
    +paintChar xpos,ypos
    ; A has the char
    +getChar xpos,ypos
    sta $770 ;1904
    ;+MultiplyTwo xpos, ypos
    ;lda #$01      ; Put the value 0 in accumulator
    ;sta $d020 
lpf
    jmp lpf





;; TESATING

; http://www.retrogamescollector.com/the-bear-essentials-developing-a-commodore-64-game-part-2/
update_debug_text:
    sta $79A
    txa
    adc #$30 ; ascii start
    sta $798
    tya
    adc #$30 ; ascii start
    sta $799
    rts

    ; test block for character
    ; for each y we add 40
    ; for each x we add 24
    ; 1024 + x + 40 * (24 - y)

    ; draw debug char