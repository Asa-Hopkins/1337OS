debug: ;prints the general purpose registers
push ax
xor ax, ax
int 0x10
pop ax
push dx
push cx
push bx
mov dx, ax
mov di, .debugS+0x08
mov si, .debugS+0x04
mov cl, 0x04
mov bx, hexarray

.loop:
mov al, dl
and al, 0x0F
xlat
mov [di], al
dec di
ror dx, cl
cmp si, di
jnz .loop

pop dx
add si, 0x0A
add di, 0x0A+0x04
dec byte [.count]
jnz .loop

mov bx, .debugS
call printS
jmp $

.count:
db 0x04




