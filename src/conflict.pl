% TODO:
% 
:- set_prolog_flag(answer_write_options,[max_depth(0), spacing(next_argument)]).

% conflicts(X,[]) :- % only fixable conflicts
% conflicts(_, [C|Cs]) :- % unfeasible, return to user
conflictsDetection(ConflictsAndSolutions, UnfeasibleConflicts) :-
    findall((C,S), conflict(C, S), ConflictsAndSolutions),
    findall(C, member((C, unfeasible), ConflictsAndSolutions), UnfeasibleConflicts).

% --- General ---
% too general(?):
% - we can define "mydif/2"
% - specialise the rules (e.g., latency/stddev)
% - hierarchy of soft/soft properties (so on boundaries)

conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, Property, B1, hard, _, _, VF, _),
    propertyExpectation(PId2, I, Property, B2, soft, _, _, VF, _), dif(B1,B2),
    Solution = (remove, [PId2]).
conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, Property, B1, hard, _, _, _, VF),
    propertyExpectation(PId2, I, Property, B2, soft, _, _, _, VF), dif(B1,B2),
    Solution = (remove, [PId2]).

% --- AFFINITY ---
conflict((PId1,PId2), unfeasible) :-
    propertyExpectation(PId1, I, affinity, dedicated, hard, _, _, VF, _),
    propertyExpectation(PId2, I, affinity, same, hard, _, _, VF, _).

conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, affinity, dedicated, soft, _, _, VF, _),
    propertyExpectation(PId2, I, affinity, same, soft, _, _, VF, _),
    Solution = (remove, [PId1,PId2]).

% --- BANDWIDTH ---
conflict((PId1,PId2), unfeasible) :- % (e.g., BW > 50 & BW < 10)    
    propertyExpectation(PId1, I, bandwidth, larger, hard, L, _, _, VF),
    propertyExpectation(PId2, I, bandwidth, smaller, hard, U, _, _, VF), L > U.

conflict((PId1,PId2), Solution) :-
    propertyExpectation(PId1, I, bandwidth, larger, soft, L, _, _, VF),
    propertyExpectation(PId2, I, bandwidth, smaller, soft, U, _, _, VF), L > U,
    Solution = (remove, [PId1,PId2]).