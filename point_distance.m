function d= point_distance(s_xloc, s_yloc)

Y= [s_xloc'; s_yloc'];
N = size(Y,2);
d = sum(Y.^2,1);
d = ones(N,1)*d + d'*ones(1,N) - 2*Y'*Y;
d= d.^0.5;

end