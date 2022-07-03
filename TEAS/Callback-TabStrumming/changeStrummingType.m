function changeStrummingType(hObject,eventData)
%change the type of strumming: strumming, arpeggio, multiple plucks
global data;
if isfield(data,'strummings')
    data.strumPara{data.numStrummingSelected,4}=data.StrummingType.Value;
    data.strummings(data.numStrummingSelected,4)=data.StrummingType.Value;
end
end