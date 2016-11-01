function [node, event_counter, first_dead, route, hop_count, packets_dropped]=event_driven_routing(clusters_head, clusters, clusters_spec_map, sink_xloc, sink_yloc, s_xloc, s_yloc, su, Neighbors, Neighbor_Count, S_Node_Energy, Min_Energy, spoints, su_trans_range, Max_hops)

K=length(clusters);
cSize= zeros(1,K);

for i=1:K
    cSize(i)= length(clusters{i});
end
%INITIALIZING SU NODE STRUCTURE% 
node= struct('cid',{},'suid',{},'x',{},'y',{},'specmap',{},'Neighbors',{},'type',{},'CH',{},'IsGateway',{},'Energy',{});

%FLAG FOR FIRST NODE THAT DIES%
first_dead=0;

%PACKET SIZES%
cltr_packet= 200; 
data_packet= 10000;

% ENERGY VALUES FOR TRANSMIT, RECEIVE ETC. PER BIT%
Etx= 50* 0.00000001;
Erx= 50* 0.00000001;
Eprocess= 5* 0.00000001;
Eda=5*0.000000001;%Data Aggregation energy
Eidle=50*0.0000000001;%Energy for idle state
Esleep=0.072;%Energy for sleep state
Co =1; % loss factor

%COUNTER FOR EVENTS%
event_counter=0;

%PACKETS DROPPED%
%in the network life time because data packet has reached
%to node that can have no gateways (neither primary nor secondary)
packets_dropped=0;

for i=1:K
    for j=1:cSize(i)
        node(clusters{i}(j)).cid= i;
        node(clusters{i}(j)).suid= clusters{i}(j);
        node(clusters{i}(j)).x= s_xloc(clusters{i}(j));
        node(clusters{i}(j)).y= s_yloc(clusters{i}(j));
        node(clusters{i}(j)).specmap= su{clusters{i}(j)};
        node(clusters{i}(j)).Neighbors= Neighbors{node(clusters{i}(j)).suid};
        if(clusters_head(i) == clusters{i}(j))
            node(clusters{i}(j)).type= 'CH';
        else
            node(clusters{i}(j)).type= 'CM';
        end
        node(clusters{i}(j)).CH= clusters_head(i);
        node(clusters{i}(j)).IsGateway= 0;
        node(clusters{i}(j)).Energy= S_Node_Energy(clusters{i}(j));
    end
end
%sink node: last object of the structure node
node(spoints+1).cid=NaN;
node(spoints+1).suid=spoints+1;
node(spoints+1).x= sink_xloc;
node(spoints+1).y= sink_yloc;
node(spoints+1).specmap= NaN;
node(spoints+1).Neighbors= NaN;
node(spoints+1).CH=NaN;
node(spoints+1).type='SINK';
node(spoints+1).IsGateway= 0;
node(spoints+1).Energy= 2;

%ROUTING STARTS NOW%
while first_dead ==0 %TILL NETWORK IS ALIVE
    event_counter=event_counter+1;
    
    source= randi(spoints); %RANDOM NODE IS SELECTED AS THE SOURCE NODE
    
    current= node(source);
    
    hop_count(event_counter)=1; %to count the no of hops in each round(time taken by a data packet to travel from source node to sink node Tround)
    
    route{event_counter}(hop_count(event_counter))=current.suid;
    
    packets_dropped(event_counter)=0;
    
    while (strcmp(current.type, 'SINK') ~= 1) && (first_dead ~= 1) 
        
        if (strcmp(current.type, 'CM'))
              % IF CURRENT NODE IS THE CLUSTER MEMBER 
              %FORWARD THE DATA PACKET TO CORRESPONDING CLUSTER'S HEAD
              [current, node, first_dead, packets_dropped]= forward_to_CH(spoints, node, current, Etx, Erx, data_packet, cltr_packet, first_dead, Co, packets_dropped, Min_Energy, event_counter);   
              %fprintf('inside CM block')
              %current
        elseif (strcmp(current.type, 'CH'))
              % IF CURRENT NODE IS THE CLUSTER HEAD
              distC_S=getDistance(current.x, current.y, sink_xloc, sink_yloc); %distance b/w current node and sink
              if(distC_S <= su_trans_range)
                    %FORWARD TO SINK%
                    [current, node, first_dead]= forward_to_sink(current, node, data_packet, cltr_packet, Eda, Co, Etx, distC_S, Min_Energy, first_dead, spoints);
                    hop_count(event_counter)=hop_count(event_counter)+1;
                    route{event_counter}(hop_count(event_counter))=current.suid;
                    %fprintf('inside CH block and foward to sink')
                    %current
                    break    
              else
                    
                    CG= setdiff(current.Neighbors, clusters{current.cid});%SET OF CANDIDATE GATEWAY NODES 
                    CG= setdiff(CG, route{event_counter}); %DATA PACKET DOESNT GET TRANSMITTED TO THE NODES 
                                                           %THAT ARE ALREADY IN ROUTE ARRAY
                    if(numel(CG) ==0)
                        %FORWARD TO PACKET FORWARDER NODE%
                        [current, node, first_dead, stop_flag, packets_dropped]= forward_to_packet_forwarder(clusters, current, spoints, node, first_dead, packets_dropped, CG, Min_Energy, data_packet, cltr_packet, Eda, Etx, Erx, Co, route, event_counter);
                        if(stop_flag==1)
                            %drop_packets
                            %packets_dropped= packets_dropped+1;
                            break
                        end
                        hop_count(event_counter)=hop_count(event_counter)+1;
                        route{event_counter}(hop_count(event_counter))=current.suid;
                        CG= setdiff(current.Neighbors, clusters{current.cid});
                        CG= setdiff(CG, route{event_counter});
                        %fprintf('inside CH block and foward to PF')
                        %current
                    end
                    %FORWARD TO GATEWAY NODE%
                    
                    [current, node, first_dead, packets_dropped]= forward_to_gateway_node(spoints, node, current, Etx, Erx, Eda, Co, data_packet, cltr_packet, first_dead, packets_dropped, CG, Min_Energy, event_counter);
                    %fprintf('inside CH block and foward to gateway')
                    %current
                    
              end     
        end

        hop_count(event_counter)=hop_count(event_counter)+1;  
        route{event_counter}(hop_count(event_counter))=current.suid;
        
        for i=1:spoints
            sEnergy(i)=node(i).Energy;
        end
        for i=1:length(clusters)
            node(clusters_head(i)).type='CM';
            clusters_head(i)= update_clusters_head(clusters{i}, sEnergy, Neighbor_Count, su, s_xloc, s_yloc, sink_xloc, sink_yloc);
            node(clusters_head(i)).type='CH';
            for k=1:length(clusters{i})
                node(clusters{i}(k)).CH=clusters_head(i);
            end
        end
        %clusters_head'        
    end
end
end