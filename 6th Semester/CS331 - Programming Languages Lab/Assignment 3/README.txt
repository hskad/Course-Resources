Prolog Assignment 3

Name: Daksh Agarwal
Roll Number: 230101123

----------------------------------------------------------------------------------------------------

How to Run:

1. Open the terminal.
2. Run the .pl file using the command:
   swipl assignment3_230101123.pl
3. Execute the queries provided in the comments of the source file.

----------------------------------------------------------------------------------------------------

Notes / Assumptions:

- Library CLP(FD): All approaches utilize 'library(clpfd)' to handle integer constraints. This ensures that the N-Queens problem is solved using modern constraint logic programming rather than simple arithmetic.
- Approach 1 (Generate and Test):
    - This approach generates a full permutation of numbers first and then checks for safety. 
    - It is the most "naive" version and becomes significantly slow for N > 10.
- Approach 2 (Early Pruning):
    - In this version, the constraints (#=) are applied before the values are generated.
    - It uses 'maplist(between(1, N), Qs)' to generate values. Because the constraints are active, Prolog "prunes" branches of the search tree as soon as an invalid queen placement is detected, making it much faster than Approach 1.
- Approach 3 (Intelligent Search):
    - This is the most optimized version. It uses the library's 'labeling/2' predicate with the 'ff' (first-fail) strategy.
    - The 'ff' strategy selects the most constrained variable to label first, which minimizes the search space and allows the program to solve high values of N (e.g., N=50) almost instantly.
- Visualizer (show_board/1):
    - A utility predicate is included to print the solution as a grid of 'Q's and dots (.).
    - It uses a failure-driven loop to iterate through the solution list and display the board row by row.
- List Truncation:
    - For large values of N, SWI-Prolog may truncate the result list with "...".
    - To see the full list, use the command:
      `set_prolog_flag(answer_write_options, [max_depth(0)]).`
