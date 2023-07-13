resourceAllocation([(N, R)|Rs], OldAlloc, NewAlloc) :-
    select((N, OldRs), OldAlloc, Rest), NewRs is OldRs + R,
    resourceAllocation(Rs, [(N, NewRs)|Rest], NewAlloc).
resourceAllocation([(N, R)|Rs], OldAlloc, NewAlloc) :-
    \+ member((N, _), OldAlloc),
    resourceAllocation(Rs, [(N, R)|OldAlloc], NewAlloc).
resourceAllocation([], Alloc, Alloc).

hwAllocation(Ps, AllocHW) :- 
    findall((N, HW), relevantNode(N, Ps, HW), HWs), 
    resourceAllocation(HWs, [], AllocHW).

relevantNode(N, P, HW) :- member(on(VNF,V,N), P), vnfXUser(VNF, V, _, HW).

avgAlloc(Alloc, Avg) :- 
    findall(A, member((_,A), Alloc), As),
    sum_list(As, Sum), length(As, Len), Avg is Sum / Len.