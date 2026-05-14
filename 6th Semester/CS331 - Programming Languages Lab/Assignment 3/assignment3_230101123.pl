:- use_module(library(clpfd)).

% ==============================================================================
% VISUALIZATION UTILITY: show_board/1
% Logic: This predicate takes the list of Queen positions and prints a grid.
% In our list Qs, the index is the Column and the value is the Row.
% ==============================================================================

show_board(Qs) :-
    length(Qs, N),
    member(Row, Qs),             % Iterate through each queen's position
    nl,
    forall(between(1, N, I),     % Print 'Q' at the row position, '.' elsewhere
        (I =:= Row -> write('Q ') ; write('. '))
    ),
    fail.                        % Force backtracking to print all columns
    
show_board(_) :- nl, nl.



% ==============================================================================
% APPROACH 1: GENERATE AND TEST (The Naive Way)
% Logic: First we assign a number to every queen (Generate), 
% then we check if that arrangement is legal (Test). 
% This is very slow for N > 8.
% ==============================================================================

n_queens_v1(N, Qs) :-
    N_less is N-1,
    length(Qs, N_less),
    maplist(between(1, N), Qs), % GENERATE: Pick all numbers first
    append(Qs, N, Q_final),
    safe_queens_v1(Q_final).         % TEST: Check if valid after picking

safe_queens_v1([]).
safe_queens_v1([Q|Qs]) :-
    safe_queens_v1_(Qs, Q, 1),
    safe_queens_v1(Qs).

safe_queens_v1_([], _, _).
safe_queens_v1_([Q|Qs], Q0, D0) :-
    Q #\= Q0,                % Not same row
    abs(Q0 - Q) #\= D0,      % Not same diagonal
    D1 is D0 + 1,
    length(Qs, 0),
    safe_queens_v1_(Qs, Q0, D1).


/* QUERIES for V1:
   ?- n_queens_v1(8, Qs).
   ?- n_queens_v1(8, Qs), show_board(Qs). 
*/



% ==============================================================================
% APPROACH 2: EARLY PRUNING (Basic CLP(FD))
% Logic: We set the rules (Constraints) BEFORE we pick any numbers.
% As soon as a Queen is placed, the "search space" for others shrinks.
% ==============================================================================

n_queens_v2(N, Qs) :-
    length(Qs, N),
    Qs ins 2..N,
    safe_queens_v2(Qs),         % CONSTRAIN: Set rules first
    maplist(between(1, N), Qs). % GENERATE: Pruning happens while picking

safe_queens_v2([]).
safe_queens_v2([Q|Qs]) :-
    safe_queens_v2_(Qs, Q, 1),
    safe_queens_v2(Qs).

safe_queens_v2_([], _, _).
safe_queens_v2_([Q|Qs], Q0, D0) :-
    Q #\= Q0,               % Constraint: Not same row
    abs(Q0 - Q) #\= D0,     % Constraint: Not same diagonal
    D1 #= D0 + 1,
    safe_queens_v2_(Qs, Q0, D1).


/* QUERIES for V2:
   ?- n_queens_v2(20, Qs).
   ?- n_queens_v2(20, Qs), show_board(Qs). 
*/



% ==============================================================================
% APPROACH 3: INTELLIGENT SEARCH
% Logic: Constraints are set first, then we use the library's built-in 
% 'labeling' with the 'ff' (first-fail) strategy to find the solution.
% ==============================================================================

n_queens_v3(N, Qs) :-
    length(Qs, N),
    Qs ins 1..N,
    safe_queens_v3(Qs),         % CONSTRAIN: Set rules first
    labeling([ff], Qs).         % SEARCH: Use intelligent labeling

safe_queens_v3([]).
safe_queens_v3([Q|Qs]) :-
    safe_queens_v3_(Qs, Q, 1),
    safe_queens_v3(Qs).

safe_queens_v3_([], _, _).
safe_queens_v3_([Q|Qs], Q0, D0) :-
    Q #\= Q0,
    abs(Q0 - Q) #\= D0,
    D #= D0 + 1,
    safe_queens_v3_(Qs, Q0, D).


/* QUERIES for V3:
   ?- n_queens_v3(50, Qs).
   ?- n_queens_v3(50, Qs), show_board(Qs). 
*/
