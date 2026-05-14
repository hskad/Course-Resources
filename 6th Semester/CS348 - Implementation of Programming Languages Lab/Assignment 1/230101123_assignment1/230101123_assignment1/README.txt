========================================================================
                      32-BIT ASSEMBLY ASSIGNMENT
                         Roll No: 230101123
========================================================================

SYSTEM REQUIREMENTS:
--------------------
1. OS: Linux (Ubuntu)
2. Assembler: NASM (Netwide Assembler)
3. Compiler: GCC (GNU Compiler Collection)
4. Libraries: 32-bit support libraries (gcc-multilib)

   To install prerequisites on Ubuntu:
   $ sudo apt-get update
   $ sudo apt-get install nasm gcc gcc-multilib

FILE LIST:
----------
1. 230101123_seta.asm   - Document character search (Pure Assembly, System Calls)
2. 230101123_setb1.asm  - K-th largest floating point number (Uses C Library)
3. 230101123_setb2.asm  - Matrix Inversion (Augmented Matrix) (Uses C Library)
4. Makefile             - Automated build script

COMPILATION & EXECUTION:
------------------------
A Makefile is provided to automate assembling and linking.

1. Build All Files:
   $ make

2. Build Individual Files:
   $ make seta
   $ make setb1
   $ make setb2

3. Run Programs:
   $ make run_a       (Runs Set A: Document Search)
   $ make run_b1      (Runs Set B1: Float Sort)
   $ make run_b2      (Runs Set B2: Matrix Inverse)

CLEAN UP:
---------
To remove all object files (.o) and executables:
   $ make clean

NOTES:
------
- All code is written for 32-bit x86 architecture.
- Set B files are linked with GCC to utilize printf/scanf for floating-point I/O.
- If running on a 64-bit machine, the Makefile flags (-m32, -m elf_i386) handle the compatibility.
