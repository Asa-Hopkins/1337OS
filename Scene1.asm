Scene1:
call  cls
mov bx, Scene1S
call printS
call enter
call enter
mov bx, .intro
call printS
call ent2con
call enter
mov bx, .intro2
call printS
call ent2con
call enter
mov bx, .intro3
call printS
call ent2con
call enter
call enter
mov bx, .intro4
call printS
call ent2con
call enter
mov bx, .intro5
call printS
call ent2con
call enter
call enter
mov bx, .intro6
call printS
call ent2con
call enter
call enter
mov bx, .intro7
call printS
call ent2con
call enter
mov bx, .intro8
call printS
call ent2con
call enter
call enter
mov bx, .intro9
call cls
call printS
call ent2con
call enter
mov bx, .intro10
call printS
call ent2con
call enter
mov bx, .intro11
call printS
call ent2con
call enter
mov bx, .intro12
call printS
call ent2con
call enter
call enter
mov bx, .intro13
call printS
call ent2con
call enter
mov bx, .intro14
call printS
call ent2con
call enter
mov bx, .intro15
call printS
call ent2con
call enter
call enter
mov bx, .intro16
call printS
call ent2con
call enter
call enter
call cls
mov bx, .intro17
call printS
call ent2con
call enter
push ax
push bx
push dx
mov dx, 0x2000
jmp ChooseOS ;choose OS
.cont:
call enter
call enter
mov bx, .intro18
call printS
call ent2con
call enter
mov bx, .intro19
call printS
call ent2con
call enter
mov bx, .intro20
call printS
call ent2con
call enter
mov bx, .intro21
call printS
call ent2con
call enter
call enter
mov bx, .intro22
call printS
call ent2con
call enter
call enter
mov bx, .intro23
call printS
call ent2con
call enter
mov [Scene], byte 0x02
jmp save

.intro:
db 'You suddenly gain consciousness and self-awareness. You look around, you are mostly surrounded by trees. You spot a clearing, and walk towards it.', 0x00

.intro2:
db 'Once in the clearing, you see a singular building. You seem to recall that people often reside in buildings, so you decide to knock on the door.', 0x00

.intro3:
db 'You wait for a few moments, and then a man opens the door. He speaks before you have a chance to.', 0x00

.intro4:
db 0xFF,0x07,"Man:", 0xFF,0x09,"Oh, you're finally here. I've been waiting for ages, come in.", 0x00

.intro5:
db 0xFF,0x07,"You:", 0xFF,0x09, "You've been expecting me?", 0x00

.intro6:
db 0xFF,0x07,"Man:", 0xFF,0x09,"Yes, you were supposed to be here hours ago. Now, I need to see your beta testing badge.", 0x00

.intro7:
db 0xFF,0x07,"You:", 0xFF,0x09,"I don't have one, I don't think I'm the person you're after.", 0x00

.intro8:
db 0xFF,0x07,"Man:", 0xFF,0x09,"Hmm, then why are you here?", 0x00

.intro9:
db 0xFF,0x07,"You:", 0xFF,0x09,"I'm lost, I was going to ask for directions.", 0x00

.intro10:
db 0xFF,0x07,"Man:", 0xFF,0x09,"Well, I could help you, but I still need a beta tester for this new processor, so how about we make a deal? I'll give you this motherboard and processor, and in return I'll give you directions.", 0x00

.intro11:
db 'That seems completely weighed in your favour.', 0x00

.intro12:
db 0xFF,0x07,"You:", 0xFF,0x09,"Seems fair to me.", 0x00

.intro13:
db 'You receive a motherboard, with an unknown processor in the socket. You notice a lack of RAM and hard disk, among other things.', 0x00

.intro14:
db 0xFF,0x07,"You:", 0xFF,0x09,"You know this won't be able to run right?", 0x00

.intro15:
db 0xFF,0x07,"Man:", 0xFF,0x09,"Well, the actual beta tester was supposed to have the other parts, but I'll see what I can find.", 0x00

.intro16:
db 'The man walks off to another room searching for parts. You decide to search through the bag that you are carying. By some miracle you produce a stick of RAM from the bag.', 0x00

.intro17:
db 0xFF,0x07,"Man:", 0xFF,0x09,"All I could find was this corrupted hard drive, I'll need to install an OS for you. So which one do you want?", 0x00

.intro18:
db 0xFF,0x07,"Man:", 0xFF,0x09,"Ok, I have that installing, now for some RAM.", 0x00

.intro19:
db 0xFF,0x07,"You:", 0xFF,0x09,"I have some here, Now we just need a way for me to interact with it...", 0x00

.intro20:
db 0xFF,0x07,"Man:", 0xFF,0x09,"I've got an old laptop we can destroy, that'll provide power and peripherals. Now, for those directions I promised. Go that way through the forest, along the path, and eventually you'll get to a city.", 0x00

.intro21:
db 'You wait for your OS to install', 0x00

.intro22:
db 0xFF,0x07,"Man:", 0xFF,0x09,"Here you go, I added a few basic programs, should be powerful enough to get you through the forest", 0x00

.intro23:
db 'You thank the man and leave, disregarding his final confusing statement. You find the path he was referencing, and continue down it', 0x00

ChosenOS:
db 0x00

ChooseOS:

call key
push word [cursor]
xor bh, bh
mov bl, [ChosenOS]
shl bl, 0x01
mov bx, [bx+.addresses]
mov [bx+1], byte 0x09

cmp [char+2], byte 0x4E ;right key
adc [ChosenOS], byte 0x00
cmp [char+2], byte 0x4C ;left key
salc
shl al, 0x01
add [ChosenOS], al
cmp [char+2], byte 0x4B
adc [ChosenOS], byte 0x00
and [ChosenOS], byte 0x03

xor bh, bh
mov bl, [ChosenOS]
shl bl, 0x01
mov bx, [bx+.addresses]
mov [bx+1], byte 0x07

mov bx, OSfamily1
call printS
call pause
pop word [cursor]

cmp [char+2], byte 0x1C
mov [char+2], byte 0x00
jne ChooseOS
pop bx ;since we pushed cursor earlier
pop dx
pop bx
pop ax
jmp Scene1.cont

.addresses:
dw OSfamily1, OSfamily2, OSfamily3, OSfamily4

OSfamily1:
db 0xFF,0x09,'Apple-DOS',0xFD, 0x00
OSfamily2:
db 0xFF,0x09,'MS-DOS',0xFD, 0x00
OSfamily3:
db 0xFF,0x09,'UNIX seventh edition',0xFD, 0x00
OSfamily4:
db 0xFF,0x09,'1337 OS', 0x00

OSfamily:
db 0x01, 0x00

OSgen:
db 0x01, 0x00






; The order of variables is RAM, RAMusage, Health, MaxHealth, RWspeed, EHP, EMaxHP, ERAM, ERAMusage, Ename
GameVars:
db '04', 0x00

db '00', 0x00

db '10', 0x00

db '10', 0x00 

db '01', 0x00

db '10', 0x00

db '10', 0x00

db '04', 0x00

db '00', 0x00

db 'Middle Aged Woman', 0x00





Scene:
db 0x00, 0x00

Scene1S:
db 'Scene 1', 0x0

insults_list:
dw .moron, .wimp, .weakling, .gayboi, .nobend, .cripple, .ape, .fat, .git, .waste, 0x00

.moron:
db 'moron', 0x00

.wimp:
db 'wimp', 0x00

.weakling:
db 'weakling', 0x00

.gayboi:
db 'gayboi', 0x00

.nobend:
db 'nob end', 0x00

.cripple:
db 'cripple', 0x00

.ape:
db 'dirty ape', 0x00

.fat:
db 'fatboy', 0x00

.git:
db 'git', 0x00

.waste:
db 'waste of space', 0x00

;physical:
;dw .punch, .kick, 0x00

;virtual:
;dw .mash, .paint, 0x00