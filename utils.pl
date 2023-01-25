getBandwidth(_, From, To, BW) :- % node - node
    node(From, _), node(To, _), link(From, To, _, BW).
getBandwidth([on(VNF,N)|Ps], From, To, BW) :- % node - VNF
    node(From, _), link(From, N, _, TmpBW), 
    getMinBW([on(VNF,N)|Ps], From, To, true, TmpBW, BW).
getBandwidth(P, From, To, BW) :- % VNF - node / VNF - VNF
    member(on(From, _), P), 
    (node(To, _); member(on(To, _), P)),
    getMinBW(P, From, To, false, inf, BW).

getMinBW([on(_, M)], _, To, _, TmpBW, NewBW) :- % base case when To is a node
    link(M, To, _, BW), NewBW is min(BW, TmpBW).
getMinBW([on(To, _)|_], _, To, _, BW, BW). % base case when To is a VNF
getMinBW([on(VNF,_)|Ps], From, To, false, OldMin, NewMin) :- % before From
    dif(VNF, From), 
    getMinBW(Ps, From, To, false, OldMin, NewMin).
getMinBW([P1,P2|Ps], From, To, _, _, NewMin) :- % found From
    P1 = on(From, N1), P2 = on(_, N2),
    link(N1, N2, _, BW),
    getMinBW([P2|Ps], From, To, true, BW, NewMin).
getMinBW([P1,P2|Ps], From, To, true, OldMin, NewMin) :- % before To
    P1 = on(_, N1), P2 = on(_, N2), dif(N1,N2),
    link(N1, N2, _, BW),
    TmpMin is min(OldMin, BW),
    getMinBW([P2|Ps], From, To, true, TmpMin, NewMin).
getMinBW([P1,P2|Ps], From, To, true, OldMin, NewMin) :- % when both VNF are on the same node, just go on 
    P1 = on(_, N), P2 = on(_, N),
    getMinBW([P2|Ps], From, To, true, OldMin, NewMin).

getLatency(_, From, To, Lat) :- % node - node
    node(From, _), node(To, _), link(From, To, Lat, _).
getLatency([on(VNF,N)|Ps], From, To, Lat) :- % node - VNF
    node(From, _), link(From, N, TmpLat, _), 
    getPathLat([on(VNF,N)|Ps], From, To, true, TmpLat, Lat).
getLatency(P, From, To, Lat) :- % VNF - node / VNF - VNF
    member(on(From, _), P), 
    (node(To, _); member(on(To, _), P)),
    getPathLat(P, From, To, false, 0, Lat).

getPathLat([on(V, M)], _, To, _, TmpLat, NewLat) :- % base case when To is a node
    link(M, To, Lat, _), vnf(V, _, ProcessingTime),
    NewLat is TmpLat + Lat + ProcessingTime.
getPathLat([on(To, _)|_], _, To, _, TmpLat, NewLat) :- % base case when To is a VNF
    vnf(To, _, ProcessingTime), NewLat is TmpLat + ProcessingTime.
getPathLat([on(VNF,_)|Ps], From, To, false, TmpLat, NewLat) :- % before From
    dif(VNF, From), 
    getPathLat(Ps, From, To, false, TmpLat, NewLat).
getPathLat([P1,P2|Ps], From, To, _, _, NewLat) :- % found From
    P1 = on(From, N1), P2 = on(_, N2),
    link(N1, N2, FeatLat, _), vnf(From, _, ProcessingTime),
    Lat is FeatLat + ProcessingTime,
    getPathLat([P2|Ps], From, To, true, Lat, NewLat).
getPathLat([P1,P2|Ps], From, To, true, TmpLat, NewLat) :- % before To
    P1 = on(V, N1), P2 = on(_, N2), dif(N1,N2),
    link(N1, N2, FeatLat, _), vnf(V, _, ProcessingTime),
    Lat is TmpLat + FeatLat + ProcessingTime,
    getPathLat([P2|Ps], From, To, true, Lat, NewLat).
getPathLat([P1,P2|Ps], From, To, true, TmpLat, NewLat) :- % when both VNF are on the same node, only add processing time
    P1 = on(V, N), P2 = on(_, N),
    vnf(V, _, ProcessingTime), 
    Lat is TmpLat + ProcessingTime,
    getPathLat([P2|Ps], From, To, true, Lat, NewLat).

getCost(VNF, NumberOfUsers, Cost) :- 
    vnfXUser(VNF, (Low, High), Cost), between(Low, High, NumberOfUsers).