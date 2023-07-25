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

% Node Affinity (maybe put in "actual" the list of other VFs on N? not only how many?)
checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, affinity, dedicated, _, _, _, V, _), 
    member(on(V,_,N), Placement), \+ (member(on(V1,_,N), Placement), dif(V1, V)).
checkProperty(PId, Placement, OldUP, [(PId, desired(dedicated), actual(L))|OldUP]) :-
    propertyExpectation(PId, _, affinity, dedicated, soft, _, _, V, _), 
    member(on(V,_,N), Placement), findall(N, member(on(_,_,N), Placement), Nodes), length(Nodes, L), L > 1.

checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, affinity, same, _, _, _, V, V1), 
    member(on(V,_,N), Placement), member(on(V1,_,N), Placement).
checkProperty(PId, Placement, OldUP, [(PId, desired(same), actual(N1,N2))|OldUP]) :-
    propertyExpectation(PId, _, affinity, same, soft, _, _, V, V1), 
    member(on(V,_,N1), Placement), member(on(V1,_,N2), Placement), dif(N1, N2).

% Numerical properties (greater/smaller)
checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, Property, Bound, _, Desired, _, From, To),
    value(Property, Placement, (From,To), Actual), respectBound(Bound, Actual, Desired).
checkProperty(PId, Placement, OldUP, [(PId, desired(Desired), actual(Actual))|OldUP]) :-
    propertyExpectation(PId, _, Property, Bound, soft, Desired, _, From, To),
    value(Property, Placement, (From,To), Actual), \+ respectBound(Bound, Actual, Desired).

value(latency, Placement, (From,To), Lat) :- pathLat(Placement, From, To, Lat).
value(bandwidth, Placement, (From,To), BW) :- minBW(Placement, From, To, BW).
value(totHW, Placement, _, TotHW) :- hwAllocation(Placement, AllocHW), sumAlloc(AllocHW, TotHW).
value(avgHW, Placement, _, AvgHW) :- hwAllocation(Placement, AllocHW), avgAlloc(AllocHW, AvgHW).
value(nodes, Placement, _, L) :- distinctNodes(Placement, Nodes), length(Nodes, L).

respectBound(greater, Actual, Desired) :- Actual >= Desired.
respectBound(smaller, Actual, Desired) :- Actual =< Desired.
respectBound(equal, Actual, Desired) :- Actual =:= Desired.