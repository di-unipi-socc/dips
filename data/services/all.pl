:- multifile intent/4.
:- multifile propertyExpectation/6.
:- multifile propertyExpectation/9.
:- multifile target/2.
:- multifile vnf/3.
:- multifile vnfXUser/4.
:- multifile changingProperty/2.

:-['./infrPr.pl'].
:-['./renderingService.pl'].

% vnf(Id, Affinity, ProcessingTime).
vnf(encVF, edge, 2).
vnf(cacheVF, edge, 2).
vnf(logVF, cloud, 1).
vnf(encodeVF, edge, 5).
vnf(decodeVF, edge, 5).
vnf(compVF, edge, 3).

% vnfXUser(Id, Version, UsersRange, HWReqs).
vnfXUser(encVF, s, (1, inf), 2).
vnfXUser(logVF, s, (1, inf), 1).
vnfXUser(compVF, s, (1, 2000), 1).
vnfXUser(compVF, m, (2001, 5000), 2).
vnfXUser(compVF, l, (5001, inf), 5).
vnfXUser(cacheVF, m, (1, inf), 10).
vnfXUser(encodeVF, s, (1, 10000), 5).
vnfXUser(encodeVF, l, (10001, inf), 8).
vnfXUser(decodeVF, s, (1, 10000), 5).
vnfXUser(decodeVF, l, (10001, inf), 8).

% changingProperty(Property, VF). 
%% changing properties defined according to priority order
changingProperty(logging, logVF).
changingProperty(privacy, encVF).
changingProperty(security, authVF).
changingProperty(caching, cacheVF).
changingProperty(compression, compVF).
changingProperty(encoding, encodeVF).
changingProperty(decoding, decodeVF).