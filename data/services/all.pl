:- multifile intent/4.
:- multifile propertyExpectation/6.
:- multifile propertyExpectation/9.
:- multifile target/2.
:- multifile vnf/3.
:- multifile vnfXUser/4.
:- multifile changingProperty/2.

:-['./infrPr.pl'].
:-['./renderingService.pl'].
:-['./gamingService.pl'].
:-['./streamingService.pl'].

% vnf(Id, Affinity, ProcessingTime).
vnf(encVF, edge, 2).
vnf(cacheVF, edge, 2).
vnf(logVF, cloud, 1).
vnf(encodeVF, edge, 5).
vnf(decodeVF, edge, 5).
vnf(compVF, edge, 3).

vnf(edgeGamingVF, edge, 15).
vnf(cloudGamingVF, cloud, 8).
vnf(uiVF, edge, 2).
vnf(syncVF, edge, 5).
vnf(renderVF, edge, 15).
vnf(streamVF, edge, 8).
vnf(storageVF, cloud, 10).

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

vnfXUser(edgeGamingVF, s, (1,100), 5).
vnfXUser(edgeGamingVF, m, (101,1000), 10).
vnfXUser(edgeGamingVF, l, (1001,inf), 15).
vnfXUser(cloudGamingVF, s, (1, 1000), 8).
vnfXUser(cloudGamingVF, m, (1001, 10000), 12).
vnfXUser(cloudGamingVF, l, (10001, inf), 25).
vnfXUser(uiVF, s, (1, inf), 2).
vnfXUser(syncVF, s, (1, 2000), 4).
vnfXUser(syncVF, m, (2001, 5000), 8).
vnfXUser(syncVF, l, (5001, inf), 12).
vnfXUser(renderVF, s, (1, 2000), 15).
vnfXUser(renderVF, m, (2001, 5000), 35).
vnfXUser(renderVF, l, (5001, inf), 60).
vnfXUser(streamVF, m, (1, 10000), 5).
vnfXUser(streamVF, l, (10000, inf), 12).
vnfXUser(storageVF, l, (1, inf), 90).

% changingProperty(Property, VF). 
%% changing properties defined according to priority order
changingProperty(logging, logVF).
changingProperty(privacy, encVF).
changingProperty(security, authVF).
changingProperty(caching, cacheVF).
changingProperty(compression, compVF).
changingProperty(encoding, encodeVF).
changingProperty(decoding, decodeVF).