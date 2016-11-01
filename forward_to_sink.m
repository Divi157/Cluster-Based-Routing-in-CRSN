function [current, node, first_dead, Min_Energy]= forward_to_sink(current, node, data_packet, cltr_packet, Eda, Co, Etx, distC_S, Min_Energy, first_dead, spoints)
    current.Energy= current.Energy- (data_packet * Eda)- (data_packet * (Co * Etx * (distC_S^2) ));
    node(current.suid)=current;
    if(current.Energy <= Min_Energy)
       first_dead=1;
       for i=1:spoints
            node(i).Energy= node(i).Energy-(cltr_packet * Etx);
       end
    end
    current= node(spoints+1);
    
end