!source "sprite-data.asm"
!source "../libs/char_control.asm"
!source "../libs/screen.asm"
!source "../libs/irq.asm"

xpos = $1004
ypos = $1005
floor = $1006
fallstate = $1007
floorchar = $1008

alpha = $1009

*=$0801
    !byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$34,$00,$00,$00,$00
    ;jmp $0810
*=$0810
    jsr clearscreen
    jsr setupbackground
    jsr initSprites

    lda #$2b
    sta floorchar

    sta fallstate ; 0 falling, 1 not
    
    lda #249
    sta $d000    ; set x coordinate to 40
    ; test setting the high bit for the sprite
    ;lda #$01
    ;sta $D010

    lda #50; + (24 * 6) + 8
    sta $d001    ; set y coordinate to 40

    jsr load_floor

    jsr irq_init ; setup last
loop:
    jmp loop


initSprites:
    lda #$01    ; only one sprite
    sta $d015    ; Turn sprite 0 on

    ; multicolor mode
    lda #$01
    sta $D01C

    lda #$04
    sta $d027   ; sprite 0 color
    lda #$03
    sta $d025   ; shared color 1
    lda #$09
    sta $d026   ; shared color 2

    lda #$80
    sta $07f8    ; set pointer: sprite data at $2000  ; end 07ff
    rts

load_floor:
    lda floorchar
    ; basic floor
    sta $770 ;1904
    sta $771
    sta $772
    ;sta $773
    ;sta $774
    ;sta $775
    ; sta $776
    ; sta $777
    ; sta $778
    ; sta $779
    ; sta $77A
    ; sta $77B
    ; sta $77C
    ; sta $77D
    ; sta $77E
    ; sta $77F
    ; sta $780
    ; sta $781
    ; sta $782
    ; sta $783
    ; sta $784
    ; sta $785
    ; sta $786
    ; sta $787
    ; sta $788

    sta $764
     sta $78c ; 248
     ;sta $78d ; 256
     ;sta $78e 
     ;sta $78f

    ; lda #$03
    ; sta $791
    ; sta $792
    ; sta $793
    ; sta $794
    ; sta $795
    rts


; -------------------------------
; This method is executed every time a hardware interrupt is generated
; -------------------------------
irq_handler
    dec $d019                       ; ack interrupt
    jsr update_sprite_location
    ;jsr update_debug_text
    jmp $ea31               ; jump back to the system IRQ handler

; -------------------------------
; Gets the x,y pos of the sprite to see if it's hitting anything.
; -------------------------------
update_sprite_location:
    lda fallstate
    bne skip
    inc $d001
skip:
    lda #8
    sta $09  ; used for the condition.
    lda #12
    sta $0a
    
    lda $d001 ; ypos
    
    sbc #16     ; 24 down because of border
    ldy #$00  ; counter for ypos
suby:
    ; a less than 8, branch
    cmp $0a
    bcc dd
    sbc #$8    ; subtract 8 until we go negative (division)
    iny
    jmp suby
dd:
    ; figure out the xpos
    ldx #$00 ; x counter to zero
    lda $d000
    cmp $09 ; used for if the high bit is set and this is less than 8
    bcc db
    ;sbc #24 ; border instead of this subtract 3 cols at the end
subx:
    inx
    sbc #$8    ; subtract 8 until we go negative (division)
    cmp $09
    bcc db
    ;BMI db
    ;beq dd
    
    jmp subx
db:
    ; if the ninth bit is set also add n columes
    lda $D010
    and #$01 ; b00000001
    beq nohighbit
    txa
    adc #32 ; add 29 columns onto x
    tax
nohighbit:
    txa 
    sbc #1 ; count for the border on the left.
    tax
    sty ypos
    stx xpos
    ;ldx #$02
    ;stx floor
    ;+paintChar xpos, ypos
    jsr getChar
    ; compare with flooor
    sta $79A ; show the char in A on screen
    cmp floorchar
    beq stop
    lda #$00
    sta fallstate
    rts
stop:
    lda #$01
    sta fallstate
    rts