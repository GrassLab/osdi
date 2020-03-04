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
