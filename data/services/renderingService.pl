intent(rsIntent, renderAppOp, 1000, renderingService).

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

target(renderingService, [uiVF, syncVF, renderVF, storageVF]).