function changeTremoloType(hObject,eventData)
%change the type of strumming: strumming, arpeggio, multiple plucks
global data;
if isfield(data,'candidateNote')
    data.candidateNote(data.numTremoloSelected,4)=data.TremoloType.Value;
end
end