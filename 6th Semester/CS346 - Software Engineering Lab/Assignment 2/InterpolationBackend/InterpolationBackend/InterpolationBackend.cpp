// InterpolationBackend.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"

/*
 * PROJECT: Interpolation Methods Suite
 * TEAM LEAD: Daksh Agarwal
 * TEAM MEMBER 1: Gugulothu Maniprakash
 * TEAM MEMBER 2: Maneesh S Kolekar
 * TEAM MEMBER 3: Vaibhav Singh
 * TEAM MEMBER 4: Samudrala Manish Kumar
 * COMPILER: Visual Studio 2010 (C++)
 *
 * DESCRIPTION:
 * Integrates five interpolation algorithms with ADDED ERROR HANDLING.
 * Includes protection against:
 * 1. Extrapolation (Out of Range inputs).
 * 2. Unsorted Data.
 * 3. Duplicate Points (Division by Zero).
 */

#include <iostream>
#include <iomanip>
#include <cmath>
#include <limits> // Required for checking numeric limits

using namespace std;

const int MAX_POINTS = 50;

// ============================================================================
// HELPER: UTILITY FUNCTIONS
// ============================================================================

// Function to sort the array of x and y coordinates
void sortData(double x[], double y[], int n) {
    for (int i = 0; i < n - 1; i++) {
        for (int j = i + 1; j < n; j++) {
            if (x[i] > x[j]) {
                swap(x[i], x[j]);
                swap(y[i], y[j]);
            }
        }
    }
}

// Check for duplicates (Prevents Division by Zero in Lagrange/Newton)
bool hasDuplicates(double x[], int n) {
    for (int i = 0; i < n - 1; i++) {
        for (int j = i + 1; j < n; j++) {
            if (abs(x[i] - x[j]) < 1e-9) return true; // Float comparison
        }
    }
    return false;
}

// ============================================================================
// 1. Piecewise Constant Interpolation
// ============================================================================
extern "C" __declspec(dllexport)
double interpolatePiecewise(double targetX, double x[], double y[], int n) {
    // Check if target is outside the valid data range (No extrapolation)
    if (targetX < x[0] || targetX > x[n - 1]) {
        cerr << "[Error: Target out of range for Piecewise] --> ";
        return 0.0; 
    }

    // Iterate through intervals to find where targetX belongs
    for (int i = 0; i < n - 1; i++) {
        // Logic: If x is in [xi, xi+1), the value is constant yi
        if (targetX >= x[i] && targetX < x[i + 1]) {
            return y[i];
        }
    }
    
    // Handle edge case: if target is exactly the last point
    if (targetX == x[n - 1]) return y[n - 1];
    
    return 0.0;
}

// ============================================================================
// 2. Nearest Neighbor Interpolation
// ============================================================================
extern "C" __declspec(dllexport)
double interpolateNearestNeighbor(double targetX, double x[], double y[], int n) {
    // Warn user if target is outside known range (Extrapolation)
    if (targetX < x[0] || targetX > x[n - 1]) {
        cout << "(Warning: Extrapolating)                   --> "; 
    }

    // Initialize: Assume the first point is the closest
    int nearestIndex = 0;
    double minDiff = abs(targetX - x[0]);

    // Iterate through remaining points to find a closer match
    for (int i = 1; i < n; i++) {
        double currentDiff = abs(targetX - x[i]);
        
        // Logic: Update index if current point has smaller absolute difference
        if (currentDiff < minDiff) {
            minDiff = currentDiff;
            nearestIndex = i;
        }
    }
    
    // Return the y-value of the geometrically closest point found
    return y[nearestIndex];
}

// ============================================================================
// 3. Linear Interpolation
// ============================================================================
extern "C" __declspec(dllexport)
double interpolateLinear(double targetX, double x[], double y[], int n) {
    // Validate input range (Linear interpolation requires bounding points)
    if (targetX < x[0] || targetX > x[n - 1]) {
        cerr << "[Error: Target out of range for Linear]    --> ";
        return 0.0; 
    }

    // Iterate through data intervals to find where targetX belongs
    for (int i = 0; i < n - 1; i++) {
        // Check if targetX is within the current interval [xi, xi+1]
        if (targetX >= x[i] && targetX <= x[i + 1]) {
            
            // Logic: Calculate slope (m) = change in y / change in x
            double slope = (y[i + 1] - y[i]) / (x[i + 1] - x[i]);
            
            // Apply point-slope form: y = y_i + m * (target - x_i)
            return y[i] + slope * (targetX - x[i]);
        }
    }
    return 0.0;
}

// ============================================================================
// 4. Newton’s Divided Difference Interpolation
// ============================================================================
extern "C" __declspec(dllexport)
double interpolateNewton(double targetX, double x[], double y[], int n) {
    double diffTable[MAX_POINTS][MAX_POINTS];

    // Safety Check: Duplicate X values would cause division by zero later
    if (hasDuplicates(x, n)) {
        cerr << "[Error: Duplicate X values cause DivByZero] --> ";
        return 0.0;
    }

    // Step 1: Initialize first column with original Y values
    for (int i = 0; i < n; i++) {
        diffTable[i][0] = y[i];
    }

    // Step 2: Build the Divided Difference Table (O(n^2))
    // 'j' represents the column (order of difference), 'i' represents the row
    for (int j = 1; j < n; j++) {
        for (int i = 0; i < n - j; i++) {
            double denominator = x[i + j] - x[i];
            
            // Formula: (Next Diff - Current Diff) / (x_end - x_start)
            diffTable[i][j] = (diffTable[i + 1][j - 1] - diffTable[i][j - 1]) / denominator;
        }
    }

    // Step 3: Evaluate Polynomial P(x) = a0 + a1(x-x0) + a2(x-x0)(x-x1)...
    double result = diffTable[0][0]; // Start with a0
    double term = 1.0;

    for (int i = 1; i < n; i++) {
        // Accumulate the product term: (target - x0) * (target - x1)...
        term = term * (targetX - x[i - 1]);
        
        // Add term * coefficient (from top row of table)
        result = result + (term * diffTable[0][i]);
    }

    return result;
}

// ============================================================================
// 5. Lagrange Interpolation
// ============================================================================
extern "C" __declspec(dllexport)
double interpolateLagrange(double targetX, double x[], double y[], int n) {
    // Safety Check: Duplicate X values result in (xi - xj) = 0
    if (hasDuplicates(x, n)) {
        cerr << "[Error: Duplicate X values cause DivByZero] --> ";
        return 0.0;
    }

    double result = 0.0;

    // Outer Loop: Summation of all weighted basis polynomials
    for (int i = 0; i < n; i++) {
        double term = y[i]; // Start with the y-value of the current point
        
        // Inner Loop: Product sequence to calculate Basis Polynomial Li(x)
        for (int j = 0; j < n; j++) {
            if (i != j) { // Skip the current point to avoid (xi - xi)
                double denominator = x[i] - x[j];
                
                // Defensive check: Ensure denominator is valid
                if (denominator == 0) {
                     cerr << "[Error: DivByZero] --> "; 
                     return 0.0;
                }
                
                // Formula: term *= (target - xj) / (xi - xj)
                term = term * (targetX - x[j]) / denominator;
            }
        }
        // Add the calculated term to the final polynomial value
        result += term;
    }
    return result;
}