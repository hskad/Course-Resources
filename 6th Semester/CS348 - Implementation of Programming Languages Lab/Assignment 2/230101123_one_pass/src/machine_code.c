#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "optab.h"

void write_machine_code(unsigned char memory[], int starting_address, char* program_name, int program_length) {
    FILE* inputFile;
    FILE* outputFile;

    // Read from "sample_input.txt"
    inputFile = fopen("text/sample_input.txt", "r");
    if (inputFile == NULL) {
        printf("Error: Cannot open sample_input.txt\n");
        exit(1);
    }

    // Output Generation
    outputFile = fopen("text/output.txt", "w");
    if (outputFile == NULL) {
        printf("Error: Cannot create output.txt\n");
        exit(1);
    }

    char line[100], label[10], mnemonic[10], operand[20];
    int locctr = 0;

    fgets(line, sizeof(line), inputFile); // Skip the START line

    char t_buffer[70] = "";
    int t_len_bytes = 0;
    int t_start_addr = -1;
    locctr = starting_address; // Reset locctr to track our position

    // Header Record
    fprintf(outputFile, "H%-6s%06X%06X\n", program_name, starting_address, program_length);

    while (fgets(line, sizeof(line), inputFile) != NULL) {
        if (line[0] == '.') continue;
        parse_line(line, label, mnemonic, operand);
        if (strcmp(mnemonic, "END") == 0) break;

        int current_code_len = 0;
        if (search_optab(mnemonic) != -1 || strcmp(mnemonic, "WORD") == 0) {
            current_code_len = 3;
        } 
        else if (strcmp(mnemonic, "BYTE") == 0) {
            current_code_len = (operand[0] == 'C') ? (strlen(operand) - 3) : 1;
        }

        if (current_code_len > 0) {
            if (t_len_bytes == 0) {
                t_start_addr = locctr;
            }

            if (t_len_bytes + current_code_len > 30) {
                fprintf(outputFile, "T%06X%02X%s\n", t_start_addr, t_len_bytes, t_buffer);
                t_start_addr = locctr;
                t_len_bytes = 0;
                strcpy(t_buffer, "");
            }

            for (int j = 0; j < current_code_len; j++) {
                char byte_str[3];
                sprintf(byte_str, "%02X", (unsigned char)memory[locctr + j]);
                strcat(t_buffer, byte_str);
            }
            t_len_bytes += current_code_len;
        } 
        else { 
            if (t_len_bytes > 0) {
                fprintf(outputFile, "T%06X%02X%s\n", t_start_addr, t_len_bytes, t_buffer);
                t_len_bytes = 0;
                strcpy(t_buffer, "");
            }
        }

        locctr += (current_code_len > 0) ? current_code_len :
                  (strcmp(mnemonic, "RESW") == 0 ? 3 * atoi(operand) : 
                  (strcmp(mnemonic, "RESB") == 0 ? atoi(operand) : 0));
    }

    if (t_len_bytes > 0) {
        fprintf(outputFile, "T%06X%02X%s\n", t_start_addr, t_len_bytes, t_buffer);
    }

    fprintf(outputFile, "E%06X\n", starting_address);

    fclose(inputFile);
    fclose(outputFile);
}
