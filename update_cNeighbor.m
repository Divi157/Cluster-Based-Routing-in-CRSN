function [cNeighbors, cNeighbor_Count] = update_cNeighbor(clusters, clusters_spec_map, point_dist, su_trans_range)

cNeighbor_Count = zeros (length(clusters), 1);
cNeighbors = cell(1, length(clusters));

for c1=1 : length(clusters)         
       for c2=1 : length(clusters)   
           if ( c1 ~= c2 )
                if ( size(point_dist) ~= [0, 0] )
                     cluster_dist(c1,c2) = cluster_distance(clusters{c1}, clusters{c2}, point_dist, 0); 
                    if (cluster_dist(c1,c2) <= su_trans_range)
                        if ( intersect(clusters_spec_map{c1}, clusters_spec_map{c2}) ~= 0 )
                            cNeighbor_Count (c1) = cNeighbor_Count (c1) + 1;
                            cNeighbors{c1}(cNeighbor_Count(c1)) = c2;
                        end
                    end
                end
            end
        end
end
end
