/* INTENT MODEL (by user) */

% intent(Stakeholder, IntentId, TargetId).
intent(gameAppOp, gsIntent, gamingService).

% propertyExpectation(IntentId, Property, Bound, From, To).
propertyExpectation(gsIntent, privacy, edge, _, _).
propertyExpectation(gsIntent, logging, edge, _, _).

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
changingProperty(logging).
changingProperty(privacy).
changingProperty(security).
changingProperty(caching).
changingProperty(compression).
changingProperty(encoding).

% node(Id, Type, HWCaps)
node(gateway, edge, 10).
node(tEdge, edge, 5).
node(hEdge, edge, 15).
node(coolCloud, cloud, 20).
node(coolCloud2, cloud, 30).

% link(From, To, FeatLat, FeatBw)
link(coolCloud, tEdge, 20, 70).
link(tEdge, coolCloud2, 15, 30).
link(coolCloud2, tEdge, 15, 30).
link(gateway, coolCloud, 10, 40).
link(coolCloud, gateway, 10, 40).
link(hEdge, coolCloud, 10, 20).
link(coolCloud, hEdge, 10, 20).
link(coolCloud, coolCloud2, 2, 100).
link(coolCloud2, coolCloud, 2, 100).
link(N, N, 0, inf). % no latency and infinite bandwdith on self-links