[bits 16]
[org 0x7c00]
call diski
call SetCursorPos
mov sp, 0xBC00 ;set up stack
les bx, [os.pointer]
call cls
mov [device], dl
xor ax, ax
call setfreq
call printS
mov cx, 0x20
call pause
;mov [program], byte '7'
;call keys
os:
mov [colour], byte 0x09
mov [program], byte '0'
mov [command], byte '0'
mov [return], word .loop
call cls
cmp [name], byte 0x00
jne .welcome_back

mov bx, .string
call printS
jmp .loop

.welcome_back:
mov bx, .returnS
call printS
call enter

.loop:
call random ;sets randint
call pauseran ; pauses based on randint
xor bh, bh
mov ax, 0x0478 ;move low note
mov bl, [randint] ;multiply by randint
mul bx
mov [note], ax ;note becomes answer, random note

call beep
jmp Uinput

jmp .loop


.string: 
db 'Welcome to 1337 OS', 0x0D,  0x00

.returnS:
db 'Welcome back to 1337 OS, ', 0xFE,0x0D, 0x00

.pointer:
time:
dw image, 0xB800

%include "diskIO.asm" ;read/write to disk
%include "startup.asm" ;opening image
%include "input.asm" ;check for all keys, or singular key.


cursor:
dw 0x0000

rt:
ret

times 510-($-$$) db 0x00
dw 0xaa55

readwrite:

%include "print.asm" ;contains printing, and other screen based stuff
%include "maths.asm" ;more complex mathematical functions that take a few lines
%include "exec.asm" ;takes the input and executes it
%include "wallpaper.asm" ;pretty colours
%include "sound.asm" ;it can beep
%include "Scene1.asm" ;scene 1 of the game
%include "wait.asm" ;waits a moment, must be manual edited at the current time
%include "Save.asm" ;saves the game
%include "paint.asm" ;Paint, an attempt at mouse drivers
%include "keys.asm" ;keyboard driver
%include "pong.asm" ;pong, back for round 2
%include "mouse.asm" ;mouse driver
%include "game.asm" ;An RPG
%include "debug.asm" ;contains debugging tools
;%include "test.asm"
%include "spinner.asm"
%include "Mandelbrot.asm"
;%include "test2.asm"
;%include "load.asm" ;loads the game

times 10240-($-$$) db 0x00
