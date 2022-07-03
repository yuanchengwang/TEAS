function rdbn(hObject,eventData,selectNb)
% RDBN to set the value of the radio buttons
global data;
track=4;
for i=1:track
   if i==selectNb
      data.bn.radiobn{i}.Value=1;
   else
      data.bn.radiobn{i}.Value=0;
   end
end
data.selectedtrack=selectNb;
end