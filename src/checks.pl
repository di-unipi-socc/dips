:-['utils.pl'].

% CHANGING PROPERTIES
%% specific cases defined before general ones
chainModifiedByProperty(logging, edge, _, _, F, [F|C], [F|C]).
chainModifiedByProperty(logging, edge, _, _, F, C, [F|C]) :- dif(C, [F|_]).
chainModifiedByProperty(_, _, From, To, F, Chain, NewChain) :- var(From), var(To), addedAtEdge(Chain, F, NewChain).
chainModifiedByProperty(_, _, From, To, F, Chain, NewChain) :- nonvar(From), var(To), vnf(From, FromAff, _), addedBefore(Chain, (From, FromAff), F, NewChain).
chainModifiedByProperty(_, _, From, To, F, Chain, NewChain) :- var(From), nonvar(To), vnf(To, ToAff, _), addedAfter(Chain, (To, ToAff), F, NewChain).
chainModifiedByProperty(_, _, From, To, F, Chain, NewChain) :- nonvar(From), nonvar(To), vnf(From, FromAff, _), vnf(To, ToAff, _), addedFromTo(Chain, (From, FromAff), (To, ToAff), F, NewChain).

% NON-CHANGING PROPERTIES
checkProperty(latency, Placement, OldUP, OldUP) :-
    propertyExpectation(_, latency, smaller, _, Value, _, From, To), pathLat(Placement, From, To, Lat), 
    Lat =< Value.
checkProperty(latency, Placement, OldUP, [(latency, desired(Value), actual(Lat))|OldUP]) :-
    propertyExpectation(_, latency, smaller, soft, Value, _, From, To), pathLat(Placement, From, To, Lat), 
    Lat > Value.
checkProperty(bandwidth, Placement, OldUP, OldUP) :-
    propertyExpectation(_, bandwidth, larger, _, Value, _, From, To), minBW(Placement, From, To, BW),
    BW >= Value.
checkProperty(bandwidth, Placement, OldUP, [(bandwidth, desired(Value), actual(BW))|OldUP]) :-
    propertyExpectation(_, bandwidth, larger, soft, Value, _, From, To), minBW(Placement, From, To, BW),
    BW < Value.