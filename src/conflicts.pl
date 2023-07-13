:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).

% conflictsDetection(X,[]) :- % only fixable conflicts
% conflictsDetection(_, [C|Cs]) :- % unfeasible, return to user
conflictsDetection(ConflictsAndSolutions, UnfeasibleConflicts) :-
    findall((C,S), conflict(C, S), CSs), sort(CSs, ConflictsAndSolutions),
    findall(C, member((C, unfeasible), ConflictsAndSolutions), UnfeasibleConflicts).

% --- General ---
% too general(?):
% - we can define "mydif/2"
% - specialise the rules (e.g., latency/stddev)
% - hierarchy of soft/soft properties (so on boundaries)

conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, Property, B1, hard, V1, _, VF, _),
    propertyExpectation(PId2, I, Property, B2, soft, V2, _, VF, _),
    dif(PId1, PId2), conflictingBounds((B1,V1),(B2,V2)),
    Solution = (remove, [PId2]).
conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, Property, B1, hard, V1, _, _, VF),
    propertyExpectation(PId2, I, Property, B2, soft, V2, _, _, VF),
    dif(PId1, PId2), conflictingBounds((B1,V1),(B2,V2)),
    Solution = (remove, [PId2]).
conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, Property, B1, soft, V1, _, VF, _),
    propertyExpectation(PId2, I, Property, B2, soft, V2, _, VF, _),
    dif(PId1, PId2), conflictingBounds((B1,V1),(B2,V2)),
    Solution = (remove, [PId1,PId2]).
conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, Property, B1, soft, V1, _, _, VF),
    propertyExpectation(PId2, I, Property, B2, soft, V2, _, _, VF),
    dif(PId1, PId2), conflictingBounds((B1,V1),(B2,V2)),
    Solution = (remove, [PId1,PId2]).
conflict((PId1,PId2), unfeasible) :- 
    propertyExpectation(PId1, I, Property, B1, hard, V1, _, VF, _),
    propertyExpectation(PId2, I, Property, B2, hard, V2, _, VF, _),
    dif(PId1, PId2), conflictingBounds((B1,V1),(B2,V2)).
conflict((PId1,PId2), unfeasible) :- 
    propertyExpectation(PId1, I, Property, B1, hard, V1, _, _, VF),
    propertyExpectation(PId2, I, Property, B2, hard, V2, _, _, VF),
    dif(PId1, PId2), conflictingBounds((B1,V1),(B2,V2)).

% CONFLICTING BOUNDS
conflictingBounds((greater, L), (smaller, U)) :- L > U.
conflictingBounds((dedicated,_), (same,_)).
% conflictingBounds((B, _), (B,_)).



