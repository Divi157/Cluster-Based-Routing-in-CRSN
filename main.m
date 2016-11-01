clc, clear all, close all

%%INITIALIZING VARIABLES%%

global simulation_area;
global spoints; %no of SUs
global ppoints; % no of PUs
global s_xloc;
global s_yloc;
global sink_xloc;
global sink_yloc;
global su; %spectrum_map of SUs
global clusters; %each cell contains the corresponding cluster members
global Initial_Energy;
global Min_Energy;
global Energy_Data_Aggregation;
global S_Node_Energy;
Initial_Energy = 100;
Min_Energy = 0.01;
Energy_Data_Aggregation = 5 * (10 ^ -9);
simulation_area = 100; % simulation area is 1000 X 1000 
su_trans_range = 50; % SU transmission range
pu_trans_range = 20; % PU transmssio range
antenna = 2;   % number of antenna per node (maximum number of channels that can be opened by an SU)
lamda_p=3/(100*100);
lamda_s=20/(100*100);
channel_list = [1 2 3];  % channel in white space
num_potential_link = 0;  % total number of potential link in the given CRN, that is, if nodes are in the transmission range of each other
Max_hops= 12;
    spoints=20; 
    ppoints=3;
    pproc_s = rand(spoints, 2); % position of SUs. Here no of sus are spoints and 2 is for 2 columns (x and y coordinates)
    pproc_p = rand(ppoints,2);  % position of PUs
    %positions of SUs in simulation area
    p_xloc = simulation_area*pproc_p(:,1);
    p_yloc = simulation_area*pproc_p(:,2);
    s_xloc = simulation_area*pproc_s(:,1);
    s_yloc = simulation_area*pproc_s(:,2);
    sink_xloc = simulation_area/2;
    sink_yloc = simulation_area/2;
    % Initalize the energy in each node
    %energy of each SU is stored in a vector
    S_Node_Energy = ones (1,(spoints+1)) * Initial_Energy;
    % Sink node has additional resources
    S_Node_Energy(spoints+1) = 2;
%SPECTRUM SENSING%

su = Spectrum_Sensing(ppoints, spoints, p_xloc, p_yloc, s_xloc, s_yloc, pu_trans_range, channel_list);

%NODE DEPLOYMENT%

plot(pproc_s(:, 1).*simulation_area, pproc_s(:, 2).*simulation_area, 'o', pproc_p(:, 1).*simulation_area, pproc_p(:, 2).*simulation_area, 'g*', sink_xloc, sink_yloc, 'rO');
    %hold on;
    
%GET NEIGHBORS AND NEIGHBORS' COUNT OF SUs%

[Neighbors, Neighbor_Count] = getNeighbor (spoints, s_xloc, s_yloc, su_trans_range, su, S_Node_Energy, Min_Energy);

%SPECTRUM AWARE CLUSTERING%

[clusters, clusters_spec_map, clusters_head, cNeighbors]= Spectrum_Aware_Clustering(spoints, Neighbors, Neighbor_Count, s_xloc, s_yloc, sink_xloc, sink_yloc, su_trans_range, lamda_s, su, S_Node_Energy, Initial_Energy, Min_Energy);

%EVENT DRIVEN ROUTING%

[node, event_counter,first_dead, route, hop_count, packets_dropped]=event_driven_routing(clusters_head, clusters, clusters_spec_map, sink_xloc, sink_yloc, s_xloc, s_yloc, su, Neighbors, Neighbor_Count, S_Node_Energy, Min_Energy, spoints, su_trans_range, Max_hops);