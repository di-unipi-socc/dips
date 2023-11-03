:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).

% Detection
conflictsDetection(Chain, ConflictsAndSolutions) :-
    findall((C,S), conflict(C, Chain, S), CSs), sort(CSs, ConflictsAndSolutions),
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
conflict((PId1,PId2), Chain, Solution) :-
    propertyExpectation(PId1, I, Property, B1, L1, V1, _, VI1, VF1),
    propertyExpectation(PId2, I, Property, B2, L2, V2, _, VI2, VF2),
    dif(PId1, PId2), conflictingBounds(Property, Chain, (VI1,VF1), (VI2, VF2), (B1,B2), (V1,V2)), 
    solution(Property, (L1,L2), (PId1,PId2), Solution).

% CONFLICTING BOUNDS 
conflictingBounds(bandwidth, (greater, smaller), (L, U)) :- L > U.
% with latency we need to know if "L" is for a subpath of "G" a -> b -> c, a -> b (< 100), a-> c (> 100)
conflictingBounds(_, (dedicated, same), _).

% levels and related SOLUTIONS (in case of conflict)
solution(_, (hard, hard), _, unfeasible). % unfeasible
solution(_, (hard, soft), (_, PId2), (remove, [PId2])). % remove soft
solution(_, (soft, soft), (PId1, PId2), (remove, [PId1, PId2])). % remove both

subchain(From, To, [V|Rest], Subchain) :- dif(From, V), subchain(From, To, Rest, Subchain).
subchain(From, To, [From|Rest], [From|Subchain]) :- subchain2(To, Rest, Subchain).

subchain2(To, [V|Rest], [V|Subchain]) :- dif(To, V), subchain2(To, Rest, Subchain).
subchain2(To, [To|_], [To]).

overlaps(C, VI1, VF1, VI2, VF2) :- subchain(VI1, VF1, C, S1), subchain(VI2, VF2, C, S2), overlaps(S1, S2).
overlaps(S1, S2) :- length(S1, L1), length(S2, L2), L1 < L2, append( [_, S1, _], S2 ), !.
overlaps(S1, S2) :- append( [_, S2, _], S1 ).