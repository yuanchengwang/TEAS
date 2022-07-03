function importPitchCurveFn(hObject,eventData)
%IMPORTPITCHCURVEFN import the pitch curve
%   Detailed explanation goes here
    global data;
    %input pitch curve
    [fileNameSuffix,filePath] = uigetfile({'*.csv';'*.txt'},'Select File');
    if isnumeric(fileNameSuffix) == 0
        
        %if the user doesn't cancel, then read the pitch curve
        fullPathName = strcat(filePath,fileNameSuffix);
        
        %pitchData is the matrix in the file
        pitchData = importdata(fullPathName);
        if strcmp(data.tgroup.SelectedTab.Title,'Pitch Detection')
            data.pitchTime = pitchData(:,1);
            data.pitch = pitchData(:,2);
            %zero padding if the pitch time doesn't increase continuously
            [data.pitch,data.pitchTime]=modify_pitch(data.pitch,data.pitchTime);
            if isfield(data,'onset')
                data=rmfield(data,'onset');
            end
            if isfield(data,'offset')
                data=rmfield(data,'offset');
            end
            plotClearFeature('Note');
            if isfield(data,'NoteOnset')
                data = rmfield(data,'NoteOnset');
                data = rmfield(data,'NoteDuration');
                data = rmfield(data,'avgPitch');
                if isfield(data,'fret')
                    data = rmfield(data,'fret');
                end
            end
            %clear vibrato
            plotClearFeature('Vibrato');
            if isfield(data,'FDMoutput')
                data = rmfield(data,'FDMoutput');
            end
            if isfield(data,'PERoutput')
                data = rmfield(data,'PERoutput');
            end
            %clear portamento
            plotClearFeature('Portamento');
            plotPitch(data.pitchTime,data.pitch,data.axePitchTabAudio,1,1);
            plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,1);%data.EdgePitch=
            plotPitch(data.pitchTime,data.pitch,data.axePitchTabVibrato,0,1);
            plotPitch(data.pitchTime,data.pitch,data.axePitchTabPortamento,0,1);
            if data.CB.plot_audio.Value
                data.plotEdgeWave=plotAudio((1:size(data.Cleaned_speech,1))/data.fs,data.Cleaned_speech,data.axeOnsetOffsetStrength,data.NoisefileNameSuffix,1); 
            end
        else%synthesis+MIDI mono
            currentname=data.subgroup.SelectedTab.Title;
            p=str2num(currentname(isstrprop(currentname,'digit')));  
            data.PitchTimeTrack{p}=pitchData(:,1);
            data.PitchTrack{p}=pitchData(:,2);
        end
    end
end
        
    

