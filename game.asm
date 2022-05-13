gamestart:
mov [command], byte 0x00
mov [char], byte 0x00 ;clear past inputs
mov [program], byte '3' ;set program
mov [return], word .loop
call cls ;clear screen
mov bx, gameS
call printS ;welcome message
call enter

.loop:
mov dx, 0x2000
call pause2
jmp Uinput ;inputs for start/load
jmp .loop


new:
mov [name], byte 0x00
mov [Insults], byte 0x00
mov [char], byte 0x00 ;clear input
jmp Ninput ;call procedure for name input

gameS:
db 'Welcome to the game', 0

Ninput:
call cls ;clears the screen, the game now begins
mov bx, nameS
call printS ;enter your name
mov bx, name ;move bx to name
push bx ;push bx as it's needed multiple times

.do:
call pause2 ;makes sure the inputs aren't horrifically fast
call key ;char now contains last keypress
mov bx, char ;point bx to char
cmp [char], byte 0x00 ;check if there is a character
je .do ;skip if not

cmp [char], byte 0x0D ;if enter
je .name_end ;end input

cmp [char], byte 0x08 ;if not backspace
jne .cont ;continue as normal
pop bx ;else, take bx
sub bx, 0x01 ;take one from the location
mov [bx], byte 0x00
push bx ;put bx back
mov [char], byte 0x00 ;set the character to empty
call backspace ;call screen backspace to edit screen
jmp .do ;go to top of loop

.cont:
call printS ;print
mov ax, [char] ;move the char to ax
pop bx ;get position in name
mov [bx], ax ;set it to char
add bx, 0x01 ;add one
push bx ;store position in name so bx can be reused
mov [command], ax ;make the char the command
mov [char], byte 0x00 ;clear buffer
jmp .do

.name_end:
mov [char], byte 0x00
pop bx ;free the space being used

createChar:
mov bx, StatsS
call printS ;print out stat choices
sub [cursor], word 0xA4 ;set cursor position
call SetCursorPos ;make it visible
.loop:
mov [char+2], byte 0x00 ;clear input
call key ;char+2 now contains scan code
cmp [char+2], byte 0x48
je .up ;if up
cmp [char+2], byte 0x50
je .down ;if down
cmp [char+2], byte 0x4D
je .right ;if right
cmp [char+2], byte 0x4B
je .left ;if left
cmp [char], byte 0x0D
je firstroll
mov [char+2], byte 0x00 ;clear input
call pause2
jmp .loop ;loop

.up: ;moves cursor up a row
cmp [cursor],word 0x128 ;if hit upper limit
jl .loop ;do nothing
sub [cursor], word 0xA0 ;lower row by 1
call SetCursorPos ;make it visible
dec byte [Stats.row]
jmp .loop

.down: ;moves cursor down a row
cmp [cursor],word 0x350 ;lower limit
jg .loop
add [cursor], word 0xA0 ;lower row by 1
call SetCursorPos
inc byte [Stats.row]
jmp .loop

.right: ;If there's unallocated points, then increment the stat corresponding to the current row, decrement points and print both on the screen
test [Points], byte 0xFF
jz .loop
push ax
push bx
xor ah, ah
mov al, [Points]
dec al
das
mov [Points], al
push word [cursor]
mov [cursor], word 0x350+0xA0+0xA0-0x08
call .printdec
pop word [cursor]
mov bx, Charisma
add bx, [Stats.row]
mov al, [bx]
inc al
daa
mov [bx], al
call .printdec
pop bx
pop ax
jmp .loop


.left: ;If there's points in the stat on the current row, then decrement the stat, decrement points and print both on the screen
push ax
push bx
xor ah, ah
mov bx, Charisma
add bx, [Stats.row]
test [bx], byte 0xFF
jnz .notzero ;I feel like there should be a more elegant solution here
pop bx
pop ax
jmp .loop
.notzero:
mov al, [bx]
dec al
das
mov [bx], al
call .printdec
mov al, [Points]
inc al
daa
mov [Points], al
push word [cursor]
mov [cursor], word 0x350+0xA0+0xA0-0x08
call .printdec
pop word [cursor]
pop bx
pop ax
jmp .loop


.printdec: ;prints al where al is in packed Binary Coded Decimal
push ax
push bx
push cx
mov ah, al
and ax, 0xF00F
mov cl, 0x04
or al, 0x30
mov bx, [cursor]
mov [es:bx], al
dec bx
dec bx
shr ax, cl
or ah, 0x30
mov [es:bx], ah
pop cx
pop bx
pop ax
ret

nameS:
db 'Enter your name:', 0



firstroll:
mov [char+2], byte 0x00
mov [cursor], word 0x500 ;set cursor position
mov bx, rollSc ;we're rolling for charisma, c
call printS 
call ent2con ;call procedure for enter to continue
call D20 ;roll a D20, stored in roll
mov [cursor], word 0x530 ;move cursor along sufficiently
mov bx, Charisma ;get charisma stat
call Str2Hex ;in hex, ready for arithmetic
mov cx, 0x0F ;make cx the value needed by someone with 0 charisma
mov ax, [roll]
add [ans], ax ;add stat and roll
call roll2S
call enter
cmp [ans], cx ;compare it to the amount needed
jl .fail;if too low
jge .success;if high enough
.fail:
mov bx, .failS
call printS
call ent2con
mov [Insults], byte 0x01
jmp Scene1
.success:
mov bx, .successS
call printS
call ent2con
popa
jmp Scene1

.failS:
db 'Although your name is ', 0xFE, ' people call you whatever they feel like calling you', 0x00

.successS:
db 'Most people respect you enough to use your real name', 0x00

ent2con:
push bx
push cx
push dx
mov [char], byte 0x00
call enter
mov cx, [cursor]
push cx
.loop:
mov bx, pressenter
call printS
pop cx
mov [cursor], cx
push cx
mov [count], byte 0x30

.input1:
call key
cmp [char+2], byte 0x1C
mov [char+2], byte 0x00
je .cont
mov dx, 0x2000
call pause2
sub [count],  byte 0x01
cmp [count], byte 0x00
jne .input1

mov bx, pressenterf
call printS
pop cx
mov [cursor], cx
push cx
mov [count], byte 0x30

.input2:
call key
cmp [char+2], byte 0x1C
mov [char+2], byte 0x00
je .cont
mov dx, 0x2000
call pause2
sub [count],  byte 0x01
cmp [count], byte 0x00
jne .input2
jmp .loop
.cont:
pop cx
mov bx, pressenterf
call printS
pop dx
pop cx
pop bx
ret

roll2S:
push ax
push bx
push dx
mov ax, [roll] ;move roll to ax
mov dx, 0x00 ;clear dx
mov bx, 0x0A ;move 10 to bx
div bx ;divide
mov [rollS], ax ;move the answer to rollS, digit 1
add [rollS], byte 0x30 ;convert to ascii
mov [rollS+1], dx
add [rollS+1], byte 0x30
mov bx, rollS
call printS
pop dx
pop bx
pop ax
ret

rollS:
db '00', 0x0
StatsS:
db 0x0D, 'Charisma:        ', 0x3C, ' 10 ', 0x3E
db 0x0D, 'Intelligence:    ', 0x3C, ' 10 ' , 0x3E
db 0x0D, 'Strength:        ', 0x3C, ' 10 ' , 0x3E
db 0x0D, 'Wisdom:          ', 0x3C, ' 10 ' , 0x3E
db 0x0D, 'Dexterity:       ', 0x3C, ' 10 ' , 0x3E
db 0x0D, 'Constitution:    ', 0x3C, ' 10 ' , 0x3E
db 0x0D, 'Points Remaining: ', ' 10 ' , 0x00

Charisma:
db 00010000b

Intelligence:
db 00010000b

Strength:
db 00010000b

Wisdom:
db 00010000b

Dexterity:
db 00010000b

Constitution:
db 00010000b

Points:
db 00010000b

Stats.row:
dw 0x0005

Insults:
db 0x00

name:
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
count:
db 0x00

rollSc:
db 'Roll for Charisma', 0

pressenter:
db 'Press enter to continue', 0
pressenterf:
db 0xFD, 0x00,0xFD, 0x00,0xFD, 0x00, 0