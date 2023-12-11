/* Intent */
intent(IntentId, Stakeholder, NUsers, TargetId).

% Changing properties
propertyExpectation(PropertyId, IntentId, Property, Bound, From/Before, To/After).
% Non-changing properties
propertyExpectation(PropertyId, IntentId, Property, Bound, Level, Value, Unit, From, To).

target(TargetId, Chain).

vnf(Id, Affinity, ProcessingTime).
vnfXUser(Id, Version, UsersRange, HWReqs).


/* Infrastructure */
changingProperty(Property, VNF).

node(Id, Type, HWCaps, Availability).
link(From, To, FeatLat, FeatBw).

/* Infrastructure Provider intent */

intent(IId, infrPr, _, _).
user(UserId, Priority).
/* in property expectations for the infrastrcuture provider,
   levels are: gold, silver, bronze, as the user priorities in user/2 
 */
propertyExpectation(PId, IId, Property, lower, Level, Value, _, _, _).