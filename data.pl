% application(Id, [VNFs])
application(gamingService, [edgeGamingVF, cloudGamingVF]).

% vnf(Id, HWReqs, ProcessingTime)
vnf(edgeGamingVF, 4, 15).
vnf(cloudGamingVF, 10, 8).
vnf(encVF, 1, 10).

% node(Id, HwCaps)
node(node42, 10).
node(edge1, 5).
node(coolCloud, 20).

% link(From, To, FeatLat, FeatBw)
link(node42, edge1, 2, 30).
link(edge1, node42, 2, 30).
link(edge1, coolCloud, 5, 29).
link(coolCloud, edge1, 5, 100).
link(node42, coolCloud, 10, 10).
link(coolCloud, node42, 10, 10).
link(N, N, 0, inf). % no latency and infinite bandwdith on self-links