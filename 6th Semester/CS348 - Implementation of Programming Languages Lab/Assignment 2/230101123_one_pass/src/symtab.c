#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

#define MAX_SYMBOLS 100

Symbol SYMTAB[MAX_SYMBOLS];
int symbol_count = 0;

// Function to search for a symbol
// Returns the Symbol pointer, or returns NULL if not found
Symbol* search_symbol(char* name) {
    for (int i=0; i<symbol_count; i++) {
        if (strcmp(SYMTAB[i].name, name) == 0) {
            return &SYMTAB[i];
        }
    }
    return NULL;
}

// Internal helper function to create a new symbol
Symbol* create_symbol(char* name) {
    if (symbol_count >= MAX_SYMBOLS) {
        printf("Error: SYMTAB is full. Increase MAX_SYMBOLS\n");
        exit(1);
    }

    Symbol* sym = &SYMTAB[symbol_count++];
    strcpy(sym->name, name);
    sym->is_defined = 0;
    sym->address = 0;
    sym->fixuplist = NULL;
    return sym;
}

// Function to record a forward reference
// Create a symbol if it doesn't exist, otherwise adds locctr to the fixuplist
void add_fixup(char* name, int locctr) {
    Symbol* sym = search_symbol(name);

    // If a symbol doesn't exist, create it
    if (sym == NULL) {
        sym = create_symbol(name);
    }

    // Create a new node for the list
    Node* new_node = (Node*)malloc(sizeof(Node));
    if (new_node == NULL) {
        printf("Error: Memory allocation failed\n");
        exit(1);
    }

    // Insert this new node at the head of the fixuplist
    new_node->target_address = locctr;
    new_node->next = sym->fixuplist;
    sym->fixuplist = new_node;
}

// Function to define a symbol when encountered in the program
// Returns the fixup-list for backpatching
Node* define_symbol(char* name, int address) {
    Symbol* sym = search_symbol(name);

    // If symbol is being encountered for the first time
    if (sym == NULL) {
        sym = create_symbol(name);
        sym->is_defined = 1;
        sym->address = address;
        return NULL; // Nothing to backpatch
    }

    if (sym->is_defined) {
        printf("Error: Duplicate Symbol '%s'\n", name);
        exit(1);
    }

    // If it was previously undefined
    sym->is_defined = 1;
    sym->address = address;

    Node* backpatch_list = sym->fixuplist;
    sym->fixuplist = NULL;

    return backpatch_list;
}

// Function to print the symbol table
void print_symtab() {
    printf("\n----------------- SYMBOL TABLE STATUS ------------------\n");
    for (int i = 0; i < symbol_count; i++) {
        printf("%-10s | %s | Addr: %04X | Pending Fixups: ", 
            SYMTAB[i].name, 
            SYMTAB[i].is_defined ? "DEF" : "UNDEF", 
            SYMTAB[i].address);
        
        Node* curr = SYMTAB[i].fixuplist;
        if (curr == NULL) printf("None");
        while (curr != NULL) {
            printf("%04X -> ", curr->target_address);
            curr = curr->next;
        }
        printf("\n");
    }
    printf("--------------------------------------------------------\n");
}
