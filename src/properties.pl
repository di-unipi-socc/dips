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
checkProperty(PId, Placement, OldUP, [(latency, desired(Value), actual(Lat))|OldUP]) :-
    propertyExpectation(PId, _, latency, smaller, soft, Value, _, From, To), pathLat(Placement, From, To, Lat), 
    Lat > Value.

% Bandwidth
checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, bandwidth, larger, _, Value, _, From, To), minBW(Placement, From, To, BW),
    BW >= Value.
checkProperty(PId, Placement, OldUP, [(bandwidth, desired(Value), actual(BW))|OldUP]) :-
    propertyExpectation(PId, _, bandwidth, larger, soft, Value, _, From, To), minBW(Placement, From, To, BW),
    BW < Value.

% Node Affinity
checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, affinity, dedicated, _, _, _, V, _), 
    member(on(V, N), Placement), \+ (member(on(V1, N), Placement), dif(V1, V)).
    % findall(N, member(on(_, N), Placement), Nodes), length(Nodes, 1).
checkProperty(PId, Placement, OldUP, [(affinity, desired(dedicated), actual(L)]) :-
    propertyExpectation(PId, _, affinity, dedicated, soft, _, _, V, _), 
    member(on(V, N), Placement), findall(N, member(on(_, N), Placement), Nodes), 
    length(Nodes, L), L > 1.
    % member(on(V1, N), Placement), dif(V1, V).

checkProperty(PId, Placement, OldUP, OldUP) :-
    propertyExpectation(PId, _, affinity, same, _, _, _, V, V1), 
    member(on(V, N), Placement), member(on(V1, N), Placement).
checkProperty(PId, Placement, OldUP, [(affinity, desired(same), actual(N1,N2))|OldUP]) :-
    propertyExpectation(PId, _, affinity, same, soft, _, _, V, V1), 
    member(on(V, N), Placement), member(on(V1, N1), Placement), dif(N, N2).



