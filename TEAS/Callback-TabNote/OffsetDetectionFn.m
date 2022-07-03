function OffsetDetectionFn(hObject,eventData)
%OFFSETDETECTIONFN run the offset detection only
global data;
if ~isfield(data,'onset')
    msgbox('Please run onset detection before offset detection.');
    return
end
%segment: pitch tail 
tau=10;
zero_position=data.pitch>0;
diff_zeros_position=diff(zero_position);
down=find(diff_zeros_position==-1);
up=find(diff_zeros_position==1)+1;
if zero_position(1)==1
    segment(1,1)=1;
    segment(2:1+length(up),1)=up;
else
    segment(:,1)=up;
end
if zero_position(end)==1
    segment(1:length(down),2)=down;
    segment(length(down)+1,2)=length(zero_position);
else
    segment(:,2)=down;
end
%tau=ceil(threshold/(time(2)-time(1)));
segment=segment(diff(segment,[],2)>=tau,:);%eliminate the note too short
offset_tail=round(data.pitchTime(segment(:,2))*data.fs/data.hop_length);
last=min(length(data.energy),round(data.pitchTime(end)*data.fs/data.hop_length));
if data.double_peak
    onset=data.onset(2:2:end);%energy与logenergy长度与不一样的问题！
    if length(onset)>=2
        onset2=data.onset(3:2:end);
    else
        onset2=[];
    end
    onset2=[onset2,last];
else
    onset=data.onset;
    onset2=[data.onset(2:end),last];
end
for j=1:length(offset_tail)
    for i=1:length(onset)    
        if offset_tail(j)>onset(i) && offset_tail(j)<onset2(i)
            onset2(i)=offset_tail(j);
            break
        end
    end
end
velocity_estimation([]);
velocity=data.velocity_fine*data.offset_threshold;
data.offset=zeros(1,length(onset));
for i=1:length(onset)
    area=data.energy(onset(i):onset2(i))<=velocity(i);
    offset_candidate=find(diff(area)==1);
    if isempty(offset_candidate)
        data.offset(i)=onset2(i);
    else
        data.offset(i)=offset_candidate(end)+onset(i);
    end
end
%display only the non-overlap offset.
if isfield(data,'patchFeaturesPoint')
    delete(data.patchFeaturesPoint);
end
if data.OnsetOffsetMethodChange.Value~=4
    data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.EdgeTime(1:end-1),data.axeOnsetOffsetStrength);%data.HD_offset_new
else
    data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.log_energy_time,data.axeOnsetOffsetStrength);%data.HD_offset_new
end
end
