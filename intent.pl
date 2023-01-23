:-['data.pl', 'utils.pl'].

start(Chain, Placement) :- processIntent(gSIntent, [on(cloudGamingVF, coolCloud)], (Chain, Placement)).

processIntent(IntentId, Ti, Tf) :-
    intent(_, IntentId), deliveryExpectation(IntentId, TargetId, TargetType),
    deliveryLogic(IntentId, TargetId, TargetType, Ti, Tf).

deliveryLogic(IntentId, TId, TType, OldPlacement, (Chain, Placement)) :- 
    splitProperties(IntentId, TId, ChangingProperties, NonChangingProperties), % split properties into changing and non-changing ones, w.r.t the chain
    assembleChain(IntentId, TType, ChangingProperties, Chain), 
    reverse(Chain, RChain), % reverse to use tail-recursion in placeChain/3
    placeChain(RChain, NonChangingProperties, OldPlacement, Placement).

splitProperties(IntentId, TId, CP, NCP) :-
    findall((P,CIds), nonChangingProperty(IntentId, TId, P, CIds), NCP),
    findall((P,CIds), relevantChangingProperty(IntentId, TId, P, CIds), Cs), sort(Cs, CP).

relevantChangingProperty(IntentId, TargetId, Priority, CIds) :-
    propertyExpectation(IntentId, Property, CIds, TargetId), changingProperty(Priority, Property).

nonChangingProperty(IntentId, TargetId, Property, CIds) :-
    propertyExpectation(IntentId, Property, CIds, TargetId), \+ changingProperty(_, Property).

assembleChain(IntentId, TType, ChangingProperties, Chain) :-
    deliveryExpectation(IntentId, _, TType),
    application(TType, S),
    considerAll(ChangingProperties, S, Chain).

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

placeChain([], P, P). % base case
placeChain([VNF|VNFs], PartialPlacement, FinalPlacement) :- % if the VNF is already placed, skip it
    member(on(VNF, _), PartialPlacement),
    placeChain(VNFs, PartialPlacement, FinalPlacement).
placeChain([VNF|VNFs], PartialPlacement, FinalPlacement) :- % try place the VNF on a node with enough resources
    \+ member(on(VNF, _), PartialPlacement),
    vnf(VNF, HWReqs, _), node(N, HWCaps),  
    hwOK(N, HWReqs, HWCaps, PartialPlacement),
    placeChain(VNFs, [on(VNF, N)|PartialPlacement], FinalPlacement).

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