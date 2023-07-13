/* INTENT MODEL (by user) */

% intent(Stakeholder, IntentId, TargetId).
intent(gameAppOp, gsIntent, gamingService).

% Changing property
% propertyExpectation(IntentId, Property, Bound, From/Before, To/After).
propertyExpectation(cp1, gsIntent, privacy, edge, _, _).
propertyExpectation(cp2, gsIntent, logging, cloud, cloudGamingVF, _).

% Non-changing property
% propertyExpectation(IntentId, Property, Bound, Level, Value, Unit, From, To).
propertyExpectation(bw1, gsIntent, bandwidth, greater, soft, 100, megabps, edgeGamingVF, cloudGamingVF).
propertyExpectation(lat1, gsIntent, latency, smaller, hard, 50, ms, gateway, edgeGamingVF).

/* PROVIDER/TARGET-DEPENDENT MODEL */

% target(TargetId, Chain).
target(gamingService, [edgeGamingVF, cloudGamingVF]).

% vnf(Id, Affinity, ProcessingTime).
vnf(edgeGamingVF, edge, 15).
vnf(cloudGamingVF, cloud, 8).
vnf(encVF, edge, 2).
vnf(logVF, cloud, 1).

% vnfXUser(Id, Version, UsersRange, HWReqs).
vnfXUser(edgeGamingVF, s, (1,100), 5).
vnfXUser(edgeGamingVF, m, (101,1000), 10).
vnfXUser(edgeGamingVF, l, (1001,inf), 15).
vnfXUser(cloudGamingVF, s, (1, 1000), 8).
vnfXUser(cloudGamingVF, m, (1001, 10000), 12).
vnfXUser(cloudGamingVF, l, (10001, inf), 25).
vnfXUser(encVF, s, (1, inf), 2).
vnfXUser(logVF, s, (1, inf), 1).

% changingProperty(Property, VF). 
%% changing properties defined according to priority order
changingProperty(logging, logVF).
changingProperty(privacy, encVF).
changingProperty(security, authVF).
changingProperty(caching, cacheVF).
changingProperty(compression, compVF).
changingProperty(encoding, encodeVF).