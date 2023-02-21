/* INTENT MODEL (by user) */

% intent(Stakeholder, IntentId, TargetId).
intent(gameAppOp, gsIntent, gamingService).

% Changing property
% propertyExpectation(IntentId, Property, Bound, From/Before, To/After).
propertyExpectation(gsIntent, privacy, edge, _, _).
propertyExpectation(gsIntent, logging, cloud, cloudGamingVF, _).

% Non-changing property
% propertyExpectation(IntentId, Property, Bound, Level, Value, Unit, From, To).
propertyExpectation(gsIntent, bandwidth, larger, soft, 100, megabps, edgeGamingVF, cloudGamingVF).
propertyExpectation(gsIntent, latency, smaller, hard, 50, ms, gateway, edgeGamingVF).

/* PROVIDER/TARGET-DEPENDENT MODEL */

% target(TargetId, [VNFs])
target(gamingService, [edgeGamingVF, cloudGamingVF]).

% vnf(Id, Affinity, ProcessingTime)
vnf(edgeGamingVF, edge, 15).
vnf(cloudGamingVF, cloud, 8).
vnf(encVF, edge, 2).
vnf(logVF, cloud, 1).

% vnfXUser(Id, Version, UsersRange, HWReqs)
vnfXUser(edgeGamingVF, s, (1,100), 5).
vnfXUser(edgeGamingVF, m, (101,1000), 10).
vnfXUser(edgeGamingVF, l, (1001,inf), 15).
vnfXUser(cloudGamingVF, s, (1, 1000), 8).
vnfXUser(cloudGamingVF, m, (1001, 10000), 12).
vnfXUser(cloudGamingVF, l, (10001, inf), 25).
vnfXUser(encVF, s, (0, inf), 2).
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
node(edge1, edge, 18).
node(edge2, edge, 25).
node(cloud1, cloud, 100).
node(cloud2, cloud, 150).

% link(From, To, FeatLat, FeatBw)

link(gateway, edge1, 5, 30).
link(gateway, edge2, 35, 30).
link(gateway, cloud1, 135, 30).
link(gateway, cloud2, 125, 30).
link(edge1, gateway, 15, 50).
link(edge1, edge2, 30, 70).
link(edge1, cloud1, 130, 120).
link(edge1, cloud2, 120, 120).
link(edge2, gateway, 35, 50).
link(edge2, edge1, 30, 70).
link(edge2, cloud1, 135, 80).
link(edge2, cloud2, 125, 80).
link(cloud1, gateway, 135, 30).
link(cloud1, edge1, 130, 120).
link(cloud1, edge2, 135, 80).
link(cloud1, cloud2, 10, 1000).
link(cloud2, gateway, 125, 30).
link(cloud2, edge1, 120, 120).
link(cloud2, edge2, 125, 80).
link(cloud2, cloud1, 10, 1000).
link(N, N, 0, inf). % no latency and infinite bandwdith on self-links