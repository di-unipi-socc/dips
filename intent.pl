% testing predicate
start(Tf) :- intent(gameAppOp, gamingServiceIntent, (chainToPlace, node42, [on(cloudGamingVF, coolCloud)]), Tf).

/* intent(Stakeholder, IntentId, OldTarget, NewTarget)
    Ti = (chainToPlace, From, PartialPlacement)
    Tf = (placedVNFchain, FinalPlacedChain, FinalPlacement)
*/
intent(gameAppOp, gamingServiceIntent, Ti, Tf) :-  
    deliveryExpectation(gamingService, Ti, T1), % piazzare le VF edgeGamingVF: FromI -> edgeGamingVF -> cloudGamingVF
    propertyExpectation(privacy, _, _, T1, T2), % inserire encryptionVF prima di edgeGamingVF 
    propertyExpectation(bandwidth, edgeGamingVF, cloudGamingVF, T2, T3), % > 30 Mbps
    propertyExpectation(latency, node42, edgeGamingVF, T3, Tf). % < 50 ms 
    
propertyExpectation(latency, From, To, T1, T2) :- 
    condition(T1, From, To, latency, smaller, 25, ms, T2).
propertyExpectation(bandwidth, From, To, T1, T2) :- 
    condition(T1, From, To, bandwidth, larger, 10, megabps, T2).
propertyExpectation(privacy, From, To, T1, T2) :-
    condition(T1, From, To, privacy, high, _, _, T2).    

% deliveryExpectation/3 checks if the chain can be placed on the network
deliveryExpectation(App, (chainToPlace, _, PartialPlacement), (placedVNFchain, VNFChain, FinalPlacement)) :-
    application(App, VNFChain),
    placeVNF(VNFChain, PartialPlacement, FinalPlacement).

% placeVNF/3 places the VNFs of the chain on the network
placeVNF([], P, P). % base case
placeVNF([VNF|VNFs], PartialPlacement, FinalPlacement) :- % if the VNF is already placed, skip it
    member(on(VNF, _), PartialPlacement),
    placeVNF(VNFs, PartialPlacement, FinalPlacement).
placeVNF([VNF|VNFs], PartialPlacement, FinalPlacement) :- % try place the VNF on a node with enough resources
    \+ member(on(VNF, _), PartialPlacement),
    vnf(VNF, HWReqs, _), node(N, HWCaps),  
    hwOK(N, HWReqs, HWCaps, PartialPlacement),
    placeVNF(VNFs, [on(VNF, N)|PartialPlacement], FinalPlacement).

% check cumulative hardware, keeping into account the already placed VNFs
hwOK(N, HWReqs, HWCaps, Placement) :-
    findall(HW, (member(on(V, N), Placement), vnf(V, HW, _)), HWs), sumlist(HWs, HWSum),
    HWSum + HWReqs =< HWCaps.

condition(T1, _, _, privacy, high, _, _, T2) :- 
    T1 = (TType, C, P),
    placeVNF([encVF], P, NewP),
    T2 = (TType, [encVF|C], NewP).

condition(T1, From, To, bandwidth, larger, Value, _, T1) :-
    T1 = (_, _, P),
    getBW(P, From, To, BW), BW >= Value.

condition(T1, From, To, latency, smaller, Value, _, T1) :-
    T1 = (_, _, P),
    getLat(P, From, To, Lat), Lat =< Value.

getBW(_, From, To, BW) :- % node - node
    node(From, _), node(To, _), link(From, To, _, BW).
getBW([on(VNF,N)|Ps], From, To, BW) :- % node - VNF
    node(From, _), link(From, N, _, TmpBW), 
    getMinBW([on(VNF,N)|Ps], From, To, true, TmpBW, BW).
getBW(P, From, To, BW) :- % VNF - node
    member(on(From, _), P), node(To, _), 
    getMinBW(P, From, To, false, inf, BW). 
getBW(P, From, To, BW) :- % VNF - VNF
    member(on(From, _), P), member(on(To, _), P),
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

getLat(_, From, To, Lat) :- % node - node
    node(From, _), node(To, _), link(From, To, Lat, _).
getLat([on(VNF,N)|Ps], From, To, Lat) :- % node - VNF
    node(From, _), link(From, N, TmpLat, _), 
    getPathLat([on(VNF,N)|Ps], From, To, true, TmpLat, Lat).
getLat(P, From, To, Lat) :- % VNF - node
    member(on(From, _), P), node(To, _), 
    getPathLat(P, From, To, false, 0, Lat).
getLat(P, From, To, Lat) :- % VNF - VNF
    member(on(From, _), P), member(on(To, _), P),
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
