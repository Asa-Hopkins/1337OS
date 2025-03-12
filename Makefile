os.bin: *.asm
	nasm -f bin -o os.bin os.asm

.PHONY: launch
launch: os.bin
	qemu-system-i386 -drive file=os.bin,index=0,if=floppy,format=raw -audiodev pa,id=snd0 -soundhw pcspk

.PHONY: clean
clean:
	rm -f os.bin
