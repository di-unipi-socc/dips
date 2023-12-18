intent(infraIntent, infrPr, _, _).

% user(UserId, Priority).
user(gameAppOp, gold).
user(renderAppOp, silver).
user(sh1, bronze).

propertyExpectation(avInfraBronze, infraIntent, chainAvailability, lower, bronze, 0.9, _, _, _).
propertyExpectation(avInfraSilver, infraIntent, chainAvailability, lower, silver, 0.99, _, _, _).
propertyExpectation(avInfraGold, infraIntent, chainAvailability, lower, gold, 0.999, _, _, _).

propertyExpectation(bwCapBronze, infraIntent, bandwidth, lower, bronze, 50, megabps, begin, end).
propertyExpectation(bwCapSilver, infraIntent, bandwidth, lower, silver, 100, megabps, begin, end).
propertyExpectation(bwCapGold, infraIntent, bandwidth, lower, gold, 500, megabps, begin, end).

propertyExpectation(hwCapBronze, infraIntent, totChainHW, lower, bronze, 50, _, _, _).
propertyExpectation(hwCapSilver, infraIntent, totChainHW, lower, silver, 100, _, _, _).
propertyExpectation(hwCapGold, infraIntent, totChainHW, lower, gold, 200, _, _, _).

gt(gold, silver).
gt(silver, bronze).
gt(gold, bronze).

listMaxLevel(L, Max) :- member(Max, L), \+ (member(X, L), dif(X, Max), gt(X, Max)), !.
cap(Property, Level, Cap) :- propertyExpectation(_, infraIntent, Property, _, Level, Cap, _, _, _).
upgradeTo(Property, ReqValue, Level) :- cap(Property, Level, Cap), Cap >= ReqValue, !.
upgradeTo(_, _, gold).