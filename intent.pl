:-['data.pl', 'utils.pl']. % load data

% testing predicate
start(Tf) :- intent(gameAppOp, gamingServiceIntent, (chainToPlace, node42, [on(cloudGamingVF, coolCloud)]), Tf).

/* We define intent/4 predicates via sets of deliveryExpectation/3 and propertyExpectation/5 predicates.
   Each expectation has an initial and a final target, and it is triggered by (one or more) condition predicates.

   For the moment being, we consider two types of targets:
    - chainToPlace: that identify a chain to be placed on the network
    - placedVNFchain: that identify a chain that has been placed on the network

	For instance:
		intent(Stakeholder, IntentId, OldTarget, NewTarget)
		Ti = (chainToPlace, From, PartialPlacement)
		Tf = (placedVNFchain, FinalPlacedChain, FinalPlacement)

	intent/4 and propertyExpectation/5 predicates can be automatically generated starting from a standard format (e.g. RDF).
*/
intent(gameAppOp, gamingServiceIntent, Ti, Tf) :-  
    deliveryExpectation(gamingService, Ti, T1), % determines a placement for the gamingService chain
    propertyExpectation(privacy, _, _, T1, T2), % adds edge encryption to the chain and to the placement
    propertyExpectation(bandwidth, edgeGamingVF, cloudGamingVF, T2, T3), % checks that bandwidth is larger than 30 Mbps
    propertyExpectation(latency, node42, edgeGamingVF, T3, Tf). % checks that latency is smaller than 50 ms
    
propertyExpectation(latency, From, To, T1, T2) :- 
    condition(T1, From, To, latency, smaller, 50, ms, T2).
propertyExpectation(bandwidth, From, To, T1, T2) :- 
    condition(T1, From, To, bandwidth, larger, 30, megabps, T2).
propertyExpectation(privacy, From, To, T1, T2) :-
    condition(T1, From, To, privacy, edge, _, _, T2).    

% deliveryExpectation/3 and condition/8 predicates are written as Prolog rules by an expert.

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

condition(T1, _, _, privacy, edge, _, _, T2) :- 
    T1 = (TType, C, P),
    placeVNF([encVF], P, NewP),
    T2 = (TType, [encVF|C], NewP).

condition(T1, From, To, bandwidth, larger, Value, _, T1) :-
    T1 = (_, _, P),
    getBandwidth(P, From, To, BW), BW >= Value.

condition(T1, From, To, latency, smaller, Value, _, T1) :-
    T1 = (_, _, P),
    getLatency(P, From, To, Lat), Lat =< Value.
