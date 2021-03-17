TRS-HARD disk emulator, aka 'FreHD'
===================================

Current release: 2.14

TRS-HARD is my contribution to the TRS80 community. It emulates
genuine Tandy hard drives, with hard drive images stored on a FAT
filesystem, located on a SD-card.

Everything to build the emulator is contained in this archive,
organized in the following directories :

+ hw
  - gal      : equations of the GAL and the compiled jedec file
  - protel99 : pcb source (schematics and pcb), in protel99 format

+ sw/pi      : pic source code and compiled hex file.
  - FatFS  : elm FatFS library, ported to PIC18

+ sw/z80
  - fredhd_rom : source code of the boot menu
  - fredhd_rom/rom-patches : patches for all TRS80 models
  - utils : FreHD utilities


To build the PIC software, you will need Microchip C18 compiler (free)
and MPLab (I used version 8.36). You will also need perl, which is
used to compute the CRC16 used by the bootloader. (If you modify the
source, you need to compile twice, the second time to include the
correct CRC in your hex file).

To build the Z80 code, you need zmac. We are using version 1.3, this
assembler is public domain (by Bruce Norskog and others).

To build the rom patches, you need 'asl'. It is available at:
http://john.ccac.rwth-aachen.de:8000/as/

This project started during the long evenings of December 2012, and I
am very proud to release it to the community today, May 12th 2013. 
Many thanks to Andrew Quinn, who beta-tested and motivated me to
finish this project, or at least make it usable :)

One last thing : you may modify, duplicate, enhance or do whatever you
want with the code. All I ask is to keep this README file. You must
make your modifications available (GPL). If you decide to build and
sell (modified) emulators, all I ask is an emulator for my TRS80, so I
can test your changes.


Enjoy !

-Frederic Vecoven (frederic@vecoven.com)


Last update: Thu Jan 23 15:19:26 2014


!!! github !!!
The code is now available on github. I don't have time to
update/polish the code, so contributions are very welcome.
