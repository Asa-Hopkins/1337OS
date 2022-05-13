printS: ; 0xFF is colour character, 0xFE is name, 0xFD is space character, 0xD0 to 0xD8 are variables
mov ax,[bx] ;sets ax to a character of the string referenced by bx
cmp al, 0x00 ;is al empty?
je .done ;if so goto finish

cmp al, 0x0D ;is it enter
jne .colour ;if not, continue to next special
call enter ;if so, new line
jmp .next ;coninue along string

.colour:
cmp al, 0xFF
jne .name
inc bx
mov ax, [bx]
mov [colour], al
jmp .next

.name:
cmp al, 0xFE ;is the char 0xfe, set by game?
jne .space
push bx
cmp [Insults], byte 0x00
jne .insult
mov bx, name
call printS
pop bx
jmp .next

.space: ;prints a bit pattern where 1 represents the foreground colour and 0 represents the background colour
cmp al, 0xFD
jne .game
inc bx
jmp space


.game:
cmp al, 0xD0
jl .normal
cmp al, 0xD8
jg .normal
push bx
xor ah, ah ;If I were allowing myself anything beyond the 8086 I'd do lea bx, [ax*2+ax+GameVars-0x270]
mov si, ax
shl ax, 0x01
add si, ax
lea bx, [si+GameVars-0x270]
call printS
pop bx
jmp .next

.insult:
call random
mov bx, insults_list
sub [randint], byte 0x30
shl byte [randint], 0x01 ;as each location is a word, not a byte
add bx, [randint] ;move along randint bytes
mov bx, [bx] ;use the insult at that location
call printS
pop bx
jmp .next


.normal: ;for non-special chars
call printn ;prints

.next:
inc bx ;tries next character
jmp printS ;loops
.done:
ret

printn: 
call columns
push ax
push bx ;save all registers
mov bx, [cursor] ;move cursor to bx, as only bx can be used to reference an address
mov ah, [colour] ; set colour of character to blue
mov [es:bx],ax ;set the bxth character to 
pop bx
pop ax ;load all registers
call SetCursorPos
add word [cursor], byte 0x02 ;goes to next position on screen
ret ;return

columns: ;Some programs bypass printn but still use columns, so I haven't merged the two
cmp [cursor], word 0xFA0
jl .done
call cls
.done:
ret

cls: ;clears the screen
push ax
push cx
push di
xor di, di
mov cx, 0xFA0
mov ax, 0x0900
rep stosw
mov [cursor], word 0x0
call SetCursorPos
pop di
pop cx
pop ax
ret

backspace:
push ax
push bx
push dx ;save all registers
xor dx, dx
mov ax, [cursor]
mov bx, 0xA0
div bx
cmp dx, byte 0x00
je .end
sub word [cursor], byte 0x02
mov bx, [cursor]
mov [es:bx], word 0x00
.end:
pop dx
pop bx
pop ax ;load all registers
call SetCursorPos
ret ;return


enter:
push ax
push bx
push dx
xor dx, dx
mov ax, [cursor]
mov bx, 0xA0
add [cursor], bx
div bx ;divide cursor by rows to get column in dx and row in ax
sub [cursor], dx
call columns
call SetCursorPos
pop dx
pop bx
pop ax
ret

SetCursorPos:
push ax
push bx
push dx
xor dx, dx
mov ax, [cursor]
mov bx, 0xA0
div bx ;divide cursor by rows to get column in dx and row in ax
mov ah, 0x02
xor bh, bh
mov dh, al
shr dl, 0x01
int 10h
pop dx
pop bx
pop ax
ret

space:
push ax
push bx
push cx
mov ch, [bx]
mov cl, 0x08
.loop:
shl ch, 0x01
salc
and al,0xDB
call printn
loop .loop
pop cx
pop bx
pop ax
jmp printS.next

colour:
db 0x09

bitss:
db 0x09