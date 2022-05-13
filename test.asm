cga:
xor bx, bx
mov ax, 0x1003
int 0x10

mov dx, 0x3D4   ; CGA Index Register
mov al, 0x09    ; Maximum Scan Line Reigster
out dx, al
mov dx, 0x3D5   ; CGA Data Port
mov al, 0x5    ; 6 scan lines, looks nearly square
out dx, al


mov cx, 0x1FFF
xor bx, bx
.fill:
xor ah, ah
;changing this to 0x00 removed the "motion blur" but halves horizontal resolution
mov al, 0xDD ;this ascii character lets us colour each half separatetly
mov [es:bx], ax
inc bx
inc bx
loop .fill

xor bx, bx 
.frame: ;every frame
cli ;interupts use the stack, but we need the stack pointers as general purpose registers
xchg sp, [.stack] ; sin = 0  initially
xchg bp, [.stack+2] ;cos = 1 initially

;sp contains cos(theta), bp contains sin(theta). They are between 0 and 1, with signs implicit from the functions
mov ax, sp
mul word [.rpm] ;rpm dictates how fast to spin
.both1:
add [.precision], ax
.both3:
adc bx, dx ;invert for both
jc .negsin
.sinedone:
mov ax, bx
mul word [.rpm] 
.both2:
sub [.precision+2], ax
.both4:
sbb sp, dx ;invert for both
jc .negcos
.cosdone:

;calculate di = (x*cos(theta) - y*sin(theta)) + 0x50(x*sin(theta) + y*cos(theta)) for first pixel at (-16,-30)
xor di, di
mov [.initial], word 0x00
mov [.initial+2], word 0x00


mov ax, 30
mul bx
shl dx, 0x01
.sin1:
add di, dx ;invert for sin
.sin2:
add [.initial], ax

mov ax, 16 ;we want -16 but we can only use unsigned arithmetic
mul sp
shl ax, 0x01
adc dx, 0x00 ;rounding
shl dx, 0x01
.cos1:
sub di, dx ;invert for cos
.cos2:
sub [.initial], ax


.next:
mov ax, 16
mul bx
.sin3:
sub [.initial+2], ax
xchg ax, dx
mov dx, 0xA0
imul dx
.sin4:
sub di, ax ;invert for sin

mov ax, 30
mul sp
.cos3:
sub [.initial+2], ax
xchg ax, dx
mov dx, 0xA0
imul dx
.cos4:
sub di, ax ;invert for cos

add di, 0x1441

mov dx, [.initial]
mov bp, [.initial+2]
mov [.initial+4], di
mov si, spinner
mov [.rows], byte 59
.loop2: ;This loop is 120 + 16 cycles, so worth around 4 cycles of the inner loop
;if the inner loop were unrolled, then cx could be repurposed and this could be reduced a little
mov cx, 32
.loop1: ;draw row
;This is the critical loop, I'll estimate the maximum theoretical framerate with cycle counting with official 8086 documentation.
;It occurs once for each pixel pair, so 59*32=1888 times
;It's around 49 cycles + 17 cycles for the loop, which could be removed entirely with unrolling. 
;Since width is a power of 2, partial unrolling is easy too, but won't be done here since it complicates the outer loop regardless.
;This gives a theoretical framerate of 4.77*10**6 / (59*32*(44 + 17)) = 41.42 fps, or with unrolling 57.4 fps
.cos5:
add dx, sp ;x increases by 1, dx increases by cos(theta). invert for cos
sbb ax, ax
shl ax, 0x01
.cos6:
sub di, ax ;if carry, add 2 to di. invert for cos

.sin5:
add bp, bx ;x increases by 1, bp increases by sin(theta)
salc
and ax, 0x00A0
.sin6:
add di, ax
;24 cycles to here
movsb ;18 cycles
dec di
loop .loop1


mov di, [.initial+4] 


.sin7:
sub [.initial], bx ;y increases by 1, dx decreases by sin(theta). invert for sin
salc
and ax, 0x0002
.sin8:
sub di, ax ;if carry, add 2 to di. invert for sin

.cos7:
add [.initial+2], sp ;y increases by 1, bp increases by cos(theta)
salc
and ax, 0x00A0
.cos8:
add di, ax 
mov [.initial+4], di
dec byte [.rows]
jnz .loop2


xchg sp, [.stack] 
xchg bp, [.stack+2] 
sti
mov dx, 0x0200
call pause
dec word [.frames]

jnz .frame

mov dx, 0x3D4   ; CGA Index Register
mov al, 0x09    ; Maximum Scan Line Reigster
out dx, al
mov dx, 0x3D5   ; CGA Data Port
mov al, 0x0F     ;16 scan lines (back to normal)
out dx, al

ret

.negsin: ;carry flag was set, check if sign needs negating


lahf
shl ah, 0x01
cmc
salc 
cbw ;0x0000 if sign, 0xFFFF otherwise
or bx, ax
not ax
xor bx, ax
sub bx, ax
and ax, 0x28 ;self modify code
xor [.both1], al
xor [.both2], al
xor [.sin1], al
xor [.sin2], al
xor [.sin3], al
xor [.sin4], al
xor [.sin5], al
xor [.sin6], al
xor [.sin7], al
xor [.sin8], al
and ax, 0x08
xor [.both4], al
xor [.both3], al
jmp .sinedone

.negcos: ;carry flag was set, check if sign needs negating

lahf
shl ah, 0x01
cmc
salc 
cbw ;0x0000 if sign, 0xFFFF otherwise
or sp, ax
not ax
xor sp, ax
sub sp, ax
and ax, 0x28
xor [.both1], al
xor [.both2], al
xor [.cos1], al
xor [.cos2], al
xor [.cos3], al
xor [.cos4], al
xor [.cos5], al
xor [.cos6], al
xor [.cos7], al
xor [.cos8], al
and ax, 0x08
xor [.both4], al
xor [.both3], al
jmp .cosdone

.rows:
db 0x00
align 2
.initial:
dw 0x0000, 0x0000, 0x0000
.rpm:
dw 0x00FF
.precision:
dw 0x0000, 0x0000
.frames:
dw 0x00FF
.stack:
dw 0xFFFF, 0x0000