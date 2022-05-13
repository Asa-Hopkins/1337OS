pong:
call cls
mov [command], byte '1'
mov [program], byte '5' ;set the program
mov ax, 0x0005
int 0x10
;the video mode is interlaced, writing to [es:bx+0x2000] gives the line below [es:bx]
;es should contain 0xB800 already
mov bx, 0x5F4 ;start in the centre of the screen
push bx

mov cx, 0x20
call pause ;give the screen time to initialise
mov cx, 0x14
.shoop: ;draw paddles once
mov [es:bx], byte 0xFF
mov [es:bx+0x2000], byte 0xFF
mov [es:bx+0x47], byte 0xFF
mov [es:bx+0x2047], byte 0xFF
add bx, 0x50
loop .shoop
pop bx
xor si, si ;start with si=0

.loop:
mov dx, 0x3000 ;alters framerate
call pause2
;key presses move player
mov al, [kbdbuf + 0x48] 
sub al, [kbdbuf + 0x50] ;al is 0xFF for down, 0x01 for up and 0x00 otherwise
cbw ;ax is 0xFFFF for down, 0x0001 for up, 0x0000 otherwise
rcr ax, 0x01
salc ;ax is 0xFFFF for down, 0x00FF for up, 0x0000 otherwise
mov bx, [.player] ;move position to be edited into bx
call .drawpaddle ;this function draws the paddle bx, and changes its position according to ax. It also flips si as necessary.
xchg si, [.interlace] 
mov [.player], bx

mov bx, [.ypos]
mov [.cputarget], bh

mov bx, [.cpu]
add bh, 0x03 ;we want the cpu to stay 3 above the target, so that the target is in the centre
cmp bh, [.cputarget] ;sign flag and carry for down, no sign flag and not carry for up
salc 
sub bh, 0x03 ;we need to put bh back as we found it
cbw ;ah is 0xFF for sign flag
stc ;cpu always moves, which isn't preferable, but it works.
salc ;movement and drawing for the cpu is very similar
call .drawpaddle
xchg si, [.interlace]
mov [.cpu], bx

;check colisions and invert directions as necessary
cmp [.ypos], word 0x1F40
cmc
call .inverty ;inverts y velocity based on carry flag

mov bx, 0x0004
call .invertx ;inverts velocity based on ah and carry
mov bl, 0x4B
call .invertx


.addx:
add [.xpos+1], byte 0x40 ;this is xvelocity, hard coded currently
.adcx:
adc [.xpos], byte 0x00 ;if this isn't between 0x00 and 0x50 then the game ends
mov ax, [.yvel]
.add1: ;I use self modifying code in order to perform direction changes after a collision
add [.ypos+2], al
salc
and al, 0x50 ;ypos is kept as a multiple of 0x50 so no multiplications are needed
add ah, al
.add2:
add [.ypos], ah ;ypos is little endian
.adc:
adc [.ypos+1], byte 0x00

xor bh, bh
mov bl, [.xpos]
add bx, [.ypos] ;note that the carry flag should be clear after this command
mov ch, [.xpos+1] ;first three bits of position say how many pixels along we are, so we want to shift ax right by this *2 (2 bits per pixel)
mov cl, 0x04 ;only 5 bits of cl are used to perform a shift (according to documentation for the 80186)
;We use the fact that the carry flag is clear to move a 0 into the 4th bit position, then the two bits we want, then another 0 (so it's multiplied by 2)
rcl cx, cl 
mov ax, 0x0050 ;bit pattern corresponding to the ball
ror ax, cl
xor [es:bx], ax
xor [es:bx+0x2000], ax


xchg bx, [.last] ;store last position of the ball
xchg ax, [.last+2]

xor [es:bx], ax
xor [es:bx+0x2000], ax ;xor last position and current position to clear where the ball just was without disrupting other pixels
cmp [.xpos], byte 0x50
jc .loop
mov ax, 0x0003 ;reset video mode on exit
int 0x10
ret

.inverty: ;convert an 0x80 /2 (ADC r/m8,imm8) to a 0x80 /3 (SBB r/m8,imm8) and a 0x00 (ADD r/m8,r8) to a 0x28 (SUB r/m8,r8) or vice versa, based on carry flag
salc 
and al, 0x28
xor [.add1], al
xor [.add2], al
and al, 0x08
xor [.adc+1], al
xor [.xpos+1], al ;keeps track of y-direction
ret

.invertx: ;convert an 0x80 /2 (ADC r/m8,imm8) to a 0x80 /3 (SBB r/m8,imm8) and a 0x00 (ADD r/m8,r8) to a 0x28 (SUB r/m8,r8) or vice versa, based on ax and bx
mov ax, [.ypos] ;check for collision
sub ax, [.player-4+bx]
mov dx, ax ;will be used for distance from centre of paddle
sub ax, 0x640
salc
cbw ;set ah if ball is within 1A rows of the paddle
mov al, [.xpos]
sub al, bl
add al, 0xFF
cmc
salc ;set al if x-position is a certain value

sub dx, 0x320 ;convert to signed distance from paddle centre
and al, ah 
cbw ;need both al and ah to be  0xFF for collision, else cleared
and dx, ax
and al, 0x28
xor [.addx+1], al 
and al, 0x08
xor [.adcx+1], al

mov al, [.xpos+1] ;we keep track of direction in a spare bit of xpos
mov cl, 0x04 ;This is also how much we must shift dx to give a signed byte
rcr al, cl
salc
cbw ;set ax if direction is upwards
sar dx, cl
xor dx, ax ;negate distance if ax is set, nothing otherwise
sub dx, ax
add [.yvel], dl ;if there is a carry, and dl is negative, then decrease most significant byte, otherwise increase
salc
cbw
shl dl, 0x01
salc
and ax, 0x50B0 
add al, ah ;This is the same trick used in paddle movement
add [.yvel+1], al
lahf ;if sign flag is set, reverse y-direction
shl ah, 0x01
salc
cbw
xor [.yvel], ax
sub [.yvel], al ;this performs an absolute value, to keep yvel positive
not al
and [.yvel+1], al ;if the yvelocity is being inverted, it clears the most significant byte, so it can't change directions and go super speed
sahf
jmp .inverty ;invert y if al was set, tail call recursion.

.drawpaddle:
push ax
and ax, 0xB028 ;essentially solve the equations ah+al=-50, al=50, so al=-100=0x60 so that ah+al gives us what we want
add al, ah
cbw
sub bx, ax ;sign flag is set if <0x00

lahf
cmp bh, 0x19 ;carry flag set if <0x19
cmc
salc
xchg ah, al ;ah is 0xFF if bh>0xC
rol al, 0x01
salc  ;al is 0xFF if bx<0x00
and ax, 0xB0A0
add al, ah
cbw
add bx, ax

pop ax
cbw
and ax, 0x1FD8
xor si, ax

;if si is 0x1FD8 then di is 0xFFD8
;if si is 0x00 then di is 0x1FB0
mov [es:bx+si], byte 0xFF
mov [es:bx+0x640+si], byte 0xFF

lahf
shl ax, 0x01
shl ax, 0x01
salc
cbw
and ax, 0x1FD8
mov di, 0xFFD8
add di, ax

mov [es:bx+di], byte 0x00
mov [es:bx+0x690+di], byte 0x00
ret



.yvel:
dw 0x0000
.player:
dw 0x05F4
.last:
dw 0x00, 0x00
.cputarget:
db 0x03
.interlace:
dw 0x0000
.ypos:
dw 0x0640
db 0x00
.xpos:
db 0x20, 0x00
hexarray:
db '0123456789ABCDEF'
debug.debugS:
db 'ax:0x', 0x00, 0x00, 0x00, 0x00, 0x0D
db 'bx:0x', 0x00, 0x00, 0x00, 0x00, 0x0D
db 'cx:0x', 0x00, 0x00, 0x00, 0x00, 0x0D
db 'dx:0x', 0x00, 0x00, 0x00, 0x00, 0x0D, 0x00
pong.cpu:
dw 0x063B