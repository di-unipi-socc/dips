:-['data.pl', 'utils.pl']. % load data

% testing predicate
start(Tf) :- intent(gameAppOp, gamingServiceIntent, (chainToPlace, node42, [on(cloudGamingVF, coolCloud)]), Tf).

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
condition(c1, privacy, high, _, _, _).
condition(c2, bandwidth, larger, 30, megabps, edgeGamingVF, cloudGamingVF).
condition(c3, latency, smaller, 50, ms, node42, edgeGamingVF).

% application(Id, [VNFs])
application(gamingService, [edgeGamingVF, cloudGamingVF]).

vnfForIntent(IntentId, L) :-
    intent(_, IntentId),
    deliveryExpectation(IntentId, TargetId, TargetType),
    application(TargetType, S),
    findall(CIds, (propertyExpectation(IntentId, Property, [CIds], TargetId), member(Property, [privacy])), Cs),
    consider(Cs, S, L).

consider([], _, L, L).
consider([C|Cs], OldL, NewL) :-
    % TODO: define partial order of conditions (e.g. logging -> privacy)
    checkCondition(C, OldL, TmpL),
    consider(Cs, TmpL, NewL).

checkCondition(C, OldL, [encVF|OldL]) :-
    condition(C, privacy, edge, _, _, _).

checkCondition(C, OldL, NewL) :-
    condition(C, privacy, cloud, _, From, To).

% satisfyIntent(IntentId, Tf) :-  