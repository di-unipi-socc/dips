:-['data/infrastructures/infr5.pl', 'data/services/all.pl'].
:-['src/properties.pl', 'src/conflicts.pl'].

:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).
:- set_prolog_flag(stack_limit, 64 000 000 000).
:- set_prolog_flag(last_call_optimisation, true).

multidips(Output) :- findall((IntentId, Targets), dips(IntentId, Targets), Output).
dips(IntentId, Targets) :- 
    intent(IntentId, _, _, _), 
    findall(T, delivery(IntentId, T), Ts), sort(Ts, Targets).

justC(IntentId, Chain) :-
    modelling(IntentId, Chain),
    conflictDetectionAndResolution(IntentId, Chain, _).

delivery(IntentId, (L, Placement, Unsatisfied)) :- 
    modelling(IntentId, Chain),
    conflictDetectionAndResolution(IntentId, Chain, NCP),
    translation(Chain, NCP, Placement, Unsatisfied), length(Unsatisfied, L).

modelling(IntentId, DimensionedChain) :-
    intent(IntentId, _, NUsers, TargetId), target(TargetId, ServiceChain),
    layeredChain(ServiceChain, LayeredChain), 
    completedChain(LayeredChain, IntentId, CompletedChain),
    dimensionedChain(CompletedChain, NUsers, DimensionedChain).

conflictDetectionAndResolution(IntentId, Chain, FilteredNCP) :-
    conflictsDetection(Chain, ConflictsAndSolutions), % if any unfeasible conflict, fail
    findall(P, propertyExpectation(P, IntentId, _,_,_,_,_,_,_), NCP),
    conflictsResolution(ConflictsAndSolutions, NCP, FilteredNCP).

%% ASSEMBLY %%

layeredChain([F|Fs], [(F,A)|NewFs]) :- vnf(F, A, _), layeredChain(Fs, NewFs).
layeredChain([], []).

completedChain(LChain, IntentId, Chain) :-
    findall((PId,F), (changingProperty(P,F), propertyExpectation(PId, IntentId, P, _, _, _)), Properties),
    modifiedChain(Properties, LChain, Chain).
modifiedChain([(PId,F)|Ps], Chain, NewChain) :- 
    propertyExpectation(PId, _, P, Bound, From, To), vnf(F, A, _),
    once(chainModifiedByProperty(P, Bound, From, To, (F,A), Chain, ModChain)),
    modifiedChain(Ps, ModChain, NewChain).
modifiedChain([], Chain, Chain).

dimensionedChain(Chain, NUsers, DimChain) :- dimensionedChain(Chain, NUsers, [], DimChain).
dimensionedChain([(F,A)|Zs], U, OldC, NewC) :- vnfXUser(F, D, (L, H), _), between(L, H, U),  dimensionedChain(Zs, U, [(F, A, D)|OldC], NewC).
dimensionedChain([], _, Chain, Chain).

%% PLACEMENT %%

translation(Chain, NCP, NewP, UP) :-
    translation(Chain, [], NewP),
    checkPlacement(NCP, NewP, UP).
translation([(F, L, D)|VNFs], OldP, NewP) :-
    vnfXUser(F, D, _, HWReqs), node(N, L, HWCaps),  
    hwOK(N, HWReqs, HWCaps, OldP),
    translation(VNFs, [on(F, D, N)|OldP], NewP).
translation([], P, P).

hwOK(N, HWReqs, HWCaps, Placement) :- % hw resources are cumulative
    findall(HW, (member(on(VNF, V, N), Placement), vnfXUser(VNF, V, _, HW)), HWs), sumlist(HWs, HWSum),
    HWSum + HWReqs =< HWCaps.

checkPlacement(NCP, Placement, UP) :- checkPlacement(NCP, Placement, [], UP).
checkPlacement([P|Ps], Placement, OldUP, NewUP) :- 
    checkProperty(P, Placement, OldUP, TmpUP), 
    checkPlacement(Ps, Placement, TmpUP, NewUP).
checkPlacement([], _, UP, UP).