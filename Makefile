all:
	nasm boot.nasm
	nasm kernel.nasm
	cat boot kernel > assembly_os.img

run:
	qemu-system-i386 -drive file=assembly_os.img,format=raw,index=0,if=floppy

clean:
	rm boot
	rm kernel
	rm assembly_os.img