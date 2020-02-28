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

