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
getLatency(P, From, To, 0) :- member(on(To, _, From), P). % node - VNF, but on(VNF, node) is in P
getLatency([on(VNF,_,N)|Ps], From, To, Lat) :- % node - VNF
    node(From, _, _), member(on(To, _, N1), Ps), dif(N1, From), link(From, N, TmpLat, _),
    getPathLat([on(VNF,_,N)|Ps], true, From, To, TmpLat, Lat).
getLatency(P, From, To, 0) :- member(on(From, _, To), P). % VNF - node, but on(VNF, node)
getLatency(P, From, To, Lat) :- % VNF - node / VNF - VNF
    member(on(From,_,_), P), 
    (node(To, _, _); (member(on(To,_,N), P), dif(N,To))),
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

addedAtEdge([X,Y|Zs], G, [X|NewZs]) :- X = (_,cloud), addedAtEdge([Y|Zs], G, NewZs).
addedAtEdge([X,Y|Zs], G, [G,X|NewZs]) :- X = (_,edge), addedAtEdge2([Y|Zs], G, NewZs).
addedAtEdge([X], _, [X]) :- X = (_,cloud).
addedAtEdge([X], G, [G,X,G]) :- X = (_,edge).
addedAtEdge([], _, []).

addedAtEdge2([X,Y|Zs], G, [X|NewZs]) :- X = (_,edge), addedAtEdge2([Y|Zs], G, NewZs).
addedAtEdge2([X,Y|Zs], G, [G,X|NewZs]) :- X = (_,cloud), addedAtEdge([Y|Zs], G, NewZs).
addedAtEdge2([X], G, [G,X]) :- X = (_,cloud).
addedAtEdge2([X], _, [X]) :- X = (_,edge).
addedAtEdge2([], _, []).

addedFromTo([X,Y|Zs], From, To, G, [X|NewZs]) :- X \== From, addedFromTo([Y|Zs], From, To, G, NewZs).
addedFromTo([From|Zs], From, To, G, [G, From|NewZs]) :- addedFromTo2(Zs, To, G, NewZs).

addedFromTo2([To|Zs], To, G, [To, G|Zs]).
addedFromTo2([X|Zs], To, G, [X|NewZs]) :- X \== To, addedFromTo2(Zs, To, G, NewZs).
