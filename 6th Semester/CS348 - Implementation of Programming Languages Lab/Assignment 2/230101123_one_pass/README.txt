One-Pass Assembler for SIC/XE Architecture
==========================================

Author
------
Name: Daksh Agarwal
Roll No: 230101123

Description
-----------
This program implements a one-pass assembler in C for the SIC/XE architecture.
It processes the source code in a single pass, generating machine code directly into an in-memory buffer. Forward references (references to labels defined later in the code) are handled using a backpatching technique with linked lists.

An intermediate file is not created, which is a key feature of one-pass assembly.

Project Structure
-----------------
The project is organized into the following directories:

1. src/ (Source Code):
   - main.c           : Main driver containing the one-pass assembly loop and backpatching logic.
   - optab.c/.h       : Implementation of the Opcode Table (reused).
   - symtab.c/.h      : Stateful Symbol Table with linked lists for handling forward references.
   - machine_code.c/.h: Handles the final generation of the object file (H, T, E records) from the memory buffer.

2. text/ (Input and Output Files):
   - sample_input.txt : The assembly source code to be assembled.
   - opcodes.txt      : List of mnemonics and their machine opcodes.
   - output.txt       : (Generated) The final Object Program.

3. Root Directory:
   - Makefile         : Script to compile, run, and clean the project.
   - assembler        : The executable (generated after compilation).

How to Compile and Run
----------------------
This project uses a Makefile for easy compilation.

1. To Compile:
   $ make

2. To Run:
   $ make run

3. To Clean (remove executable and generated output files):
   $ make clean

Outputs
-------
After running the program, the following file is generated in the 'text/' folder:

1. text/output.txt : The final object code (H, T, and E records).
