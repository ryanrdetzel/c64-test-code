firstH = $1000
firstL = $1001
secondH = $1002
secondL = $1003
    lda #$4
    sta firstH
    lda #$0
    sta firstL

    lda #$03
    sta secondH
    lda #$84
    sta secondL
;+MultiplyTwo one, two
+Add firstH, firstL, secondH, secondL
ll:
    jmp ll