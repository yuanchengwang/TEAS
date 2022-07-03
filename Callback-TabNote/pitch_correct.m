function [midiPitchOriginal,segment]=pitch_correct(midiPitchOriginal,time,segment,onsetTime,offsetTime)
%flag=zeros(size(midiPitchOriginal));    
if ~isempty(offsetTime)
%     offsetTime=segment(:,2);
% else
    %modify the end of pitch curve segments 
    for i=1:size(segment,1)
        a=find(offsetTime>segment(i,2),1);
        if isempty(a)
            if offsetTime(end)>segment(i,1)
                segment(i,2)=offsetTime(end);
            else
                segment(i:end,:)=0;
                break
            end
        else
            if onsetTime(a)<segment(i,2)
                segment(i,2)=offsetTime(a);
            else
                if a>1
                    if offsetTime(a-1)>segment(i,1)
                        segment(i,2)=offsetTime(a-1);
                    else
                        segment(i,:)=0;
                    end
                else
                    segment(i,:)=0;
                end
            end
        end
    end
end
segment(segment(:,1)==0,:)=[];%delete the 0 line.
if size(segment,1)==1
    segment(1)=onsetTime(1);
else
seg_flag=zeros(size(segment,1),1);
segment(1)=onsetTime(1);
for i=2:size(segment,1)
    area=onsetTime(onsetTime>=segment(i-1,2) & onsetTime<segment(i,1));
    if ~isempty(area)
        %seg_flag(i)=0;
        segment(i,1)=area(1);
    else
        area=onsetTime(onsetTime>=segment(i,1) & onsetTime<segment(i,2));
        if ~isempty(area)
            segment(i,1)=area(1);
        else
            seg_flag(i)=1;
        end
    end
end
segment(logical(seg_flag),:)=[];
end
midiPitchOriginal=pitch_dilate(midiPitchOriginal,time,segment);
end