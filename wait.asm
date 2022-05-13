pause: ;pauses for cx:dx microseconds
;converts to number of ticks from a 1.193182MHz clock
push ax
push bx

mov ax, cx
mov cl, [shift]
shl dx, cl
rcl ax, cl
mov cx, ax
; Since each cx is 2**16 microseconds, and each microsecond is 1.193182 clock ticks, then we want to wait for 
;cx * 2**16 * 1.193182 = cx * 78196.3755 = cx * 2**16 + cx * 12660 + cx * 24612 * 2**-16   clock ticks, which can be done with integer arithmetic
;We do something similar for dx, getting dx * 1.193182 = dx + dx * 12660 * 2**-16
mov ax, 12660 
push dx
mul cx
add dx, cx
mov [overflow], dx
mov bx, ax
mov ax, 24612 
mul cx
mov ax, dx
add ax, bx
adc [overflow], word 0x0000
pop dx
add ax, dx
adc [overflow], word 0x0000
mov bx, ax
mov ax, 12660
mul dx
add bx, dx
adc [overflow], word 0x000
mov ax, bx
jz .loop1
call gettime
dec word [overflow]

.loop: ;wait until overflow is zero
call gettime
mov dx, [time+2]
sub dx, [time]
sub ax, dx
sbb [overflow], word 0x0000
jnc .loop

.loop1: ;wait for the remainder in ax
call gettime
mov dx, [time+2]
sub dx, [time]
sub ax, dx
jnc .loop1

pop bx
pop ax
ret

.toggle:
not byte [shift]
add [shift], byte 0x02
jmp os

pause2: ;pauses based on dx only, for shorter pauses
push cx
xor cx, cx
call pause
pop cx
ret

pauseran:
push ax
push cx
push dx
xor dh, dh
mov dl, [randint]
mov ah, 0x86 ;set action to wait
mov cx, 0x0002
add cx, dx
mov dx, cx
call pause

.finish:
pop dx
pop cx
pop ax
ret

gettime:
push ax
pushf
cli
xor ax, ax
out 0x43, al
in al, 0x40
xchg al, ah
in al, 0x40
xchg al, ah
xchg ax, [time]
mov [time+2], ax
sti
popf
pop ax
ret

setfreq: ;frequency becomes 1.193182MHz/ax, with 0=65536
cli
out 0x40, al
xchg al, ah
out 0x40, al
xchg al, ah
sti
ret

overflow:
dw 0x0000



shift:
db 0x00