#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

#define MAX_SYMBOLS 100

Symbol SYMTAB[MAX_SYMBOLS];
int symbol_count = 0;

// Function to insert a symbol into the SYMTAB
// Will print an error if a symbol is duplicate
void insert_symbol(char* label, int address) {
    if (search_symtab(label) != -1) {
        printf("Error: Duplicate Symbol '%s'\n", label);
        exit(1);
    }

    if (symbol_count < MAX_SYMBOLS) {
        strcpy(SYMTAB[symbol_count].label, label);
        SYMTAB[symbol_count].address = address;
        symbol_count += 1;
    }
    else {
        // If symbol_count reaches MAX, stop inserting further symbols
        printf("Error: SYMTAB is full. Increase MAX_SYMBOLS\n");
        exit(1);
    }
}

// Function to search the SYMTAB for the input label
// Returns the address if found, otherwise returns -1
int search_symtab(char* label) {
    for (int i=0; i<symbol_count; i++) {
        // If symbol is found, return the corresponding address
        if (strcmp(SYMTAB[i].label, label) == 0) {
            return SYMTAB[i].address;
        }
    }
    return -1; // If not found, return -1
}

void print_symtab() {
    printf("\n--- SYMBOL TABLE ---\n");
    // Print addresses in uppercase hexadecimal
    for (int i=0; i<symbol_count; i++) {
        printf("%-10s\t%04X\n", SYMTAB[i].label, SYMTAB[i].address);
    }
    printf("--------------------\n");
}
