/* INTENT MODEL (by user) */

% intent(Stakeholder, IntentId, TargetId).
intent(gameAppOp, gsIntent, gamingService).

% Changing property
% propertyExpectation(IntentId, Property, Bound, From/Before, To/After).
propertyExpectation(gsIntent, privacy, edge, _, _).
propertyExpectation(gsIntent, logging, edge, cloudGamingVF, _).

% Non-changing property
% propertyExpectation(IntentId, Property, Bound, Level, Value, Unit, From, To).
propertyExpectation(gsIntent, bandwidth, larger, soft, 30, megabps, edgeGamingVF, cloudGamingVF).
propertyExpectation(gsIntent, latency, smaller, soft, 50, ms, gateway, edgeGamingVF).

/* PROVIDER/TARGET-DEPENDENT MODEL */

% target(TargetId, [VNFs])
target(gamingService, [edgeGamingVF, cloudGamingVF]).

% vnf(Id, Affinity, ProcessingTime)
vnf(edgeGamingVF, edge, 10).
vnf(cloudGamingVF, cloud, 8).
vnf(encVF, edge, 1).
vnf(logVF, cloud, 1).

% vnfXUser(Id, Version, UsersRange, HWReqs)
vnfXUser(edgeGamingVF, s, (1,100), 5).
vnfXUser(edgeGamingVF, m, (101,1000), 10).
vnfXUser(edgeGamingVF, l, (1001,inf), 12).
vnfXUser(cloudGamingVF, s, (1, 1000), 8).
vnfXUser(cloudGamingVF, m, (1001, 10000), 12).
vnfXUser(cloudGamingVF, l, (10001, inf), 20).
vnfXUser(encVF, s, (0, inf), 1).
vnfXUser(decVF, s, (0, inf), 1).
vnfXUser(logVF, s, (0, inf), 1).

% changingProperty(Property). 
%% changing properties defined according to priority order
changingProperty(logging, logVF).
changingProperty(privacy, encVF).
changingProperty(security, authVF).
changingProperty(caching, cacheVF).
changingProperty(compression, compVF).
changingProperty(encoding, encodeVF).

% node(Id, Type, HWCaps)
node(gateway, edge, 10).
node(edge1, edge, 5).
node(edge2, edge, 15).
node(cloud1, cloud, 20).
node(cloud2, cloud, 30).

% link(From, To, FeatLat, FeatBw)
link(cloud1, edge1, 20, 70).
link(edge1, cloud2, 15, 30).
link(cloud2, edge1, 15, 30).
link(gateway, cloud1, 10, 40).
link(cloud1, gateway, 10, 40).
link(edge2, cloud1, 10, 20).
link(cloud1, edge2, 10, 20).
link(cloud1, cloud2, 2, 100).
link(cloud2, cloud1, 2, 100).
link(N, N, 0, inf). % no latency and infinite bandwdith on self-links