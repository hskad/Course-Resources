#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include "optab.h"
#include "symtab.h"
#include "machine_code.h"

#define MEMORY_SIZE 0x8000 // 32KB Memory Size

unsigned char memory[MEMORY_SIZE]; // Virtual memory of the SIC Machine

char program_name[10];
int starting_address;
int program_length;

// Function to parse a line of assembly and break it down into its components
void parse_line(char* line, char* label, char* mnemonic, char* operand) {
    // Initialize them with NULL character
    label[0] = '\0';
    mnemonic[0] = '\0';
    operand[0] = '\0';

    int count = sscanf(line, "%s %s %s", label, mnemonic, operand);

    if (count == 3) {
        // Line has label, mnemonic and operand
        return;
    }
    else if (count == 2) {
        // Line has just mnemonic and operand
        strcpy(operand, mnemonic);
        strcpy(mnemonic, label);
        label[0] = '\0';
    }
    else if (count == 1) {
        // Line has just mnemonic (ex. "RSUB")
        strcpy(mnemonic, label);
        label[0] = '\0';
        operand[0] = '\0';
    }
}

void pass1() {
    FILE* inputFile;
    FILE* outputFile;
    char line[100], label[10], mnemonic[10], operand[20];
    int locctr = 0;

    printf("---STARTING PASS 1---\n");
    printf("\n");

    // Read from "sample_input.txt"
    inputFile = fopen("text/sample_input.txt", "r");
    if (inputFile == NULL) {
        printf("Error: Cannot open sample_input.txt\n");
        exit(1);
    }

    // Read the first line to handle the START mnemonic
    fgets(line, sizeof(line), inputFile);
    parse_line(line, label, mnemonic, operand);

    // If the first mnemonic is START, initialize locctr to starting_address
    if (strcmp(mnemonic, "START") == 0) {
        starting_address = strtol(operand, NULL, 16); // Convert Hex string to Decimal
        locctr = starting_address;
        strcpy(program_name, label);
    }
    else {
        // If no START, we initialize locctr to 0
        // We should handle the first line here but we assume the START would always be present
        locctr = 0;
    }

    while (fgets(line, sizeof(line), inputFile) != NULL) {
        // Ignore if it is a comment
        if (line[0] == '.') {
            continue;
        }

        parse_line(line, label, mnemonic, operand);

        // Break if encounter an END directive
        if (strcmp(mnemonic, "END") == 0) {
            break;
        }

        // Handle label definition
        if (strlen(label) > 0) {
            Node* fixups = define_symbol(label, locctr);

            // Perform BACKPATCHING
            while (fixups != NULL) {
                int target_addr = fixups->target_address;
                
                // Backpatching writes to existing code spots, so flags are already true
                memory[target_addr] = (locctr >> 8) & 0xFF; // High Byte
                memory[target_addr + 1] = locctr & 0xFF; // Low Byte

                printf("Backpatching: Fixed loc %04X with value %04X\n", target_addr, locctr);

                // Free the node and move to next
                Node* temp = fixups;
                fixups = fixups->next;
                free(temp);
            }
        }

        // Handle Instructions and Directives
        if (search_optab(mnemonic) != -1) {
            int opcode = search_optab(mnemonic);
            int operand_addr = 0;

            memory[locctr] = opcode;

            if (strlen(operand) > 0) {
                int is_indexed = 0;
                char sym_name[20];
                strcpy(sym_name, operand);

                // Check for indexed addressing
                if (strstr(sym_name, ",X")) {
                    is_indexed = 1;
                    sym_name[strlen(sym_name) - 2] = '\0'; // Remove ",X"
                }

                Symbol* sym = search_symbol(sym_name);

                if (sym != NULL && sym->is_defined) { // Symbol is known (Backward Reference)
                    operand_addr = sym->address;
                    if (is_indexed) operand_addr |= 0x8000;

                    memory[locctr + 1] = (operand_addr >> 8) & 0xFF;
                    memory[locctr + 2] = operand_addr & 0xFF;
                }
                else { // Symbol is not known (Forward Reference)
                    // Add locctr + 1 to fixuplist
                    add_fixup(sym_name, locctr + 1);

                    int placeholder = is_indexed ? 0x8000 : 0x0000;
                    memory[locctr + 1] = (placeholder >> 8) & 0xFF;
                    memory[locctr + 2] = placeholder & 0xFF;
                }
            }
            else { // No operand (RSUB)
                memory[locctr + 1] = 0;
                memory[locctr + 2] = 0;
            }
            locctr += 3;
        }
        else if (strcmp(mnemonic, "WORD") == 0) {
            int val = atoi(operand);
            memory[locctr] = (val >> 16) & 0xFF;
            memory[locctr + 1] = (val >> 8) & 0xFF;
            memory[locctr + 2] = val & 0xFF;
            locctr += 3;
        }
        else if (strcmp(mnemonic, "BYTE") == 0) {
            if (operand[0] == 'C') {
                for (int i=2; i<strlen(operand)-1; i++) {
                    memory[locctr++] = operand[i];
                }
            }
            else if (operand[0] == 'X') {
                char hex[3] = {operand[2], operand[3], '\0'};
                memory[locctr++] = (int)strtol(hex, NULL, 16);
            }
        }
        else if (strcmp(mnemonic, "RESW") == 0) {
            locctr += 3 * atoi(operand);
        }
        else if (strcmp(mnemonic, "RESB") == 0) {
            locctr += atoi(operand);
        }
    }

    program_length = locctr - starting_address;

    print_symtab();

    write_machine_code(memory, starting_address, program_name, program_length);

    fclose(inputFile);

    printf("\n");
    printf("<Created output.txt>\n");
    printf("\n");
    printf("---PASS 1 COMPLETE---\n");
}

int main() {
    // Function to initialize the OPTAB by reading from "opcodes.txt"
    load_optab();

    // Clear memory with a marker (0x00)
    memset(memory, 0, MEMORY_SIZE);

    printf("===STARTING ASSEMBLER===\n");
    printf("\n");

    pass1();

    printf("\n");
    printf("===ASSEMBLY COMPLETE===\n");
}
