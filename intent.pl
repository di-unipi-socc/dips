:-['data.pl', 'utils.pl']. % load data

% testing predicate
start(L, P) :- vnfForIntent(gSIntent, L, P).

% intent(Stakeholder, IntentId).
intent(gameAppOp, gSIntent).

% changingProperties([Prop1, Prop2, ...])
% changingProperties([logging, privacy]).

% changingProperty(Priority, Property).
changingProperty(0, privacy).

% application(Id, [VNFs])
application(gamingService, [edgeGamingVF, cloudGamingVF]).

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

vnfForIntent(IntentId, Chain, Placement) :-
    intent(_, IntentId), deliveryExpectation(IntentId, TargetId, TargetType),
    sortProperties(IntentId, TargetId, ChangingProperties, NonChangingProperties),
    assembleChain(IntentId, TargetType, ChangingProperties, Chain),
    placeChain(Chain, NonChangingProperties, [on(cloudGamingVF, coolCloud)], Placement).

sortProperties(IntentId, TId, CP, NCP) :-
    findall((P,CIds), nonChangingProperty(IntentId, TId, P, CIds), NCP),
    findall((P,CIds), relevantChangingProperty(IntentId, TId, P, CIds), Cs), sort(Cs, CP).

assembleChain(IntentId, TType, ChangingProperties, Chain) :-
    deliveryExpectation(IntentId, _, TType),
    application(TType, S),
    considerAll(ChangingProperties, S, Chain).

relevantChangingProperty(IntentId, TargetId, Priority, CIds) :-
    propertyExpectation(IntentId, Property, CIds, TargetId),
    changingProperty(Priority, Property).

nonChangingProperty(IntentId, TargetId, Property, CIds) :-
    propertyExpectation(IntentId, Property, CIds, TargetId),
    \+ changingProperty(_, Property).

considerAll([], L, L).
considerAll([(_, CIds)|Ps], OldL, NewL) :-
    consider(CIds, OldL, TmpL),
    considerAll(Ps, TmpL, NewL).

consider([], L, L).
consider([C|Cs], OldL, NewL) :-
    checkCondition(C, OldL, TmpL),
    consider(Cs, TmpL, NewL).

checkCondition(C, OldL, [encVF|OldL]) :-
    condition(C, privacy, edge, _, _, _).

placeChain(Chain, NonChangingProperties, OldP, NewP) :-
    placeChain(Chain, OldP, NewP),
    checkPlacement(NonChangingProperties, NewP).

% placeChain/3 places the VNFs of the chain on the network
placeChain([], P, P). % base case
placeChain([VNF|VNFs], OldP, NewP) :- % if the VNF is already placed, skip it
    member(on(VNF, _), OldP),
    placeChain(VNFs, OldP, NewP).
placeChain([VNF|VNFs], OldP, NewP) :- % try place the VNF on a node with enough resources
    \+ member(on(VNF, _), OldP),
    vnf(VNF, HWReqs, _), node(N, HWCaps),  
    hwOK(N, HWReqs, HWCaps, OldP),
    placeChain(VNFs, [on(VNF, N)|OldP], NewP).

% check cumulative hardware, keeping into account the already placed VNFs
hwOK(N, HWReqs, HWCaps, Placement) :-
    findall(HW, (member(on(V, N), Placement), vnf(V, HW, _)), HWs), sumlist(HWs, HWSum),
    HWSum + HWReqs =< HWCaps.

checkPlacement([], _).
checkPlacement([(_, CIds)|Ps], Placement) :-
    checkAll(CIds, Placement),
    checkPlacement(Ps, Placement).

checkAll([], _).
checkAll([C|Cs], Placement) :-
    checkCondition(C, Placement),
    checkAll(Cs, Placement).

checkCondition(C, Placement) :-
    condition(C, latency, smaller, Value, _, From, To),
    getLatency(Placement, From, To, Lat), Lat =< Value.

checkCondition(C, Placement) :-
    condition(C, bandwidth, larger, Value, _, From, To),
    getBandwidth(Placement, From, To, BW), BW >= Value.
    
% sort properties by a list of ordered properties
/* mySort(RP, P, C) :-
    subtract(RP, P, Tmp),
    subtract(RP, Tmp, C).
*/