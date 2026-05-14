/**
 * Program: Bubble Sort with Pass Matrix Storage
 * Author: Daksh Agarwal
 * Date: 20/01/2026
 * Description: This program reads a list of integers from "input.txt",
 *              sorts them using the Bubble Sort algorithm, stores the
 *              state of the array after each pass in a 2D matrix, and
 *              then prints the resulting matrix to the console.
 */

#include <stdio.h>
#include <stdlib.h>

// Define a maximum size for the array to prevent buffer overflows.
#define MAX_SIZE 100

int main(void) {
    // Declaration of Variables
    int numbers[MAX_SIZE];                 // 1D array to store integers from file and for sorting.
    int passes_matrix[MAX_SIZE][MAX_SIZE]; // 2D array to store the state of 'numbers' after each pass.
    int n = 0;                             // Counter for the number of integers read from the file.
    int i, j, k, temp;                     // Loop counters and a temporary variable for swapping.
    FILE *file;                            // File pointer for reading the input file.

    // --- 1. Read integers from input file ---
    file = fopen("input.txt", "r");
    if (file == NULL) {
        printf("Error: Could not open input.txt\n");
        return 1; // Exit with an error code if file cannot be opened.
    }

    // Read integers into the 'numbers' array until EOF or MAX_SIZE is reached.
    while (n < MAX_SIZE && fscanf(file, "%d", &numbers[n]) == 1) {
        n++;
    }
    fclose(file); // Always close the file after use.

    // Check if any numbers were read.
    if (n == 0) {
        printf("Input file is empty or contains no valid integers.\n");
        return 1;
    }

    // --- 2. Print the initial unsorted array ---
    printf("Input: ");
    for (i = 0; i < n; i++) {
        printf("%d  ", numbers[i]);
    }
    printf("\n\n");
    
    // --- 3. Perform Bubble Sort and store each pass in the matrix ---
    // The outer loop controls the passes. It runs 'n' times as per the assignment's output example.
    for (i = 0; i < n; i++) {
        // The inner loop performs comparisons and swaps for one pass.
        // It bubbles the largest unsorted element to its correct position.
        for (j = 0; j < n - 1; j++) {
            // If the current element is greater than the next one, swap them.
            if (numbers[j] > numbers[j + 1]) {
                temp = numbers[j];
                numbers[j] = numbers[j + 1];
                numbers[j + 1] = temp;
            }
        }

        // After one full pass, store the current state of the 'numbers' array
        // into the i-th row of the 'passes_matrix'.
        for (k = 0; k < n; k++) {
            passes_matrix[i][k] = numbers[k];
        }
    }

    // --- 4. Print the matrix containing all the passes ---
    printf("Passes:\n");
    for (i = 0; i < n; i++) {
        printf("%d:   ", i + 1); // Print pass number (1-based index).
        for (j = 0; j < n; j++) {
            printf("%d ", passes_matrix[i][j]);
        }
        printf("\n");
    }

    return 0; // Indicate successful execution.
}