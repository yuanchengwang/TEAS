function testParametersetting(hObject,eventData)
global data;
%track number test
assert(~isempty(data.track_nb),'Empty track number, please reset it in parametersetting.m.');
assert((fix(data.track_nb)==data.track_nb)&& (data.track_nb>=1),'The track number must be positive interger, please reset it in parametersetting.m.');
%track index test
assert(~isempty(data.track_index),'Empty track index, please reset it in parametersetting.m.');
assert((fix(data.track_index)==data.track_index)&& (data.track_index>=1)&& (data.track_index<=data.track_nb),'The track index must be positive interger, equal or less than the track number, please reset it in parametersetting.m.');
%String definition test
assert(~isempty(data.str),'The open string is empty, please reset it in parametersetting.m.');
assert(length(data.str)==data.track_nb,'The wrong size of open string or track number.');
for i=1:data.track_nb
   assert((fix(data.str{i})==data.str{i}) &&(data.str{i}>=20),'The open string must be positive interger greater than 20, please reset it in parametersetting.m.');
end