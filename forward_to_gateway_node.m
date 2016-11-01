function [current, node, first_dead, packets_dropped]= forward_to_gateway_node(spoints, node, current, Etx, Erx, Eda, Co, data_packet, cltr_packet, first_dead, packets_dropped, CG, Min_Energy, event_counter)
   %CG
    for m=1:length(CG)         
         dist_CG_to_its_CH= getDistance(node(node(CG(m)).CH).x, node(node(CG(m)).CH).y, node(CG(m)).x, node(CG(m)).y);
         dist_its_CH_to_sink= getDistance(node(node(CG(m)).CH).x, node(node(CG(m)).CH).y, node(spoints+1).x, node(spoints+1).y);
         %ASSIGNING WEIGHT TO CANDIDATE GATEWAY NODES
         CGNW(m)= (node(CG(m)).Energy)* length(intersect(node(CG(m)).specmap, current.specmap))* (1/(dist_CG_to_its_CH + dist_its_CH_to_sink)^2);
         %NODE WITH MAXIMUM WEIGHT IS SELECTED AS GATEWAY NODE  
         %m
         %CGNW
    end
    CGNW
    [mm, ii] = max(CGNW);
    G=CG(ii); %GATEWAY NODE HAS SUID AS 'G'
    %CURRENT NODE AGGREGATES AND FORWARDS THE DATA TO GATEWAY NODE
    distance= getDistance(current.x, current.y, node(G).x, node(G).y);
    current.Energy= current.Energy- (data_packet * Eda)- (data_packet * (Co * Etx * (distance^2) ));
    node(current.suid)=current;
    if(current.Energy <= Min_Energy)
        first_dead=1;
        for i=1:spoints
            node(i).Energy= node(i).Energy-(cltr_packet * Etx);
        end
    end
        
    current=node(G); % GATEWAY NODE IS NOW CURRENT NODE
    current.Energy= current.Energy- (data_packet * (Co * Erx * (distance^2) ));
    if(current.Energy <= Min_Energy)
        first_dead=1;
        %packets_dropped=packets_dropped+1;
        packets_dropped(event_counter)= packets_dropped(event_counter)+1;
        for i=1:spoints
            node(i).Energy= node(i).Energy-(cltr_packet * Etx);
        end
        return
    end      
end