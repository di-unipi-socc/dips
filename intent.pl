:-['data.pl', 'utils.pl']. % load data

% testing predicate
start(L) :- vnfForIntent(gSIntent, L).

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

vnfForIntent(IntentId, L) :-
    intent(_, IntentId),
    deliveryExpectation(IntentId, TargetId, TargetType),
    application(TargetType, S),
    findall(CIds, relevantProperty(IntentId, TargetId, CIds), Cs),
    consider(Cs, S, L).

relevantProperty(IntentId, TargetId, CIds) :-
    propertyExpectation(IntentId, Property, CIds, TargetId),
    changingProperties(ChangingProperties),
    member(Property, ChangingProperties).

consider([], L, L).
consider([C|Cs], OldL, NewL) :-
    % TODO: define partial order of conditions (e.g. logging -> privacy)
    checkCondition(C, OldL, TmpL),
    consider(Cs, TmpL, NewL).

checkCondition(C, OldL, [encVF|OldL]) :-
    condition(C, privacy, edge, _, _, _).

% sort properties by a list of ordered properties
mySort(RP, P, C) :-
    subtract(RP, P, Tmp),
    subtract(RP, Tmp, C).


% checkCondition(C, OldL, NewL) :-
    % condition(C, privacy, cloud, _, From, To).
