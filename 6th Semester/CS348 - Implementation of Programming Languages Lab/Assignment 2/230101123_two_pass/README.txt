Two-Pass Assembler for SIC/XE Architecture
==========================================

Author
------
Name: Daksh Agarwal
Roll No: 230101123

Description
-----------
This program implements a standard two-pass assembler in C.
- Pass 1: Generates the Symbol Table (SYMTAB) and an Intermediate File.
- Pass 2: Generates the Object Code using the SYMTAB and Opcode Table (OPTAB).

Project Structure
-----------------
The project is organized into the following directories:

1. src/ (Source Code):
   - main.c       : Main driver containing Pass 1 and Pass 2 logic.
   - optab.c/.h   : Implementation of the Opcode Table.
   - symtab.c/.h  : Implementation of the Symbol Table.

2. text/ (Input and Output Files):
   - sample_input.txt : The assembly source code to be assembled.
   - opcodes.txt      : List of mnemonics and their machine opcodes.
   - intermediate.txt : (Generated) The source program with assigned addresses.
   - output.txt       : (Generated) The final Object Program.

3. Root Directory:
   - Makefile     : Script to compile, run, and clean the project.
   - assembler    : The executable (generated after compilation).

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
After running the program, the following files are generated in the 'text/' folder:

1. text/intermediate.txt : The output of Pass 1.
2. text/output.txt       : The final object code (H, T, and E records).
