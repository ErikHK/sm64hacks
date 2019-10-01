;.n64
;.open "Super Mario 64 (U) [!] - Kopia.z64",0x80245000

.n64

@ROM_START equ 0x7CC6C0
@RAM_START equ 0x80367500

@RAM_OFFSET equ (@RAM_START - @ROM_START)

@MAX_SIZE equ 0x11200


.orga 0x13e9cc
ADDIU SP, SP, 0x4D8
JR RA




; ---------------------------------- START OF BOBOMB LOOP! ---------------------------
;add position from speed etc!
.orga 0xA2438 ; start at 802E7438

;A0 doesn't always contain a pointer to the object.. check first
LI T3, 0x18
LB T4, 0x1(A0)
BNE T3, T4, exitbobomb

;LI T3, 0x21
;LB T4, 0x3(A0)
;BNE T3, T4, exitbobomb




;A0 holds the pointer to the object
; X Y Z VEL are at AC B0 B4
; X Y Z POS are at A0 A4 A8

;load the x position to F0
LWC1 F0, 0xA0 (A0)

;load the x speed to F1
LWC1 F1, 0xAC (A0)

;add them together
ADD.S F0, F0, F1

;store to position
S.S F0, 0xA0 (A0)



;load the y position to F0
LWC1 F0, 0xA4 (A0)

;load the y speed to F1
LWC1 F1, 0xB0 (A0)

;add them together
ADD.S F0, F0, F1

;store to position
S.S F0, 0xA4 (A0)




;load the z position to F0
LWC1 F0, 0xA8 (A0)

;load the z speed to F1
LWC1 F1, 0xB4 (A0)

;add them together
ADD.S F0, F0, F1

;store to position
S.S F0, 0xA8 (A0)

NOP
NOP
NOP
NOP
NOP

;check timer
LW T1, 0x154(A0)
LI T2, 0x100
BLT T1, T2, afterkillself
NOP
killself:
;JAL 0x802a0568
NOP
SH R0, 0x74 (A0)
NOP
NOP

afterkillself:
NOP
NOP
;check if there are any pointers to collisions osv
;A0 contains a pointer to the current bobomb
LW T1, 0x78 (A0)
BEQ T1, R0, nohit ;if T1 = null pointer, jump to nohit
NOP

hit:
;T1 contains pointer to colliding object, kill it! (check if mario first??)
LUI T2, 0x8035
ADDI T2, 0xB888
BEQ T1, T2, nohit
NOP

LUI T2, 0x8035
ADDI T2, 0xB170
BEQ T1, T2, nohit
NOP

;check if the killed object is a goomba first:
LUI T2, 0x800f
ADDI T2, 0xf8ac
LW T3, 0x20c(T1)
BNE T2, T3, nohit



;LI T3, 0x18
;LB T4, 0x1(T0)
;BNE T3, T4, nohit

NOP
NOP
SH R0, 0x74 (T1)

nohit:
NOP
NOP
NOP
NOP
exitbobomb:
NOP
NOP

ADDIU SP, SP, 0x28
JR RA
NOP
NOP
NOP
NOP
; ----------------------------------- END OF BOBOMB LOOP -------------------------------




.orga 0x8625c ;802CB25C
J @on_every_mario_active_frame


;.orga 0x862cc ;802CB2CC
;.orga 0x862d0
;.orga 0x2cb2cc
;.orga 0x7CC718 ;807CC718 80a11718
.orga 0xF5000 ;8033A000
;.org @ROM_START
.headersize 0x245000
.area @MAX_SIZE
@on_every_mario_active_frame:

ADDIU SP, SP, 0xFFE8
SW RA, 0x14 (SP)


;count how many bobombs there are:
LUI A0, 0x1300
ADDI A0, 0x3174 ;bobomb
JAL 0x8029FBDC
NOP
LUI T0, 0x8033
SW V0, 0x0(T0)


;check if zoomed in, in that case, do everything etc
LUI A0, 0x8033
ADDI A0, 0x2609

LB A1, 0x0 (A0) ; A1 = 
LI A2, 0x12
BNE A1, A2, notzoomedin

zoomedin:
;render cannon reticle if zoomed in
LI A0, 0x2
JAL 0x802db08c
LI A0, 0x0
JAL 0x802a04c0	;hide mario
NOP
NOP

;F2 = x, F3 = y, F4 = z

LUI T0, 0x8034
ADDI T0, 0xB1AC	;T0 = Mario x

LUI T1, 0x8034
ADDI T1, 0xC6A4 ;T1 = Camera x



LWC1 F1, 0x0 (T1) ;camera y pos
LWC1 F0, 0x0(T0) ;mario x pos 
SUB.S F2, F0, F1 ; mario_x - camera_x
NOP


LWC1 F1, 0x04 (T1) ;camera y pos
LWC1 F0, 0x04 (T0) ;mario y pos
SUB.S F3, F0, F1 ; mario_y - camera_y
NOP
LI.S F1, 125
NOP
add.s F3, F3, F1 ; mario_y - camera_y + 125


NOP
LWC1 F1, 0x08 (T1) ;camera z pos
LWC1 F0, 0x08 (T0) ;mario z pos
SUB.S F4, F0, F1 ; mario_z - camera_z



NOP
lui T0, 0x8034
ADDI T0, 0xB000


S.S F2, 0x00(T0) ;store x to 80330000
S.S F3, 0x04(T0) ;store y to 80330004
S.S F4, 0x08(T0) ;store z to 80330008


;check if Z is pressed:

LUI T0, 0x8034
ADDI T0, 0xB170

LUI T3, 0x00

LB T1, 0x2(T0)
BEQ T1, T3, notpressing

pressing: ;here we are pressing (holding) Z or B, create a bobomb here maybe?

;LUI T0, 0x802A
;ADDI T0, 0xEDCC

;LUI A0, 0x8036
;ADDI A0, 0x1160 ;A0 = 0x80361160 

LUI A0, 0x8035
ADDI A0, 0xB888

;LUI A0, 0x8035
;ADDI A0, 0xDE88

LI A1, 0xBC ;bobomb
;LI A1, 0x76 ;blue coin

LUI A2, 0x1300
ADDI A2, 0x3174 ;bobomb
;ADDI A2, 0x30A4 ;blue coin
;ADDI A2, 0x0a78 ;YES! typ?
;ADDI A2, 0x

LI A3, 0x4E2

JAL 0x8029EDCC ;run SpawnObj
;now V0 contains a pointer to the object, set speeds!!
NOP		;important shit
NOP

;try to hide mario!
;LUI A0, 0x8034
;ADDI A0, 0xB170

;LUI A0, 0x8035
;ADDI A0, 0xB888

;first check byte at 80332609 if camera is zoomed in
;LUI A0, 0x8033
;ADDI A0, 0x2609

;LB A1, 0x0 (A0) ; A1 = 
;LI A2, 0x12
;BNE A1, A2, unhidemario
;NOP
;NOP
;hidemario:
;LI A0, 0x0
;NOP
;NOP
;J dohideorunhidemario
;NOP
;NOP

;unhidemario:
;LI A0, 0x1

;dohideorunhidemario:
;JAL 0x802a04c0
;NOP
;NOP


;load back the F2, F3, and F4 values..

LUI A0, 0x8034
ADDI A0, 0xB000
LWC1 F2, 0x0(A0)
LWC1 F3, 0x4(A0)
LWC1 F4, 0x8(A0)


S.S F2, 0xAC(V0) ;x vel
S.S F3, 0xB0(V0) ;y vel
S.S F4, 0xB4(V0) ;z vel

;load marios position and store it to new object

LUI T0, 0x8034
ADDI T0, 0xB1AC	;T0 = Mario x

LWC1 F0, 0x0(T0) ;mario x
S.S F0, 0xA0 (V0) ;store to new objects x

LWC1 F0, 0x4(T0) ;mario y
S.S F0, 0xA4 (V0) ;store to new objects y

LWC1 F0, 0x8(T0) ;mario z
S.S F0, 0xA8 (V0) ;store to new objects z





;also add to position
;LWC1 F0, 0xA0 (V0)
;ADD.S F0, F2, F0
;S.S F0, 0xA0 (V0)

;LI.S F1, 20000
;LWC1 F3, 0xA4 (V0)
;ADD.S F1, F3, F1
;S.S F1, 0xA4 (V0)

;LWC1 F0, 0xA8 (V0)
;ADD.S F0, F4, F0
;S.S F0, 0xA8 (V0)


NOP
NOP
J afterpresscheck

notpressing:
NOP
NOP


J afterzoom

notzoomedin:
LI A0, 0x1
JAL 0x802a04c0  ;unhide mario
NOP
NOP

afterzoom:


afterpresscheck:

;;;;;;;;;;;;;;;;;;;;;;;;;;

LW RA, 0x14 (SP)
JR RA
ADDIU SP, SP, 0x18

.endarea
.skip 4
