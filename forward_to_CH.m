function [current, node, first_dead, packets_dropped]= forward_to_CH(spoints, node, current, Etx, Erx, data_packet, cltr_packet, first_dead, Co, packets_dropped, Min_Energy, event_counter)

    
    distance= getDistance(current.x, current.y, node(current.CH).x, node(current.CH).y); %DISTANCE B/W CURRENT NODE AND CORREPONDING CLUSTER'S CH
    current.Energy= current.Energy- (data_packet * (Co * Etx * (distance^2) )); %SOME ENERGY IS CONSUMED IN TRANSMITTING DATA PACKET
    node(current.suid)=current;
    if(current.Energy <= Min_Energy) %IF CURRENT NODE(TRANSMITTING ONE) IS DEAD
        first_dead=1;
        for i=1:spoints
            node(i).Energy= node(i).Energy-(cltr_packet * Etx);
        end
        return
    end
    
    current= node(current.CH); %CLUSTER HEAD IS NOW CURRENT NODE
    current.Energy= current.Energy- (data_packet * (Co * Erx * (distance^2) )); %SOME ENERGY IS CONSUMED IN RECEIVING DATA PACKET
    node(current.suid)=current;
    if(current.Energy <= Min_Energy) %IF CURRENT NODE(RECEIVING ONE) IS DEAD
        first_dead=1;
        packets_dropped(event_counter)= packets_dropped(event_counter)+1; %PACKET IS DROPPED AS CURRENT NODE IS DEAD NOW
        for i=1:spoints
            node(i).Energy= node(i).Energy-(cltr_packet * Etx);
        end
        return
    end
    
end