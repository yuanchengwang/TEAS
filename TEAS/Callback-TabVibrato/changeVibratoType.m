function changeVibratoType(hObject,eventData)
%change the type of pitch fluctuation techniques: vibrato, trill, bending
global data;
if isfield(data,'vibratos')
    data.vibratos(data.numViratoSelected,4)=data.VibratoType.Value;
end
end