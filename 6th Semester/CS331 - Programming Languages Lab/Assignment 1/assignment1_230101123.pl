% Q1. CLAUSES :-

% 1. Base Case: The simplest possible list. The recursion stops here.
flatten([], []).

% 2. Recursive Rule for when the Head IS a list.
flatten([H|T], FinalFlatList) :-
    is_list(H),
    flatten(H, FlattenHead),
    flatten(T, FlattenTail),
    append(FlattenHead, FlattenTail, FinalFlatList).

% 3. Recursive Rule for when the Head is NOT a list (it is a simple element).
flatten([H|T], [H|Flatlist]) :-
    \+ is_list(H),
    flatten(T, Flatlist).


% QUERIES :-
%
% ?- flatten([a,b,[c,d],[],[[[e]]],f], L).
% L = [a,b,c,d,e,f] 
%
% ?- flatten(a, [a]).
% false
%

% ------------------------------------------------------------------------------------------------------------------

% Q2. CLAUSES :-

% 1. Facts to look up the word for a given number.
means(0, zero).
means(1, one).
means(2, two).
means(3, three).
means(4, four).
means(5, five).
means(6, six).
means(7, seven).
means(8, eight).
means(9, nine).

% 2. The base case: an empty list translates to an empty list.
translate([], []).

% 3. The recursive step: translate the head, then recursively translate the tail.
translate([H1|T1], [H2|T2]) :-
    means(H1, H2),
    translate(T1, T2).


% QUERIES :-
%
% ?- translate([3, 5, 1, 3], L).
% L = [three, five, one, three].
%
% ?- translate([3, 5, 1, 3], [three,five,one,three]).
% true.
%

% ------------------------------------------------------------------------------------------------------------------

% Q3. CLAUSES :-

% 'the' is a title/article before a noun (Prefix). Precedence 500.
:- op(500, fx, the).

% 'of' connects two nouns (Infix). Precedence 600.
:- op(600, xfx, of).

% 'was' is the main relationship (Infix). Precedence 700.
:- op(700, xfx, was).

joe was the head of the department.


% QUERIES:-
%
% ?- write_canonical(joe was the head of the department).
% was(joe,of(the(head),the(department)))
% true.
%
% ?- Who was What.
% Who = joe,
% What = the head of the department.
%
% ?- joe was What.
% What = the head of the department.
%
% ?- Who was the head of the department.
% Who = joe.
%
% ?- joe was the head of What.
% What = the department.
%

% ------------------------------------------------------------------------------------------------------------------


% Q4. CLAUSES :-

% The base case: the only way to get a sum of 0 is with an empty sub-list from an empty list.
subsum([], 0, []).

% Rule 1 (Include): A solution can include the Head of the list...
subsum([H|T1], Sum, [H|T2]) :-
    H =< Sum,
    Sum_New is Sum - H,
    subsum(T1, Sum_New, T2).

% Rule 2 (Exclude): A solution can exclude the Head of the list...
subsum([_|T1], Sum, T2) :-
    subsum(T1, Sum, T2).


% QUERIES :-
%
% ?- subsum([], 0, []).
% true.
%
% ?- subsum( [1,2,7,3,6],6, PartList).
% PartList = [1, 2, 3] ;
% PartList = [6] .
%

% ------------------------------------------------------------------------------------------------------------------


% Q5. CLAUSES :-

% Base case: returns the current lower bound if it is within the range.
between(Num1, Num2, Num1) :-
    Num1 =< Num2.

% Recursive step: increments the lower bound to find the next integer in the range.
between(Num1, Num2, X) :-
    Num1 =< Num2,
    Num1_new is Num1 + 2,
    between(Num1_new, Num2, X).


% QUERIES :-
%
% ?- between(6, 4, X).
% false.
% 
% ?- between(3, 6, X).
% X = 3 ;
% X = 4 ;
% X = 5 ;
% X = 6 ;
% false.
%
% ?- between(3, 6, 5).
% true.
% 
