:-['utils.pl'].

% CHANGING PROPERTIES
%% specific cases defined before general ones
chainModifiedByProperty(logging, edge, _, _, F, [F|C], [F|C]).
chainModifiedByProperty(logging, edge, _, _, F, C, [F|C]) :- dif(C, [F|_]).
% TODO: mutuamente esclusivo con i casi specifici
chainModifiedByProperty(_, _, From, To, F, Chain, NewChain) :- var(From), var(To), addedAtEdge(Chain, F, NewChain).
chainModifiedByProperty(_, _, From, To, F, Chain, NewChain) :- nonvar(From), var(To), vnf(From, FromAff, _), addedBefore(Chain, (From, FromAff), F, NewChain).
chainModifiedByProperty(_, _, From, To, F, Chain, NewChain) :- var(From), nonvar(To), vnf(To, ToAff, _), addedAfter(Chain, (To, ToAff), F, NewChain).
chainModifiedByProperty(_, _, From, To, F, Chain, NewChain) :- nonvar(From), nonvar(To), vnf(From, FromAff, _), vnf(To, ToAff, _), addedFromTo(Chain, (From, FromAff), (To, ToAff), F, NewChain).

% NON-CHANGING PROPERTIES

% Latency
checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, latency, smaller, _, Value, _, From, To), pathLat(Placement, From, To, Lat), 
    Lat =< Value.
checkProperty(PId, Placement, OldUP, [(PId, desired(Value), actual(Lat))|OldUP]) :-
    propertyExpectation(PId, _, latency, smaller, soft, Value, _, From, To), pathLat(Placement, From, To, Lat), 
    Lat > Value.

% Bandwidth
checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, bandwidth, larger, _, Value, _, From, To), minBW(Placement, From, To, BW),
    BW >= Value.
checkProperty(PId, Placement, OldUP, [(PId, desired(Value), actual(BW))|OldUP]) :-
    propertyExpectation(PId, _, bandwidth, larger, soft, Value, _, From, To), minBW(Placement, From, To, BW),
    BW < Value.

% Node Affinity
checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, affinity, dedicated, _, _, _, V, _), 
    member(on(V,_,N), Placement), \+ (member(on(V1,_,N), Placement), dif(V1, V)).
checkProperty(PId, Placement, OldUP, [(PId, desired(dedicated), actual(L))|OldUP]) :-
    propertyExpectation(PId, _, affinity, dedicated, soft, _, _, V, _), 
    member(on(V,_,N), Placement), findall(N, member(on(_,_,N), Placement), Nodes), length(Nodes, L), L > 1.
    % maybe put in "actual" the list of other VFs on N? not only how many?

checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, affinity, same, _, _, _, V, V1), 
    member(on(V,_,N), Placement), member(on(V1,_,N), Placement).
checkProperty(PId, Placement, OldUP, [(PId, desired(same), actual(N1,N2))|OldUP]) :-
    propertyExpectation(PId, _, affinity, same, soft, _, _, V, V1), 
    member(on(V,_,N), Placement), member(on(V1,_,N1), Placement), dif(N, N2).

% TOTAL MAX HW LOAD
checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, hardware, smaller, _, Value, _, _, _),
    findall(HW, (member(on(VNF,V,_), Placement), vnfXUser(VNF, V, _, HW)), HWs), sumlist(HWs, TotHW),
    TotHW =< Value.
checkProperty(PId, Placement, OldUP, [(PId, desired(Value), actual(TotHW))|OldUP]) :-
    propertyExpectation(PId, _, hardware, smaller, soft, Value, _, _, _),
    findall(HW, (member(on(VNF,V,_), Placement), vnfXUser(VNF, V, _, HW)), HWs), sumlist(HWs, TotHW),
    TotHW > Value.

