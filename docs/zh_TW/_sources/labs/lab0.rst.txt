=========================
Lab 0: Environment Setup
=========================

Introduction
=============
The first step of creating a masterpiece is preparing the tool.
You're going to implement a 64-bit kernel on ARM CPU.
Hence, you need a toolchain to help you finish the jobs.

In this lab, you'll set up the working environment for future development.

Goals of this lab
=================

* Understand cross-platform development.

* Setup the working environment.

* Test your hardware.

.. note::
  This lab is an introductory lab, it won't be taken as part of your final grade.
  But you still need to do the ``required`` stuff, or you'll be in trouble in the next lab.

Cross-platform development
==========================

Cross compiler
---------------
rpi3 uses ARM Cortex-A53 CPU.
You need a cross-compiler either using C/C++/Rust.

``required`` Install the cross compiler on your host computer.

``question`` What's the RAM size of Raspberry Pi 3B+?

``question`` What's the cache size and level of Raspberry Pi 3B+?

.. note:: You're doing 64-bit programming, make sure you choose the right cross compiler.

Bare Metal Programming
----------------------
Some features and standard library of a programming language rely on operating system support.
Hence you cannot naively use them.

Also, you should set the corresponding compiler flags to generate correct code.

Linker
-------
You might not notice the existence of linker.
It's because the compiler uses the default linker script for you. (``ld --verbose`` to check the content)
But in bare metal programming, you should set the memory layout yourself.

This is an incomplete linker script for you, you should extend it in the following lab.

.. code-block:: none
  :linenos:

  SECTIONS
  {
    . = 0x80000;
    .text : { *(.text) }
  }
  
``question`` Explain each line of the above linker script.

QEMU
-----------
In cross-platform development,
it's easier to validate on emulators first to get better control.
You can use QEMU to test your code first before validating them on your real rpi3.

.. warning:: 
  Although QEMU provides a machine option for rpi3, it doesn't act the same as real rpi3.
  You should validate your code on rpi3, too.

``required`` Install ``qemu-system-aarch64`` as an emulator for rpi3.

From source code to kernel image
=====================================

You have the basic knowledge of the toolchain for cross-platform development.
Now, it's time to practice them.

From source code to object files
--------------------------------

Source code is compiled or assembled to be object file by cross compiler.

.. code-block:: c

  .section ".text"
  _start:
    wfe
    b _start

Assemble the assembly to object file by the following command.

.. code-block:: none

  aarch64-linux-gnu-gcc -c a.S

From object files to ELF
------------------------

Linker links object files to a ELF file
It contains debugging information for debugger.
It also could be load by QEMU and some bootloaders.

Save the provided linker script as linker.ld and run the following command to link the object file.

.. code-block:: none

  aarch64-linux-gnu-ld -T linker.ld -o kernel8.elf a.o


From elf to kernel image
---------------------------

To run your code on real rpi3,
you need to make the elf file a raw binary image.
Also, the default name of it should be kernel8.img.
You can use objcopy to translate elf to raw binary.

.. code-block:: none

  aarch64-linux-gnu-objcopy -O binary kernel8.elf kernel8.img

Check on QEMU
-------------

After building,  you can use QEMU to see the dumped assembly.

.. code-block:: none

  qemu-system-aarch64 -M raspi3 -kernel kernel8.img -display none -d in_asm

``required`` Build your first kernel image and check it by QEMU.


Deploy to REAL rpi3
===================

Flash bootable image to SD card
--------------------------------
To prepare a bootable image for rpi3, you have to prepare at least the following stuff.

* A FAT16/32 partition contains

  * Firmware for GPU

  * Kernel image (kernel8.img)

There are two ways to do it.

1. 
  We already prepared a `bootable image
  <https://github.com/GrassLab/osdi/raw/master/supplement/nctuos.img>`_.
  You can use the following command to flash it to your sd card.

  .. code-block:: none

    dd if=nctuos.img of=/dev/sdb

  .. warning:: /dev/sdb should be replaced by your sd card device, you can check it by `lsblk`

  It's already partition and contains a FAT32 filesystem with firmware inside.
  You can mount the partition to check.

2. 
  Partition the disk and prepare the booting firmware yourself.
  You can download the firmware from 
  https://github.com/raspberrypi/firmware/tree/master/boot

  bootcode.bin, fixup.dat and start.elf are essentials.
  More information about pi3's booting could be checked on official website
  https://www.raspberrypi.org/documentation/configuration/boot_folder.md
  https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/README.md

  Finally, put firmware and your kernel image into the FAT partition.

  .. note::
    Besides using mkfs.fat -F 32 to FAT32 you should also set the partition type.


``required`` Use either one of the methods to set up your sd card.

Interact with rpi3
------------------
Use the provided `kernel8.img <https://github.com/GrassLab/osdi/raw/master/supplement/kernel8.img>`_ and connect TX, RX, GND to the corresponding pin on rpi3.
After power on, you can read and write data from /dev/ttyUSB0 (Linux).
You can use putty or screen with baud rate 115200 to interact with your rpi3.

.. code-block:: none

  screen /dev/ttyUSB0 115200


Debugging
==========

Debug on QEMU
-------------

Debugging on QEMU is a relatively easy way to validate your code.
QEMU could show the content of memory and registers or expose them to debugger.
You can use the following command waiting for gdb connection.

.. code-block:: none

  qemu-system-aarch64 -M raspi3 -kernel kernel8.img -display none -S -s

Then you can use the following command in gdb to load debugging information and connect to QEMU.

.. code-block:: none

  file kernel8.elf
  target remote :1234

.. note::
  Your gdb should also be cross-platform gdb.


Debug on real rpi3
-------------------

If you'd like to debug on real rpi3, you could either use print log or using JTAG.
We don't provide JTAG in this course, you can try it if you have one.
https://metebalci.com/blog/bare-metal-raspberry-pi-3b-jtag/
