/**
 * Program: Interactive Quadratic Equation Solver
 * Author: Daksh Agarwal
 * Date: 20/01/2026
 * Description: Solves quadratic equations of the form ax^2 + bx + c = 0.
 *              Supports both direct console input and file input.
 *              Includes robust validation to check if coefficients are numeric
 *              and reports all invalid inputs.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>

/**
 * @brief Checks if a given string represents a valid number (integer or float).
 * @param str The input string to check.
 * @return Returns 1 (true) if the string is numeric, 0 (false) otherwise.
 */
int is_numeric(const char *str) {
    int i = 0;
    int len;
    int decimal_point_count = 0;

    if (str == NULL || str[0] == '\0') {
        return 0; // Invalid if string is null or empty.
    }
    
    len = strlen(str);

    // Allow a single leading sign '+' or '-'.
    if (str[0] == '-' || str[0] == '+') {
        i = 1;
    }
    
    // A string with only a sign is not a valid number.
    if (i == len) {
        return 0;
    }

    // Iterate through the rest of the string.
    for (; i < len; i++) {
        if (str[i] == '.') {
            decimal_point_count++;
        } else if (!isdigit(str[i])) {
            return 0; // Not a digit and not a decimal point.
        }
    }

    // A valid number can have at most one decimal point.
    if (decimal_point_count > 1) {
        return 0;
    }

    return 1; // If all checks pass, the string is numeric.
}

int main(void) {
    // Declaration of Variables
    char a_str[100], b_str[100], c_str[100]; // Buffers to store raw string input for validation.
    double a, b, c, discriminant, x1, x2;   // Variables for numeric coefficients and roots.
    int choice;
    int is_valid_a, is_valid_b, is_valid_c; // Flags for individual input validity.
    int all_inputs_valid = 1;               // Master flag to control the calculation step.
    FILE *file;

    // --- 1. Get user's choice for input method ---
    printf("Select Input Method:\n");
    printf("1: Direct input\n");
    printf("2: File input\n");
    printf("Enter your choice: ");
    scanf("%d", &choice);

    // --- 2. Read coefficients based on user choice ---
    if (choice == 1) { // Direct input from console
        printf("Enter value for a: ");
        scanf("%s", a_str);
        printf("Enter value for b: ");
        scanf("%s", b_str);
        printf("Enter value for c: ");
        scanf("%s", c_str);
    } else if (choice == 2) { // Input from file "coeffs.txt"
        file = fopen("coeffs.txt", "r");
        if (file == NULL) {
            printf("Error: Could not open coeffs.txt\n");
            return 1;
        }
        fscanf(file, "%s %s %s", a_str, b_str, c_str);
        fclose(file);
    } else {
        printf("Invalid choice.\n");
        return 1;
    }
    
    // --- 3. Validate each input string to ensure it is numeric ---
    is_valid_a = is_numeric(a_str);
    is_valid_b = is_numeric(b_str);
    is_valid_c = is_numeric(c_str);

    // Check each coefficient and report all errors found.
    if (!is_valid_a) {
        printf("Invalid input: The value of coefficient a ='%s' should be numeric\n", a_str);
        all_inputs_valid = 0; // Set master flag to false.
    }
    if (!is_valid_b) {
        printf("Invalid input: The value of coefficient b ='%s' should be numeric\n", b_str);
        all_inputs_valid = 0;
    }
    if (!is_valid_c) {
        printf("Invalid input: The value of coefficient c ='%s' should be numeric\n", c_str);
        all_inputs_valid = 0;
    }

    // --- 4. If all inputs are valid, solve the equation ---
    if (all_inputs_valid) {
        // Convert valid strings to double-precision floating-point numbers.
        a = atof(a_str);
        b = atof(b_str);
        c = atof(c_str);

        // A quadratic equation requires 'a' to be non-zero.
        if (a == 0) {
            printf("This is not a quadratic equation (a cannot be 0).\n");
        } else {
            // Calculate the discriminant (b^2 - 4ac).
            discriminant = b * b - 4 * a * c;

            // Case 1: Two distinct real roots.
            if (discriminant > 0) {
                x1 = (-b + sqrt(discriminant)) / (2 * a);
                x2 = (-b - sqrt(discriminant)) / (2 * a);
                printf("Output: x1 = %.2f, x2 = %.2f\n", x1, x2);
            // Case 2: Two equal real roots.
            } else if (discriminant == 0) {
                x1 = -b / (2 * a);
                printf("Output: x1 = x2 = %.2f\n", x1);
            // Case 3: Two complex (imaginary) roots.
            } else {
                double realPart = -b / (2 * a);
                double imagPart = sqrt(-discriminant) / (2 * a);
                printf("Roots are complex.\n");
                printf("Output: x1 = %.2f + %.2fi, x2 = %.2f - %.2fi\n", realPart, imagPart, realPart, imagPart);
            }
        }
    }

    return 0; // Indicate successful execution.
}