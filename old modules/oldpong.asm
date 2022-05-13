pong:
push ax
push bx
push cx
push dx
call cls
mov [command], byte '1'
mov [program], byte '5' ;set the program

.loop:
mov dx, 0xC000
call pause2

;key presses, move player
mov al, [kbdbuf + 0x48] ;get up key
cmp al, 0x00
jnz     .up
.updone:
mov al, [kbdbuf + 0x50] ;get down key
cmp al, 0x00
jnz     .down
.downdone:


;draw ball
mov bl, [.bally+1] ;get ball y higher byte
mov al, byte 0xA0 ;multiply by screen width
mul bl
mov bx, [ans]
mov ax, [.cpuy] ;get cpu position and compare to ball height
add ax, 0x140
cmp ax, bx


;cpu movement
push bx
jg .cpuup
jl .cpudown
.cpudone:
pop bx

;move ball
mov ax, [.bally] ;move y
add ax, [.yvel]
mov [.bally], ax
cmp ax, 0x7F ;check y collisions
jge .wallt
neg word [.yvel] ;change sign on collision
.wallt:
cmp ax, 0x187F
jl .wallb
neg word [.yvel]
.wallb:

mov ax, [.ballx] ;move x
add ah, [.xvel]
add ah, [.xvel]
jo .ballright ;if least significant byte under/overflows, the ball moves into the next pixel
jc .ballleft

.ballxcol: ;check x collisions
cmp al, 0x0C
jc .playerc ;with the player

cmp al, 0x92
jnc .cpuc ;with the cpu

.ballxdone:
mov [.ballx], ax


;finish drawing the ball
xor ah, ah
add bx, ax
mov [es:bx], word 0x2500 ;set pixel to green background
cmp bx, [.ballxy] ;check against last position
je .balldrawn ;skip if equal
push bx
mov bx, [.ballxy]
mov [es:bx], word 0x0900 ;set last position to blue text, green background
pop bx
mov [.ballxy], bx
.balldrawn:

;draw the player
mov cx, 0x04
mov bx, [.playery] ;get player y
xor ax, ax
.drawplayer:
mov [es:bx+0x0A], word 0x2500 ;make the pixel green
add bx, 0xA0 ;increment row
loop .drawplayer

;draw the cpu
mov cx, 0x04
mov bx, [.cpuy]
.drawcpu:
mov [es:bx+0x92], word 0x2500 ;repeat for cpu
add bx, 0xA0
loop .drawcpu

jmp .loop

.up: ;move player up
mov ax, [.playery] 
cmp ax, 0x00 ;check if at the top
je .updone ;skip if so
sub [.playery], word 0xA0 ;decrease y position
mov bx, [.playery]
add bx, 0x280 ;clear below paddle
mov [es:bx+0x0A], word 0x0900
jmp .updone

.down: ;move player down
mov ax, [.playery]
cmp ax, 0x0D20 ;check if at the bottom
jge .downdone ;skip if so
mov bx, [.playery]
mov [es:bx+0x0A], word 0x0900 ;clear above
add [.playery], word 0xA0
jmp .downdone


.cpuup: ;same as above but for cpu
mov ax, [.cpuy]
cmp ax, 0x00
je .cpudone
sub [.cpuy], word 0xA0
mov bx, [.cpuy]
add bx, 0x280
mov [es:bx+0x92], word 0x0900
jmp .cpudone

.cpudown: ;same as above but for cpu
mov ax, [.cpuy] ;This needs optimising I think, maybe pass in an address pointer to the y variable.
cmp ax, 0x0D20
jge .cpudone
mov bx, [.cpuy]
mov [es:bx+0x92], word 0x0900
add [.cpuy], word 0xA0
jmp .cpudone

.ballright: ;move ball right
add al, 0x02
xor ah, ah
jmp .ballxcol

.ballleft: ;move ball left
sub al, 0x02
xor ah, ah
jmp .ballxcol

.playerc: ;if collision with player
cmp al, 0x06 ;check if ball is out of play
je .lose
push ax
mov ax, [.playery]
mov cl, 0xA0
div cl
mov cl,al ;convert playery to row
pop ax
cmp cl, [.bally+1] ;compared row to ball row
jg .ballxdone ;if between playery and playery+4 then it's hit the paddle
add cl, 0x03
cmp [.bally+1], cl
jg .ballxdone

xor ch, ch
sub cl, [.bally+1]

cmp cl, 0x01
jle .pbot ;check if it's hit the top or bottom of the paddle
shl cl, 1
shl cl, 1
shl cl, 1
shl cl, 1
add [.yvel], word 0x10 ;change yvel accordingly
sub [.yvel], cx
jmp .ptop

.pbot:
shl cl, 1
shl cl, 1
shl cl, 1
shl cl, 1
sub [.yvel], cx ;change yvel accordingly
add [.yvel], word 0x20

.ptop:
add [.xvel], byte 0x80 ;reverse ball x
jo .ballxdone
add [.xvel], byte 0x80 ;it's real dodgy so this ensures the value is now positive
jmp .ballxdone

.cpuc: ;same as above but for cpu, could be optimised
cmp al, 0x94
je .win
push ax
mov ax, [.cpuy]
mov cl, 0xA0
div cl
mov cl,al
pop ax
cmp cl, [.bally+1]
jg .ballxdone
add cl, 0x03
cmp [.bally+1], cl
jg .ballxdone

xor ch, ch
sub cl, [.bally+1]

cmp cl, 0x01
jle .cbot
shl cl, 1
shl cl, 1
shl cl, 1
shl cl, 1
add [.yvel], word 0x10
sub [.yvel], cx
jmp .ctop

.cbot:
shl cl, 1
shl cl, 1
shl cl, 1
shl cl, 1
sub [.yvel], cx
add [.yvel], word 0x20

.ctop:
add [.xvel], byte 0x80
jno .ballxdone
add [.xvel], byte 0x80
jmp .ballxdone

.win: ;endgame messages
mov bx, .winS
jmp .gameover

.lose:
mov bx, .loseS
jmp .gameover

.gameover: ;end the game
call printS
call enter
mov bx, pressenter
call printS
.ent2con:
mov al, [kbdbuf + 0x1C] ;get enter key
cmp al, 0x00
je     .ent2con
pop dx
pop cx
pop bx
pop ax
ret

;playerx is 10, cpux is 70, both are constant
.playery:
dw 0
.cpuy:
dw 0
.ballx:
db 80, 0 ;second value acts as decimal
.bally:
dw 0x0c00
.xvel:
db 0x7F
.yvel:
dw 0x00
.ballxy:
dw 0x00
.winS:
db 'You Won!', 0
.loseS:
db 'You Lost!',0