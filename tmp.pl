% placeChain/3 places the VNFs of the chain on the network, with head recursion
placeChain([VNF|VNFs], OldP, [on(VNF, N)|NewP]) :- % if the VNF is already placed, skip it
    placeChain(VNFs, OldP, NewP),
    member(on(VNF, N), OldP).
placeChain([VNF|VNFs], OldP, [on(VNF, N)|NewP]) :- % try place the VNF on a node with enough resources
    placeChain(VNFs, OldP, NewP),
    \+ member(on(VNF, _), OldP),
    vnf(VNF, HWReqs, _), node(N, HWCaps),  
    hwOK(N, HWReqs, HWCaps, OldP).
placeChain([], _, []). % base case


% sort properties by a list of ordered properties
mySort(RP, P, C) :-
    subtract(RP, P, Tmp),
    subtract(RP, Tmp, C).

considerAll([], L, L).
considerAll([(_, CIds)|Ps], OldL, NewL) :-
    consider(CIds, OldL, TmpL),
    considerAll(Ps, TmpL, NewL).

consider([], L, L).
consider([C|Cs], OldL, NewL) :-
    checkCondition(C, OldL, TmpL),
    consider(Cs, TmpL, NewL).