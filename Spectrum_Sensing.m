function su = Spectrum_Sensing(ppoints, spoints, p_xloc, p_yloc, s_xloc, s_yloc, pu_trans_range, channel_list)

su= cell(1, spoints);
% channel assigned to PUs 
    ch = randi([1 length(channel_list)],1,ppoints); %% matrix of 1-by-ppoints having elements in the interval of [1, length(channel_list)]
    for i = 1:ppoints
        pu_channel(i) = ch(i);
    end

%define communication protection radius of PUs
    R_pu = 2 * pu_trans_range;
    
% find the spectrum map of each SUs
     for i = 1:spoints
         su{i} = channel_list;
         for j = 1:ppoints
             distance = getDistance(s_xloc(i), s_yloc(i), p_xloc(j), p_yloc(j));
             if (distance<=R_pu)
                 unavailabe_channel = pu_channel(j);
                 su{i} = setdiff(su{i},unavailabe_channel);
             end
         end
        %disp(su{i});  % displays the spectrum map of each SU
     end
end