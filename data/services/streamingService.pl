intent(ssIntent, streamAppOp, 10000, streamingService).

target(streamingService, [storageVF, streamVF]).

% propertyExpectation(PropertyId, IntentId, Property, Bound, From/Before, To/After).
propertyExpectation(ch1, ssIntent, caching, _, _, storageVF).
propertyExpectation(ch2, ssIntent, encoding, _, _, storageVF).
propertyExpectation(ch3, ssIntent, decoding, _, streamVF, _).

propertyExpectation(bw1, ssIntent, bandwidth, greater, hard, 40, megabps, storageVF, cacheVF).
propertyExpectation(bw4, ssIntent, bandwidth, lower, soft, 10, megabps, encodeVF, cacheVF).

propertyExpectation(aff1, ssIntent, affinity, dedicated, hard, _, _, storageVF, _).
propertyExpectation(aff2, ssIntent, affinity, same, soft, _, _, storageVF, encodeVF). % conflict with aff1

propertyExpectation(lat1, ssIntent, latency, lower, hard, 100, ms, storageVF, streamVF).
propertyExpectation(lat2, ssIntent, latency, greater, soft, 120, ms, encodeVF, decodeVF).
propertyExpectation(hw1, ssIntent, totChainHW, lower, hard, 5, gb, _, _).

propertyExpectation(av1, ssIntent, chainAvailability, greater, hard, 0.99, _, storageVF, streamVF).
propertyExpectation(av2, ssIntent, vnfAvailability, greater, hard, 0.9, _, encodeVF, _).

vnf(storageVF, cloud, 10).
vnf(streamVF, edge, 8).

vnfXUser(storageVF, l, (1, inf), 20).
vnfXUser(streamVF, m, (1, 10000), 5).
vnfXUser(streamVF, l, (10000, inf), 12).