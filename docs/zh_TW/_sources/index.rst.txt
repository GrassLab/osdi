.. nctuos documentation master file, created by
   sphinx-quickstart on Sat Nov 23 15:22:13 2019.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

NCTU, Operating System Design & Implementation, Spring 2020
===========================================================
`中文 <../zh_TW/index.html>`__

This course aims to introduce the design and implementation of the operating system kernel.
You'll learn both concept and implementation from a series of labs.

This course uses `Raspberry Pi 3 Model B+ <https://www.raspberrypi.org/products/raspberry-pi-3-model-b-plus/>`_ (rpi3 for short)
as a hardware platform.
Students can get their hands dirty on a **Real Machine** instead of an emulator.

Labs
----
There are 8 + 1 labs in this course.
You'll learn the concept of **design** of kernel by **implementing** it yourself.

The main point of these labs is the design principle not programming languages.
Hence, you are free to choose any programming languages such as ASM/C/C++/Rust.
However, there are a lot of things which are language dependent and even compiler dependent.
You need to manage them yourself.

We use ``aarch64-linux-gnu-`` toolchain and C to develop.
If you choose other toolchain or programming languages, we might not help you.

There are 3 types of labels appear in each lab.

================== ===========================================================================================
``required``       You're required to implement it by the description, they take up major of your scores.
``elective``       You can implement some of them to get bonus.
``question``       During the demo, you need to answer the question correctly to get full score.
================== ===========================================================================================

.. toctree::
  :caption: Labs
  :hidden:

  labs/lab0
  labs/lab1
  labs/lab2

Hardware
---------
Students who register this course will get a rpi3, a 5.1V 2.5A power supply, a USB-TTL cable, a micro SD card, and an SD card reader.

We don't expect every student to have experience in embedded system or microcontroller.
So, the hardware information needed by labs will be provided.
You can check them when you need them.

Disclaimer
----------
We're not kernel developers or experienced embedded developers.
It's common we made mistakes in the description.
If you find any of them, send an issue to the course github.

.. note::
  This documentation is not well self-contained, you can get more information from external references.

.. toctree::
  :caption: Hardware
  :hidden:

  hardware/asm
  hardware/uart
  hardware/mailbox


.. toctree::
  :caption: Miscs
  :hidden:

  external_reference/index
