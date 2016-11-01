function [clusters, clusters_spec_map, clusters_head, cNeighbors]= Spectrum_Aware_Clustering(spoints, Neighbors, Neighbor_Count, s_xloc, s_yloc, sink_xloc, sink_yloc, su_trans_range, lamda_s, su, S_Node_Energy, Initial_Energy, Min_Energy)

% Clusters is a cell array of vectors.  Each vector contains the
% indicies of the points belonging to that cluster.
clusters = cell(spoints,1);
clusters_spec_map = cell(spoints,1);
clusters_head = zeros(spoints,1);

linkage = 2;
cNeighbors = Neighbors;
cNeighbor_Count = Neighbor_Count;

Energy_compute_dist = 5 * 0.000000001;
Energy_send_merge_request= 50 * 0.000000001;
Energy_receive_merge_request= 50 * 0.000000001;

cltr_packet= 200;

% INITIALLY EACH POINT IS IN ITS OWN CLUSTER %.
for cc = 1:length(clusters)
    clusters{cc} = [cc];
    clusters_spec_map{cc} = su{cc};
    clusters_head(cc) = cc;
end

% DISTANCE BETWEEN EACH PAIR OF POINTS %

point_dist = point_distance(s_xloc, s_yloc);

    %Energy consumption 
for i=1:spoints
    S_Node_Energy(i) = S_Node_Energy(i) - ( cltr_packet * Energy_compute_dist* Neighbor_Count(i));
end

% OPTIMAL NUMBER OF CLUSTERS %

kopt = floor( (spoints/(su_trans_range * ((3 * lamda_s)^0.5))) + 0.5);

% AVERAGE SIZE OF CLUSTERS AFTER WHOLE MERGING %

avg_cl_size= ceil(spoints/kopt);

%UNTIL THE TERMINATION CONDITION IS MET %

while length(clusters) > kopt
    length(clusters)
    % compute the distances between all pairs of clusters
    cluster_dist = inf*ones(length(clusters));
    for c1 = 1:length(clusters)
        Energy_compute_cluster_dist = 0;
        for l = 1: length(cNeighbors{c1})
            c2= cNeighbors{c1}(l);
            if ( c1 ~= c2 )
                cluster_dist(c1,c2) = cluster_distance(clusters{c1}, clusters{c2}, point_dist, linkage);
                %point distances are mainly computed here so energy consumption will be no of nodes in clusters{c1}* clusters{c2}* energy_compute_dist               
                Energy_compute_cluster_dist= Energy_compute_cluster_dist + ( length(clusters{c1})*length(clusters{c2})* Energy_compute_dist * cltr_packet);         
            end
        end
        %UPDATE S_Node_Energy(clusters_head(c1))
        % that is energy consumption in computing cluster_dist
        S_Node_Energy(clusters_head(c1))= S_Node_Energy(clusters_head(c1)) - Energy_compute_cluster_dist;       
    end
    
    %EACH CLUSTER SENDS MERGE REQUEST TO NEIGHBORHOOD CLUSTER HAVING
    %MAXIMUM WEIGHT
    W= zeros(length(clusters), length(clusters));
    for c1 = 1:length(clusters)
        for l = 1: length(cNeighbors{c1})
            c2= cNeighbors{c1}(l);
            if ( c1 ~= c2 )              
                W(c1,c2)= (length(intersect(clusters_spec_map{c1}, clusters_spec_map{c2}))) * (1/ cluster_dist(c1,c2));
            end
        end
    end
    [mm, ii]= max(W);   
    merge_flag= zeros(1, length(clusters));
    
    for i=1:length(ii)
        ii(2,i)=i;                 
        merge_flag(i)= ii(1,i);
        
       %UPDATE S_Node_Energy(clusters_head(c1))
       %that is energy consumption in sending merge requests and receiving
       %mergerequests
        S_Node_Energy(clusters_head(i))= S_Node_Energy(clusters_head(i)) - ( cltr_packet * Energy_send_merge_request);
        S_Node_Energy(clusters_head(ii(1,i)))= S_Node_Energy(clusters_head(ii(1,i))) - (cltr_packet * Energy_receive_merge_request);
       
    end
    
    for i=1:length(merge_flag)
        if (i <= length(merge_flag)) && (merge_flag(i) <= length(merge_flag))
           if (isnan(merge_flag(i)) ~= 1) && (merge_flag(i) ~= i) && (merge_flag(merge_flag(i)) == i)
                %MERGE CLUSTERS i AND merge_flag(i) THAT IS i1 AND i2
                    i1= i;
                    i2= merge_flag(i);
                    [clusters, clusters_spec_map, clusters_head, merge_flag] = merge_clusters(clusters, clusters_spec_map, clusters_head, i1, i2, merge_flag, S_Node_Energy, su, Neighbor_Count, s_xloc, s_yloc, sink_xloc, sink_yloc);
                %MERGE COMPLETE
                %break
           end        
        end
    end
   
    %UPDATE cNeighbors
        [cNeighbors, cNeighbor_Count] = update_cNeighbor(clusters, clusters_spec_map, point_dist, su_trans_range);
    %UPDATION COMPLETE
   
end
length(clusters)
end
