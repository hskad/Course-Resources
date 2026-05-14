% Q1. CLAUSES :-

split_without_cut([], [], []).
split_without_cut([H|T_num], [H|T_pos], Negatives) :-
    H >= 0, split_without_cut(T_num, T_pos, Negatives).
split_without_cut([H|T_num], Positives, [H|T_neg]) :-
    H < 0, split_without_cut(T_num, Positives, T_neg).

split_with_cut([], [], []).
split_with_cut([H|T_num], [H|T_pos], Negatives) :-
    H >= 0, !, split_with_cut(T_num, T_pos, Negatives).
split_with_cut([H|T_num], Positives, [H|T_neg]) :-
    split_with_cut(T_num, Positives, T_neg).


% QUERIES :-
%
% ?- split_without_cut([3,-1,0,5,-2],[3,0,5],[-1,-2]).
% true ;
% false.
%
% ?- split_without_cut([3,-1,0,5,-2],X,Y).
% X = [3, 0, 5],
% Y = [-1, -2] ;
% false.
%
% ?- split_with_cut([3,-1,0,5,-2],X,Y).
% X = [3, 0, 5],
% Y = [-1, -2].
%
% ?- split_with_cut([3,-1,0,5,-2],[3,0,5],[-1,-2]).
% true.
%



% Q2. CLAUSES :-

connected(guwahati, tezpur).
connected(nagaon, guwahati).
connected(lumding, nagaon).
connected(haflong, lumding).
connected(silchar, haflong).
connected(agartala, silchar).
connected(aizawl, agartala).

directTrain(X, Y) :- connected(X, Y).
directTrain(X, Y) :- connected(Y, X).

route(Src, Dest, Path) :-
    travel(Src, Dest, [Src], Path).

travel(Dest, Dest, Visited, Path) :-
    reverse(Visited, Path).

travel(Current, Dest, Visited, Path) :-
    directTrain(Current, Next),
    \+ member(Next, Visited),
    travel(Next, Dest, [Next | Visited], Path).


% QUERIES :-
%
% ?- route(aizawl, guwahati, R).
% R = [aizawl, agartala, silchar, haflong, lumding, nagaon, guwahati].
%
% ?- route(haflong, tezpur, R).
% R = [haflong, lumding, nagaon, guwahati, tezpur].
%



% Q3. CLAUSES :-

% The problem is that the cut is only reached if the second argument of the query is 0.
% So a query like number_of_parents(adam, 2) bypasses the cut entirely and incorrectly succeeds using the third clause.
% Also, a query like number_of_parents(X, 2) returns only adam and not eve.

% To fix it, you must use a variable for the number so the name matches first, then use the cut, and then specify the number:

% number_of_parents(adam, N) :- !, N is 0.
% number_of_parents(eve, N) :- !, N is 0.
% number_of_parents(X, 2).

% This solution still has the issue that number_of_parents(X, 0) returns only adam.
% Final fix:

number_of_parents(adam, 0).
number_of_parents(eve, 0).
number_of_parents(X, 2) :- X \= adam, X \= eve.


% QUERIES :-
%
% ?- number_of_parents(adam, X).
% X = 0.
%
% ?- number_of_parents(X, 0).
% X = adam ;
% X = eve.
%

split([H|T]) :-
    H >= 0,
    H =< 9.
