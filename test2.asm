man:
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
mov al, 0xDD ;this ascii character lets us colour each half separatetly
mov [es:bx], ax
inc bx
inc bx
loop .fill

mov ax, .squares
mov cl, 0x04
shr ax, cl
mov ds, ax
xor bx, bx
.loop:
add bx, 0x02
mov ax, bx
mul bx


shl bx, 0x01
sbb ax, ax
rcr bx, 0x01
xor bx, ax
sub bx, ax
mov ax, [bx]




align 16
.squares:
