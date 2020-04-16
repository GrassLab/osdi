The Assembly You Need
======================

Although this is not a course about assembly language,
you still need to write some assembly in bare metal programming.

Here, we provide pieces of assembly code you possibly need.
After copy and paste, you still need to look up the manual to understand how this codes work.


.. note::
  You might still need others to achieve some extra function.
  Please refer to this two manual for more information.
  https://static.docs.arm.com/100898/0100/the_a64_Instruction_set_100898_0100.pdf
  https://static.docs.arm.com/ddi0596/a/DDI_0596_ARM_a64_instruction_set_architecture.pdf
  https://static.docs.arm.com/ddi0487/ea/DDI0487E_a_armv8_arm.pdf


Lab 0
-----

.. code-block:: c
  
  // enter busy loop
  _start:
    wfe
    b _start

Lab 1
-----

.. code-block:: c

  // let core with cpuid != 0 enter busy loop
  _start:
  	mrs x0, mpidr_el1
  	and x0, x0, 3
  	cbz x0, 2f
  1:
  	wfe
  	b 1b
  2:

.. code-block:: c

  // set stack pointer and branch to main function.
  2:
  	ldr x0, = _stack_top
  	mov sp, x0
  	bl main
  1:
  	b 1b

.. code-block:: c

  // read frequency of core timer
  mrs x0, cntfrq_el0

.. code-block:: c

  // read counts of core timer
  mrs x0, cntpct_el0

Lab 2
-----

Lab 3
-----

.. code-block:: c

  // enable interrupt
  msr DAIFClr, 0xf
  // disable interrupt
  msr DAIFSet, 0xf

.. code-block:: c

  // supervisor call with ISS = 1
  svc 1
  // breakpoint with ISS = 1
  brk 1

.. code-block:: c

  // save general registers to stack
  save_all:
    sub sp, sp, 32 * 8
    stp x0, x1, [sp ,16 * 0]
    stp x2, x3, [sp ,16 * 1]
    stp x4, x5, [sp ,16 * 2]
    stp x6, x7, [sp ,16 * 3]
    stp x8, x9, [sp ,16 * 4]
    stp x10, x11, [sp ,16 * 5]
    stp x12, x13, [sp ,16 * 6]
    stp x14, x15, [sp ,16 * 7]
    stp x16, x17, [sp ,16 * 8]
    stp x18, x19, [sp ,16 * 9]
    stp x20, x21, [sp ,16 * 10]
    stp x22, x23, [sp ,16 * 11]
    stp x24, x25, [sp ,16 * 12]
    stp x26, x27, [sp ,16 * 13]
    stp x28, x29, [sp ,16 * 14]
    str x30, [sp, 16 * 15]

  // load general registers from stack
  load_all:
    ldp x0, x1, [sp ,16 * 0]
    ldp x2, x3, [sp ,16 * 1]
    ldp x4, x5, [sp ,16 * 2]
    ldp x6, x7, [sp ,16 * 3]
    ldp x8, x9, [sp ,16 * 4]
    ldp x10, x11, [sp ,16 * 5]
    ldp x12, x13, [sp ,16 * 6]
    ldp x14, x15, [sp ,16 * 7]
    ldp x16, x17, [sp ,16 * 8]
    ldp x18, x19, [sp ,16 * 9]
    ldp x20, x21, [sp ,16 * 10]
    ldp x22, x23, [sp ,16 * 11]
    ldp x24, x25, [sp ,16 * 12]
    ldp x26, x27, [sp ,16 * 13]
    ldp x28, x29, [sp ,16 * 14]
    ldr x30, [sp, 16 * 15]
    add sp, sp, 32 * 8


.. code-block:: c

  // load exception_table to vbar_el2
  ldr x0, =exception_table
  msr vbar_el2, x0
  
  // Simple vector table
  .align 11 // vector table should be aligned to 0x800
  .global exception_table
  exception_table:
    b exception_handler // branch to a handler function.
    .align 7 // entry size is 0x80, .align will pad 0
    b exception_handler
    .align 7
    b exception_handler
    .align 7
    b exception_handler
    .align 7
  
    b exception_handler
    .align 7
    b exception_handler
    .align 7
    b exception_handler
      .align 7
    b exception_handler
    .align 7
  
    b exception_handler
    .align 7
    b exception_handler
    .align 7
    b exception_handler
    .align 7
    b exception_handler
    .align 7
  
    b exception_handler
    .align 7
    b exception_handler
    .align 7
    b exception_handler
    .align 7
    b exception_handler
    .align 7



.. code-block:: c

  from_el2_to_el1:
    mov x0, (1 << 31) // EL1 use aarch64
    msr hcr_el2, x0
    mov x0, 0x3c5 // EL1h (SPSel = 1) with interrupt disabled
    msr spsr_el2, x0
    adr x0, rest_initialization // load exception return address
    msr elr_el2, x0
    adr x0, _stack_top // init sp for el1 option 1
    msr sp_el1, x0
    eret // return to EL1
  rest_initialization:
    adr x0, _stack_top // init sp for el1 option 2
    mov sp, x0
    ...
  load_excepntion_table:
    adr x0, exception_table 
    msr vbar_el1, x0

.. code-block:: c

  #define USER_STACK 0x1000

  from_el1_to_el0:
    mov x0, USER_STACK
    msr sp_el0, x0
    mov x0, 0 // EL0 with interrupt enabled
    msr spsr_el1, x0
    adr x0, shell // return to shell run in EL0
    msr elr_el1, x0
    eret 


Lab 4 
-----

