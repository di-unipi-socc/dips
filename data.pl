/* INTENT MODEL (by user) */

% intent(Stakeholder, IntentId, TargetId).
intent(gameAppOp, gSIntent, gamingService).

% propertyExpectation(IntentId, Property, [ConditionIds]).
propertyExpectation(gSIntent, privacy, [c1]).
propertyExpectation(gSIntent, bandwidth, [c2]).
propertyExpectation(gSIntent, latency, [c3]).

% condition(ConditionId, Property, Value, Unit, From, To).
condition(c1, privacy, edge, _, _, _).
condition(c2, bandwidth, larger, 30, megabps, edgeGamingVF, cloudGamingVF).
condition(c3, latency, smaller, 50, ms, node42, edgeGamingVF).

/* PROVIDER/TARGET-DEPENDENT MODEL */

% target(TargetId, [VNFs])
target(gamingService, [edgeGamingVF, cloudGamingVF]).

% vnf(Id, ProcessingTime)
vnf(edgeGamingVF, 10).
vnf(cloudGamingVF, 8).
vnf(encVF, 1).
vnf(decVF, 1).

% vnfXUser(Id, Version, UsersRange, HWReqs)
vnfXUser(edgeGamingVF, s, (1,100), 5).
vnfXUser(edgeGamingVF, m, (101,1000), 10).
vnfXUser(edgeGamingVF, l, (1001,inf), 12).
vnfXUser(cloudGamingVF, s, (1, 1000), 8).
vnfXUser(cloudGamingVF, m, (1001, 10000), 12).
vnfXUser(cloudGamingVF, l, (10001, inf), 20).
vnfXUser(encVF, s, (0, inf), 1).
vnfXUser(decVF, s, (0, inf), 1).

% changingProperty(Priority, Property).
changingProperty(0, logging).
changingProperty(1, privacy).
changingProperty(2, security).
changingProperty(3, caching).
changingProperty(4, compression).
changingProperty(5, videoEncoding).
changingProperty(6, rendering). % app dependent ?

% node(Id, Type, HWCaps)
node(node42, edge, 10).
node(edge1, edge, 5).
node(edge2, edge, 8).
node(coolCloud, cloud, 20).
node(coolCloud2, cloud, 20).

% link(From, To, FeatLat, FeatBw)
link(node42, edge1, 2, 30).
link(edge1, node42, 2, 30).
link(edge1, coolCloud, 5, 100).
link(coolCloud, edge1, 5, 100).
link(edge1, coolCloud2, 5, 100).
link(coolCloud2, edge1, 5, 100).
link(node42, coolCloud, 10, 10).
link(coolCloud, node42, 10, 10).
link(coolCloud, coolCloud2, 2, 100).
link(coolCloud2, coolCloud, 2, 100).
link(N, N, 0, inf). % no latency and infinite bandwdith on self-links