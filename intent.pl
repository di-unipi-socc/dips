:-['data.pl', 'utils.pl'].

% Ti = (NumberOfUsers, PartialPlacement)
% Tf = (Chain, FinalPlacement, TotCost, UnsatisfiedProperties)
start(NumberOfUsers, C, P, UP) :- processIntent(gSIntent, (NumberOfUsers, [on(cloudGamingVF, l, coolCloud)]), (C, P, UP)).

processIntent(IntentId, Ti, Tf) :-
    intent(_, IntentId), deliveryExpectation(IntentId, TargetId, TargetType),
    deliveryLogic(IntentId, TargetId, TargetType, Ti, Tf).

deliveryLogic(IntentId, TId, TType, (Users, OldPlacement), (Chain, Placement, UP)) :- 
    splitProperties(IntentId, TId, CP, NCP),
    assembleChain(TType, CP, Chain),
    % computeCost(Chain, Users, 0, Cost), % TODO: retrieve triples (VNF, version, HWReqs)
    getDimension(Chain, Users, [], DChain),
    reverse(DChain, RChain),
    placeChain(RChain, NCP, OldPlacement, Placement, UP).

getDimension([], _, Chain, Chain).
getDimension([VNF|VNFs], Users, OldC, NewC) :-
    vnfXUser(VNF, Version, (Low, High), _), between(Low, High, Users), 
    getDimension(VNFs, Users, [(VNF, Version)|OldC], NewC).

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

placeChain(Chain, NCP, OldP, NewP, UP) :-
    placeChain(Chain, OldP, NewP),
    checkPlacement(NCP, NewP, [], UP).

placeChain([], P, P). % base case
placeChain([(VNF,Version)|VNFs], OldP, NewP) :- % if the VNF is already placed, skip it
    member(on(VNF, Version, _), OldP),
    placeChain(VNFs, OldP, NewP).
placeChain([(VNF,Version)|VNFs], OldP, NewP) :- % try place the VNF on a node with enough resources
    \+ member(on(VNF, Version, _), OldP),
    vnf(VNF, _), vnfXUser(VNF, Version, _, HWReqs), node(N, HWCaps),  
    hwOK(N, HWReqs, HWCaps, OldP),
    placeChain(VNFs, [on(VNF, Version, N)|OldP], NewP).

hwOK(N, HWReqs, HWCaps, Placement) :-
    findall(HW, (member(on(VNF, V, N), Placement), vnfXUser(VNF, V, _, HW)), HWs), sumlist(HWs, HWSum),
    HWSum + HWReqs =< HWCaps.

checkPlacement([], _, UP, UP).
checkPlacement([(_, [])|Ps], Placement, OldUP, NewUP) :- checkPlacement(Ps, Placement, OldUP, NewUP).
checkPlacement([(P,[C|Cs])|Ps], Placement, OldUP, NewUP) :-
    checkCondition(C, Placement, OldUP, TmpUP),
    checkPlacement([(P,Cs)|Ps], Placement, TmpUP, NewUP).

checkCondition(C, Placement, OldUP, OldUP) :-
    condition(C, latency, smaller, Value, _, From, To),
    getLatency(Placement, From, To, Lat), 
    Lat =< Value.
checkCondition(C, Placement, OldUP, [(C, latency, desired(Value), actual(Lat))|OldUP]) :-
    condition(C, latency, smaller, Value, _, From, To),
    getLatency(Placement, From, To, Lat), 
    Lat > Value.

checkCondition(C, Placement, OldUP, OldUP) :-
    condition(C, bandwidth, larger, Value, _, From, To),
    getBandwidth(Placement, From, To, BW), 
    BW >= Value.
checkCondition(C, Placement, OldUP, [(C, bandwidth, desired(Value), actual(BW))|OldUP]) :-
    condition(C, bandwidth, larger, Value, _, From, To),
    getBandwidth(Placement, From, To, BW), 
    BW < Value.