#ifndef SYMTAB_H
#define SYMTAB_H

// Entry in the symbol table [SYMTAB]
typedef struct {
    char label[10];
    int address;
} Symbol;

// Function to insert a symbol into the SYMTAB
// Will print an error if a symbol is duplicate
void insert_symtab(char* label, int address);

// Function to search the SYMTAB for the input label
// Returns the address if found, otherwise returns -1
int search_symtab(char* label);

void print_symtab();

#endif
