function [onset,max_energy]=onsetEnergyCorrect(onset,energy)
max_energy=onset;
onset_tmp=onset;
onset_tmp(length(onset)+1)=length(energy)-1;
for i=1:length(onset)
energy_tmp=energy(onset_tmp(i)+1:onset_tmp(i)+round((onset_tmp(i+1)-onset_tmp(i))/2)+1);
[max_energy(i),max_pos]=max(energy_tmp);
onset(i)=onset(i)+max_pos-1;%get the max point
for j=1:10%10 at most,0.05 s for resolution
   if energy(min(max(1,onset(i)+max_pos-j),length(energy)))<=0.95*max_energy
       onset(i)=onset(i)+max_pos-j;
       break
   end
end
end
end