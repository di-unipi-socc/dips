:-['data.pl', 'utils.pl'].

% Ti = (NumberOfUsers, PartialPlacement)
% Tf = (Chain, FinalPlacement, TotCost, UnsatisfiedProperties)
start(NumberOfUsers, Cost, Chain, P) :- processIntent(gSIntent, (NumberOfUsers, [on(cloudGamingVF, coolCloud)]), (Cost, Chain , P)).

processIntent(IntentId, Ti, Tf) :-
    intent(_, IntentId), deliveryExpectation(IntentId, TargetId, TargetType),
    deliveryLogic(IntentId, TargetId, TargetType, Ti, Tf).

deliveryLogic(IntentId, TId, TType, (Users, OldPlacement), (Cost, Chain, Placement)) :- 
    splitProperties(IntentId, TId, CP, NCP),
    assembleChain(TType, CP, Chain),
    computeCost(Chain, Users, 0, Cost),
    reverse(Chain, RChain),
    placeChain(RChain, NCP, OldPlacement, Placement).

computeCost([], _, Cost, Cost).
computeCost([VNF|VNFs], Users, OldC, NewC) :-
    vnfXUser(VNF, (Low, High), C), 
    between(Low, High, Users), TmpC is OldC + C,
    computeCost(VNFs, Users, TmpC, NewC).

splitProperties(IntentId, TId, CP, NCP) :-
    findall((P,CIds), nonChangingProperty(IntentId, TId, P, CIds), NCP),
    findall((P,CIds), relevantChangingProperty(IntentId, TId, P, CIds), Cs), sort(Cs, CP).

relevantChangingProperty(IntentId, TargetId, Priority, CIds) :-
    propertyExpectation(IntentId, Property, CIds, TargetId), changingProperty(Priority, Property).

nonChangingProperty(IntentId, TargetId, Property, CIds) :-
    propertyExpectation(IntentId, Property, CIds, TargetId), \+ changingProperty(_, Property).

assembleChain(TType, CP, Chain) :-
    application(TType, S), considerAll(CP, S, Chain).

considerAll([], L, L).
considerAll([(_, [])|Ps], L, NewL) :- considerAll(Ps, L, NewL).
considerAll([(P,[C|Cs])|Ps], OldL, NewL) :-
    checkCondition(C, OldL, TmpL),
    considerAll([(P,Cs)|Ps], TmpL, NewL).

checkCondition(C, [encVF|L], [encVF|L]) :- 
    condition(C, privacy, edge, _, _, _).
checkCondition(C, L, [encVF|L]) :- 
    condition(C, privacy, edge, _, _, _), dif(L, [encVF|_]).

placeChain(Chain, NCP, OldP, NewP) :-
    placeChain(Chain, OldP, NewP),
    checkPlacement(NCP, NewP).

placeChain([], P, P). % base case
placeChain([VNF|VNFs], OldP, NewP) :- % if the VNF is already placed, skip it
    member(on(VNF, _), OldP),
    placeChain(VNFs, OldP, NewP).
placeChain([VNF|VNFs], OldP, NewP) :- % try place the VNF on a node with enough resources
    \+ member(on(VNF, _), OldP),
    vnf(VNF, HWReqs, _), node(N, HWCaps),  
    hwOK(N, HWReqs, HWCaps, OldP),
    placeChain(VNFs, [on(VNF, N)|OldP], NewP).

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