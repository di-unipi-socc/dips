getBandwidth(_, From, To, BW) :- % node - node
    node(From, _, _), node(To, _, _), link(From, To, _, BW).
getBandwidth([on(VNF,_,N)|Ps], From, To, BW) :- % node - VNF
    node(From, _, _), link(From, N, _, TmpBW), 
    getMinBW([on(VNF,_,N)|Ps], true, From, To, TmpBW, BW).
getBandwidth(P, From, To, BW) :- % VNF - node / VNF - VNF
    member(on(From, _, _), P), 
    (node(To, _, _); member(on(To,_,_), P)),
    getMinBW(P, false, From, To, inf, BW).

getMinBW([on(_,_,M)], true, _, To, TmpBW, NewBW) :- % base case when To is a node
    link(M, To, _, BW), NewBW is min(BW, TmpBW).
getMinBW([on(To,_,_)|_], true, _, To, BW, BW). % base case when To is a VNF
getMinBW([on(VNF,_,_)|Ps], false, From, To, OldMin, NewMin) :- % before From
    dif(VNF, From), getMinBW(Ps, false, From, To, OldMin, NewMin).
getMinBW([P1,P2|Ps], false, From, To, _, NewMin) :- % found From
    P1 = on(From,_,N1), P2 = on(_,_,N2),
    link(N1, N2, _, BW),
    getMinBW([P2|Ps], true, From, To, BW, NewMin).
getMinBW([P1,P2|Ps], true, From, To, OldMin, NewMin) :- % before To
    P1 = on(_,_,N1), P2 = on(_,_,N2), dif(N1,N2),
    link(N1, N2, _, BW),
    TmpMin is min(OldMin, BW),
    getMinBW([P2|Ps], true, From, To, TmpMin, NewMin).
getMinBW([P1,P2|Ps], true, From, To, OldMin, NewMin) :- % when both VNF are on the same node, just go on 
    P1 = on(_,_,N), P2 = on(_,_,N),
    getMinBW([P2|Ps], true, From, To, OldMin, NewMin).

getLatency(_, From, To, Lat) :- % node - node
    node(From, _, _), node(To, _, _), link(From, To, Lat, _).
getLatency([on(VNF,_,N)|Ps], From, To, Lat) :- % node - VNF
    node(From, _, _), link(From, N, TmpLat, _), 
    getPathLat([on(VNF,_,N)|Ps], true, From, To, TmpLat, Lat).
getLatency(P, From, To, Lat) :- % VNF - node / VNF - VNF
    member(on(From,_,_), P), 
    (node(To, _, _); member(on(To,_,_), P)),
    getPathLat(P, false, From, To, 0, Lat).

getPathLat([on(V,_,M)], true, _, To, TmpLat, NewLat) :- % base case when To is a node
    link(M, To, Lat, _), vnf(V, _, ProcessingTime),
    NewLat is TmpLat + Lat + ProcessingTime.
getPathLat([on(To,_,_)|_], true, _, To, TmpLat, NewLat) :- % base case when To is a VNF
    vnf(To, _, ProcessingTime), NewLat is TmpLat + ProcessingTime.
getPathLat([on(VNF,_,_)|Ps], false, From, To, TmpLat, NewLat) :- % before From
    dif(VNF, From), getPathLat(Ps, false, From, To, TmpLat, NewLat).
getPathLat([P1,P2|Ps], false, From, To, _, NewLat) :- % found From
    P1 = on(From,_,N1), P2 = on(_,_,N2),
    link(N1, N2, FeatLat, _), vnf(From, _, ProcessingTime),
    Lat is FeatLat + ProcessingTime,
    getPathLat([P2|Ps], true, From, To, Lat, NewLat).
getPathLat([P1,P2|Ps], true, From, To, TmpLat, NewLat) :- % between From and To
    P1 = on(V,_,N1), P2 = on(_,_,N2), dif(N1,N2),
    link(N1, N2, FeatLat, _), vnf(V, _, ProcessingTime),
    Lat is TmpLat + FeatLat + ProcessingTime,
    getPathLat([P2|Ps], true, From, To, Lat, NewLat).
getPathLat([P1,P2|Ps], true, From, To, TmpLat, NewLat) :- % when both VNF are on the same node, only add processing time
    P1 = on(V,_,N), P2 = on(_,_,N),
    vnf(V, _, ProcessingTime), 
    Lat is TmpLat + ProcessingTime,
    getPathLat([P2|Ps], true, From, To, Lat, NewLat).

addAtEdge(L, VNF, NewL) :- addAtEdge(L, VNF, [], NewL).
addAtEdge([T], _, X, NewX) :- reverse([T|X], NewX).
addAtEdge([L,R|Rest], VNF, X, NewX) :-
    vnf(L, A1, _), vnf(R, A2, _), A1 == A2,
    addAtEdge([R|Rest], VNF, [L|X], NewX).
addAtEdge([E,C|Rest], VNF, X, NewX) :-
    vnf(E, edge, _), vnf(C, cloud, _), dif(VNF, E),
    addAtEdge([C|Rest], VNF, [VNF, E|X], NewX).
addAtEdge([E,C|Rest], VNF, X, NewX) :-
    vnf(E, edge, _), vnf(C, cloud, _), VNF == E,
    addAtEdge([C|Rest], VNF, X, NewX).
addAtEdge([C,E|Rest], VNF, X, NewX) :-
    vnf(C, cloud, _), vnf(E, edge, _), dif(VNF, C),
    addAtEdge([E|Rest], VNF, [VNF, C|X], NewX).
addAtEdge([C,E|Rest], VNF, X, NewX) :-
    vnf(C, cloud, _), vnf(E, edge, _), VNF == C,
    addAtEdge([E|Rest], VNF, X, NewX).

addFromTo(L, From, To, VNF, NewL) :- addFromTo(L, false, From, To, VNF, [], NewL).
addFromTo([], true, _, _, _, X, NewX) :- reverse(X, NewX).
addFromTo([To], true, _, To, VNF, X, NewX) :- 
    reverse([VNF, To|X], NewX).
addFromTo([T|Rest], false, From, To, VNF, X, NewX) :- % before From
    dif(T, From), addFromTo(Rest, false, From, To, VNF, [T|X], NewX).
addFromTo([From|Rest], false, From, To, VNF, X, NewX) :- % found From
    addFromTo(Rest, true, From, To, VNF, [From, VNF|X], NewX).
addFromTo([T|Rest], true, From, To, VNF, X, NewX) :- % between From and To
    dif(T, To), addFromTo(Rest, true, From, To, VNF, [T|X], NewX).
addFromTo([To|Rest], true, From, To, VNF, X, NewX) :- % after To
    addFromTo(Rest, true, From, To, VNF, [VNF, To|X], NewX).
