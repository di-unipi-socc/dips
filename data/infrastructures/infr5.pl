% node(Id, Type, HWCaps).
node(gateway, edge, 10).
node(edge1, edge, 18).
node(edge2, edge, 25).
node(cloud1, cloud, 100).
node(cloud2, cloud, 150).

% link(From, To, FeatLat, FeatBw).
link(gateway, edge1, 5, 30).
link(gateway, edge2, 35, 30).
link(gateway, cloud1, 135, 30).
link(gateway, cloud2, 125, 30).
link(edge1, gateway, 15, 50).
link(edge1, edge2, 30, 70).
link(edge1, cloud1, 130, 120).
link(edge1, cloud2, 120, 120).
link(edge2, gateway, 35, 50).
link(edge2, edge1, 30, 70).
link(edge2, cloud1, 135, 80).
link(edge2, cloud2, 125, 80).
link(cloud1, gateway, 135, 30).
link(cloud1, edge1, 130, 120).
link(cloud1, edge2, 135, 80).
link(cloud1, cloud2, 10, 1000).
link(cloud2, gateway, 125, 30).
link(cloud2, edge1, 120, 120).
link(cloud2, edge2, 125, 80).
link(cloud2, cloud1, 10, 1000).
link(N, N, 0, 100000). % no latency and infinite bandwdith on self-links