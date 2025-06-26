# Assembly OS V0.3
Assembly os is os made entirely in assembly.

![image](https://github.com/user-attachments/assets/68ddaa2a-6405-4ab4-909a-ec4a49978ce7)

Video Showcase (V0.1): https://www.youtube.com/watch?v=9uRwTcXG23M

# Dependencies

- nasm
- qemu
- make (optional)

# How to use

```
make
make run
```

or download assembly_os.img and run

```
qemu-system-i386 -drive file=assembly_os.img,format=raw,index=0,if=floppy
```

# Credits

Creator: sixpennyfox4

Inspired By: MikeOS (https://mikeos.sourceforge.net/)
