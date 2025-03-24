# 1337OS
A bootloader program written in NASM Assembly. Not really an OS, but this system acts as a playground for me to code on bare metal.

Started in 2017, this has gone through multiple total rewrites as I've discovered better ways to do things, however I made certain to preserve the rhythmic beeping noises exactly as they were.

I revisit this project periodically to add a new module, and the hours deciphering my own code have taught me many valuable lessons in proper commenting and labeling.

To run in an emulator, I recommend using `qemu` and there is now a makefile with a launch option that tries to use `qemu-i386` if it's available. For usage on real hardware, use `dd` to write `os.bin` to the start of a boot device, and then boot from it as normal. In theory, anything that supports real mode booting should be able to boot it, but in practice my best results are from a Pentium II machine. I get issues on newer hardware, such as a Thinkpad X21, where the beeping would work but the display wouldn't.

Once booted, commands are issued by pressing return, where the previous character pressed is taken as the command to be performed. The command 'h' gives a list of available commands.
