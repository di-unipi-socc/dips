:- ['utils.pl', 'properties.pl'].
:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).

% Detection
conflictsDetection(Chain, ConflictsAndSolutions) :-
    findall((C,S), conflict(C, Chain, S), CSs), sort(CSs, ConflictsAndSolutions),
    write('Conflicts: '), writeln(ConflictsAndSolutions),
    findall(C, member((C, unfeasible), ConflictsAndSolutions), UnfeasibleConflicts),
    handleUnfeasibleConflicts(UnfeasibleConflicts).

% Resolution (based on action)
conflictsResolution([((_,_),intra(remove,L))|Cs], NCP, FNCP) :- subtract(NCP, L, TmpNCP), conflictsResolution(Cs, TmpNCP, FNCP).
conflictsResolution([((_,_),Op,_)|Cs], NCP, FNCP) :- dif(Op, remove), conflictsResolution(Cs, NCP, FNCP).
conflictsResolution([], NCP, NCP).

% TODO: actions to add: forcedCap, upgradeTo, forceCapWarning

handleUnfeasibleConflicts(UnfeasibleConflicts) :- 
dif(UnfeasibleConflicts, []), write('Unfeasible conflicts: '), writeln(UnfeasibleConflicts), fail.
handleUnfeasibleConflicts([]).

% --- General "intra"-property numeric conflicts ---
intraDetect((PId1,PId2), Chain, (B1,B2), (L1,L2), (V1,V2), (VI1,VF1), (VI2,VF2)) :-
    propertyExpectation(PId1, I, Property, B1, L1, V1, _, VI1, VF1),
    propertyExpectation(PId2, I, Property, B2, L2, V2, _, VI2, VF2),
    dif(PId1, PId2).

interDetect((PId1,PId2), Chain, (B1,B2), (L1,L2), (V1,V2), (VI1,VF1), (VI2,VF2)) :-
    intent(I1, SH1, _, T1), intent(I2, infrPr, _, T2), dif(SH1, infrPr)
    propertyExpectation(PId1, I1, Property, B1, L1, V1, _, VI1, VF1),
    propertyExpectation(PId2, I2, Property, B2, L2, V2, _, VI2, VF2),
    dif(PId1, PId2), user(SH1, L2).

typeDetect(Property, (VI1,VF1), (VI2,VF2), (B1,B2), (V1,V2)) :-
    additive(Property), additiveConflict(Chain, (VI1,VF1), (VI2,VF2), (B1,B2), (V1,V2)).
typeDetect(Property, (VI1,VF1), (VI2,VF2), (B1,B2), (V1,V2)) :-
    (concave(Property); multiplicative(Property)), concaveConflict(Chain, (VI1,VF1), (VI2,VF2), (B1,B2), (V1,V2)).
typeDetect(Property, (VI1,VF1), (VI2,VF2), (B1,B2), _) :-
    other(Property), otherConflict(Property, (VI1,VF1), (VI2,VF2), (B1,B2)).

conflict(PIds, Chain, Solution) :-
    intraDetect(PIds, Chain, Boundaries, Levels, Values, VF1, VF2),
    typeDetect(Property, VF1, VF2, Boundaries, Values),
    once(solution(Property, Levels, PIds, Solution)).
conflict(PIds, Chain, Solution) :-
    interDetect(PIds, Chain, Boundaries, Levels, Values, VF1, VF2),
    typeDetect(Property, VF1, VF2, Boundaries, Values),
    once(solutionInfrPr(Property, Levels, V1, (PId1,PId2), Solution)).

% --- Specific numeric conflicts ---

% totChainHW 1
conflict((PId1, PId2), _, Solution) :- % one changing property hw is too large
    propertyExpectation(PId1, I, P, _, _, _),
    propertyExpectation(PId2, I, totChainHW, _, L, V, _, _, _),
    changingProperty(P, VF), vnfXUser(VF, _, (Low, High), HWReqs), between(Low, High, U), HWReqs >= V,
    once(solution(totChainHW, (L, hard), (PId1,PId2), Solution)).
conflict((PId1, PId2), _, Solution) :- % one changing property hw is too large
    intent(I1, SH1, _, T1), intent(I2, infrPr, _, T2), dif(SH1, infrPr),
    propertyExpectation(PId1, I1, P, _, _, _),
    propertyExpectation(PId2, I2, totChainHW, _, UP, V, _, _, _), user(SH1, UP), 
    changingProperty(P, VF), vnfXUser(VF, _, (Low, High), HWReqs), between(Low, High, U), HWReqs >= V,
    once(solutionInfrPr(totChainHW, (hard,UP), V1, (PId1,PId2), Solution)).

% totChainHW 2
conflict((PId1, tooMuchHW), Chain, Solution) :- % whole chain hw is too large
    intent(I1, SH1, _, _), dif(SH1, infrPr),
    propertyExpectation(PId1, I1, totChainHW, _, L, V, _, _, _),
    findall(HW, dimensionedHW(Chain, U, HW), HWs), sum_list(HWs, TotHW), TotHW > V,
    once(solution(totChainHW, (L, hard), (PId1,PId2), Solution)).
conflict((PId1, tooMuchHW), Chain, Solution) :- % whole chain hw is too large
    intent(I2, infrPr, _, _), % TODO: CHECK THIS
    propertyExpectation(PId1, I2, totChainHW, _, L, V, _, _, _),
    findall(HW, dimensionedHW(Chain, U, HW), HWs), sum_list(HWs, TotHW), TotHW > V, 
    once(solutionInfrPr(totChainHW, (L, hard), V1, (PId1, tooMuchHW), Solution)). 

% chainAvailability
conflict((PId1, PId2), Chain, Solution) :- % there exists a vnf 
    intent(I, SH1, _, _), dif(SH1, infrPr),
    propertyExpectation(PId1, I, chainAvailability, _, L1, V1, _, VI, VF),
    propertyExpectation(PId2, I, vnfAvailability, _, L2, V2, _, VNF, _),
    subChain(VI, VF, Chain, SubChain), member(VNF, SubChain), V1 > V2,
    once(solution(availability, (L1,L2), (PId1,PId2), Solution)).
conflict((PId1, PId2), Chain, Solution) :- % there exists a vnf 
    intent(I1, SH1, _, T1), intent(I2, infrPr, _, T2), dif(SH1, infrPr),
    propertyExpectation(PId1, I1, chainAvailability, _, L1, V1, _, VI, VF),
    propertyExpectation(PId2, I2, vnfAvailability, _, UP, V2, _, VNF, _),
    user(SH1, UP), subChain(VI, VF, Chain, SubChain), member(VNF, SubChain), V1 > V2,
    once(solutionInfrPr(availability, (L1,UP), V1, (PId1,PId2), Solution)).

% CONFLICTING BOUNDS 
additiveConflict(C, (VI1,VF1), (VI2,VF2), (greater, lower), (V1,V2)) :- subpath(C, VI1, VF1, VI2, VF2), V1 > V2.

concaveConflict(C, (VI1,VF1), (VI2,VF2), (greater, lower), (V1,V2)) :- overlaps(C, VI1, VF1, VI2, VF2), V1 > V2.
concaveConflict(C, (VI1,VF1), (VI2,VF2), (greater, greater), _) :- overlaps(C, VI1, VF1, VI2, VF2).
concaveConflict(C, (VI1,VF1), (VI2,VF2), (lower, lower), _) :- overlaps(C, VI1, VF1, VI2, VF2).

concaveConflict(C, (VI1,VF1), (VI2,VF2), (greater, lower), (V1,V2)) :- subpath(C, VI1, VF1, VI2, VF2), V1 > V2.
concaveConflict(C, (VI1,VF1), (VI2,VF2), (greater, greater), _) :- subpath(C, VI1, VF1, VI2, VF2). %, V1 > V2.
concaveConflict(C, (VI1,VF1), (VI2,VF2), (lower, lower), _) :- subpath(C, VI1, VF1, VI2, VF2).%, V1 > V2.

otherConflict(affinity, (V,_), (V, _), (dedicated, same)).
otherConflict(affinity, (V,_), (_, V), (dedicated, same)).

% --- intra-intent solutions ---
% Bandwidth 
solution(Property, _, (PIdMin, PId2), intra(remove, [PIdMin])) :-
    (Property = bandwidth; Property = chainAvailability),
    propertyExpectation(PIdMin, _, _, greater, _, VMin, _, _, _),
    propertyExpectation(PId2, _, _, greater, _, V2, _, _    , _),
    VMin =< V2.
solution(Property, _, (PId1, PIdMin), intra(remove, [PIdMin])) :-
    (Property = bandwidth; Property = chainAvailability),
    propertyExpectation(PId1, _, _, greater, _, V1, _, _, _),
    propertyExpectation(PIdMin, _, _, greater, _, VMin, _, _, _),
    VMin < V1.

solution(bandwidth, _, (PIdMax, PId2), intra(remove, [PIdMax])) :-
    propertyExpectation(PIdMax, _, bandwidth, lower, _, BWMax, _, _, _),
    propertyExpectation(PId2, _, bandwidth, lower, _, BW2, _, _, _),
    BWMax >= BW2.
solution(bandwidth, _, (PId1, PIdMax), intra(remove, [PIdMax])) :-
    propertyExpectation(PId1, _, bandwidth, lower, _, BW1, _, _, _),
    propertyExpectation(PIdMax, _, bandwidth, lower, _, BWMax, _, _, _),
    BWMax > BW1.

% general intra-intent ones
solution(_, (hard, hard), _, unfeasible). % unfeasible
solution(_, (soft, hard), (PId1, _), intra(remove, [PId1])). % remove soft
solution(_, (hard, soft), (_, PId2), intra(remove, [PId2])). % remove soft
solution(_, (soft, soft), (PId1, PId2), intra(remove, [PId1, PId2])). % remove both

% --- inter-intent solutions ---
% if gold, forcedCapWarning
solutionInfrPr(Property, (hard,gold), V, PId, inter(forcedCapWarning, Cap, PId)) :- cap(Property, gold, Cap).

% if less than gold, upgradeTo
solutionInfrPr(Property, (hard, _), V, PId, inter(upgradeTo, MinLevel, PId)) :- upgradeTo(Property, V, MinLevel).

% forcedCap if soft
solutionInfrPr(Property, (soft, L2), _, PId, inter(forcedCap, Cap, PId)) :- cap(Property, L2, Cap).
