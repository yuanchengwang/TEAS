function playAudioFn(hObject,eventData,param)
%PLAYVIBRATOFUNCTION Play feature audio.
%   Detailed explanation goes here
    global data;
    currentTabName = data.tgroup.SelectedTab.Title;
    if param == 1
        if strcmp(currentTabName,'Read Audio')
            %play the whole audio
            startPoint = 1;
            endPoint = length(data.audio);
            axeFeature = data.axeWave;
            featureAudio = data.audio(startPoint:endPoint);
        elseif strcmp(currentTabName,'Note Detection') 
            startPoint = round(data.notes(data.numNoteSelected,1) * data.fs);
            endPoint = round(sum(data.notes(data.numNoteSelected,1:2))* data.fs);
            %axeFeature = data.axePitchTabNoteIndi;
            featureAudio = data.Cleaned_speech(startPoint:endPoint);
        elseif strcmp(currentTabName,'Vibrato Analysis')
            startPoint = round(data.vibratos(data.numViratoSelected,1) * data.fs);
            endPoint = round(data.vibratos(data.numViratoSelected,2) * data.fs);
            %axeFeature = data.axePitchTabVibratoIndi;
            featureAudio = data.Cleaned_speech(startPoint:endPoint);
        elseif strcmp(currentTabName,'Sliding Analysis')
            startPoint = round(data.portamentos(data.numPortamentoSelected,1) * data.fs);
            endPoint = round(data.portamentos(data.numPortamentoSelected,2) * data.fs);     
            %axeFeature = data.axePitchTabPortamentoIndi;
            featureAudio = data.Cleaned_speech(startPoint:endPoint);
        elseif strcmp(currentTabName,'Tremolo Analysis')
            startPoint = round(data.candidateNote(data.numTremoloSelected,1) * data.fs);
            endPoint = round(data.candidateNote(data.numTremoloSelected,2) * data.fs);     
            %axeFeature = data.axePitchTabPortamentoIndi;
            if data.speedvalue.Value==1
                featureAudio = data.Cleaned_speech(startPoint:endPoint);
            else%change the speed and keep the key
                featureAudio = stretchAudio(data.Cleaned_speech(startPoint:endPoint),data.speedvalue.Value,"Method","wsola");
                %"Method","wsola" better fidelity but more computational
                %comsumption,difference cannot be found for a short snippet of tremolo and good .
            end
        elseif strcmp(currentTabName,'Multitrack+MIDI')
            %play the whole audio
            if isfield(data,'denoisedWaveTrack')
                for p=1:data.track_nb+1
                    if data.CB.MIDIDenoisedWave{p}.Value
                        if p<=length(data.denoisedWaveTrack)
                            if ~isempty(data.denoisedWaveTrack{p})   
                                    featureAudio=data.denoisedWaveTrack{p};
                                    break
                            else
                                msgbox('No audio input for this track.')
                                return
                            end
                        else
                            msgbox('No audio input for this track.')
                            return
                        end
                    end
                end
            else
                msgbox('No audio input for this track.')
                return
            end
            axeFeature = data.axeTabSynMIDI;
        end
    elseif param == 2
        featureAudio = data.Cleaned_speech;
        if strcmp(currentTabName,'Read Audio')   
            axeFeature = data.axedenoisedWave;
        elseif strcmp(currentTabName,'Pitch detection')        
            axeFeature = data.axePitchWave;
        end
    end
    
    data.audioFeaturePlayer = audioplayer(featureAudio,data.fs);
    
    %setup the timer for the audioplayer object
%     data.audioFeaturePlayer.TimerFcn = {@plotAudioMarker, data.audioFeaturePlayer,data.fs, axeFeature}; % timer callback function (defined below)
%     data.audioFeaturePlayer.TimerPeriod = 0.01; % period of the timer in seconds
%     set(data.audioFeaturePlayer,'TimerPeriod',128/44000,'TimerFcn',{@plotBar,axeFeature.get('Ylim'),axeFeature});

    %The progress bar is displayed in the 'Read Audio' and  'Pitch detection'
    if strcmp(currentTabName,'Read Audio')||strcmp(currentTabName,'Pitch detection') ||strcmp(currentTabName,'Multitrack+MIDI')
        set(data.audioFeaturePlayer,'TimerPeriod',128/44000,'TimerFcn',{@plotBar,axeFeature.get('Ylim'),axeFeature});%,'StopFcn',@stopbar);
        data.audioFeaturePlayer.StopFcn
    end
    play(data.audioFeaturePlayer);
end

