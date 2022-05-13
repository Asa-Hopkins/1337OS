Mandelbrot:
call cls
mov [command], byte '1'
mov [program], byte '7' ;set the program
mov ax, 0x0013
int 0x10
mov ax, 0xA000
mov es, ax
xor bx, bx
push bx
mov cx, 0x04

mov [.rows], word 0x140
mov [.columns], byte 0xC8

;We need change in x and change in y from one pixel to next
; x_scale/320 and y_scale/200
xor dx, dx
mov ax, [.x_scale]
mov bx, 0x140
div bx
mov [.dx], ax
xor ax, ax
div bx
mov [.dx+2], ax

xor dx, dx
mov ax, [.y_scale]
mov bx, 0xC8
div bx
mov [.dy], ax
xor ax, ax
div bx
mov [.dy+2], ax


mov ax, [.y_min]
mov [.y0], ax
mov [.y0+2], word 0x0000


; We have x_min, y_min, x_max, y_max that defines viewing area
; Signed fixed point, decimal point is after the 4th binary digit

;Assume we have x_2 and y_2 in si and di respectively
;And that x, y are in ax and bx
.nextrow:
mov ax, [.x_min]
mov [.x0], ax
mov [.x0+2], word 0x0000
mov [.rows], word 0x140

.nextpix:

mov ax, [.x0]
mov bx, [.y0]
mov [.iteration], byte 0x10
jmp .first

.loop:
imul bx     ; dx:ax = xy >> 4 
dec cx
shr ah, cl
inc cx
inc cx
shl dx, cl
dec cx
or dl, ah
; we need to put the decimal point back in the right place
; rotate 4 bits of ax into dx


add dx, [.y0] ; dx = 2xy+x_0
mov bx, dx ; save y in cx

mov ax, si ; ax = x^2
sub ax, di ; ax = x^2 - y^2
add ax, [.x0] ; ax = x^2 - y^2 + x_0

.first:
mov si, ax ; save x in si temporarily
mov ax, bx ; ax = y
imul ax ; dx:ax = y^2 >> 4
; we need to put the decimal point back in the right place

shr ah, cl
shl dx, cl
or dl, ah

mov di, dx ; di = y^2
mov ax, si ; restore ax
imul ax ; dx:ax = x^2 >> 4
; we need to put the decimal point back in the right place

shr ah, cl
shl dx, cl
or dl, ah

mov ax, si
mov si, dx

; if x^2 + y^2 >= 4, break
; Should always be positive, so can treat as unsigned
mov dx, di
add dx, si

cmp dx, 0x4000

jnc .break
dec byte [.iteration]
jnz .loop

.break:

pop bx
mov al, 0x30
sub al, [.iteration]
mov [es:bx], al
inc bx
push bx

mov dx, [.dx]
mov ax, [.dx+2]
add [.x0+2], ax
adc [.x0], dx
dec word [.rows]

jnz .nextpix

mov dx, [.dy]
mov ax, [.dy+2]
add [.y0+2], ax
adc [.y0], dx

dec byte [.columns]
jnz .nextrow

pop bx

.input:
mov cx, 0x0001
xor dx, dx
call pause

mov cl, 0x04
cmp [kbdbuf + 0x48], byte 0x01
je .up

cmp [kbdbuf + 0x4B], byte 0x01
je .left

cmp [kbdbuf + 0x4D], byte 0x01
je .right

cmp [kbdbuf + 0x50], byte 0x01
je .down

cmp [kbdbuf + 0x2C], byte 0x01
je .in

cmp [kbdbuf + 0x2D], byte 0x01
je .out

jmp .input

.down:
mov ax, [.y_scale]
shr ax, cl
add [.y_min], ax
jmp Mandelbrot

.up:
mov ax, [.y_scale]
shr ax, cl
sub [.y_min], ax
jmp Mandelbrot

.left:
mov ax, [.x_scale]
shr ax, cl
sub [.x_min], ax
jmp Mandelbrot

.right:
mov ax, [.x_scale]
shr ax, cl
add [.x_min], ax
jmp Mandelbrot

.in:
mov ax, [.x_scale]
shr ax, 1
mov [.x_scale], ax
shr ax, 1
add [.x_min], ax

mov ax, [.y_scale]
shr ax, 1
mov [.y_scale], ax
shr ax, 1
add [.y_min], ax
jmp Mandelbrot

.out:
mov ax, [.x_scale]
shr ax, 1
sub [.x_min], ax
shl ax, 1
shl ax, 1
mov [.x_scale], ax

mov ax, [.y_scale]
shr ax, 1
sub [.y_min], ax
shl ax, 1
shl ax, 1
mov [.y_scale], ax

jmp Mandelbrot




.rows:
dw 0x0000

.columns:
db 0x00


.iteration:
db 0x10

.x0:
dw 0xE000, 0x0000
.y0:
dw 0xE000, 0x0000

.dx:
dw 0x0000, 0x0000
.dy:
dw 0x0000, 0x0000

.x_min:
dw 0xE000
.x_scale:
dw 0x4000
.y_min:
dw 0xE000
.y_scale:
dw 0x4000

