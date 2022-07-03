function x=auto_adjust_edge(x,env)
    %sigma=0.05*data.fs/data.hop_length;
    %E=sum(abs(data.Cleaned_speech_spec),1); 
    %env=E(2:end).*data.onset_env.*gaussmf(1:length(data.onset_env),[sigma,x]);%
    %[~,x]=max(env);
    %find the local maxima
    sigma=5;%+-5
    [~,loc]=findpeaks(env(max(1,x-sigma):min(length(env),x+sigma)));
    [~,loc2]=min(abs(loc-1-sigma));
    x=x+loc(loc2)-sigma;
%else
%offset removed
%     %get the closest non-constraint peaks from offset-env, no peak ???
%     %step 1;get the possible area
%     ind=sum(x-data.onset>0);
%     TauB=round(0.03*data.fs/data.hop_length);
%     if ind==length(data.onset)
%         if data.onset(ind)+TauB<=length(data.offset_env)
%             offset_area=data.HD_offset_new(data.onset(ind)+TauB:length(data.offset_env)); %no last one
%         else
%             return%x=x
%         end
%     else
%         offset_area=data.HD_offset_new(data.onset(ind)+TauB:data.onset(ind+1)); 
%     end  
%     [~,b]=findpeaks(offset_area);
%     b=b-1+data.onset(ind)+TauB;
%     [~,ind2]=min(abs(b-x));
%     x=b(ind2);
end