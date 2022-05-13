save:
push bx
call cls
mov bx, .saveS
call printS
call ent2con
call enter
call disko
jc .fail
mov bx, .success
call printS
pop bx
call ent2con
jmp gamestart

.saveS:
db 'The game will now be saved. Once the game has been saved you may turn off your device', 0x0D, 'If you do not wish to save, power off your device now', 0x00
.success:
db 'Save successful, that is all for now so quitting', 0x00
.failure:
db 'Save failed, quitting. You may retry saving from the menu.', 0x00

.fail:
mov bx, .failure
call printS
call ent2con
pop bx
jmp gamestart