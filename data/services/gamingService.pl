% intent(IntentId, Stakeholder, NUsers, TargetId).
intent(gsIntent, gameAppOp, 3000, gamingService).

% Changing property
% propertyExpectation(PropertyId, IntentId, Property, Bound, From/Before, To/After).
propertyExpectation(cp1, gsIntent, privacy, edge, _, _).
propertyExpectation(cp2, gsIntent, logging, cloud, cloudGamingVF, _).
propertyExpectation(cp3, gsIntent, caching, _, _, edgeGamingVF).

% Non-changing property
% propertyExpectation(PropertyId, IntentId, Property, Bound, Level, Value, Unit, From, To).
propertyExpectation(bw1, gsIntent, bandwidth, greater, soft, 100, megabps, edgeGamingVF, cloudGamingVF).
propertyExpectation(lat1, gsIntent, latency, lower, hard, 50, ms, gateway, edgeGamingVF).
propertyExpectation(aff1, gsIntent, affinity, dedicated, hard, _, _, cacheVF, _).

% target(TargetId, Chain).
target(gamingService, [edgeGamingVF, cloudGamingVF]).