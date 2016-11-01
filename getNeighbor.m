function [Neighbors, Neighbor_Count] = getNeighbor (spoints, s_xloc, s_yloc, su_trans_range, su, S_Node_Energy, Min_Energy)

Neighbor_Count = zeros (spoints, 1);
Neighbors = cell(1, spoints);

for i=1 : spoints           
    for j=1 : spoints    
        if (S_Node_Energy (j) > Min_Energy)
            Distance(i,j) = getDistance(s_xloc(i), s_yloc(i), s_xloc(j), s_yloc(j));
            if (Distance (i, j) <= su_trans_range)
                if ( intersect(su{i}, su{j}) ~= 0 )
                Neighbor_Count (i) = Neighbor_Count (i) + 1;
                Neighbors{i}(Neighbor_Count(i)) = j;
                end
            end
        end
    end
end
end