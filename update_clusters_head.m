function x= update_clusters_head(clustersi, S_Node_Energy, Neighbor_Count, su, s_xloc, s_yloc, sink_xloc, sink_yloc)

for i=1:length(clustersi)
    snode=clustersi(i);
    distance= getDistance(s_xloc(snode), s_yloc(snode), sink_xloc, sink_yloc);
    NW(i)= S_Node_Energy(snode) * length(su(snode)) * Neighbor_Count(snode) * (1/(distance^2));
end

[mm, ii]= max(NW);

x= clustersi(ii);

end