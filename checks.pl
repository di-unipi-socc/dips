:-['utils.pl'].

% CHANGING PROPERTIES
checkCondition(C, [logVF|L], [logVF|L]) :- 
    condition(C, logging, edge, _, _, _, _, _).
checkCondition(C, L, [logVF|L]) :- 
    condition(C, logging, edge, _, _, _, _, _), dif(L, [logVF|_]).

checkCondition(C, L, NewL) :-
    condition(C, privacy, edge, _, _, _, _, _),
    addAtEdge(L, (encVF, decVF), NewL).

% NON-CHANGING PROPERTIES
checkCondition(C, Placement, OldUP, OldUP) :-
    condition(C, latency, smaller, _, Value, _, From, To),
    getLatency(Placement, From, To, Lat), 
    Lat =< Value.
checkCondition(C, Placement, OldUP, [(C, latency, desired(Value), actual(Lat))|OldUP]) :-
    condition(C, latency, smaller, s, Value, _, From, To),
    getLatency(Placement, From, To, Lat), 
    Lat > Value.

checkCondition(C, Placement, OldUP, OldUP) :-
    condition(C, bandwidth, larger, _, Value, _, From, To),
    getBandwidth(Placement, From, To, BW), 
    BW >= Value.
checkCondition(C, Placement, OldUP, [(C, bandwidth, desired(Value), actual(BW))|OldUP]) :-
    condition(C, bandwidth, larger, soft, Value, _, From, To),
    getBandwidth(Placement, From, To, BW), 
    BW < Value.