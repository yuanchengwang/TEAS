function velocity=velocity_estimation_syn(p,notes)
%create velocity for all notes
    global data;
    if isfield(data,'denoisedWaveTrack')
        if isempty(data.denoisedWaveTrack{p})
            msgbox('No audio, velocity cannot be deduced.');
            return
        end
    else
        msgbox('No audio, velocity cannot be deduced.');
        return
    end
    audio=data.denoisedWaveTrack{p};
    L=floor((length(audio)-data.win_length)/data.hop_length);%RMS get from
    e=zeros(L,1);
    for i=1:L
        m=mean(audio((i-1)*data.hop_length+1:(i-1)*data.hop_length+data.win_length));
        e(i)=sum((audio((i-1)*data.hop_length+1:(i-1)*data.hop_length+data.win_length)-m).^2);
    end
    onset=round(notes(:,1)*data.fs/data.hop_length)-round(data.win_length/2/data.hop_length);
    %onset=max(,1);%the approximate frame index
    velocity=round(10*log10(e(onset)));

    %Normalization and discretization
    velocity=min(127,max(0,round(128/data.max_velocity*min(velocity,data.max_velocity))-1))';%-1 for encoding  
end