function output=pitch_bend(detail,bps)
    %step=1/120;%(sec) default for midi pitch bend or CC resolution,
    %i.e. protocol.CC_resolution
    %1/8 is the default speed for cubase,
    %quantification in software
    detailname=fieldnames(detail);
    output=[];
    for i=1:length(detailname)%for each segment of vibrato
        %L=size(tmp,1);
        %step_tmp=;%?
        tmp=getfield(detail,detailname{i});
        output_tmp=zeros(size(tmp,1),4);
        output_tmp(:,1)=tmp(:,3)*bps;%only the real time%resampleinterp1(1:L,tmp(:,3),step_tmp)
        output_tmp(:,2)=ones(size(tmp,1),1);%channel=1, no other channel
        %output_tmp(:,3)=output_tmp(:,3)/4*protocol.PB_range+protocol.PB_center;
        output_tmp(:,4)=tmp(:,3);
        L=size(output_tmp,1);
        t=2*tmp(end,3)-tmp(end-1,3);
        tmp(:,2)=smooth(tmp(:,2),5);%slightly smooth
        %tmp(:,2)=freqToMidi(smooth(tmp(:,2),5));
        ref=MidiToFreq(floor(freqToMidi(median(tmp(:,2)))));
        output_tmp(:,3)=tmp(:,2)/ref;%fraction is required, normalized by the first sample,it works for pitch fluctuation techniques.
        output_tmp(L+1,:)=[t*bps,1,1,t];%
        output=[output;output_tmp];%注意:需要off时间？CC只有on没有off？最后的结果还需要对起始点归一化！
    end
end