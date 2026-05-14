#ifndef SYMTAB_H
#define SYMTAB_H

#include <stdbool.h>

// A node in the linked list used for storing addresses that will be backpatched
typedef struct Node {
    int target_address;
    struct Node* next;
} Node;

// A Symbol Table [SYMTAB] entry
typedef struct {
    char name[10];
    int address;
    bool is_defined;
    Node* fixuplist; // Linked List of addresses that need to be backpatched
} Symbol;

// Function to search for a symbol
// Returns the Symbol pointer, or returns NULL if not found
Symbol* search_symbol(char* name);

// Function to record a forward reference
// Create a symbol if it doesn't exist, otherwise adds locctr to the fixuplist
void add_fixup(char* name, int locctr);

// Function to define a symbol when encountered in the program
// Returns the fixup-list for backpatching
Node* define_symbol(char* name, int address);

// Function to print the symbol table
void print_symtab();

#endif
