application(gamingService, [edgeGamingVF, cloudGamingVF]).
vnf(edgeGamingVF, 4).
vnf(cloudGamingVF, 10).

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