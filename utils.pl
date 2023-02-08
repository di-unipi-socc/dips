getBandwidth(_, From, To, BW) :- % node - node
    node(From, _, _), node(To, _, _), link(From, To, _, BW).
getBandwidth([on(VNF,_,N)|Ps], From, To, BW) :- % node - VNF
    node(From, _, _), link(From, N, _, TmpBW), 
    getMinBW([on(VNF,_,N)|Ps], From, To, true, TmpBW, BW).
getBandwidth(P, From, To, BW) :- % VNF - node / VNF - VNF
    member(on(From, _, _), P), 
    (node(To, _, _); member(on(To,_,_), P)),
    getMinBW(P, From, To, false, inf, BW).

getMinBW([on(_,_,M)], _, To, _, TmpBW, NewBW) :- % base case when To is a node
    link(M, To, _, BW), NewBW is min(BW, TmpBW).
getMinBW([on(To,_,_)|_], _, To, _, BW, BW). % base case when To is a VNF
getMinBW([on(VNF,_,_)|Ps], From, To, false, OldMin, NewMin) :- % before From
    dif(VNF, From), 
    getMinBW(Ps, From, To, false, OldMin, NewMin).
getMinBW([P1,P2|Ps], From, To, _, _, NewMin) :- % found From
    P1 = on(From,_,N1), P2 = on(_,_,N2),
    link(N1, N2, _, BW),
    getMinBW([P2|Ps], From, To, true, BW, NewMin).
getMinBW([P1,P2|Ps], From, To, true, OldMin, NewMin) :- % before To
    P1 = on(_,_,N1), P2 = on(_,_,N2), dif(N1,N2),
    link(N1, N2, _, BW),
    TmpMin is min(OldMin, BW),
    getMinBW([P2|Ps], From, To, true, TmpMin, NewMin).
getMinBW([P1,P2|Ps], From, To, true, OldMin, NewMin) :- % when both VNF are on the same node, just go on 
    P1 = on(_,_,N), P2 = on(_,_,N),
    getMinBW([P2|Ps], From, To, true, OldMin, NewMin).

getLatency(_, From, To, Lat) :- % node - node
    node(From, _, _), node(To, _, _), link(From, To, Lat, _).
getLatency([on(VNF,_,N)|Ps], From, To, Lat) :- % node - VNF
    node(From, _, _), link(From, N, TmpLat, _), 
    getPathLat([on(VNF,_,N)|Ps], From, To, true, TmpLat, Lat).
getLatency(P, From, To, Lat) :- % VNF - node / VNF - VNF
    member(on(From,_,_), P), 
    (node(To, _, _); member(on(To,_,_), P)),
    getPathLat(P, From, To, false, 0, Lat).

getPathLat([on(V,_,M)], _, To, _, TmpLat, NewLat) :- % base case when To is a node
    link(M, To, Lat, _), vnf(V, _, ProcessingTime),
    NewLat is TmpLat + Lat + ProcessingTime.
getPathLat([on(To,_,_)|_], _, To, _, TmpLat, NewLat) :- % base case when To is a VNF
    vnf(To, _, ProcessingTime), NewLat is TmpLat + ProcessingTime.
getPathLat([on(VNF,_,_)|Ps], From, To, false, TmpLat, NewLat) :- % before From
    dif(VNF, From), 
    getPathLat(Ps, From, To, false, TmpLat, NewLat).
getPathLat([P1,P2|Ps], From, To, _, _, NewLat) :- % found From
    P1 = on(From,_,N1), P2 = on(_,_,N2),
    link(N1, N2, FeatLat, _), vnf(From, _, ProcessingTime),
    Lat is FeatLat + ProcessingTime,
    getPathLat([P2|Ps], From, To, true, Lat, NewLat).
getPathLat([P1,P2|Ps], From, To, true, TmpLat, NewLat) :- % before To
    P1 = on(V,_,N1), P2 = on(_,_,N2), dif(N1,N2),
    link(N1, N2, FeatLat, _), vnf(V, _, ProcessingTime),
    Lat is TmpLat + FeatLat + ProcessingTime,
    getPathLat([P2|Ps], From, To, true, Lat, NewLat).
getPathLat([P1,P2|Ps], From, To, true, TmpLat, NewLat) :- % when both VNF are on the same node, only add processing time
    P1 = on(V,_,N), P2 = on(_,_,N),
    vnf(V, _, ProcessingTime), 
    Lat is TmpLat + ProcessingTime,
    getPathLat([P2|Ps], From, To, true, Lat, NewLat).

addAtEdge(L, What, NewL) :- addAtEdge(L, What, [], NewL).

%addAtEdge([], _, X, NewX) :- reverse(X, NewX).
addAtEdge([T], _, X, NewX) :- reverse([T|X], NewX).
addAtEdge([L,R|Rest], What, X, NewX) :-
    vnf(L, A1, _), vnf(R, A2, _), A1 == A2,
    addAtEdge([R|Rest], What, [L|X], NewX).
addAtEdge([E,C|Rest], What, X, NewX) :-
    vnf(E, edge, _), vnf(C, cloud, _), What = (E2C, _), dif(E2C, E),
    addAtEdge([C|Rest], What, [E2C, E|X], NewX).
addAtEdge([E,C|Rest], What, X, NewX) :-
    vnf(E, edge, _), vnf(C, cloud, _), What = (E2C, _), E2C == E,
    addAtEdge([C|Rest], What, X, NewX).
addAtEdge([C,E|Rest], What, X, NewX) :-
    vnf(C, cloud, _), vnf(E, edge, _), What = (_, C2E), dif(C2E, C),
    addAtEdge([E|Rest], What, [C2E, C|X], NewX).
addAtEdge([C,E|Rest], What, X, NewX) :-
    vnf(C, cloud, _), vnf(E, edge, _), What = (_, C2E), C2E == C,
    addAtEdge([E|Rest], What, X, NewX).