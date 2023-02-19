:-['utils.pl'].

% CHANGING PROPERTIES
chainModifiedByProperty(logging, edge, _, _, [(logVF,A)|C], [(logVF,A)|C]) :- vnf(logVF, A, _).
chainModifiedByProperty(logging, edge, _, _, C, [(logVF,A)|C]) :- dif(C, [(logVF,_)|_]), vnf(logVF, A, _).
chainModifiedByProperty(privacy, edge, From, To, Chain, NewChain) :- var(From), var(To), addedAtEdge(Chain, (encVF,edge), NewChain).
chainModifiedByProperty(privacy, edge, From, To, Chain, NewChain) :- 
    nonvar(From), nonvar(To), vnf(From, AffFrom, _), vnf(To, AffTo, _), 
    addedFromTo(Chain, (From, AffFrom), (To, AffTo), (encVF,edge), NewChain).

% NON-CHANGING PROPERTIES
checkProperty(P, Placement, OldUP, OldUP) :-
    propertyExpectation(_, P, smaller, _, Value, _, From, To),
    getLatency(Placement, From, To, Lat), 
    Lat =< Value.
checkProperty(P, Placement, OldUP, [(P, desired(Value), actual(Lat))|OldUP]) :-
    propertyExpectation(_, P, smaller, soft, Value, _, From, To),
    getLatency(Placement, From, To, Lat), 
    Lat > Value.

checkProperty(P, Placement, OldUP, OldUP) :-
    propertyExpectation(_, P, larger, _, Value, _, From, To),
    getBandwidth(Placement, From, To, BW), 
    BW >= Value.
checkProperty(P, Placement, OldUP, [(P, bandwidth, desired(Value), actual(BW))|OldUP]) :-
    propertyExpectation(_, P, larger, soft, Value, _, From, To),
    getBandwidth(Placement, From, To, BW), 
    BW < Value.