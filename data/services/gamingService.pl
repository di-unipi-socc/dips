/* INTENT MODEL (by user) */

% intent(Stakeholder, IntentId, TargetId).
intent(gameAppOp, gsIntent, gamingService).

% Changing property
% propertyExpectation(PropertyId, IntentId, Property, Bound, From/Before, To/After).
propertyExpectation(cp1, gsIntent, privacy, edge, _, _).
propertyExpectation(cp2, gsIntent, logging, cloud, cloudGamingVF, _).
propertyExpectation(cp3, gsIntent, caching, edge, _, edgeGamingVF).

% Non-changing property
% propertyExpectation(PropertyId, IntentId, Property, Bound, Level, Value, Unit, From, To).
propertyExpectation(bw1, gsIntent, bandwidth, greater, soft, 100, megabps, edgeGamingVF, cloudGamingVF).
propertyExpectation(lat1, gsIntent, latency, smaller, hard, 50, ms, gateway, edgeGamingVF).
propertyExpectation(aff1, gsIntent, affinity, dedicated, hard, _, _, cacheVF, _).

/* PROVIDER/TARGET-DEPENDENT MODEL */

% target(TargetId, Chain).
target(gamingService, [edgeGamingVF, cloudGamingVF]).

% vnf(Id, Affinity, ProcessingTime).
vnf(edgeGamingVF, edge, 15).
vnf(cloudGamingVF, cloud, 8).

% vnfXUser(Id, Version, UsersRange, HWReqs).
vnfXUser(edgeGamingVF, s, (1,100), 5).
vnfXUser(edgeGamingVF, m, (101,1000), 10).
vnfXUser(edgeGamingVF, l, (1001,inf), 15).
vnfXUser(cloudGamingVF, s, (1, 1000), 8).
vnfXUser(cloudGamingVF, m, (1001, 10000), 12).
vnfXUser(cloudGamingVF, l, (10001, inf), 25).