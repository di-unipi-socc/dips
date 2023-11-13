:- ['allocation.pl'].

minBW(_, From, To, BW) :- node(From,_,_), node(To,_,_), link(From, To, _, BW). % node - node
minBW([on(_,_,N)|Zs], From, To, BW) :- node(From,_,_), \+ node(To,_,_),  link(From, N, _, TmpBW), minBW2(Zs, To, TmpBW, BW). % node - VNF
minBW(P, From, To, BW) :- minBW(P, From, To, inf, BW). % VNF - node / VNF - VNF

minBW([on(X,_,_),Y|Zs], From, To, OldBW, NewBW) :- dif(X, From), minBW([Y|Zs], From, To, OldBW, NewBW).
minBW([on(From,_,N),on(Y,_,M)|Zs], From, To, _, NewBW) :- link(N,M,_,BW), minBW2([on(Y,_,M)|Zs], To, BW, NewBW).
minBW([on(From,_,N)], From, To, OldBW, NewBW) :- link(N, To, _, BW), NewBW is min(OldBW, BW). % To is a node

minBW2([on(X,_,N),on(Y,_,M)|Zs], To, OldBW, NewBW) :- dif(X, To), link(N,M,_,BW), TmpBW is min(OldBW, BW), minBW2([on(Y,_,M)|Zs], To, TmpBW, NewBW).
minBW2([on(_,_,N)|_], To, OldBW, NewBW) :- link(N, To, _, BW), NewBW is min(OldBW, BW). % To is a node
minBW2([on(To,_,_)|_], To, BW, BW). % To is a VNF

pathLat(_, From, To, Lat) :- node(From, _, _), node(To,_,_), link(From, To, Lat, _).
pathLat([on(F,_,N)|Zs], From, To, Lat) :- node(From,_,_), \+ node(To,_,_), link(From, N, FeatLat, _), vnf(F,_,PTime), TmpLat is FeatLat + PTime, pathLat2(Zs, To, TmpLat, Lat). % node - VNF
pathLat(P, From, To, Lat) :- pathLat(P, From, To, 0, Lat). % VNF - node / VNF - VNF

pathLat([on(X,_,_),Y|Zs], From, To, OldLat, NewLat) :- dif(X, From), pathLat([Y|Zs], From, To, OldLat, NewLat).
pathLat([on(From,_,N),on(Y,_,M)|Zs], From, To, _, NewLat) :- link(N,M,Lat,_), vnf(From,_,PTime), TmpLat is Lat + PTime, pathLat2([on(Y,_,M)|Zs], To, TmpLat, NewLat).
pathLat([on(From,_,N)], From, To, OldLat, NewLat) :- link(N, To, Lat, _), vnf(From,_,PTime), NewLat is OldLat + Lat + PTime. % To is a node

pathLat2([on(X,_,N),on(Y,_,M)|Zs], To, OldLat, NewLat) :- dif(X, To), link(N,M,Lat,_), vnf(X,_,PTime), TmpLat is OldLat + Lat + PTime, pathLat2([on(Y,_,M)|Zs], To, TmpLat, NewLat).
pathLat2([on(X,_,N)|_], To, OldLat, NewLat) :- link(N, To, Lat, _), vnf(X,_,PTime), NewLat is OldLat + Lat + PTime. % To is a node
pathLat2([on(To,_,_)|_], To, TmpLat, NewLat) :- vnf(To, _, PTime), NewLat is TmpLat + PTime. % To is a VNF

addedAtEdge([X,Y|Zs], G, [X|NewZs]) :- X = (_,cloud), addedAtEdge([Y|Zs], G, NewZs).
addedAtEdge([X,Y|Zs], G, [G,X|NewZs]) :- X = (_,edge), addedAtEdge2([Y|Zs], G, NewZs).
addedAtEdge([X], _, [X]) :- X = (_,cloud).
addedAtEdge([X], G, [G,X,G]) :- X = (_,edge).
addedAtEdge([], _, []).

addedAtEdge2([X,Y|Zs], G, [X|NewZs]) :- X = (_,edge), addedAtEdge2([Y|Zs], G, NewZs).
addedAtEdge2([X,Y|Zs], G, [G,X|NewZs]) :- X = (_,cloud), addedAtEdge([Y|Zs], G, NewZs).
addedAtEdge2([X], G, [G,X]) :- X = (_,cloud).
addedAtEdge2([X], _, [X]) :- X = (_,edge).
addedAtEdge2([], _, []).

addedFromTo([X,Y|Zs], From, To, G, [X|NewZs]) :- dif(X,From), addedFromTo([Y|Zs], From, To, G, NewZs).
addedFromTo([From|Zs], From, To, G, [G, From|NewZs]) :- addedFromTo2(Zs, To, G, NewZs).

addedFromTo2([To|Zs], To, G, [To, G|Zs]).
addedFromTo2([X|Zs], To, G, [X|NewZs]) :- dif(X,To), addedFromTo2(Zs, To, G, NewZs).

addedBefore([Before|Zs], Before, G, [G, Before|Zs]) :- addedBefore(Zs, Before, G, Zs).
addedBefore([X|Zs], Before, G, [X|NewZs]) :- dif(X,Before), addedBefore(Zs, Before, G, NewZs).
addedBefore([], _, _, []).

addedAfter([After|Zs], After, G, [After, G|Zs]) :- addedAfter(Zs, After, G, Zs).
addedAfter([X|Zs], After, G, [X|NewZs]) :- dif(X,After), addedAfter(Zs, After, G, NewZs).
addedAfter([], _, _, []).

distinctNodes(P, Ns) :- findall(N, member(on(_,_,N), P), Ms), sort(Ms, Ns).

subChain(From, To, [V|Rest], Subchain) :- dif(From, V), subChain(From, To, Rest, Subchain).
subChain(From, To, [From|Rest], [From|Subchain]) :- subChain2(To, Rest, Subchain).

subChain2(To, [V|Rest], [V|Subchain]) :- dif(To, V), subChain2(To, Rest, Subchain).
subChain2(To, [To|_], [To]).

overlaps(C, VI1, VF1, VI2, VF2) :- 
    findall(VF, (member((VF,_,_),C)), Chain),
    subChain(VI1, VF1, Chain, S1), subChain(VI2, VF2, Chain, S2), overlaps(S1, S2).
overlaps(S1,S2) :- append([_,[X,Y],_], S1), append([_,[X,Y],_],S2).

subpath(C, VI1, VF1, VI2, VF2) :- 
    findall(VF, (member((VF,_,_),C)), Chain),
    subChain(VI1, VF1, Chain, S1), subChain(VI2, VF2, Chain, S2), subpath(S1, S2).
subpath(S1, S2) :- length(S1, L1), length(S2, L2), L1 =< L2, append( [_, S1, _], S2 ).

dimensionedHW(Chain, U, HWReqs) :- member((VF, _, D), Chain), vnfXUser(VF, D, (L, H), HWReqs), between(L, H, U).
