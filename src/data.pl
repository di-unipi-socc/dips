/* INTENT MODEL (by user) */

% intent(Stakeholder, IntentId, TargetId).
intent(gameAppOp, gsIntent, gamingService).

% propertyExpectation(IntentId, Property, [ConditionIds]).
propertyExpectation(gsIntent, privacy, [cPriv]).
propertyExpectation(gsIntent, logging, [cLog]).
propertyExpectation(gsIntent, bandwidth, [cBW]).
propertyExpectation(gsIntent, latency, [cLat]).

% condition(ConditionId, Property, Bound, From, To).
condition(cPriv, privacy, edge, _, _).
condition(cLog, logging, edge, _, _).

% condition(ConditionId, Property, Bound, Level, Value, Unit, From, To).
condition(cBW, bandwidth, larger, soft, 30, megabps, edgeGamingVF, cloudGamingVF).
condition(cLat, latency, smaller, hard, 50, ms, gateway, edgeGamingVF).

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

% changingProperty(Priority, Property).
changingProperty(0, logging).
changingProperty(1, privacy).
changingProperty(2, security).
changingProperty(3, caching).
changingProperty(4, compression).
changingProperty(5, encoding).

% node(Id, Type, HWCaps)
node(gateway, edge, 10).
node(tEdge, edge, 5).
node(hEdge, edge, 15).
node(coolCloud, cloud, 20).
node(coolCloud2, cloud, 30).

% link(From, To, FeatLat, FeatBw)
link(gateway, tEdge, 2, 30).
link(tEdge, gateway, 2, 30).
link(tEdge, coolCloud, 20, 70).
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