% d = cluster_distance(c1,c2,point_dist,linkage)
%    Computes the pairwise distances between clusters c1
%    and c2, using the point distance info in point_dist.
%----------------------------------------------------------
function d = cluster_distance(c1,c2,point_dist,linkage)

d = point_dist(c1,c2);
switch linkage
    case 0
        % -- Simple Linkage --
        % distance between two nearest points
        d = min(d(:));
        
    case 1
        % -- Average Linkage --
        % average distance between points in the two clusters
        d = mean(d(:));
        
    case 2
        % -- Complete Linkage --
        % distance between two furthest points
        d = max(d(:));
          
    otherwise
        error('unknown linkage');
end

end