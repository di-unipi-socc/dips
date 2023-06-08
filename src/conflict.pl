:- discontiguous propertyExpectation/9.

intent(sh1, int1, streamingService).

% target(TargetId, Chain).
target(streamingService, [storageVF, encodeVF, decodeVF]).

% TODO: 
% - add ids to propertyExpectation's 

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

% SYNTAX CONFLICTS: impossible to satisfy contrasting intents on same request.
%%%%% Example 1 %%%%%
% The intent requires that storageVF run on a dedicated server AND
% that encodeVF runs on the same server as storageVF. Conflict.
% Solution: inform user? or just fail?
propertyExpectation(aff1, int1, affinity, dedicated, hard, _, _, storageVF, _).
propertyExpectation(aff2, int1, affinity, same, hard, _, _, storageVF, encodeVF).


%%%%% Example 2 %%%%%
% The intent requires that storageVF run on a dedicated server AND
% that encodeVF *possibly* runs on the same server as storageVF. Conflict.
% Solution: ignore nodeAffinity as it is soft (shadowing). Inform user?
% propertyExpectation(aff1, int1, affinity, dedicated, hard, _, _, storageVF, _).
propertyExpectation(aff3, int1, affinity, same, soft, _, _, storageVF, encodeVF).

%%%%% Example 3 %%%%%
% The intent requires that storageVF run on a dedicated server AND
% that encodeVF *possibly* runs on the same server as storageVF. Conflict.
% Solution: ignore nodeAffinity as it is soft (shadowing). Inform user?
% propertyExpectation(aff3, int1, affinity, same, soft, _, _, storageVF, encodeVF).
propertyExpectation(aff4, int1, affinity, dedicated, soft, _, _, storageVF, _).

%%%%% Example 3 %%%%%
% The intent requires that end-to-end bandwidth is at least 50Mbps AND
% that bandwidth between encodeVF and decodeVF is at most 10Mbps. Conflict.
% Solution: inform user? or just fail?
propertyExpectation(5, int1, bandwidth, larger, hard, 50, megabps, storageVF, decodeVF).
propertyExpectation(6, int1, bandwidth, smaller, hard, 10, megabps, encodeVF, decodeVF).

%%%%% Example 4 %%%%%
% The intent requires possibly that end-to-end bandwidth is at least 50Mbps AND
% that possibly bandwidth between encodeVF and decodeVF is at most 10Mbps. Conflict.
% Solution: ignore both as they are soft. Inform user?
propertyExpectation(7, int1, bandwidth, larger, soft, 50, megabps, storageVF, decodeVF).
propertyExpectation(8, int1, bandwidth, smaller, soft, 10, megabps, encodeVF, decodeVF).

%%%%% Example 5 %%%%%
% The intent requires an edge caching service between storageVF and encodeVF AND
% that the overall hardware consumption of the chain is at most 25GB.
% Caching requires 30GB alone. Conflict.
% Solution: inform user? or just fail?
propertyExpectation(9, int1, caching, edge, encodeVF, decodeVF).
propertyExpectation(10, int1, hardware, smaller, hard, 25, gb, _, _).
vnf(cacheVF, edge, 30).