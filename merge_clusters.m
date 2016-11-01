function [clusters, clusters_spec_map, clusters_head, merge_flag] = merge_clusters(clusters, clusters_spec_map, clusters_head, i1, i2, merge_flag, S_Node_Energy, su, Neighbor_Count, s_xloc, s_yloc, sink_xloc, sink_yloc)
  
    clusters_spec_map{i1} = intersect( clusters_spec_map{i1}, clusters_spec_map{i2} );
    clusters_spec_map(i2) = [];
    clusters{i1} = [clusters{i1} clusters{i2}];
    clusters(i2) = [];
    
    %fprintf('merge_flag before merging')
    %merge_flag
    for i=1:length(merge_flag)
        if merge_flag(i) < i2
        elseif merge_flag(i) == i2
            merge_flag(i) = NaN;
        elseif merge_flag(i) > i2
            merge_flag(i) = merge_flag(i) - 1;
        end  
    end
    merge_flag(i1)=NaN;
    merge_flag(i2)=[];
    
    %fprintf('merge_flag after merging')
    %merge_flag
    
    clusters_head(i1)= update_clusters_head(clusters{i1}, S_Node_Energy, Neighbor_Count, su, s_xloc, s_yloc, sink_xloc, sink_yloc);
    clusters_head(i2)=[];
end