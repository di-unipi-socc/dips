/* INTENT MODEL */

% intent(Stakeholder, IntentId).
intent(gameAppOp, gSIntent).

% changingProperty(Priority, Property).
changingProperty(0, logging).
changingProperty(1, privacy).

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

/* TARGET DEPENDENT MODEL */

% application(Id, [VNFs])
application(gamingService, [edgeGamingVF, cloudGamingVF]).

% vnf(Id, HWReqs, ProcessingTime)
vnf(edgeGamingVF, 4, 15).
vnf(cloudGamingVF, 10, 8).
vnf(encVF, 1, 10).

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