intent(rsIntent, renderAppOp, 1000, renderingService).

target(renderingService, [uiVF, syncVF, renderVF, storageVF]).

% propertyExpectation(PropertyId, IntentId, Property, Bound, From/Before, To/After).
propertyExpectation(ch2, rsIntent, compression, _, _, renderVF).
propertyExpectation(ch1, rsIntent, privacy, _, _, renderVF).

propertyExpectation(bw1, rsIntent, bandwidth, greater, hard, 150, megabps, begin, end).

propertyExpectation(aff1, rsIntent, affinity, dedicated, hard, _, _, renderVF, _).
propertyExpectation(aff2, rsIntent, affinity, same, hard, _, _, renderVF, storageVF).

propertyExpectation(lat1, rsIntent, latency, lower, soft, 40, ms, syncVF, renderVF).
propertyExpectation(lat2, rsIntent, latency, lower, hard, 20, ms, renderVF, storageVF).
propertyExpectation(hw1, rsIntent, totChainHW, lower, hard, 100, gb, _, _).

propertyExpectation(av1, rsIntent, chainAvailability, greater, hard, 0.999, _, begin, end).

vnf(uiVF, edge, 2).
vnf(syncVF, edge, 5).
vnf(renderVF, edge, 10).
vnf(storageVF, cloud, 8).

vnfXUser(uiVF, s, (1, inf), 2).
vnfXUser(syncVF, s, (1, 2000), 1).
vnfXUser(syncVF, m, (2001, 5000), 2).
vnfXUser(syncVF, l, (5001, inf), 5).
vnfXUser(renderVF, s, (1, 2000), 8).
vnfXUser(renderVF, m, (2001, 5000), 25).
vnfXUser(renderVF, l, (5001, inf), 50).
vnfXUser(storageVF, l, (1, inf), 80).