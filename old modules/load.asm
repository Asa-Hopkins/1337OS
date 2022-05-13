load:
cmp [Scene], byte 0x00
jne .Scene
call enter
mov bx, .nosave
call printS
;this will be a check if save data exists. currently there's nothing more to load
ret

.Scene:
cmp [Scene], byte 0x02
je Scene2
jmp $
.nosave:
db 'No save data', 0x00