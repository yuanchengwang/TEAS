function importNoteFn(hObject,eventData)
%IMPORTNOTEFN import the note data
%   Detailed explanation goes here
    global data;
    %input notes
    [fileNameSuffix,filePath] = uigetfile({'*.csv';'*.txt'},'Select File');
    if isnumeric(fileNameSuffix) == 0
        %if the user doesn't cancel, then read the note filepath
        fullPathName = strcat(filePath,fileNameSuffix);
        
        if strcmp(data.tgroup.SelectedTab.Title,'Note Detection')
            %pitchData is the matrix in the file
            data.notes = importdata(fullPathName);
            assert(size(data.notes,2)==3 || 4 || 5,'Bad format for the note file or no note in imported file.');
            data.NoteOnset = data.notes(:,1);
            data.NoteDuration = data.notes(:,2);
            data.avgPitch = data.notes(:,3);
            if size(data.notes,2)==3
                data.fret=fret_estimation;
                data.notes(:,4)=data.fret;
            end
            if size(data.notes,2)>3
                data.fret=data.notes(:,4);
            end
            if size(data.notes,2)==5
                data.velocity=data.notes(:,5);
            end
            %remove the note alignment
%             model=get(data.CB.auto_NoteEdge,'value');
%             if isfield(data,'onset') && model
%                 if ~isempty(data.onset)
%                     if size(data.onset,2)~=size(data.offset,2)
%                         msgbox('Onset and offset numbers are not identical. The unaligned notes are kept.');
%                         return
%                     else
%                         [NoteOnset_temp,NoteDuration_temp]=auto_alignment(data.NoteOnset,data.NoteDuration,data.onset,data.offset,round(0.03*data.fs/data.hop_length));
% %                         if sum(NoteDuration_temp<=0)>0
% %                             uiwait(msgbox('Bad onset/offset or notes detected. Alignment disabled.'));
% %                         else
%                             pos=(NoteDuration_temp>0);
%                             data.NoteOnset(pos)=NoteOnset_temp(pos);
%                             data.NoteDuration(pos)=NoteDuration_temp(pos);
% %                        end
%                     end
%                 end
%             end
            if isfield(data,'patchNoteArea')
                delete(data.patchNoteArea);
                data=rmfield(data,'patchNoteArea');
            end
            %avgPitch=MidiToFreq(data.fret+data.str{num2str(fullPathName(end-4))});
            %data.patchNoteArea=plotNote(data.NoteOnset,data.NoteDuration,avgPitch,data.axeOnsetOffsetStrength);
            data.patchNoteArea=plotNote(data.NoteOnset,data.NoteDuration,data.avgPitch,data.axeOnsetOffsetStrength);
            hold on;
            plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,0);
            hold off;
            %plot the Note number indices in the listbox
            plotFeatureNum(data.NoteOnset,data.noteListBox);

            %show individual note in the subaxis    
            data.numNoteSelected=1;%Initial indi
            data.NoteDetail=getPassages(data.pitchTime,data.pitch,[data.NoteOnset,data.NoteOnset+data.NoteDuration,data.NoteDuration],0);
            time=data.notes(data.numNoteSelected,1:2);
            timerange=round(time(1)*data.fs):round(sum(time)*data.fs);
            time=timerange/data.fs;
            if isfield(data,'Cleaned_speech')
                audio=data.Cleaned_speech(timerange);
                xAxis = get(data.noteXaxisPara,'Value');
                if xAxis == 2%normalized time
                    time=time-time(1);
                end
                plotAudio(time,audio,data.axePitchTabNoteIndi,data.NoisefileNameSuffix,1);
            end
            plotPitchFeature(data.NoteDetail,data.numNoteSelected,data.noteXaxisPara,data.axePitchTabNoteIndi);
            plotHighlightFeatureArea(data.patchNoteArea,data.numNoteSelected,1);

            %Parameter display area
            note=notename(round(freqToMidi(data.avgPitch(data.numNoteSelected))));
            data.NoteXEdit.String=[num2str(data.NoteOnset(data.numNoteSelected)),'-',num2str(data.NoteOnset(data.numNoteSelected)+data.NoteDuration(data.numNoteSelected)),'+',note{1}];
            if size(data.notes,2)~=5
                velocity_estimation([]);
                data.notes(:,5)=data.velocity;
            end
            data.NoteXEdit.String=[data.NoteXEdit.String,'+',num2str(data.velocity(data.numNoteSelected))];
            %Plot for tremolo
            %highlight the first notecandidate
            data.candidateNote=[data.notes(:,1),data.notes(:,1)+data.notes(:,2),data.notes(:,2),data.notes(:,3)];
            if isfield(data,'patchTremoloArea')
                delete(data.patchTremoloArea);
            end
            data.patchTremoloArea=plotFeaturesArea(data.candidateNote,data.axeWaveTabTremolo);
            data.numTremoloSelected = 1;
            plotHighlightFeatureArea(data.patchTremoloArea,data.numTremoloSelected,1);

            %plot the tremolo num in the listbox
            plotFeatureNum(data.candidateNote,data.tremoloListBox);

            %show the first portamento in tremolo listbox
            data.tremoloListBox.Value = data.numTremoloSelected;

            %show individual candidate notes in the sub axes
            if isfield(data,'patchWaveCandidateNotes')
                delete(data.patchWaveCandidateNotes);
                data=rmfield(data,'patchWaveCandidateNotes');
            end
            time=data.candidateNote(data.numTremoloSelected,1:2);
            timerange=round(time(1)*data.fs):round(time(end)*data.fs);
            time=timerange/data.fs;
            if isfield(data,'Cleaned_speech')
                audio=data.Cleaned_speech(timerange);
                xAxis = get(data.tremoloXaxisPara,'Value');
                if xAxis == 2%normalized time
                    time=time-time(1);
                end
                plotAudio(time,audio,data.axeWaveTabTremoloIndi,data.NoisefileNameSuffix,0);
            end
        else
            currentname=data.subgroup.SelectedTab.Title;
            p=str2num(currentname(isstrprop(currentname,'digit')));  
            notes=importdata(fullPathName);
            assert(size(notes,2)==3 || 4 || 5,'Bad format for the note file or no note in imported file.');
            
            if size(notes,2)==3 
                if isfield(data,'PitchTrack')
                    if p<=length(data.PitchTrack)
                        if isempty(data.PitchTrack{p})
                            fret=fret_estimation(p,notes,data.PitchTrack{p});
                            notes(:,4)=fret;
                        else
                            msgbox('Note features are too short, pitch track is required.');
                            return
                        end
                    else
                        msgbox('Note features are too short, pitch track is required.');
                        return
                    end
                else
                    msgbox('Note features are too short, pitch track is required.');
                    return
                end
            end
            if size(notes,2)<5
                notes(:,5)=velocity_estimation_syn(p,notes);
            end
            data.NoteTrack{p}=notes;
        end
    end
end
        
    

