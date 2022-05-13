random:
push ax
push bx
push dx
mov ah,0x00
int 0x1A
mov ax, dx
xor dx, dx
mov bx, 0x000A
div bx
mov [randint], dl
pop dx
pop bx
pop ax
ret

D20:
push ax
push bx
push dx
mov [roll], byte 0x00
mov ah, 0x00
int 0x1A
mov ax, dx
mov dx, 0
mov bx, 0x0015
div bx
mov [roll], word dx
pop dx
pop bx
pop ax
ret
randint:
db 0x00

Str2Hex: ;converts a 2 digit string, pointed to by bx, to hex
push ax
push bx
push cx
mov ax, [bx]
sub ax, 0x30
mov cl, 0x0A
mul cl
mov [ans], ax
mov ax, [bx+1]
sub ax, 0x30
add [ans], ax
mov [ans+1], byte 0x00
pop cx
pop bx
pop ax
ret


parse:
mov bp, sp
xor cx, cx ;Set min precedence
push cx ; pass in min precendence and lhs (both 0)
push cx
call .parse1 ; get result in ax
ret

.parse1: ; lhs in bx, min precedence in cx
push bp
mov bp, sp
sub sp, byte 0x20



lodsb ; ax = lookahead
;get precedence
jc rt



.operands:
db "+-*/%&|^"
db 1,1,2,2,2,3,3,3
;db .add-ops, .sub-ops, .mul-ops, .div-ops, .mod-ops, .and-ops, .or-ops, .xor-ops ; 8 bit addresses relative to .ops

ops: ; combines ax and bx to produce a result in ax




roll:
db 0x00, 0x00

ans:
db 0x0, 0x0, 0x0
