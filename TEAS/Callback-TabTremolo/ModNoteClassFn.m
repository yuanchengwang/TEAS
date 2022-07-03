function ModNoteClassFn(hObject,eventData)
%MODNOTECLASSFN 
global data;
if isfield(data,'tremolos')
    data.NoteClass(data.numTremoloSelected)=1-data.NoteClass(data.numTremoloSelected);%0->1,1->0;
    plotTremoloStatistics(data.textTremolo,data.tremoloPara(:,data.NoteClass),data.numTremoloSelected);
end
end