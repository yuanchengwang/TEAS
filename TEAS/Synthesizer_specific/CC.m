function output=CC(detail,bps,channel,range)
    %step=1/120;%(sec) default for midi pitch bend or CC resolution,
    %i.e. protocol.CC_resolution
    %1/8 is the default speed for cubase,
    %quantification in software
    %global data;
    %onset (beates), channel, command, value, onset(sec)
    global protocol;
    detailname=fieldnames(detail);
    output=[];
    for i=1:length(detailname)%for each segment of vibrato
        %L=size(tmp,1);
        %step_tmp=;%?
        tmp=getfield(detail,detailname{i});
        output_tmp=zeros(1,5);%size is fixed, only the range-level amplitude defined(not change with time within an interval) 
        output_tmp(1)=tmp(1,3)*bps;%onset(beat)%resampleinterp1(1:L,tmp(:,3),step_tmp)
        output_tmp(5)=tmp(1,3);
        output_tmp(2)=channel;%channel depends on the define
        %output_tmp(:,3)=output_tmp(:,3)/4*protocol.PB_range+protocol.PB_center;
        output_tmp(3)=1;%command
        L=size(output_tmp,1);
        t=2*tmp(end,3)-tmp(end-1,3);
        tmp(:,2)=freqToMidi(smooth(tmp(:,2),5));%slightly smooth and convert to MIDI value.
        tmp(:,2)=tmp(:,2)-floor(median(tmp(:,2)));
        extend=max(abs(tmp(:,2)));
        % This part is set by ranges
        output_tmp(4)=min(127,extend/range*127);%Fixed extend, max=1?%0-127 
        output_tmp(L+1,:)=[t*protocol.CC_resolution/60,1,1,0,t];
        output=[output;output_tmp];%注意:需要off时间？CC只有on没有off？最后的结果还需要对起始点归一化！
    end
end