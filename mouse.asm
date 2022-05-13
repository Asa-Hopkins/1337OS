mouse: ;setup mouse driver
push ax
push bx
push cx
xor ax, ax
mov al,0xa8  
out 0x64,al ;activate auxilliary
call .waitr
call .mpause
in al, 0x60
mov bl, 0xff ;set command
call .send
cmp ax, 0xFA
;jne os ;initialisation failed
call .waitr
call .mpause
in al,0x60 ;should be 0xAA
in al,0x60 ;should be device ID (assuming 0x00 for now)
mov bl, 0xF4
call .send
pop cx
pop bx
pop ax
ret
;No real need to be able to disable the driver



.send: ;send and acknowledge
mov cx, 10
.loop:
call .waitw
mov al,0xd4  ;next byte written goes to mouse
out 0x64, al
call .waitw
mov al, bl
out 0x60, al ;send next byte as data, to mouse
call .waitr
call .mpause
in al, 0x60
cmp al,0xfa 
jz .done   ;zf set on success
loop .loop
.done:
	ret

.mpause: ;pause to allow time
push cx
mov cx,0xa000
.1: loop .1
pop cx

ret

.waitw:
in al, 0x64
and al, 0x02
cmp al, 0x00
jne .waitw
ret

.waitr:
in al, 0x64
and al, 0x01
cmp al, 0x01
jne .waitr
ret
