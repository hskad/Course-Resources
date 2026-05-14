#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "optab.h"

#define MAX_OPCODES 100

Opcode OPTAB[MAX_OPCODES];
int opcode_count = 0;

// Function to initialize the OPTAB by reading from "opcodes.txt"
void load_optab() {
    // Open "opcodes.txt"
    FILE* file = fopen("text/opcodes.txt", "r");
    if (file == NULL) {
        printf("Error: Cannot open opcodes.txt\n");
        exit(1);
    }

    char mnemonic[10];
    int op_val;

    // Read each line from the file and insert into the OPTAB
    while (fscanf(file, "%s %x", mnemonic, &op_val) == 2) {
        if (opcode_count < MAX_OPCODES) {
            strcpy(OPTAB[opcode_count].mnemonic, mnemonic);
            OPTAB[opcode_count].opcode = op_val;
            opcode_count += 1;
        }
        else {
            // If opcode_count reaches MAX, stop inserting further opcodes
            printf("Error: OPTAB is full. Increase MAX_OPCODES\n");
            break;
        }
    }

    fclose(file);
}

// Function to search a mnemonic in the OPTAB
// Returns the opcode if found, otherwise returns -1
int search_optab(char* mnemonic) {
    for (int i=0; i<opcode_count; i++) {
        // If mnemonic is found, return the corresponding opcode
        if (strcmp(OPTAB[i].mnemonic, mnemonic) == 0) {
            return OPTAB[i].opcode;
        }
    }
    return -1; // If not found, return -1
}
