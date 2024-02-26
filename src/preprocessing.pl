/* multidips(Oks) :- 
    propertyDict(AllProps),
    findall(Prop-Ps, (member(Prop, AllProps), group_by(Prop, pE(PId, IId, Prop), propertyExpectation(PId, IId, Prop), Ps)), GProperties),
    preprocessing(GProperties, Oks).

propertyDict(AllProps):- findall(P, propertyExpectation(_, _, P), AllP), sort(AllP, AllProps).

propertyExpectation(PId, IId, P) :- (propertyExpectation(PId, IId, P, _, _, _); propertyExpectation(PId, IId, P, _, _, _, _, _, _)), dif(IId, infraIntent).

preprocessing([P-Ps|Groups], [P|Ok]) :-
    preprocessing(Groups, Ok),
    once(preprocessProperty(P, Ps)).
preprocessing([], []).

preprocessProperty(affinity, Ps) :- 
    findall(PId, (member(pE(PId, IId, affinity), Ps), propertyExpectation(PId, IId, affinity, dedicated, hard, _, _, _, _)), AffinityDedicated),
    findall(NId, node(NId, _, _), Nodes),
    length(AffinityDedicated, LP), length(Nodes, LN), LP =< LN. */

checkAffinity:-
    findall(PId, (propertyExpectation(PId, _, affinity, dedicated, hard, _, _, _, _)), AffinityDedicated),
    findall(NId, node(NId, _, _), Nodes),
    length(AffinityDedicated, LP), length(Nodes, LN), LP =< LN.

checkHW(Compatibles):-
    findall(req(VNF,IId,L,HW), hwXvnf(VNF,IId,L,HW), VNFs),
    singleCompatible(VNFs, Compatibles),!.

% substitute with [Comp|Atibles] to get for all VNFs (not just singletons), 
% and remove the second clause of singleCompatible/2.
singleCompatible([req(V,I,L,HWReqs)|Cs], [(V,I,HWReqs,[Compatible])|Rest]):-
    singleCompatible(Cs, Rest),
    findall(N, (node(N, L, HWCaps), HWReqs =< HWCaps), [Compatible]).
singleCompatible([_|Cs], Rest):- singleCompatible(Cs, Rest).
singleCompatible([],[]).

hwXvnf(VNF, IntentId, Layer, HWReqs) :-
    intent(IntentId, SH, NUsers, TargetId), dif(SH, infrPr),
    target(TargetId, Chain), member(VNF, Chain),
    vnf(VNF, Layer, _), vnfXUser(VNF, _, (L, H), HWReqs), between(L, H, NUsers).


