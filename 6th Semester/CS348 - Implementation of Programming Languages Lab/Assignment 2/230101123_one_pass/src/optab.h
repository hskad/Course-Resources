#ifndef OPTAB_H // Header Guard
#define OPTAB_H

// Entry in the opcode table [OPTAB]
typedef struct {
    char mnemonic[10];
    int opcode;
} Opcode;

// Function to initialize the OPTAB by reading from "opcodes.txt"
void load_optab();

// Function to search a mnemonic in the OPTAB
// Returns the opcode if found, otherwise returns -1
int search_optab(char* mnemonic);

#endif
