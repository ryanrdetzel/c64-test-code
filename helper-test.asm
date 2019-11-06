
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