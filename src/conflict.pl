% TODO: 
% - define bandwidth conflicts


% conflicts(X,[]) :- % only fixable conflicts
% conflicts(_, [C|Cs]) :- % unfeasible, return to user
conflicts(ConflictsAndSolutions, UnfeasibleConflicts) :-
    findall((C,S), conflict(C, S), ConflictsAndSolutions),
    findall(C, member((C, unfeasible), ConflictsAndSolutions), UnfeasibleConflicts).

conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, Property, B1, hard, _, _, VF, _),
    propertyExpectation(PId2, I, Property, B2, soft, _, _, VF, _), dif(B1,B2),
    Solution = (remove, [PId2]).

conflict((PId1,PId2), unfeasible) :-
    propertyExpectation(PId1, I, affinity, dedicated, hard, _, _, VF, _),
    propertyExpectation(PId2, I, affinity, same, hard, _, _, VF, _).

conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, affinity, dedicated, soft, _, _, VF, _),
    propertyExpectation(PId2, I, affinity, same, soft, _, _, VF, _),
    Solution = (remove, [PId1,PId2]).

% same as above, but regarding the bandwidth (check that lower bound and upper bound can be compatibles)
conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, bandwidth, B1, hard, _, _, VF, _),
    propertyExpectation(PId2, I, bandwidth, B2, soft, _, _, VF, _), dif(B1,B2),
    Solution = (remove, [PId2]).

conflict((PId1,PId2), unfeasible) :-
    propertyExpectation(PId1, I, bandwidth, B1, hard, _, _, VF, _),
    propertyExpectation(PId2, I, bandwidth, B2, hard, _, _, VF, _), dif(B1,B2),
    % (check that lower bound and upper bound can be compatibles)
    

    