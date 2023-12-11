intent(infraIntent, infrPr, _, _).

% user(UserId, Priority).
user(gameAppOp, gold).
user(sh1, bronze).

%propertyExpectation(avInfraBronze1, infraIntent, chainAvailability, greater, bronze, 0.9, _, _, _).
propertyExpectation(avInfraBronze2, infraIntent, chainAvailability, lower, bronze, 0.99, _, _, _).
%propertyExpectation(avInfraSilver1, infraIntent, chainAvailability, greater, silver, 0.99, _, _, _).
propertyExpectation(avInfraSilver2, infraIntent, chainAvailability, lower, silver, 0.999, _, _, _).
%propertyExpectation(avInfraGold, infraIntent, chainAvailability, greater, gold, 0.999, _, _, _).
propertyExpectation(avInfraGold, infraIntent, chainAvailability, lower, gold, 1, _, _, _).

propertyExpectation(bwCapBronze, infraIntent, bandwidth, lower, bronze, 100, megabps, begin, end).
propertyExpectation(bwCapSilver, infraIntent, bandwidth, lower, silver, 500, megabps, begin, end).
propertyExpectation(bwCapGold, infraIntent, bandwidth, lower, gold, 1000, megabps, begin, end).

propertyExpectation(hwCapBronze, infraIntent, totChainHW, lower, bronze, 50, _, _, _).
propertyExpectation(hwCapSilver, infraIntent, totChainHW, lower, silver, 100, _, _, _).
propertyExpectation(hwCapGold, infraIntent, totChainHW, lower, gold, 200, _, _, _).

gt(gold, silver).
gt(silver, bronze).
gt(gold, bronze).

listMaxLevel(L, Max) :- member(Max, L), \+ (member(X, L), dif(X, Max), gt(X, Max)), !.
cap(Property, Level, Cap) :- propertyExpectation(_, _, Property, _, Level, Cap, _, _, _).
upgradeTo(Property, ReqValue, Level) :- 
    propertyExpectation(_, _, Property, _, Level, Cap, _, _, _), 
    Cap >= ReqValue, !.
upgradeTo(_, _, gold).