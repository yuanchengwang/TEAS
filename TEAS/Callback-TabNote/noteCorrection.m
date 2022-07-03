function [onset,duration]=noteCorrection(onset,duration,onsetTime,offsetTime)
onset(1)=onsetTime(1);
j=2;
L=length(onset);
k=1;
if length(onset)>=2 && length(onsetTime)>=2
%onset modification to the pluck point
for i=2:L
    %if sum(onset(i)==onsetTime)~=1%slide的部分也未必要改
    if onset(i)>onsetTime(j)%notice may lose a note
        %a=find(onset(i)-onsetTime>0,1,'last');%the last before estimated onset(not correct)
        if j<length(onsetTime)
            if onset(i)>=onsetTime(j+1)%notice: there may lose a note
                onset(L+k)=onsetTime(j);
                duration(L+k)=offsetTime(j)-onsetTime(j);
                k=k+1;
            else
                b=onsetTime(j);
                duration(i-1)=min(duration(i-1),b-onset(i-1));%previous offset
                duration(i)=duration(i)+onset(i)-b;
                onset(i)=b; 
            end
            j=j+1;
        else%notice the sliding in last note
            if i>=2
                if onset(i-1)~=onsetTime(j)
                    b=onsetTime(j);
                    duration(i-1)=min(duration(i-1),b-onset(i-1));%previous offset
                    duration(i)=duration(i)+onset(i)-b;
                    onset(i)=b;
                end
            end
        end
    elseif onset(i)<onsetTime(j)%onset before pluck
        if onset(i)+duration(i)>onsetTime(j)%not sliding,rare
            duration(i)=onset(i)+duration(i)-onsetTime(j);
            onset(i)=onsetTime(j);
            if j<length(onsetTime)
                j=j+1;
            end
        else%sliding
            duration(i)=onsetTime(j)-onset(i);
         end      
    else
        if j<length(onsetTime)
            j=j+1;
        end
    end
end
end
[onset,order]=sort(onset);
duration=duration(order);
%correction for offset
j=1;
flag=[];
for i=1:length(onset)
    %if sum(onset(i)==onsetTime)~=1%slide的部分也未必要改
    if offsetTime(j)==onset(i)+duration(i)
        %a=find(onset(i)-onsetTime>0,1,'last');%the last before estimated onset(not correct)
%         b=offsetTime(j);
%         duration(i-1)=min(duration(i-1),b-onset(i-1));%previous offset
%         duration(i)=duration(i)+onset(i)-b;
%         onset(i)=b;
        if j<length(offsetTime)
            j=j+1;
        end
    elseif onset(i)+duration(i)<offsetTime(j)%onset before pluck
        if j<length(onset) && i<length(onset)
            if onset(i+1)<offsetTime(j)%sliding, 2 at most            
                duration(i)=onset(i+1)-onset(i);
                if duration(i)<=0.05
                    flag=[flag;i];
                    onset(i+1)=onset(i); 
                end
                duration(i+1)=offsetTime(j)-onset(i+1);
%                 if j<length(offsetTime)
%                     j=j+1;
%                 end
            else%not sliding
                duration(i)=offsetTime(j)-onset(i);
                if j<length(offsetTime)
                    j=j+1;
                end
            end  
        end
    else
        duration(i)=offsetTime(j)-onset(i);
        if j<length(offsetTime)
            j=j+1;
        end
%         if j<length(onsetTime)
%             j=j+1;
%         end
    end
end
if ~isempty(flag)
    onset(flag)=[];
    duration(flag)=[];
end
end