exec:
push ax
push bx
mov [char], byte 0x00 ;clear buffer
cmp [command], byte 'h'; the help command
jne .action 
mov bx, [program] ;add twice
shl bx, 0x01;
add bx, .help-0x60 ;point bx to start of help array
;take 2*'0' since [program] is a character
mov bx, [bx] ;resolve address
call printS ;print help message
call enter ;new line
jmp .end 

.action:

cmp [command], byte '1' ;command <1 aren't allowed
jl .end
mov bx, [program]
shl bx, 0x01
add bx, .programs-0x60 ;point bx at programs array

mov ax, [bx+2] ;get the value of the next item in the array
mov bx, [bx] ;resolve address
sub ax, bx ;this gives the distance between arrrays in bytes
shr ax, 1 ;bytes to words
add ax, '0' ;to string
cmp al, [command] ;compare to [command]
jl .end ;if command is greater or equal to it is out the range of the array and not a valid command for this program

add bx, [command] ;add [command] words to bx
add bx, [command]
sub bx, 0x62 ;take 2*'1' since commands begin at 1 (should probably change this)
mov bx, [bx] ;resolve address
mov [return+2], bx ;save address for jumping
pop bx  ;restore registers
pop ax
jmp word [return+2] 

.end: ;restore addresses, jump to [return]
pop bx
pop ax 
jmp word [return]

.programs:
dw .os, .piano, .wallpaper, .game, .paint, .pong, .array 

.os:
dw piano, .off, wallpaper, gamestart, keys, keys, pause.toggle

.piano:
dw .quit

.wallpaper:
dw .quit

.game:
dw new, save, .quit

.paint:
dw .quit

.pong:
dw .quit

.array:

.off: ;turn off command, should probably be put elsewhere
mov [command], byte 0x00
mov [program], byte '0'
mov [char], byte 0x00
call disko
mov ax, 0x5301; Function 5301h: APM Connect real-mode interface
xor bx, bx; Device ID: 0000h (= system BIOS)
int 0x15; Call interrupt: 15h

mov ax, 0x530E; Function 530Eh: APM Driver version
mov cx, 0x0102; Driver version: APM v1.2
int 0x15; Call interrupt: 15h

mov ax, 0x5307; Function 5307h: APM Set system power state
mov bl, 0x01; Device ID: 0001h (= All devices)
mov cx, 0x0003; Power State: 0003h (= Off)
int 0x15; Call interrupt: 15h 
jmp .quit

.quit: ;return to os
pop bx
pop ax
jmp os

.help:
dw .helpOS, .helpPiano,.helpPaint,.helpGame, .helpPaint
.helpOS:
db 0x0D, 'enter 1 for piano', 0x0D, 'enter 2 for off, and saves the game', 0x0D, 'enter 3 for wallpaper', 0x0D, 'enter 4 for game', 0x0D, 'enter 5 for paint', 0x0D, 'enter 6 for pong', 0x0D, 'enter 7 to toggle pause durations', 0x0D, 'enter h for help with any program', 0
.helpPiano:
db 0x0D, 'Press a key and produce a tone', 0x0D, 'Enter 1 to quit', 0
.helpGame:
db 0x0D, 'enter 1 for new game, 2 to save your progress and the computer state. enter 3 to exit', 0
.helpPaint:
db 0x0D, 'enter 1 to exit', 0
command:
db 0x00, 0x00
program:
db '0', 0x00
return:
dw 0x0000, 0x0000