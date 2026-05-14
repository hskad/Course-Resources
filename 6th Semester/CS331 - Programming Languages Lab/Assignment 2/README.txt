Prolog Assignment 2

Name: Daksh Agarwal
Roll Number: 230101123

----------------------------------------------------------------------------------------------------

How to Run:

1. Open the terminal.
2. Run the .pl file using the command:
   swipl assignment2_230101123.pl
3. Execute the queries provided in the comments of the source file.

----------------------------------------------------------------------------------------------------

Notes / Assumptions:

- Q1 (split/3): Two versions are provided. The version without the cut is logically pure and can backtrack. The version with the cut is deterministic and more efficient for single solutions.
- Q2 (route/3): 
    - The base facts are defined as 'link/2'. 
    - A 'directTrain/2' rule handles symmetry (traveling both ways) safely to avoid left-recursion loops.
    - Cycle detection is implemented using a 'Visited' list to prevent infinite loops in the train network.
    - The 'reverse/2' predicate is used to ensure the final path is displayed from Source to Destination.
- Q3 (number_of_parents/2): 
    - The original implementation had a logical flaw where the cut was bypassed if the second argument was not 0.
    - The final fix uses negation (\=) instead of a cut. This allows the predicate to be fully relational, meaning it works correctly for queries like 'number_of_parents(X, 0)' to find both Adam and Eve.
