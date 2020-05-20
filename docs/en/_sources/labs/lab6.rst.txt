====================
Lab 6 : Allocator
====================

************
Introduction
************

In all previous labs, you implement a static memory allocator for each class of objects.
You may partition a huge amount of memory for one class of objects without actually allocating it.
Therefore, the kernel wastes part of the memory. 
Also, for general-purpose OS, the amount of memory and the maximum objects users need are unknown at compile time.
Hence, a dynamic memory allocator is necessary to solve these problems.

.. note::
  Starting from lab 6 to lab 8, the ``required`` part will only run in single thread and you can finish these labs 
  without **interrupt**, **multitasking**, and **virtual memory**.

  However, the ``elective`` and ``question`` parts will still related the topics you have done in all previous labs.

*******************
Goals of this lab
*******************

* Understand how to design a startup memory allocator.

* Implement the buddy system for contiguous page frame allocation.

* Understand how to design an object allocator.

* Replace the original static memory allocator by the new dynamic memory allocator.

************
Background
************

Static vs Dynamic Memory Pool
==================================

Static memory pool 
-------------------------
The memory pool is partitioned on .bss at compile time.
Hence, the amount of usable memory is fixed at runtime.
It's good for a small memory platform or deterministic system.

Dynamic memory pool
-------------------------
The memory pool's location is determined at runtime.

In user programs, the memory pool is usually allocated through system calls. 
Once the memory is used up, the library calls ``brk()`` or ``mmap()`` to gain new virtual memory region.
And the physical memory is allocated when the user access the region and the kernel will create the page mapping.

In kernels, memory pools are usually in the form of contgnuous page frame.
Once, the memory is used up, the kernel allocates another contiguous page frame.

Fixed vs Varied Sized Allocator
=================================

A memory pool is a big memory region, the memory allocator needs to cut the pool into chunks for each allocation call.

For typed programming language, the size of an object is known and the allocator can allocate the size fit to the object to reduce external fragmentation.
However, each class of object needs its memory pool in the fixed-sized allocator.
If the object is seldom used, there is internal fragmentation.

Hence, varied-sized allocators such as ``malloc()`` keep the record of each allocated data chunk's size to support varied length allocation.

Memory Pool Allocator vs Object Allocator
=========================================
In user programs, the memory pool is usually allocated through system calls. 
Hence, even the library doesn't need to worry about how to get or expand its memory pool.
It only needs to take care of how to bookkeep the use of the memory pool and the allocated chunks. 

In kernels, the memory pool allocation should be done itself and usually by page allocator.
In the last lab, you already implement a simple page allocator.
In this lab, you'll implement the :ref:`buddy` for page allocation to create memory pools with different sizes.

With a memory pool, objects can be allocated from it.
You should design your :ref:`alloc` in this lab. 

Observability of Allocators
============================

Comparing to previous labs, the internal state of the memory allocator is hard to be observed and hence hard to demo.
To check the correctness of your allocator, you need to **print the log of each allocation and free**.

.. note::
  TAs will verify the correctness by these logs in demo.

*********
Required
*********

Before Requirements
===================
General-purpose kernels don't know how many page descriptors should be statically allocated at compile-time because users may change the hardware.
Hence, it needs a startup allocator for dynamically allocating the page's descriptor array.

However the size of rpi3's physical memory is a known fact,
Therefore, we left the :ref:`startup_alloc` as elective but you can still start from implementing it.


.. _buddy:

Buddy System
=============

Buddy system is a well-known and simple algorithm for allocating memory block but with the internal fragmentation problem.
But, it's still suitable for page allocation because the internal fragmentation problem can be solved by object allocator.
We provide one possible implementation in the following part.
You can still devise it yourself as long as you follow the specification of the buddy system allocator.

``required 1`` Implement the buddy system for contiguous pages allocation.

``question 1`` Is buddy allocator perfectly eliminate external fragmentation? If yes, prove it? If no, give an external fragmentation example.

.. note::
  * **page allocation** here means page frame (physical memory) allocation. It means the allocation unit is 4KB.

  * You don't need to handle the out-of-memory failure, just return NULL and print the failed log.


Search for a proper block
--------------------------

The user provides the block size as arguments to buddy allocator.
The buddy allocator should find a large enough block in the buddy system.

You can implement it by :ref:`linkedlist` and :ref:`release_redu`

.. _linkedlist:

Linked-lists for blocks with different size
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Buddy system is allocated by the power of 2.
You can set a maximum order and create one linked-list for each order.
The linked-list links free block with the same size.
The buddy allocator's search starts from the specified block size list.
If the list is empty, it tries to find a larger block in the higher-order block list
If there are no more contiguous page frames in the higher-order block list, it returns NULL.

.. _release_redu:

Release redundant memory block
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The above algorithm may allocate one block far larger than the required size.
The allocator will cut off the bottom half the block and put it back to the buddy system until the size equals to the required size.

.. note::
  You should print the log of releasing redundant memory block for demo

Coalesce the free block
--------------------------
To make the buddy system contains larger contiguous memory blocks.
When the user frees the allocated memory block, the buddy allocator should not naively put it back to the linked-list.
It should try to :ref:`find_buddy` and try to :ref:`merge_iter`.

.. _find_buddy:

Find the buddy
^^^^^^^^^^^^^^
The page frame number(PFN) and the block size order can be used to find the page frame's buddy.
For example, if a memory block's PFN is 8 and the block size is 16KB (order = 2) you can find its buddy by
0b1000 xor 0b100 = 0b1100 = 12.

However, **it's not guaranteed that the buddy's page descriptor you get in the buddy system**.
Even it's in the buddy system, it's block size may not be the same as the free one because the tail of it may be allocated.
Hence, you need to check that the buddy descriptor you found is in the buddy system and the size is the same as the free one.
If it's indeed a buddy, you can merge them into one block.


.. _merge_iter:

Merge iteratively
^^^^^^^^^^^^^^^^^
There is still a possible buddy for the merged block.
You should use the same way to find the buddy of the merge block.
When you can't find the buddy of the merged block or the merged block size is maximum-block-size, 
the allocator stops and put the merged block to the linked-list.

.. note::
  You should print the log of merge iteration for demo.

.. _alloc:

Object Allocator
==================

Page allocator is your memory pool allocator. 
Now, you can implement the object allocator.
You need to implement both fixed-sized allocator and varied-sized allocator.

Fixed-sized allocator
---------------------

Registration
^^^^^^^^^^^^^

The fixed-size allocator cut the memory pool into chunks with the size the same as the size of the object.
Hence, you need to provide an API for users to register the allocator for certain object classes. 
And the API returns a token to the caller.
With the token, the user can ask the allocator to allocate one object from the corresponding pool for that class.

``required 2-1`` Implement the API for register a fixed-size allocator.

Allocate 
^^^^^^^^^

After the allocator gets one request from the user.
It does the following things.

1. Check the token and find the memory pool.

2. If the memory pool is empty, allocate page frames.

  * Initialize the memory pool for bookkeeping.

3. Find empty slot in the memory pool and return it to user

Free
^^^^^^

The user frees the object by passing the address of the object as an argument to the allocator.
The allocator should look up its internal data structure and put the object to the right pool.

``required 2-2`` Implement the API for allocate and free for fixed-size object.

``question 2`` If the registered object size is 2049 byte, one page frame can only fit in one object. Hence the internal fragmentation is around 50%.
How to decrease the percentage of the internal fragmentation in this case?

.. hint::
  * The prefix of the address of the allocated object will be the PFN of the memory pool that allocated the object.
    You can look up the memory pool by it.

  * The bookkeeping of memory pool can be done by either list or bit array.

Varied-sized allocator
-----------------------

In some cases, an object should be dynamically allocated but it's not frequently used.
It's wasteful to prepare a dedicated memory pool for it.
Also, an untyped allocator is easier to use.

The implementation of varied-sized allocator can be simply as create several fixed-sized allocators.
The varied-sized allocator works as a proxy of page allocator and fixed-sized allocator. 
If the allocated size is very big, it calls page allocator directly to allocate contiguous page frames.
Otherwise, it rounds up the allocated size to one of the registered allocators and uses the token to the fixed-sized allocator.

``required 3`` Implement a varied-sized allocator.

***********
Elective
***********

.. _startup_alloc:

Startup allocator
===================

The dynamic allocator relies on the page allocator.
The page allocator relies on the page array.
The page array relies on dynamic allocation at runtime.

Then it introduces the chicken or the egg problem.
To break the dilemma, you need a dedicated allocator for the startup time allocation.

In the early stage of booting, the kernel can get the amount of RAM and the memory hole through the message from the device tree, BIOS, ACPI, or bootloader.
Then, the physical memory can be divided into several large regions.
The startup allocator can simply bookkeep the information of the region's start and end. 
Then it can use a small amount of memory to describe a huge amount of physical memory.

Again, it needs descriptors for bookkeeping.
You can statically allocate a small size descriptors' array.
And the array can grow up at runtime by recording and allocating a larger array in the old array.
Then copy the information to the new array.
Therefore, it can bootstrap to manage all region's information. 

``elective 1`` Implement the startup allocator.

Refactor your code
====================

With the dynamic allocator, you can depreciate your legacy static memory allocator.
Hence, the .bss section size should be relatively small.
You should use ``nm --size-sort -S kernel8.elf | grep -i " b "`` to check your .bss
The largest one should not be greater than 1KB.

``elective 2`` Replace the static memory allocator with the dynamic memory allocator in your kernel.

``question 3`` What's the benefit to prevent static allocation?
