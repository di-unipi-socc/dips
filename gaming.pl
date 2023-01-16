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
link(edge1, coolCloud, 20, 100).
link(coolCloud, edge1, 20, 100).

hwTh(2).



% the beast that generates the intent:
% intent(Stakeholder, IntentId, OldTarget, NewTarget) :-
% Ti = (chainToPlace, From, PartialPlacement) = (chainToPlace, node42, [on(cloudGamingVF, coolCloud)])
% Tf = (placedVNFchain, FinalPlacedChain, FinalPlacement) = 
%       (placedVNFchain, [encVF, edgeGamingVF, cloudGamingVF], [on(encVF, node42), on(edgeGamingVF, edge1), on(cloudGamingVF, coolCloud)])

intent(gameAppOp, gamingServiceIntent, Ti, Tf) :-  
    deliveryExpectation(gamingService, Ti, T1), % piazzare le VF edgeGamingVF: FromI -> edgeGamingVF -> cloudGamingVF
    propertyExpectation(privacy, _, _, T1, T2), % inserire encryptionVF prima di edgeGamingVF 
    propertyExpectation(bandwidth, edgeGamingVF, cloudGamingVF, T2, T3), % > 30 Mbps
    propertyExpectation(latency, node42, edgeGamingVF, T3, Tf). % < 50 ms 
    
propertyExpectation(latency, From, To, T1, T2) :- 
    condition(T1, From, To, latency, smaller, 50, ms, T2).
propertyExpectation(bandwidth, From, To, T1, T2) :- 
    condition(T1, From, To, bandwidth, larger, 30, megabps, T2).
propertyExpectation(privacy, From, To, T1, T2) :-
    condition(T1, From, To, privacy, high, _, _, T2).

% TODO: an "expert" will write condition/8 predicates to express when the associated propertyExpectation/5 or deliveryExpectation/3 is satisfied
% TODO: define a priority among propertyExpectation "types"

% deliveryExpectation/3 checks if the chain can be placed on the network
deliveryExpectation(App, (chainToPlace, From, PartialPlacement), (placedVNFchain, FinalPlacedChain, FinalPlacement)) :-
    application(App, VNFChain),
    placeVNF(VNFChain, From, [], PartialPlacement, FinalPlacedChain, FinalPlacement).

% placeVNF/5 places the VNFs of the chain on the network
placeVNF([], _, Chain, Placement, Chain, Placement).
placeVNF([VNF|VNFs], From, PartialPlacedChain, PartialPlacement, FinalPlacedChain, FinalPlacement) :-
    vnf(VNF, HWReqs, _),
    node(N, HWCaps),  
    hwTh(T), HWReqs < HWCaps + T, % check if the node has enough HW resources (considering also a pre-defined HW threshold)
    placeVNF(VNFs, N, [VNF|PartialPlacedChain], [on(VNF, N)|PartialPlacement], FinalPlacedChain, FinalPlacement).

% for the latency property, we need to check the latency along the whole chain
condition((Step, C, P), From, To, latency, smaller, Value, _, (Step, C, P)) :-
    (node(N1, _); member(on(From, N1), P)), 
    (node(N2, _); member(on(To, N2), P)), 
    chainLatency(C, P, 0, ChainLat),
    ChainLat < Value.

chainLatency([], _, Lat, Lat).

