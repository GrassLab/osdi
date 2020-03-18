.. _mailbox:

Mailbox
========

Mailbox is a communication mechanism  between ARM and VideoCoreIV GPU.
You can use it to set framebuffer or configure some peripherals.

We only list the materials needed for the labs.
For details, please refer to https://github.com/raspberrypi/firmware/wiki/Mailboxes

Basics
------

The mailbox mechanism consists of three components mailbox registers, channels, and messages.

**Mailbox registers**

Mailbox registers are accessed by MMIO, we only need Mailbox 0 Read/Write (CPU read from GPU),
Mailbox 0 status (check GPU status) and Mailbox 1 Read/Write(CPU write to GPU)

**Channels**

Mailbox 0 define several channels, but we only use channel 8 (CPU->GPU) for communication.

**Message**

To pass messages by the mailbox, you need to prepare a message array.
Then apply the following steps.

1. Combine the message address (upper 28 bits) with channel number (lower 4 bits) 

2. Check if Mailbox 0 status register's full flag is set.

3. If not, then you can write to Mailbox 1 Read/Write register.

4. Check if Mailbox 0 status register's empty flag is set.

5. If not, then you can read from Mailbox 0 Read/Write register.

6. Check if the value is the same as you wrote in step 1.

.. note::
  Because only upper 28 bits of message address could be passed, the message array should be correctly aligned.

**mailbox address and flags**

.. code-block:: c

  #define MMIO_BASE       0x3f000000
  #define MAILBOX_BASE    MMIO_BASE + 0xb880

  #define MAILBOX_READ    MAILBOX_BASE
  #define MAILBOX_STATUS  MAILBOX_BASE + 0x18
  #define MAILBOX_WRITE   MAILBOX_BASE + 0x20

  #define MAILBOX_EMPTY   0x40000000
  #define MAILBOX_FULL    0x80000000


Tag
---

Mailbox property interface(channel 8, 9) contains several tags to indicate different operations.
You should refer to https://github.com/raspberrypi/firmware/wiki/Mailbox-property-interface
to get detail specifications.

Below, we provide an example to get rpi3's board revision number.

.. code-block:: c

  #define GET_BOARD_REVISION  0x00010002
  #define REQUEST_CODE        0x00000000
  #define REQUEST_SUCCEED     0x80000000
  #define REQUEST_FAILED      0x80000001
  #define TAG_REQUEST_CODE    0x00000000
  #define END_TAG             0x00000000

  void get_board_revision(){
    unsigned int mailbox[7];
    mailbox[0] = 7 * 4; // buffer size in bytes
    mailbox[1] = REQUEST_CODE; 
    // tags begin
    mailbox[2] = GET_BOARD_REVISION; // tag identifier
    mailbox[3] = 4; // maximum of request and response value buffer's length.
    mailbox[4] = TAG_REQUEST_CODE; 
    mailbox[5] = 0; // value buffer
    // tags end
    mailbox[6] = END_TAG;

    mailbox_call(mailbox); // message passing procedure call, you should implement it following the 6 steps provided above.

    printf("0x%x\n", mailbox[5]); // it should be 0xa020d3 for rpi3 b+
  }

Framebuffer
-----------

Rpi3 has a display output which controlled by GPU.
You can set GPU's framebuffer by mailbox to show an image or text on your screen.

There are several items to configure.
I list some of them with brief explanations.
You should experiment in different configurations on real rpi3 to get a better understanding.

* **Allocate buffer:** 
  To get the framebuffer's memory base address. 
  Then you can set pixel's color according to its address.

  .. note::
    The buffer address returned by GPU should be bitwise AND with 0x3fff_ffff.

* **Physical (display) width/height:** 
  The display buffer size.

* **Virtual (buffer) width/height:**
  A portion of framebuffer that sends to display.

* **Virtual (buffer) offset:**
  The virtual buffer's size might be bigger than the display buffer's size, an offset is used to decide which part of the virtual buffer is sent to display.

* **Depth:**
  How many bits to represent a pixel.

* **Pixel order:**
  Pixel order is either RGB or BGR.

* **Get pitch:**
  Pitch is how many bytes stores per horizontal line.
  For drawing k'th row in the screen, you need to skip k times pitch instead of k times display width.
