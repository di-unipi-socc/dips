intent(int1, sh1, 10000, streamingService).

target(streamingService, [storageVF, streamVF]).

% propertyExpectation(PropertyId, IntentId, Property, Bound, From/Before, To/After).
propertyExpectation(ch1, int1, caching, _, _, storageVF).
propertyExpectation(ch2, int1, encoding, _, _, storageVF).
propertyExpectation(ch3, int1, decoding, _, streamVF, _).

% SYNTAX CONFLICTS: impossible to satisfy contrasting intents on same request.
%%%%% Example 1 %%%%%
% The intent requires that storageVF run on a dedicated server AND
% that encodeVF runs on the same server as storageVF. Conflict.
% Solution: inform user? or just fail?
propertyExpectation(aff1, int1, affinity, dedicated, hard, _, _, storageVF, _).
%propertyExpectation(aff2, int1, affinity, same, hard, _, _, storageVF, encodeVF). % conflict with aff1
propertyExpectation(aff3, int1, affinity, dedicated, soft, _, _, storageVF, _). % conflict with aff3
propertyExpectation(aff4, int1, affinity, dedicated, hard, _, _, cacheVF, _).

propertyExpectation(bw1, int1, bandwidth, greater, hard, 40, megabps, storageVF, cacheVF).
%propertyExpectation(bw2, int1, bandwidth, smaller, hard, 10, megabps, encodeVF, decodeVF).
propertyExpectation(bw4, int1, bandwidth, smaller, soft, 10, megabps, encodeVF, cacheVF).
propertyExpectation(hw1, int1, totHW, smaller, hard, 50, gb, _, _).



%%%%% Example 2 %%%%%
% The intent requires that storageVF run on a dedicated server AND
% that encodeVF *possibly* runs on the same server as storageVF. Conflict.
% Solution: ignore nodeAffinity as it is soft (shadowing). Inform user?

%%%%% Example 3 %%%%%
% The intent requires that storageVF run on a dedicated server AND
% that encodeVF *possibly* runs on the same server as storageVF. Conflict.
% Solution: ignore nodeAffinity as it is soft (shadowing). Inform user?


%%%%% Example 3 %%%%%
% The intent requires that end-to-end bandwidth is at least 50Mbps AND
% that bandwidth between encodeVF and decodeVF is at most 10Mbps. Conflict.
% Solution: inform user? or just fail?

%%%%% Example 4 %%%%%
% The intent requires possibly that end-to-end bandwidth is at least 50Mbps AND
% that possibly bandwidth between encodeVF and decodeVF is at most 10Mbps. Conflict.
% Solution: ignore both as they are soft. Inform user?

%%%%% Example 5 %%%%%
% The intent requires an edge caching service between storageVF and encodeVF AND
% that the overall hardware consumption of the chain is at most 25GB.
% Caching requires 30GB alone. Conflict.
% Solution: inform user? or just fail?

vnf(storageVF, cloud, 10).
vnf(streamVF, edge, 8).

vnfXUser(storageVF, l, (1, inf), 20).
vnfXUser(streamVF, m, (1, 10000), 5).
vnfXUser(streamVF, l, (10000, inf), 12).