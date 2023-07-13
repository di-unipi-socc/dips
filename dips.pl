:-['data/infrastructures/infr5.pl', 'data/services/streamingService.pl'].
:-['src/properties.pl', 'src/conflicts.pl'].

:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).
:- set_prolog_flag(stack_limit, 64 000 000 000).
:- set_prolog_flag(last_call_optimisation, true).

dips(StakeHolder, IntentId, NUsers, Targets) :-
    findall(T, delivery(StakeHolder, IntentId, NUsers, T), Ts), sort(Ts, Targets).

delivery(StakeHolder, IntentId, NUsers, (L, Placement, Unsatisfied)) :- 
    modelling(StakeHolder, IntentId, NUsers, Chain),
    conflictDetectionAndResolution(IntentId, NCP),
    translation(Chain, NCP, Placement, Unsatisfied), length(Unsatisfied, L).

modelling(StakeHolder, IntentId, NUsers, DimensionedChain) :-
    chainForIntent(StakeHolder, IntentId, Chain),
    dimensionedChain(Chain, NUsers, DimensionedChain).

conflictDetectionAndResolution(IntentId, FilteredNCP) :-
    conflictsDetection(ConflictsAndSolutions, UnfeasibleConflicts),
    handleUnfeasibleConflicts(UnfeasibleConflicts),
    findall(P, propertyExpectation(P, IntentId, _,_,_,_,_,_,_), NCP),
    conflictsResolution(ConflictsAndSolutions, NCP, FilteredNCP).

handleUnfeasibleConflicts([]).
handleUnfeasibleConflicts(UnfeasibleConflicts) :- dif(UnfeasibleConflicts, []), writeln(UnfeasibleConflicts), fail.

conflictsResolution([((_,_),remove,L)|Cs], NCP, FNCP) :- 
    subtract(NCP, L, NCP1), 
    conflictsResolution(Cs, NCP1, FNCP).
conflictsResolution([((_,_),Op,_)|Cs], NCP, FNCP) :-
    dif(Op, remove), 
    conflictsResolution(Cs, NCP, FNCP).
conflictsResolution([], NCP, NCP).

%% ASSEMBLY %%

chainForIntent(StakeHolder, IntentId, Chain) :-
    intent(StakeHolder, IntentId, TargetId), 
    target(TargetId, ServiceChain), 
    layeredChain(ServiceChain, LChain),
    findall((P,F), (changingProperty(P,F), propertyExpectation(_, IntentId, P, _, _, _)), Properties),
    completedChain(IntentId, Properties, LChain, Chain).

layeredChain([F|Fs], [(F,A)|NewFs]) :- vnf(F, A, _), layeredChain(Fs, NewFs).
layeredChain([], []).

completedChain(IntentId, [(P,F)|Ps], Chain, NewChain) :- 
    propertyExpectation(_, IntentId, P, Bound, From, To), vnf(F, A, _),
    chainModifiedByProperty(P, Bound, From, To, (F,A), Chain, ModChain),
    completedChain(IntentId, Ps, ModChain, NewChain).
completedChain(_, [], Chain, Chain).

%% PLACEMENT %%

dimensionedChain(Chain, NUsers, DimChain) :- dimensionedChain(Chain, NUsers, [], DimChain).
dimensionedChain([(F,A)|Zs], U, OldC, NewC) :- vnfXUser(F, D, (L, H), _), between(L, H, U),  dimensionedChain(Zs, U, [(F, A, D)|OldC], NewC).
dimensionedChain([], _, Chain, Chain).

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