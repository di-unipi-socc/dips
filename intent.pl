:-['data.pl', 'checks.pl'].

:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).
:- set_prolog_flag(stack_limit, 32 000 000 000).
:- set_prolog_flag(last_call_optimisation, true).

processIntent(IntentId, NUsers, Tfs) :-
    intent(_, IntentId, TargetId), 
    findall(Tf, deliveryLogic(IntentId, TargetId, NUsers, Tf), Ts),
    sort(Ts, Tfs).

deliveryLogic(IntentId, TId, NUsers, (L, Placement, UP)) :- 
    splitProperties(IntentId, CP, NCP),
    assembleChain(TId, CP, Chain),
    getDimension(Chain, NUsers, [], DChain),
    placeChain(DChain, NCP, Placement, UP), length(UP, L).

getDimension([], _, Chain, Chain).
getDimension([VNF|VNFs], Users, OldC, NewC) :-
    vnfXUser(VNF, Dim, (Low, High), _), between(Low, High, Users), 
    getDimension(VNFs, Users, [(VNF, Dim)|OldC], NewC).

splitProperties(IntentId, CP, NCP) :-
    findall((P,CIds), nonChangingProperty(IntentId, P, CIds), NCP),
    findall((P,CIds), relevantChangingProperty(IntentId, P, CIds), Cs), sort(Cs, CP).

relevantChangingProperty(IntentId, Priority, CIds) :-
    propertyExpectation(IntentId, Property, CIds), changingProperty(Priority, Property).

nonChangingProperty(IntentId,  Property, CIds) :-
    propertyExpectation(IntentId, Property, CIds), \+ changingProperty(_, Property).

assembleChain(TargetId, CP, Chain) :-
    target(TargetId, S), considerAll(CP, S, Chain).

considerAll([], L, L).
considerAll([(_, [])|Ps], L, NewL) :- considerAll(Ps, L, NewL).
considerAll([(P,[C|Cs])|Ps], OldL, NewL) :-
    checkCondition(C, OldL, TmpL),
    considerAll([(P,Cs)|Ps], TmpL, NewL).

placeChain(Chain, NCP, NewP, UP) :-
    placeChain(Chain, [], NewP),
    checkPlacement(NCP, NewP, [], UP).
placeChain([], P, P). % base case
placeChain([(VNF,Dim)|VNFs], OldP, NewP) :- % (try to) place the VNF on a node with enough resources
    vnf(VNF, Type, _), vnfXUser(VNF, Dim, _, HWReqs), node(N, Type, HWCaps),  
    hwOK(N, HWReqs, HWCaps, OldP),
    placeChain(VNFs, [on(VNF, Dim, N)|OldP], NewP).

hwOK(N, HWReqs, HWCaps, Placement) :- % hw resources are cumulative
    findall(HW, (member(on(VNF, V, N), Placement), vnfXUser(VNF, V, _, HW)), HWs), sumlist(HWs, HWSum),
    HWSum + HWReqs =< HWCaps.

checkPlacement([], _, UP, UP).
checkPlacement([(_, [])|Ps], Placement, OldUP, NewUP) :- checkPlacement(Ps, Placement, OldUP, NewUP).
checkPlacement([(P,[C|Cs])|Ps], Placement, OldUP, NewUP) :-
    checkCondition(C, Placement, OldUP, TmpUP),
    checkPlacement([(P,Cs)|Ps], Placement, TmpUP, NewUP).
