:-['utils.pl'].

% CHANGING PROPERTIES
% add at the beginning of the chain
checkCondition(C, [logVF|L], [logVF|L]) :- 
    condition(C, logging, edge, _, _).
checkCondition(C, L, [logVF|L]) :- 
    condition(C, logging, edge, _, _), dif(L, [logVF|_]).

% add at the board (whenever affinitiy changes)
checkCondition(C, L, NewL) :-
    condition(C, privacy, edge, From, To), var(From), var(To),
    addAtEdge(L, encVF, NewL).
% add before 'From' and after 'To' (specified by the user)
checkCondition(C, L, NewL) :-
    condition(C, privacy, edge, From, To), nonvar(From), nonvar(To),
    addFromTo(L, From, To, encVF, NewL).

% NON-CHANGING PROPERTIES
checkCondition(C, Placement, OldUP, OldUP) :-
    condition(C, latency, smaller, _, Value, _, From, To),
    getLatency(Placement, From, To, Lat), 
    Lat =< Value.
checkCondition(C, Placement, OldUP, [(C, latency, desired(Value), actual(Lat))|OldUP]) :-
    condition(C, latency, smaller, soft, Value, _, From, To),
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