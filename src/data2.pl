:- discontiguous propertyExpectation/9.

intent(sh1, int1, streamingService).

target(streamingService, [storageVF, encodeVF, decodeVF]).

% SYNTAX CONFLICTS: impossible to satisfy contrasting intents on same request.
%%%%% Example 1 %%%%%
% The intent requires that storageVF run on a dedicated server AND
% that encodeVF runs on the same server as storageVF. Conflict.
% Solution: inform user? or just fail?
propertyExpectation(aff1, int1, affinity, dedicated, hard, _, _, storageVF, _).
propertyExpectation(aff2, int1, affinity, same, hard, _, _, storageVF, encodeVF). % comment to remove unfeasibility


%%%%% Example 2 %%%%%
% The intent requires that storageVF run on a dedicated server AND
% that encodeVF *possibly* runs on the same server as storageVF. Conflict.
% Solution: ignore nodeAffinity as it is soft (shadowing). Inform user?
propertyExpectation(aff3, int1, affinity, same, soft, _, _, storageVF, encodeVF). % conflict with aff1

%%%%% Example 3 %%%%%
% The intent requires that storageVF run on a dedicated server AND
% that encodeVF *possibly* runs on the same server as storageVF. Conflict.
% Solution: ignore nodeAffinity as it is soft (shadowing). Inform user?
propertyExpectation(aff4, int1, affinity, dedicated, soft, _, _, storageVF, _). % conflict with aff3

%%%%% Example 3 %%%%%
% The intent requires that end-to-end bandwidth is at least 50Mbps AND
% that bandwidth between encodeVF and decodeVF is at most 10Mbps. Conflict.
% Solution: inform user? or just fail?
propertyExpectation(bw1, int1, bandwidth, larger, hard, 50, megabps, storageVF, decodeVF).
propertyExpectation(bw2, int1, bandwidth, smaller, hard, 10, megabps, encodeVF, decodeVF).

%%%%% Example 4 %%%%%
% The intent requires possibly that end-to-end bandwidth is at least 50Mbps AND
% that possibly bandwidth between encodeVF and decodeVF is at most 10Mbps. Conflict.
% Solution: ignore both as they are soft. Inform user?
propertyExpectation(bw3, int1, bandwidth, larger, soft, 50, megabps, storageVF, decodeVF).
propertyExpectation(bw4, int1, bandwidth, smaller, soft, 10, megabps, encodeVF, decodeVF).

%%%%% Example 5 %%%%%
% The intent requires an edge caching service between storageVF and encodeVF AND
% that the overall hardware consumption of the chain is at most 25GB.
% Caching requires 30GB alone. Conflict.
% Solution: inform user? or just fail?
propertyExpectation(cp1, int1, caching, edge, encodeVF, decodeVF).
propertyExpectation(hw1, int1, hardware, smaller, hard, 25, gb, _, _).