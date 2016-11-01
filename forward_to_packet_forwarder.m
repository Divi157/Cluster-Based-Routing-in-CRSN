function [current, node, first_dead, stop_flag, packets_dropped]= forward_to_packet_forwarder(clusters, current, spoints, node, first_dead, packets_dropped, CG, Min_Energy, data_packet, cltr_packet, Eda, Etx, Erx, Co, route, event_counter)

stop_flag=0;
PF=[];
CPF= setdiff(clusters{current.cid}, current.suid); % SET OF CANDIDATE PACKET FORWARDER NODE
CPF= setdiff(CPF, route{event_counter});
       while (numel(CG) == 0)  % TILL CANDIDATE GATEWAY SET IS EMPTY
             CPF= setdiff(CPF, PF); % CANDIDATE PACKET FORWADER SET
             if (numel(CPF) == 0)
                 stop_flag=1;
                 %packets_dropped=packets_dropped+1;
                 packets_dropped(event_counter)= packets_dropped(event_counter)+1;
                 return
             end
             PFNW=[];
             for l=1:length(CPF)
                 PFNW(l)= (node(CPF(l)).Energy)* length(node(CPF(l)).Neighbors) * length(node(CPF(l)).specmap);
             end
             [mm, ii] = max(PFNW);
             PF=CPF(ii);
        
             CG= setdiff(node(PF).Neighbors, clusters{node(PF).cid}); %UPDATED CANDIDATE GATEWAY NODE SET
             CG= setdiff(CG, route{event_counter});
       end  
        distance= getDistance(current.x, current.y, node(PF).x, node(PF).y);
        current.Energy= current.Energy- (data_packet * Eda)- (data_packet * (Co * Etx * (distance^2) ));
        node(current.suid)=current;
        if(current.Energy <= Min_Energy)
            first_dead=1;
            for i=1:spoints
                node(i).Energy= node(i).Energy-(cltr_packet * Etx);
            end
            return
        end
        current= node(PF); %PACKET FORWADER NODE IS NOW CURRENT NODE
        current.Energy= current.Energy- (data_packet * (Co * Erx * (distance^2) ));
        node(current.suid)=current;
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