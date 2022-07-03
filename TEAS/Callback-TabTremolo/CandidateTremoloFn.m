function CandidateTremoloFn(hObject,eventData)
%CANDIDATETREMOLOFn Select and plot the notes without the other playing
%techniques(Vibrato/Portamento).
    global data;
    if isfield(data,'PTfreeFeaturePlot')
        delete(data.PTfreeFeaturePlot);
    end
    if ~isfield(data,'notes')
        msgbox('Notes not detected');
        return
    end
    plotClearFeature('Tremolo')
    if isfield(data,'addTremolo_valid')
        data=rmfield(data,'addTremolo_valid');
    end
    if isfield(data,'vibratos') && isfield(data,'portamentos') && data.CB.PTfree.Value
        data.PTfreelist=eliminate_PT(data.notes,data.vibratos,data.portamentos);
        data.candidateNote=[data.notes(data.PTfreelist,1),sum(data.notes(data.PTfreelist,1:2),2),data.notes(data.PTfreelist,2),data.notes(data.PTfreelist,3),ones(sum(data.PTfreelist),1)];       
    else
        if data.CB.PTfree.Value
            msgbox('Vibrato or Sliding not detected, all notes plotted');
        end
        data.candidateNote=[data.notes(:,1),sum(data.notes(:,1:2),2),data.notes(:,2),data.notes(:,3),ones(size(data.notes,1),1)];
    end
    if isempty(data.candidateNote)
        disp('No candidate note detected.')
        return
    end
    
    if isfield(data,'tremoloPara')
        data=rmfield(data,'tremoloPara');
    end
    
    %data.candidateNote(:,2)=data.candidateNote(:,2)+data.candidateNote(:,1);
    data.patchTremoloArea=plotFeaturesArea(data.candidateNote,data.axeWaveTabTremolo);
    data.numTremoloSelected = 1;
    plotHighlightFeatureArea(data.patchTremoloArea,data.numTremoloSelected,1);

    %plot the tremolo num in the listbox

    plotFeatureNum(data.candidateNote,data.tremoloListBox);

    %show the first portamento in tremolo listbox
    data.tremoloListBox.Value = data.numTremoloSelected;

    %show individual candidate notes in the sub axes
    time=data.candidateNote(data.numTremoloSelected,1:2);
    timerange=round(time(1)*data.fs):round(time(end)*data.fs);
    time=timerange/data.fs;
    audio=data.Cleaned_speech(timerange);
    xAxis = get(data.tremoloXaxisPara,'Value');
    if xAxis == 2%normalized time
        time=time-time(1);
    end
    plotAudio(time,audio,data.axeWaveTabTremoloIndi,data.NoisefileNameSuffix,0);
    
    %clean the parameter texts and tremolo type
    data.TremoloType.Value=data.candidateNote(data.numTremoloSelected,5);
    if isfield(data,'tremoloPara')
    data=rmfield(data,'tremoloPara');
    end
    for i=1:length(data.treParaName)
        data.textTremolo(i,1).String=[];
    end 
end