diski:
push ax
push bx
push cx
push dx
push es

mov cx, 0x00
mov es, cx ;we are in sector 0
mov ah, 0x02 ;set mode to read
mov al, 0x14 ;sectors to read
mov dh, 0x00
mov cl, 0x02
mov bx, readwrite ;load them to test
int 0x13

pop es
pop dx
pop cx
pop bx
pop ax
ret
disko:
push ax
push bx
push cx
push dx
push es
mov cx, 0x00
mov es, cx ;we are in sector 0
mov ah, 0x03 ;set mode to write
mov al, 0x13 ;sectors to write
mov dl, [device]
mov dh, 0x00
mov cl, 0x02
mov bx, readwrite ;write them to test
int 0x13
pop es
pop dx
pop cx
pop bx
pop ax
ret
device:
db 0x00