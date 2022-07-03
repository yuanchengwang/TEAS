function [pitch,pitchTime]=modify_pitch(pitch,pitchTime)
pitch(isnan(pitch))=0;%convert the NaN to zeros
delta=diff(pitchTime);%
%T=length(pitch);
%delta(1)=128/44100;
delta1=abs(delta-delta(1));
a=(delta1>=delta(1));
if sum(a)~=0
b=round(delta1(a)/delta(1))-1;
c=find(a==1);
for i=1:length(b)  
    pitch=[pitch(1:c(i));zeros(b(i),1);pitch(c(i)+1:end)];
    pitchTime=[pitchTime(1:c(i));pitchTime(c(i))+delta(1).*(1:b(i))';pitchTime(c(i)+1:end)];
    if i~=length(b)
        c(i+1:end)=c(i+1:end)+b(i);
    end
end
end
% Fill the zeros if the pitch time doesn't start from 0.
% if pitchTime(1)~=0 
%     N=floor(pitchTime(1)/delta(1));
%     pitchTime=[pitchTime(1)-(N:-1:1)'*delta(1);pitchTime];
%     pitch=[zeros(N,1);pitch];
% end
end