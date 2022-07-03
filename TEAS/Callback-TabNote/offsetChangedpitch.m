function pitchRaw=offsetChangedpitch(pitchRaw,time,onsetTime,offsetTime)
%extract the offset non-equal to onset
%global data;
flag=find(onsetTime(2:end)~=offsetTime(1:end-1)');%+1?
for i=1:length(flag)
    %if flag(i)~=
    [~,a]=min(abs(time-offsetTime(flag(i))));
    [~,b]=min(abs(time-onsetTime(flag(i)+1)));
    pitchRaw(a:b)=0;
end
end