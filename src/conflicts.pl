:- ['utils.pl', 'properties.pl'].
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

% --- General "intra"-property numeric conflicts ---
conflict((PId1,PId2), Chain, Solution) :-
    propertyExpectation(PId1, I, Property, B1, L1, V1, _, VI1, VF1),
    propertyExpectation(PId2, I, Property, B2, L2, V2, _, VI2, VF2),
    dif(PId1, PId2), additive(Property),
    additiveConflict(Chain, (VI1,VF1), (VI2,VF2), (B1,B2), (V1,V2)),
    once(solution(Property, (L1,L2), (PId1,PId2), Solution)).
conflict((PId1,PId2), Chain, Solution) :-
    propertyExpectation(PId1, I, Property, B1, L1, V1, _, VI1, VF1),
    propertyExpectation(PId2, I, Property, B2, L2, V2, _, VI2, VF2),
    dif(PId1, PId2), concave(Property), concaveConflict(Chain, (VI1,VF1), (VI2,VF2), (B1,B2), (V1,V2)),
    once(solution(Property, (L1,L2), (PId1,PId2), Solution)).
conflict((PId1,PId2), _, Solution) :- % other
    propertyExpectation(PId1, I, Property, B1, L1, _, _, VI1, VF1),
    propertyExpectation(PId2, I, Property, B2, L2, _, _, VI2, VF2),
    dif(PId1, PId2), other(Property), otherConflict(Property, (VI1,VF1), (VI2,VF2), (B1,B2)),
    once(solution(Property, (L1,L2), (PId1,PId2), Solution)).

% --- Specific "intra"-property numeric conflicts ---

% totChainHW
conflict((PId1, PId2), _, Solution) :- % one changing property hw is too large
    propertyExpectation(PId1, I, totChainHW, _, L, V, _, _, _),
    propertyExpectation(PId2, I, P, _, _, _),
    intent(I, _, U, _), changingProperty(P, VF), vnfXUser(VF, _, (Low, High), HWReqs), between(Low, High, U), HWReqs >= V,
    solution(totChainHW, (L, hard), (PId1,PId2), Solution).
conflict((PId1, tooMuchHW), Chain, Solution) :- % whole chain hw is too large
    propertyExpectation(PId1, I, totChainHW, _, L, V, _, _, _),
    intent(I, _, U, _), findall(HW, dimensionedHW(Chain, U, HW), HWs), sum_list(HWs, TotHW), TotHW > V, 
    solution(totChainHW, (L, hard), (PId1, tooMuchChainHW), Solution).

% availability
conflict((PId1, PId2), Chain, Solution) :- % there exists a vnf 
    propertyExpectation(PId1, I, chainAvailability, _, L1, V1, _, VI, VF),
    propertyExpectation(PId2, I, vnfAvailability, _, L2, V2, _, VNF, _),
    subChain(Chain, VI, VF, SubChain), member(VNF, SubChain), V1 > V2,
    once(solution(_, (L1,L2), (PId1,PId2), Solution)).

% CONFLICTING BOUNDS 
additiveConflict(C, (VI1,VF1), (VI2,VF2), (greater, lower), (V1,V2)) :- subpath(C, VI1, VF1, VI2, VF2), V1 > V2.

concaveConflict(C, (VI1,VF1), (VI2,VF2), (greater, lower), (V1,V2)) :- overlaps(C, VI1, VF1, VI2, VF2), V1 > V2.
concaveConflict(C, (VI1,VF1), (VI2,VF2), (greater, greater), (V1,V2)) :- overlaps(C, VI1, VF1, VI2, VF2).
concaveConflict(C, (VI1,VF1), (VI2,VF2), (lower, lower), (V1,V2)) :- overlaps(C, VI1, VF1, VI2, VF2).

concaveConflict(C, (VI1,VF1), (VI2,VF2), (greater, lower), (V1,V2)) :- subpath(C, VI1, VF1, VI2, VF2), V1 > V2.
concaveConflict(C, (VI1,VF1), (VI2,VF2), (greater, greater), (V1,V2)) :- subpath(C, VI1, VF1, VI2, VF2), V1 > V2.
concaveConflict(C, (VI1,VF1), (VI2,VF2), (lower, lower), (V1,V2)) :- subpath(C, VI1, VF1, VI2, VF2), V1 > V2.

otherConflict(affinity, (V,_), (V, _), (dedicated, same)).
otherConflict(affinity, (V,_), (_, V), (dedicated, same)).

% levels and related SOLUTIONS (in case of conflict)
solution(bandwidth, _, (PIdMin, PId2), (remove, [PIdMin])) :-
    propertyExpectation(PIdMin, _, bandwidth, greater, _, BWMin, _, _, _),
    propertyExpectation(PId2, _, bandwidth, greater, _, BW2, _, _, _),
    BWMin =< BW2.
solution(bandwidth, _, (PId1, PIdMin), (remove, [PIdMin])) :-
    propertyExpectation(PId1, _, bandwidth, greater, _, BW1, _, _, _),
    propertyExpectation(PIdMin, _, bandwidth, greater, _, BWMin, _, _, _),
    BWMin < BW1.
solution(bandwidth, _, (PIdMax, PId2), (remove, [PIdMax])) :-
    propertyExpectation(PIdMax, _, bandwidth, lower, _, BWMax, _, _, _),
    propertyExpectation(PId2, _, bandwidth, lower, _, BW2, _, _, _),
    BWMax >= BW2.
solution(bandwidth, _, (PId1, PIdMax), (remove, [PIdMax])) :-
    propertyExpectation(PId1, _, bandwidth, lower, _, BW1, _, _, _),
    propertyExpectation(PIdMax, _, bandwidth, lower, _, BWMax, _, _, _),
    BWMax > BW1.

solution(_, (hard, hard), _, unfeasible). % unfeasible
solution(_, (soft, hard), (PId1, _), (remove, [PId1])). % remove soft
solution(_, (hard, soft), (_, PId2), (remove, [PId2])). % remove soft
solution(_, (soft, soft), (PId1, PId2), (remove, [PId1, PId2])). % remove both