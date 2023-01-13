
% An Intent from an AppOperator is a set of expectations E1, ..., En.
% intent(AppOp, IntentName) :- E1, ..., En. 

% An expectation specify its type (delivery, property), its Targets (service instance, resource, node) and a (possibly empty) set of conditions C1, ..., Ck to define when the system complies with the expectation.
% expectation(ExpectationId, Type, Target) :- C1, ..., Ck.

% A delivery expectation is a request to the system to deliver a service instance to a target node. It is not associated to 
% expectation(delivery, Target).

% A property expectation is a request to the system to provide a property of a service instance or a resource.
% expectation(property, Target) :- C1, ..., Ck.

% target(TargetId, TargetType).
target(vpn1, vpnService).
target(vpn2, vpnService).

pathProtection(vpn2).

% the beast that generates the intent:
intent(stakeholder, exampleIntent1, T1) :-  % T1 = (Resource, Constraints, Configurations)
    expectation(delivery, vpnService, T1), 
    expectation(property, pathProtection, T1),
    expectation(property, latency, T1).

% the expert that knows how to treat events:
expectation(delivery, vpnService, T1) :- target(T1, vpnService). % edgeUsher che piazza la vpn come catena di funzioni
expectation(property, pathProtection, T1) :- pathProtection(T1). % verifica se la catena generata ha pathProtection

% intent(sf, exampleIntent1) :-
%     expectation(e1, delivery, t1), %%%% TODO: add type!!!
%     expectation(e2, property, t1).

% expectation(e1, delivery, t1).
% expectation(e2, property, t1) :- condition(t1, smaller, valueOf, latency, 50, ms).


% A target is a service instance, a resource or a node, that determine what needs to fulfill the requirement. 

% A condition is a set of constraints on the system state, that determine when the expectation is fulfilled.
% condition(QuantityType, ConditionQuantity, Value, Unit).

expectation(e1, i1, delivery, vpnService, t1).
expectation(e2, i1, property, pathProtection, t1).
expectation(e3, i1, property, latency, t1).

satisfyIntent(IId, Targets, Constraints, Configs) :- 
    findall(E, expectation(E, IId, Type, TargetType, TId), Es),
    processExpectations(Es, (Targets, Constraints, Configs)).