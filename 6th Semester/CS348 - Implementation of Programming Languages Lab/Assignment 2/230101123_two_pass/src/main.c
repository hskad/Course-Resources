#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "optab.h"
#include "symtab.h"

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

// First Pass
void pass1() {
    FILE* inputFile;
    FILE* intermediateFile;
    char line[100], label[10], mnemonic[10], operand[20];
    int locctr = 0;

    printf("---STARTING PASS 1---\n");

    // Read from "sample_input.txt"
    inputFile = fopen("text/sample_input.txt", "r");
    if (inputFile == NULL) {
        printf("Error: Cannot open sample_input.txt\n");
        exit(1);
    }

    // Create a new file names "intermediate.txt"
    intermediateFile = fopen("text/intermediate.txt", "w");
    if (intermediateFile == NULL) {
        printf("Error: Cannot create intermediate.txt\n");
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
        fprintf(intermediateFile, "%04X %s", locctr, line);
    }
    else {
        // If no START, we initialize locctr to 0
        // We should handle the first line here but we assume the START would always be present
        locctr = 0;
    }

    while (fgets(line, sizeof(line), inputFile) != NULL) {
        // Write the line in the intermediate file if it is a comment
        if (line[0] == '.') {
            fprintf(intermediateFile, "     %s", line);
            continue;
        }

        parse_line(line, label, mnemonic, operand);

        // If mnemonic is not END
        if (strcmp(mnemonic, "END") != 0) {
            fprintf(intermediateFile, "%04X %s", locctr, line);

            // If label was present in the line, add it to the SYMTAB
            if (strlen(label) > 0) {
                insert_symbol(label, locctr);
            }

            // Update locctr based on mnemonic
            if (search_optab(mnemonic) != -1) {
                locctr += 3;
            }
            else if (strcmp(mnemonic, "WORD") == 0) { // Initialize a word of 3 bytes
                locctr += 3;
            }
            else if (strcmp(mnemonic, "RESW") == 0) { // Reserve space for 'operand' number of words
                locctr += 3 * atoi(operand);
            }
            else if (strcmp(mnemonic, "RESB") == 0) { // Reserve space for 'operand' number of bytes
                locctr += atoi(operand);
            }
            else if (strcmp(mnemonic, "BYTE") == 0) { // Initialize a byte 
                if (operand[0] == 'C') {
                    locctr += strlen(operand) - 3; // BYTE    C'EOF'
                }
                else if (operand[0] == 'X') {
                    locctr += (strlen(operand) - 3) / 2; // BYTE    X'F1'
                }
            }
            else {
                printf("Error: Invalid mnemonic '%s'\n", mnemonic);
            }
        }
    }

    program_length = locctr - starting_address;

    fprintf(intermediateFile, "%04X %s", locctr, line);

    fclose(inputFile);
    fclose(intermediateFile);

    print_symtab();

    printf("\n");
    printf("<Created intermediate.txt>\n");
    printf("\n");
    printf("---PASS 1 COMPLETE---\n");
}

// Second Pass
void pass2() {
    FILE* intermediateFile; 
    FILE* outputFile;
    char line[100], label[10], mnemonic[10], operand[20], object_code[10];
    int address;
    int text_record_start_addr = 0;
    int text_record_length = 0;
    char text_record[70];

    printf("---STARTING PASS 2---\n");

    intermediateFile = fopen("text/intermediate.txt", "r");
    if (intermediateFile == NULL) {
        printf("Error: Cannot open intermediate.txt\n");
        exit(1);
    }

    outputFile = fopen("text/output.txt", "w");
    if (outputFile == NULL) {
        printf("Error: Cannot create output.txt\n");
        exit(1);
    }

    // Writing the Header Record
    // HCOPY  00100000107A
    fprintf(outputFile, "H%-6s%06X%06X\n", program_name, starting_address, program_length);

    // Initialize the first Text Record
    text_record_start_addr = starting_address;
    strcpy(text_record, "");

    // Read the first START line
    fgets(line, sizeof(line), intermediateFile);

    while (fgets(line, sizeof(line), intermediateFile) != NULL) {
        // Ignore the line if it is a comment
        if (line[0] == '.') continue;

        // Read the address and the rest of the line separately
        char rest_of_line[100];
        int items_read = sscanf(line, "%x %[^\n]", &address, rest_of_line);

        if (items_read == 2) {
            // We found an address and some text and use parse_line
            parse_line(rest_of_line, label, mnemonic, operand);
        }
        else {
            continue;
        }

        object_code[0] = '\0';

        // Stop if found the END
        if (strcmp(mnemonic, "END") == 0) break;

        if (search_optab(mnemonic) != -1) {
            int opcode = search_optab(mnemonic);
            int operand_addr = 0;

            if (strlen(operand) > 0) {
                // Check for indexed addressing
                if (strstr(operand, ",X") != NULL) {
                    operand[strlen(operand) - 2] = '\0'; // Remove ",X"
                    operand_addr = search_symtab(operand);
                    if (operand_addr != -1) {
                        operand_addr |= 0x8000; // Set the index bit
                    }
                }
                else {
                    operand_addr = search_symtab(operand);
                }

                if (operand_addr == -1) {
                    printf("Error: Undefined Symbol '%s'\n", operand);
                    operand_addr = 0;
                }
            }
            sprintf(object_code, "%02X%04X", opcode, operand_addr);
        }
        else if (strcmp(mnemonic, "WORD") == 0) {
            sprintf(object_code, "%06X", atoi(operand));
        }
        else if (strcmp(mnemonic, "BYTE") == 0) {
            if (operand[0] == 'C') {
                for (int i=2; i<strlen(operand)-1; i++) {
                    char hex_val[3];
                    sprintf(hex_val, "%X", operand[i]);
                    strcat(object_code, hex_val);
                }
            }
            else if (operand[0] = 'X') {
                for (int i=2; i<strlen(operand)-1; i++) {
                    object_code[i-2] = operand[i];
                }
                object_code[strlen(operand) - 3] = '\0';
            }
        }

        // Logic for a Text Record
        if (strlen(object_code) > 0) {
            // If the new object code doesn't fit, write the current T record
            if (text_record_length + strlen(object_code) > 60) {
                fprintf(outputFile, "T%06X%02X%s\n", text_record_start_addr, text_record_length/2, text_record);
                text_record_length = 0;
                strcpy(text_record, "");
            }

            // If the buffer is empty, this is the start of a new T record
            if (text_record_length == 0) {
                text_record_start_addr = address;
            }

            strcat(text_record, object_code);
            text_record_length += strlen(object_code);
        } 
        else if (strcmp(mnemonic, "RESW") == 0 || strcmp(mnemonic, "RESB") == 0) {
            // If we encounter a RESW or RESB, finish the current T record
            if (text_record_length > 0) {
                fprintf(outputFile, "T%06X%02X%s\n", text_record_start_addr, text_record_length/2, text_record);
                text_record_length = 0;
                strcpy(text_record, "");
            }
        }
    }

    // Write the last Text Record if it's not empty
    if (text_record_length > 0) {
        fprintf(outputFile, "T%06X%02X%s\n", text_record_start_addr, text_record_length/2, text_record);
    }

    // Write End Record
    fprintf(outputFile, "E%06X\n", starting_address);

    fclose(intermediateFile);
    fclose(outputFile);

    printf("\n");
    printf("<Created output.txt>\n");
    printf("\n");
    printf("---PASS 2 COMPLETE---\n");
}

int main() {
    // Function to initialize the OPTAB by reading from "opcodes.txt"
    load_optab();

    printf("===STARTING ASSEMBLER===\n");
    printf("\n");

    pass1();

    printf("\n");
    printf("\n");

    pass2();

    printf("\n");
    printf("===ASSEMBLY COMPLETE===\n");
}
