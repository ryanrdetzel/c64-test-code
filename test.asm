!source "sprite-data.asm"
!source "math.asm"
!source "herlper.asm"

fallstate = $1007
*=$0801
    !byte $0c,$08,$0a,$00,$9e,$32,$30,$36,$34,$00,$00,$00,$00
    ;jmp $0810
*=$0810
    jsr clearscreen
    jsr irq_init
    lda #$01      ; Put the value 0 in accumulator
    sta $d020     ; Put value of acc in $d020
    lda #$00
    sta $d021     ; Put value of acc in $d021

    sta fallstate ; 0 falling, 1 not
    ;!source "test2.asm" ;loadInitial
    lda #$01
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

    lda #0
    sta $d000    ; set x coordinate to 40
    ; test setting the high bit for the sprite
    lda #$01
    sta $D010

    lda #50; + (24 * 6) + 8
    sta $d001    ; set y coordinate to 40

    lda #$80
    sta $07f8    ; set pointer: sprite data at $2000  ; end 07ff

load_floor:
    lda #$02
    ; basic floor
    sta $770 ;1904
    sta $771
    sta $772
    sta $773
    sta $774
    sta $775
    sta $776
    sta $777
    sta $778
    sta $779
    sta $77A
    sta $77B
    sta $77C
    sta $77D
    sta $77E
    sta $77F
    sta $780
    sta $781
    sta $782
    sta $783
    sta $784
    sta $785
    sta $786
    sta $787
    sta $788

    sta $78d
    sta $790

    lda #$03
    sta $791
    sta $792
    sta $793
    sta $794
    sta $795
loop:
    jmp loop

; -------------------------------
; This method is executed every time a hardware interrupt is generated
; -------------------------------
irq_handler
    dec $d019                       ; ack interrupt
    jsr update_sprite_location
    ;jsr update_debug_text
    jmp $ea31               ; jump back to the system IRQ handler

update_sprite_location:
    lda fallstate
    bne skip
    inc $d001
skip:
    lda #8
    sta $09
    lda $d001 ; ypos

    ; check if it collides y
    ;sta $d001  ; get current y position
    
    sbc #24 ; 24 down because of border
    ldy #$00  ; counter for ypos
suby:
    ; a less than 8, branch
    cmp $09
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
    sbc #8 ; border
subx:
    sbc #$8    ; subtract 8 until we go negative (division)
    cmp $09
    bcc db
    ;BMI db
    ;beq dd
    inx
    jmp subx
db:
    ; if the ninth bit is set also add n columes
    lda $D010
    and #$01 ; b00000001
    beq nohighbit
    txa
    adc #29 ; add 29 columns onto x
    tax
nohighbit:

xpos = $1004
ypos = $1005
floor = $1006

    sty ypos
    stx xpos
    ldx #$02
    stx floor
    ;+paintChar xpos, ypos
    +getChar xpos,ypos
    ; compare with flooor
    sta $79A ; show the char in A on screen
    cmp floor
    beq stop
    lda #$00
    sta fallstate
    rts
stop:
    lda #$01
    sta fallstate
    ;jsr update_debug_text
    rts

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

; We never get ehre.
fourty = $1000
row = $1001
    lda #$40
    sta fourty
    tya
    sta row
test:
    +MultiplyTwo fourty, row
    jmp test
    rts

; -------------------------------
; Sets up an interrupt to occur every screen refresh on line 0 (raster beam IRQ)
; -------------------------------
irq_init       
    sei                                     ; disable interrupts
    ldy #$7f
    sty $dc0d                       ; turn off CIA timer interrupt
    lda $dc0d                       ; cancel pending IRQs
    lda #$01
    sta $d01a                       ; enable VIC-II Raster Beam IRQ
    lda $d011                       ; 
    and #$7f                        ; bit 7 of $d011 is the 9th bit of the raster line counter, set it to 0
    sta $d011
                                                                                                                
    lda #0
    sta $d012               ; raster line register
    lda #<irq_handler       ; set the interrupt method handler
    sta $314
    lda #>irq_handler
    sta $315
    cli                     ; re-enable interupts
    rts

; clear the screen
clearscreen:
    lda #$00      ; Put the value 0 in accumulator
    sta $d020     ; Put value of acc in $d020
    ;lda #$01             ; white
    sta $d021     ; Put value of acc in $d021
    tax           ; Put value of acc in x reg
    lda #$20      ; Put the value $20 in acc
clrloop:
    sta $0400,x   ; Put value of acc in $0400 + value in x reg
    sta $0500,x   
    sta $0600,x   
    sta $0700,x
    dex            ; Decrement value in x reg
    bne clrloop    ; If not zero, branch to clrloop
    rts