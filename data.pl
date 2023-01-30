/* INTENT MODEL (by user) */

% intent(Stakeholder, IntentId).
intent(gameAppOp, gSIntent).

% target(TargetId, TargetType).
% target(t1, gamingService).

% deliveryExpectation(IntentId, TargetID, TargetType).
deliveryExpectation(gSIntent, t1, gamingService).

% propertyExpectation(IntentId, Property, [ConditionIds], TargetId).
propertyExpectation(gSIntent, privacy, [c1], t1).
propertyExpectation(gSIntent, bandwidth, [c2], t1).
propertyExpectation(gSIntent, latency, [c3], t1).

% condition(ConditionId, Property, Value, Unit, From, To).
condition(c1, privacy, edge, _, _, _).
condition(c2, bandwidth, larger, 30, megabps, edgeGamingVF, cloudGamingVF).
condition(c3, latency, smaller, 50, ms, node42, edgeGamingVF).

/* PROVIDER/TARGET-DEPENDENT MODEL */

% application(Id, [VNFs])
application(gamingService, [edgeGamingVF, cloudGamingVF]).

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
vnfXUser(encVF, x, (0, inf), 1).
vnfXUser(decVF, x, (0, inf), 1).

% changingProperty(Priority, Property).
changingProperty(0, logging).
changingProperty(1, privacy).

% node(Id, HwCaps)
node(node42, 10).
node(edge1, 5).
node(coolCloud, 20).

% link(From, To, FeatLat, FeatBw)
link(node42, edge1, 2, 30).
link(edge1, node42, 2, 30).
link(edge1, coolCloud, 5, 100).
link(coolCloud, edge1, 5, 100).
link(node42, coolCloud, 10, 10).
link(coolCloud, node42, 10, 10).
link(N, N, 0, inf). % no latency and infinite bandwdith on self-links