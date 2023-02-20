getBandwidth([on(F,_,N)|Ps], From, To, BW) :-
    node(From, _, _), link(From, N, _, TmpBW), 
    getMinBW([on(F,_,N)|Ps], true, From, To, TmpBW, BW).
getBandwidth(P, From, To, BW) :-
    member(on(From, _, _), P), 
    (node(To, _, _); member(on(To,_,_), P)),
    getMinBW(P, false, From, To, inf, BW).
getBandwidth(_, From, To, BW) :-
    node(From, _, _), node(To, _, _), link(From, To, _, BW).