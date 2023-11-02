:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).

% Detection
conflictsDetection(ConflictsAndSolutions) :-
    findall((C,S), conflict(C, S), CSs), sort(CSs, ConflictsAndSolutions),
    findall(C, member((C, unfeasible), ConflictsAndSolutions), UnfeasibleConflicts),
    handleUnfeasibleConflicts(UnfeasibleConflicts).

% Resolution (based on action)
conflictsResolution([((_,_),remove,L)|Cs], NCP, FNCP) :- 
    subtract(NCP, L, NCP1), 
    conflictsResolution(Cs, NCP1, FNCP).
conflictsResolution([((_,_),Op,_)|Cs], NCP, FNCP) :-
    dif(Op, remove), 
    conflictsResolution(Cs, NCP, FNCP).
conflictsResolution([], NCP, NCP).

handleUnfeasibleConflicts(UnfeasibleConflicts) :- 
    dif(UnfeasibleConflicts, []), write('Unfeasible conflicts: '), writeln(UnfeasibleConflicts), fail.
handleUnfeasibleConflicts([]).

% --- General "intra"-property conflicts ---
conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I1, Property, B1, L1, V1, _, VF, _),
    propertyExpectation(PId2, I2, Property, B2, L2, V2, _, VF, _),
    dif(PId1, PId2), conflictingBounds(Property, (I1,I2), (B1,B2),(V1,V2)), solution(Property, (L1,L2), (PId1,PId2), Solution).
conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I1, Property, B1, L1, V1, _, _, VF),
    propertyExpectation(PId2, I2, Property, B2, L2, V2, _, _, VF),
    dif(PId1, PId2), conflictingBounds(Property, (I1,I2), (B1,B2),(V1,V2)), solution(Property, (L1,L2), (PId1,PId2), Solution).

% levels and related SOLUTIONS (in case of conflict)
solution(_, (hard, hard), _, unfeasible). % unfeasible
solution(_, (hard, soft), (_, PId2), (remove, [PId2])). % remove soft
solution(_, (soft, soft), (PId1, PId2), (remove, [PId1, PId2])). % remove both

% CONFLICTING BOUNDS 
conflictingBounds(_, _, (greater, smaller), (L, U)) :- L > U.
conflictingBounds(_, _, (dedicated, same), _).



