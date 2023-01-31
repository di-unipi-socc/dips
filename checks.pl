:-['utils.pl'].

% CHANGING PROPERTIES
checkCondition(C, [encVF|L], [encVF|L]) :- 
    condition(C, privacy, edge, _, _, _).
checkCondition(C, L, [encVF|L]) :- 
    condition(C, privacy, edge, _, _, _), dif(L, [encVF|_]).

placeChain(Chain, NCP, OldP, NewP, UP) :-
    placeChain(Chain, OldP, NewP),
    checkPlacement(NCP, NewP, [], UP).

% NON-CHANGING PROPERTIES
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