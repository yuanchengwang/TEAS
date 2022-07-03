function getTremoloFn(hObject,eventData)
%getTremoloFn Get the tremolo annotation
%   The tremolo annotation file should be [start(s):end(s):duration(s)]
    global data;   
    if ~isfield(data,'candidateNote') || ~isfield(data,'Cleaned_speech')
        msgbox('No candidate note or no cleaned speech.');
        return
    end
    %plotClearFeature('Tremolo')
    tremolo_estimation(1);%output data.tremolosPara
    
    axes(data.axeWaveTabTremoloIndi);
    y=data.axeWaveTabTremoloIndi.YLim;
    if isfield(data,'patchTremoloOnset')
        delete(data.patchTremoloOnset);
        data=rmfield(data,'patchTremoloOnset');
    end
    data.numTremoloSelected=1;
    onset=data.onset_tremolo{data.numTremoloSelected};
    for j=1:length(onset)
        data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red');             
    end
    %plot the envelope
    time=data.candidateNote(data.numTremoloSelected,1:2);%onset+offset in a note
    timerange=round(time(1)*data.fs):round(time(end)*data.fs);
    time1=timerange/data.fs;
    audio=data.Cleaned_speech(timerange);
    xAxis = get(data.tremoloXaxisPara,'Value');
    if xAxis == 2%normalized time
        time1=time1-time1(1);
    end
    cla(data.axeWaveTabTremoloIndi);
    plotAudio(time1,audio,data.axeWaveTabTremoloIndi,data.NoisefileNameSuffix,0);
    if isfield(data,'patchTremoloOnset')
        delete(data.patchTremoloOnset);
        data=rmfield(data,'patchTremoloOnset');
    end
    if ~isempty(data.onset_tremolo{data.numTremoloSelected})
        y=data.axeWaveTabTremoloIndi.YLim;
        if isfield(data,'patchTremoloOnset')
            delete(data.patchTremoloOnset);
            data=rmfield(data,'patchTremoloOnset');
        end
        onset=data.onset_tremolo{data.numTremoloSelected};
        if data.tremoloXaxisPara.Value==2
            onset=onset-data.candidateNote(data.numTremoloSelected,1);
        end
        for j=1:length(onset)
            data.patchTremoloOnset(j) = line([onset(j),onset(j)],y,'color','red');             
        end
        hold on;
        if data.changeTremoloMethod.Value~=1
            [~,a]=min(abs(data.EdgeTime-time(1)));
            [~,b]=min(abs(data.EdgeTime-time(2)));
            data.patchTremoloOnset(length(onset)+1)=plot(data.EdgeTime(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
        else
            [~,a]=min(abs(data.log_energy_time-time(1)));
            [~,b]=min(abs(data.log_energy_time-time(2)));     
            data.patchTremoloOnset(length(onset)+1)=plot(data.log_energy_time(a:b),data.onset_env_tremolo(a:b)*y(2),'color','green');
        end
        hold off;
    end
    %Show the tremolo parameters in statistics tab.
    for i=1:length(data.treParaName)
        data.textTremolo(i,1).String=num2str(data.tremoloPara{data.numTremoloSelected,i});
    end 
    
    %Show the types of tremolo
    data.tremoloListBox.Value=data.numTremoloSelected;
    data.TremoloType.Value=data.candidateNote(data.numTremoloSelected,5);    
    %plotAudio(time,audio,data.axeWaveTabTremoloIndi,data.NoisefileNameSuffix,0);
    %close(h);
end    


