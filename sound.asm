beep:
push ax
push bx
push cx
mov cx, 0x0002
mov     al, 182         ; Prepare the speaker for the
out     43h, al         ;  note.
mov     ax, [note]        ; Frequency number (in decimal)
                  		;  for middle C.
out     42h, al         ; Must output a byte at a time
mov     al, ah
out     42h, al 
in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
or      al, 00000011b   ; Set bits 1 and 0.
out     61h, al         ; Send new value.
mov     bx, 25          ; Pause for duration of note.
call pause
in      al, 61h         ; Turn off note (get value from
                        ;  port 61h).
and     al, 11111100b   ; Reset bits 1 and 0.
out     61h, al         ; Send new value.
pop cx
pop bx
pop ax
ret

note:
dw 0x0

piano:
call cls ;clear the screen
mov bx, pianoS
call printS ;print the welcome message
mov [command], byte 0x00
mov [char], byte 0x00
mov [program], byte '1' ;set the program
mov [return], word piano.loop
.loop:
cmp [command], byte ' '
je Uinput
mov ax, 0x0028 ;move a tone to ax
mov bx, [command] 
mul bx
mov [note], ax
call beep ;play it
jmp Uinput


pianoS:
db 'The Piano', 0x0D, 0x00