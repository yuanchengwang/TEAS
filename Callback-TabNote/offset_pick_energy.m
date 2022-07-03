function offset=offset_pick_energy(onset,energy,max_energy,wait)
%Reference: The last 0.05*max
onset_tmp=onset;
onset_tmp(length(onset)+1)=length(energy);
offset=onset_tmp(2:end);%init
for i=1:length(onset)
    for j=1:max(onset_tmp(i+1)-onset_tmp(i)-wait,1)
        if energy(onset_tmp(i+1)-j)>=max_energy(i)*0.05%Threshold
            offset(i)=onset_tmp(i+1)-j;
            break
        end
    end
end
end
