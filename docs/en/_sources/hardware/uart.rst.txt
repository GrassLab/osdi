.. _uart:

UART
====

rpi3 has 2 UARTs, mini UART and PL011 UART.

This documentation provides a basic overview and steps to set up them.
Detail descriptions please refer to https://cs140e.sergio.bz/docs/BCM2837-ARM-Peripherals.pdf 

MMIO
----

rpi3 access peripheral registers by memory mapped io (MMIO).

There is a VideoCore/ARM MMU sit between ARM CPU and peripheral bus.
This MMU maps ARM's physical address 0x3f000000 to 0x7e000000.

.. note::
  The register's memory address in reference is bus address, you should translate into physical address.

GPIO
----
rpi3 has several GPIO lines for basic input-output such as light on an LED use button as input.
Besides, some of the GPIO lines provide alternate functions such as UART and SPI.
Before using UART, you should configure GPIO pin to the corresponding mode.

GPIO 14, 15 can be both used for mini UART and PL011 UART.
However, mini UART should set ALT5 and PL011 UART should set ALT0
You need to **configure GPFSELn register to change alternate function.**

Next, you need to **configure pull up/down register to disable GPIO pull up/down**.
It's because these GPIO pins use alternate functions, not basic input-output.
Please refer to the description of **GPPUD and GPPUDCLKn** registers for a detailed setup.

mini UART
---------

mini UART is provided by rpi3's auxiliary peripherals.
It supports limited functions for UART.

**Setup(Lab1)**

1. Set AUXENB register to enable mini UART. 
   Then mini UART register can be accessed.

2. Set AUX_MU_CNTL_REG to 0. Disable transmitter and receiver during configuration.

3. Set AUX_MU_IER_REG to 0. Disable interrupt because currently you don't need interrupt.

4. Set AUX_MU_LCR_REG to 3. Set the data size to 8 bit.

5. Set AUX_MU_MCR_REG to 0. Don't need auto flow control.

6. Set AUX_MU_BAUD to 270. Set baud rate to 115200

   After booting, the system clock is 250 MHz.

.. math::
  \text{baud rate} = \frac{\text{systemx clock freq}}{8\times(\text{AUX_MU_BAUD}+1)}
    
7. Set AUX_MU_IIR_REG to 6. No FIFO.

8. Set AUX_MU_CNTL_REG to 3. Enable the transmitter and receiver.

**Read data**

1. Check AUX_MU_LSR_REG's data ready field.

2. If set, read from AUX_MU_IO_REG

**Write data**

1. Check AUX_MU_LSR_REG's Transmitter empty field.

2. If set, write to AUX_MU_IO_REG

.. note::
  By default, QEMU uses UART0 (PL011 UART) as serial io. 
  If you want to use UART1 (mini UART) use flag ``-serial null -serial stdio``
