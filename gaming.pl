application(gamingService, [edgeGamingVF, cloudGamingVF]).
% vnf(Id, HWReqs, ProcessingTime)
vnf(edgeGamingVF, 4, 15).
vnf(cloudGamingVF, 10, 8).
vnf(encVF, 1, 10).

% node(Id, HwCaps)
node(node42, 10).
node(edge1, 5).
node(coolCloud, 20).

% link(From, To, FeatLat, FeatBw)
link(node42, edge1, 10, 30).
link(edge1, node42, 10, 30).
link(edge1, coolCloud, 20, 29).
link(coolCloud, edge1, 20, 100).
link(node42, coolCloud, 50, 10).
link(coolCloud, node42, 50, 10).
link(N, N, 0, inf). % no latency on self-links

% intent(gameAppOp, gamingServiceIntent, (chainToPlace, node42, [on(cloudGamingVF, coolCloud)]), Tf).

% the beast that generates the intent:
% intent(Stakeholder, IntentId, OldTarget, NewTarget) :-
% Ti = (chainToPlace, From, PartialPlacement) = (chainToPlace, node42, [on(cloudGamingVF, coolCloud)])
% Tf = (placedVNFchain, FinalPlacedChain, FinalPlacement) = 
%       (placedVNFchain, [encVF, edgeGamingVF, cloudGamingVF], [on(encVF, node42), on(edgeGamingVF, edge1), on(cloudGamingVF, coolCloud)])

intent(gameAppOp, gamingServiceIntent, Ti, Tf) :-  
    deliveryExpectation(gamingService, Ti, T1), % piazzare le VF edgeGamingVF: FromI -> edgeGamingVF -> cloudGamingVF
    propertyExpectation(privacy, _, _, T1, T2), % inserire encryptionVF prima di edgeGamingVF 
    propertyExpectation(bandwidth, edgeGamingVF, cloudGamingVF, T2, Tf). % > 30 Mbps
    % propertyExpectation(latency, node42, edgeGamingVF, T3, Tf). % < 50 ms 
    
propertyExpectation(latency, From, To, T1, T2) :- 
    condition(T1, From, To, latency, smaller, 50, ms, T2).
propertyExpectation(bandwidth, From, To, T1, T2) :- 
    condition(T1, From, To, bandwidth, larger, 30, megabps, T2).
propertyExpectation(privacy, From, To, T1, T2) :-
    condition(T1, From, To, privacy, high, _, _, T2).    

% deliveryExpectation/3 checks if the chain can be placed on the network
deliveryExpectation(App, (chainToPlace, _, PartialPlacement), (placedVNFchain, VNFChain, FinalPlacement)) :-
    application(App, VNFChain),
    placeVNF(VNFChain, PartialPlacement, FinalPlacement).

% placeVNF/5 places the VNFs of the chain on the network
placeVNF([], Placement, Placement).
placeVNF([VNF|VNFs], PartialPlacement, FinalPlacement) :-
    member(on(VNF, _), PartialPlacement), % if the VNF is already placed, skip it
    placeVNF(VNFs, PartialPlacement, FinalPlacement).
placeVNF([VNF|VNFs], PartialPlacement, FinalPlacement) :-
    \+ member(on(VNF, _), PartialPlacement),
    vnf(VNF, HWReqs, _), node(N, HWCaps),  
    % TODO: check cumulative hardware (findall and sumlist)
    HWReqs =< HWCaps, % check if the node has enough HW resources
    placeVNF(VNFs, [on(VNF, N)|PartialPlacement], FinalPlacement).

condition(T1, _, _, privacy, high, _, _, T2) :- 
    T1 = (TType, C, P),
    placeVNF([encVF], P, NewP),
    T2 = (TType, [encVF|C], NewP).

condition(T1, From, To, bandwidth, larger, Value, _, T1) :-
    T1 = (_, _, P),
    getBW(P, From, To, BW), BW >= Value.

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

getMinBW([on(_, M)], _, To, _, TmpBW, NewBW) :- 
    link(M, To, _, BW), NewBW is min(BW, TmpBW).
getMinBW([on(To, _)|_], _, To, _, BW, BW). % found To
getMinBW([on(VNF,_)|Ps], From, To, false, OldMin, NewMin) :- % before From
    dif(VNF,From), 
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
getMinBW([P1,P2|Ps], From, To, true, OldMin, NewMin) :-
    P1 = on(_, N), P2 = on(_, N),
    getMinBW([P2|Ps], From, To, true, OldMin, NewMin).
