:-['src/data.pl', 'src/checks.pl'].

:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).
:- set_prolog_flag(stack_limit, 32 000 000 000).
:- set_prolog_flag(last_call_optimisation, true).

dips(StakeHolder, IntentId, NUsers, Tfs) :-
    findall(Tf, deliveryLogic(StakeHolder, IntentId, NUsers, Tf), Ts), sort(Ts, Tfs).

deliveryLogic(StakeHolder, IntentId, NUsers, (L, Placement, UP)) :- 
    chainForIntent(StakeHolder, IntentId, Chain),
    dimensionedChain(Chain, NUsers, [], DimChain),
    findall(P, propertyExpectation(IntentId, P,_,_,_,_,_,_), NCP),
    placeChain(DimChain, NCP, Placement, UP), length(UP, L).

%% ASSEMBLY %%

chainForIntent(StakeHolder, IntentId, Chain) :-
    intent(StakeHolder, IntentId, TargetId), 
    target(TargetId, ServiceChain), 
    affinizedChain(ServiceChain, AffServiceChain),
    findall(P, (changingProperty(P), propertyExpectation(IntentId, P, _, _, _)), Properties),
    completedChain(IntentId, Properties, AffServiceChain, Chain).

affinizedChain([F|Fs], [(F,A)|NewFs]) :- vnf(F, A, _), affinizedChain(Fs, NewFs).
affinizedChain([], []).

completedChain(IntentId, [P|Ps], Chain, NewChain) :- 
    propertyExpectation(IntentId, P, Bound, From, To),
    chainModifiedByProperty(P, Bound, From, To, Chain, ModChain),
    completedChain(IntentId, Ps, ModChain, NewChain).
completedChain(_, [], Chain, Chain).

%% PLACEMENT %%

dimensionedChain([(F,_)|Zs], U, OldC, NewC) :- vnfXUser(F, D, (L, H), _), between(L, H, U),  dimensionedChain(Zs, U, [(F, D)|OldC], NewC).
dimensionedChain([], _, Chain, Chain).

placeChain(Chain, NCP, NewP, UP) :-
    placeChain(Chain, [], NewP),
    checkPlacement(NCP, NewP, [], UP).
placeChain([(VNF,Dim)|VNFs], OldP, NewP) :-
    vnf(VNF, Type, _), vnfXUser(VNF, Dim, _, HWReqs), node(N, Type, HWCaps),  
    hwOK(N, HWReqs, HWCaps, OldP),
    placeChain(VNFs, [on(VNF, Dim, N)|OldP], NewP).
placeChain([], P, P).

hwOK(N, HWReqs, HWCaps, Placement) :- % hw resources are cumulative
    findall(HW, (member(on(VNF, V, N), Placement), vnfXUser(VNF, V, _, HW)), HWs), sumlist(HWs, HWSum),
    HWSum + HWReqs =< HWCaps.

checkPlacement([P|Ps], Placement, OldUP, NewUP) :- 
    checkProperty(P, Placement, OldUP, TmpUP), 
    checkPlacement(Ps, Placement, TmpUP, NewUP).
checkPlacement([], _, UP, UP).