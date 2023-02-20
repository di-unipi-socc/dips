:-['src/data.pl', 'src/checks.pl'].

:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).
:- set_prolog_flag(stack_limit, 32 000 000 000).
:- set_prolog_flag(last_call_optimisation, true).

dips(StakeHolder, IntentId, NUsers, Targets) :-
    findall(T, delivery(StakeHolder, IntentId, NUsers, T), Ts), sort(Ts, Targets).

delivery(StakeHolder, IntentId, NUsers, (L, Placement, Unsatisfied)) :- 
    chainForIntent(StakeHolder, IntentId, Chain),
    dimensionedChain(Chain, NUsers, [], DimChain),
    findall(P, propertyExpectation(IntentId, P,_,_,_,_,_,_), NCP),
    placedChain(DimChain, NCP, Placement, Unsatisfied), length(Unsatisfied, L).

%% ASSEMBLY %%

chainForIntent(StakeHolder, IntentId, Chain) :-
    intent(StakeHolder, IntentId, TargetId), 
    target(TargetId, ServiceChain), 
    affinitisedChain(ServiceChain, AffServiceChain),
    findall((P,F), (changingProperty(P,F), propertyExpectation(IntentId, P, _, _, _)), Properties),
    completedChain(IntentId, Properties, AffServiceChain, Chain).

affinitisedChain([F|Fs], [(F,A)|NewFs]) :- vnf(F, A, _), affinitisedChain(Fs, NewFs).
affinitisedChain([], []).

completedChain(IntentId, [(P,F)|Ps], Chain, NewChain) :- 
    propertyExpectation(IntentId, P, Bound, From, To), vnf(F, A, _),
    chainModifiedByProperty(P, Bound, From, To, (F,A), Chain, ModChain),
    completedChain(IntentId, Ps, ModChain, NewChain).
completedChain(_, [], Chain, Chain).

%% PLACEMENT %%

dimensionedChain([(F,A)|Zs], U, OldC, NewC) :- vnfXUser(F, D, (L, H), _), between(L, H, U),  dimensionedChain(Zs, U, [(F, A, D)|OldC], NewC).
dimensionedChain([], _, Chain, Chain).

placedChain(Chain, NCP, NewP, UP) :-
    placedChain(Chain, [], NewP),
    checkPlacement(NCP, NewP, [], UP).
placedChain([(F, A, D)|VNFs], OldP, NewP) :-
    vnfXUser(F, D, _, HWReqs), node(N, A, HWCaps),  
    hwOK(N, HWReqs, HWCaps, OldP),
    placedChain(VNFs, [on(F, D, N)|OldP], NewP).
placedChain([], P, P).

hwOK(N, HWReqs, HWCaps, Placement) :- % hw resources are cumulative
    findall(HW, (member(on(VNF, V, N), Placement), vnfXUser(VNF, V, _, HW)), HWs), sumlist(HWs, HWSum),
    HWSum + HWReqs =< HWCaps.

checkPlacement([P|Ps], Placement, OldUP, NewUP) :- 
    checkProperty(P, Placement, OldUP, TmpUP), 
    checkPlacement(Ps, Placement, TmpUP, NewUP).
checkPlacement([], _, UP, UP).