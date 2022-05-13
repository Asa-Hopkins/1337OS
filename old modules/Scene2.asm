Scene2:
call  cls
mov bx, Scene2S
call printS
call enter
call enter
mov bx, .tut1
call printS
call ent2con
call enter
call enter
mov bx, .tut2
call printS
call ent2con
call enter
mov bx, .tut3
call printS
call ent2con
call enter
call enter
mov bx, .tut4
call printS
call ent2con
call enter
mov bx, .tut5
call printS
call ent2con
call enter
call Fight
jmp $

.tut1:
db "Once again you find yourself surrounded by trees, and you still don't really know where you're going", 0x00
.tut2:
db 'You see a woman walking towards you on the path. You think nothing of it', 0x00
.tut3:
db 'The woman comes closer, she has a laptop in her hand, and is staring at you directly', 0x00
.tut4:
db 'As you are about to pass, your laptop suddenly turns on. The screen is flashing red with the words "Threat Detected".', 0x00
.tut5:
db 'You keep reading the words on the screen. It says "Initiating battle routines". Although the laptop seems ready for battle, you think that you could just punch this woman and be done with it.', 0x00
Scene2S:
db 'Scene 2', 0x00

