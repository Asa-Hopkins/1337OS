paint:
push es
call cls ;clear the screen
mov bx, paintS
call printS ;print the welcome message
call enter ;new line
mov [command], byte '0'
mov [char], byte 0x00
mov [return], word .loop
mov [program], byte '4' ;set the program
mov [kbdbuf + 0x02], byte 0 ;clear key '1' buffer so it doesn't instantly quit
call mouse ;enable mouse drivers
mov ax, 0xA000
mov es, ax
xor ax, ax
mov ax, 0x10
mov bx, 0x00
int 10h

mov dx, 3C4h       ; address of sequencer address register
mov ax, 0x0C02         ; index of map mask register, plus colour to switch to
out dx, ax

xor bx, bx
.loop:
in al, 0x64 ;check for mouse input
and al, 0x01
cmp al, 0x01
je .mouse ;if so, accept the input
.mousedone:
call .cursor
mov [es:bx], al ;write to screen
;mov al, [kbdbuf + 0x4B] ;move left

;mov al, [kbdbuf + 0x4D] ;move right

;mov al, [kbdbuf + 0x48] ;move up

;mov al, [kbdbuf + 0x50] ;move down

;mov al, [kbdbuf + 0x2C] ;brush down

mov al, [mpos]
and al, 1b
cmp al, 0x00
jnz .z
;mov al, [kbdbuf + 0x2D] ;brush up

mov al, [mpos]
and al, 10b
cmp al, 0x00
jnz .x

mov al, [kbdbuf + 0x02]
cmp al, 0x00
jz     .loop
mov [command], word '1'
mov ax, 0xB800
mov es, ax
xor ax, ax
mov ax, 0x03
mov bx, 0x00
int 10h
pop es
ret
mov bl, 0xF5
call mouse.send
jmp .loop

.z:
mov [.brush], byte 0xff
jmp .loop

.x:
mov [.brush], byte 0x00
jmp .loop

.mouse:
push ax
push bx
push cx

call mouse.waitr
call mouse.mpause
xor bx, bx
in al, 0x64
and al, 0x20
cmp al, 0x00
je .ydone

in al, 0x60
mov [mpos], al ;store this directly so mouse button presses are saved
call mouse.waitr
call mouse.mpause
in al, 0x64
and al, 0x20
cmp al, 0x00
je .ydone
in al, 0x60
mov bl, al
mov cl, [mpos]
and cl, 0x10
cmp cl, 0
jne .sub1
add [mpos+1], bx
.xdone:

call mouse.waitr
call mouse.mpause
in al, 0x64
and al, 0x20
cmp al, 0x00
je .ydone
in al, 0x60

mov bl, al
mov cl, [mpos]
and cl, 0x20
cmp cl, 0
jne .sub2
sub [mpos+3], bx
.ydone:

in al, 0x60
in al, 0x60
in al, 0x60
in al, 0x60
in al, 0x60
in al, 0x60
in al, 0x60
in al, 0x60
pop cx
pop bx
pop ax
jmp .mousedone

.sub1:
add [mpos+1], bx
sub [mpos+1], word 0x100
jmp .xdone

.sub2:
sub [mpos+3], bx
add [mpos+3], word 0x100
jmp .ydone

.cursor:
mov ax, 0x50
mov bx, [mpos+3]
shr bx, 0x03
mul bx
xor bx, bx
mov bx, [mpos+1]
shr bx, 0x06
add ax, bx
mov bx, ax
mov cx, [mpos+1]
shr cx, 0x03
and cx, 111b
mov al, 0x80
shr al, cl
mov si, bx
push cx
push bx
push ax
call .readscreen
pop ax
mov cl, [.brush]
cmp cl, 0xFF
jne .remove
or al, bl
jmp .written
.remove:
not al
and al, bl
.written:
pop bx
pop cx
ret
 
.readscreen:
mov dx,0x03ce
mov ax,0x0005
out dx,ax
mov ax,0304h ;ah = plane, al = read modus
out dx,ax ;go to read mode 
mov bh,[es:si] ;read intensity
dec ah
out dx,ax
mov bl,[es:si] ;read red
ret

;mov cl,[es:bx]
;or al, cl
;ret

.brush:
db 0xFF, 0

paintS:
db 'Welcome to paint', 0

mpos:
db 0
dw 0,0
