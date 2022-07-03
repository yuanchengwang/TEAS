function addNoteFn(hObject,eventData)
%ADDNOTEFN Add note
    global data;
    %binary variable show whether the new added note is valid or not
    %1: valide, 0: not valid
    validNewNote = 1;    
    rect = getrect(data.axeOnsetOffsetStrength);
    
    newNoteStart = rect(1);
    newNoteEnd = rect(1) + rect(3);
    
    %----START of new note validation---------------
    if isfield(data,'NoteOnset')
        %check the partialy overlapping with exising notes
        for i = 1:size(data.notes,1)
           if (validNewNote == 1) && (newNoteStart >= round(data.NoteOnset(i),3) && newNoteStart <= round(data.NoteOnset(i)+data.NoteDuration(i),3)) ||...
                   (newNoteEnd >= round(data.NoteOnset(i),3) && newNoteEnd <= round(data.NoteOnset(i)+data.NoteDuration(i),3))
               validNewNote = 0;
               uiwait(msgbox('The new note is overlapping exisiting notes!','Warning!','Error'));
               return;
           end
        end

        %check whether it is out of the scope of the recording
        if (validNewNote == 1) && ((newNoteStart > length(data.Cleaned_speech)/data.fs) || ...
                (newNoteEnd < 0))%data.axeOnsetOffsetStrength.XLim(2)%data.axeOnsetOffsetStrength.XLim(1)
            validNewNote = 0;
            uiwait(msgbox('The new note must be within the recording!','Warning!','Error'));
            return;
        end
        
        %check whether the new added note is an area
        if (validNewNote == 1) && ((newNoteStart >= newNoteEnd))
            validNewNote = 0;
            uiwait(msgbox('The new note should be an area!','Warning!','Error'));
            return;
        end        
%     else
%         %if there is no note
%         validNewNote = 0;
%         uiwait(msgbox('Please run Pitch2Note button or import external notes before adding note.','Warning!','Error'));
%         return
    end
    %----END of new note validation---------------
    
    if validNewNote == 1
        if isfield(data,'onset') && isfield(data,'offset')
            if data.double_peak
                onset=data.onset(1:2:end)*data.hop_length/data.fs;
            else
                onset=data.onset*data.hop_length/data.fs;
            end
            offset=data.offset*data.hop_length/data.fs;
            ind=find(offset-newNoteEnd>0,1);
            newNoteEnd=offset(ind);
            ind=find(newNoteEnd-onset>0);
            newNoteStart=onset(ind(end));
        end
        %model=get(data.CB.auto_NoteEdge,'value');
        if isfield(data,'NoteOnset') == 1
            % add the new note into the note array
            [data.NoteOnset,index] = sort([data.NoteOnset;newNoteStart]);
            indexNewNote = find(index(:,1) == size(index,1));
            data.NoteDuration = [data.NoteDuration;newNoteEnd-newNoteStart];
            data.NoteDuration=data.NoteDuration(index);%duration order
            if isfield(data,'onset') %&& model
                if ~isempty(data.onset)
                    if size(data.onset,2)~=size(data.offset,2) && ~data.double_peak
                        uiwait(msgbox('Onset and offset numbers are not identical. The unaligned notes are kept.','Warning!','Error'));
                        return
                    else
                        if size(data.onset,2)/2~=size(data.offset,2) && data.double_peak
                        uiwait(msgbox('Onset and offset numbers are not identical. The unaligned notes are kept.','Warning!','Error'));
                        return
                        end
                        [NoteOnset_temp,NoteDuration_temp]=auto_alignment(data.NoteOnset,data.NoteDuration,data.onset,data.offset,round(0.03*data.fs/data.hop_length));
                        if sum(NoteDuration_temp<=0)>0
                            uiwait(msgbox('Bad onset/offset or notes detected. Alignment disabled.','Warning!','Error'));
                            return
                        else
                            data.NoteOnset=NoteOnset_temp;
                            data.NoteDuration=NoteDuration_temp;
                        end
                    end
                end
            end
            
            %add the time-pitch into the NoteDetail struct
            noteNames = fieldnames(data.NoteDetail);
            for i = size(data.NoteOnset,1):-1:indexNewNote + 1
               data.NoteDetail = setfield(data.NoteDetail,['passage',num2str(i)],getfield(data.NoteDetail, char(noteNames(i-1))));
            end
            timeNoteVector=[data.NoteOnset,data.NoteOnset+data.NoteDuration,data.NoteDuration];
            timePitchNewNote = getPassages(data.pitchTime,data.pitch,timeNoteVector(indexNewNote,:),0);
            data.NoteDetail = setfield(data.NoteDetail,['passage',num2str(indexNewNote)],timePitchNewNote.passage1);
    
            %-----START of calculating the new para-----------
            [~,temp_min]=min(abs(newNoteStart-data.pitchTime));
            [~,temp_max]=min(abs(newNoteEnd-data.pitchTime));
            temp_pitch=data.pitch(temp_min:temp_max);
            temp_pitch=temp_pitch(temp_pitch>0);
            data.avgPitch = [data.avgPitch;median(temp_pitch)];%mean->median
            data.avgPitch=data.avgPitch(index);
            data.fret=fret_estimation;
            data.notes=[data.notes;data.NoteOnset(indexNewNote),data.NoteDuration(indexNewNote),data.avgPitch(indexNewNote),data.fret(indexNewNote),0];
            data.notes=data.notes(index,:);
            %velocity_estimation([]);
            data.notes(index,5)=0;%data.velocity;%data.velocity;
            %-----END of calculating the new para-----------
        else
            %the new added note is the first note
            indexNewNote = 1;
            data.NoteOnset=newNoteStart; %duration
            data.NoteDuration=newNoteEnd-newNoteStart;
            %model=get(data.CB.auto_NoteEdge,'value');
            if isfield(data,'onset') %&& model
                if ~isempty(data.onset)
                    if size(data.onset,2)~=size(data.offset,2) && ~data.double_peak
                        msgbox('Onset and offset numbers are not identical. The unaligned notes are kept.');
                        return
                    else
                        if ~data.double_peak
                        [data.NoteOnset,data.NoteDuration]=auto_alignment(data.NoteOnset,data.NoteDuration,data.onset,data.offset,round(0.03*data.fs/data.hop_length_edge));
                        else
                            if size(data.onset,2)/2~=size(data.offset,2)                      
                                msgbox('Onset and offset numbers are not identical. The unaligned notes are kept.');
                                return
                            end
                            [data.NoteOnset,data.NoteDuration]=auto_alignment(data.NoteOnset,data.NoteDuration,data.onset(1:2:end),data.offset,round(0.03*data.fs/data.hop_length_edge));
                        end
                    end
                end
            end
            [~,temp_min]=min(abs(newNoteStart-data.pitchTime));
            [~,temp_max]=min(abs(newNoteEnd-data.pitchTime));    
            timeNoteVector=[data.NoteOnset,data.NoteOnset+data.NoteDuration,data.NoteDuration];
            data.NoteDetail = getPassages(data.pitchTime,data.pitch,timeNoteVector,0);
            %----START of getting note para-------
            temp_pitch=data.pitch(temp_min:temp_max);
            temp_pitch=temp_pitch(temp_pitch>0);
            data.avgPitch=mean(temp_pitch);
            data.fret=fret_estimation; 
            data.notes=[data.NoteOnset,data.NoteDuration,data.avgPitch,data.fret];
            velocity_estimation([]);
            data.notes=[data.notes,data.velocity];
            %-----END of calculating the new para-----------
        end

        data.numNoteSelected = indexNewNote;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %plot the new created note
        %add the new patch into patch list
        if isfield(data,'patchNoteArea')
            data=rmfield(data,'patchNoteArea');
        end
        %avgPitch=MidiToFreq(data.fret+data.str{data.track_index});
        data.patchNoteArea=plotNote(data.NoteOnset,data.NoteDuration,data.avgPitch,data.axeOnsetOffsetStrength);
        %data.patchNoteArea=plotNote(data.NoteOnset,data.NoteDuration,avgPitch,data.axeOnsetOffsetStrength);
        hold on;
        plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,0);
        hold off;
        %higlight the selected note
        plotHighlightFeatureArea(data.patchNoteArea,data.numNoteSelected,1);

        %plot the note num in the listbox
        plotFeatureNum(data.NoteOnset,data.noteListBox);

        %show the highlighted num of vibrato in vibrato listbox
        data.noteListBox.Value = data.numNoteSelected;

        %show thes vibrato's X(time) range in the edit text
        note=notename(round(freqToMidi(data.avgPitch(data.numNoteSelected))));
                    
        data.NoteXEdit.String=[num2str(data.NoteOnset(data.numNoteSelected)),'-',num2str(data.NoteOnset(data.numNoteSelected)+data.NoteDuration(data.numNoteSelected)),'+',note{1},'+',num2str(data.velocity(data.numNoteSelected))];
        
        %show individual note in the sub axes
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
    end
end

