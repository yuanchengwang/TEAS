function modNoteFn(hObject,eventData)
%MODNOTEFN modify note
%   此处显示详细说明
    global data;
    
    %get the time range after the change
    note =  split(get(data.NoteXEdit,'String'),{'-','+'});
    modNoteStart = round(str2num(note{1}),3);
    modNoteEnd = round(str2num(note{2}),3);
    %modVe
    %get the sort of the modification note
    modIndex = data.numNoteSelected;
    
    
    %binary variable show whether the modified note is valid or not
    %1: valide, 0: not valid
    validModNote = 1;
  
    %-----START of modification note validation------
    %check the partly overlapping with exising notes
    if isfield(data,'NoteOnset') == 1
        if modIndex == 1 
            if length(data.NoteOnset)>=2
                if (validModNote == 1) && (modNoteEnd > data.NoteOnset(2))
                   validModNote = 0;
                   uiwait(msgbox(['The modification note is overlapping exisiting notes!',num2str(1)],'Warning!','Error'));               
                   return
                end
            end
        elseif modIndex == size(data.NoteOnset,1)
            if (validModNote == 1) && (modNoteStart < data.NoteOnset(modIndex-1)+data.NoteDuration(modIndex-1))
               validModNote = 0;
               uiwait(msgbox(['The modification note is overlapping exisiting notes!',num2str(2)],'Warning!','Error'));              
               return
            end
            
        %Note in the middle
        else
            for i = 1:size(data.NoteOnset,1)
               if (validModNote == 1) && (i<modIndex) && modNoteStart < round(data.NoteOnset(i)+data.NoteDuration(i),3)
                   validModNote = 0;
                   uiwait(msgbox(['The modification note is overlapping exisiting notes!',num2str(3)],'Warning!','Error'));
                   return
               elseif (validModNote == 1) && (i>modIndex) && (modNoteEnd > round(data.NoteOnset(i),3))
                   validModNote = 0;
                   uiwait(msgbox(['The modification note is overlapping exisiting notes!',num2str(4)],'Warning!','Error'));
                   return
               %the x range does not change
               elseif (validModNote == 1) && (i == modIndex) && (modNoteStart ==  round(data.NoteOnset(i),3)) && (modNoteEnd == data.NoteOnset(i)+data.NoteDuration(i))
                   validModNote = 1;
               end
            end
        end

        %check whether the modification note is an area
        if (validModNote == 1) && ((modNoteStart > modNoteEnd))
            validModNote = 0;
            uiwait(msgbox('The modification note should be an area!','Warning!','Error'));
            return
        end

        %check whether it is out of the scope of the recording
        if (validModNote == 1) && ((modNoteStart < data.axeOnsetOffsetStrength.XLim(1)) || ...
                (modNoteEnd > data.axeOnsetOffsetStrength.XLim(2)))
            validModNote = 0;
            uiwait(msgbox('The modification note should be within the recording!','Warning!','Error'));
            return
        end
                    
    else
        %if there is no note
        validModNote = 0;
        uiwait(msgbox('Please import the note or click pitch2note button before modifying note.','Warning!','Error'));
        return
    end
    %----END of modification vibrato validation---------------
    
    if validModNote == 1
        %modify the time-pitch into the vibratosDetail struct  
        %noteNames = fieldnames(data.NoteDetail);
        if data.velocity(modIndex)==str2num(note{4})%update the velocity by the onset
            velocity_estimation([]);
        else
            velocity_estimation(str2num(note{4}));
        end
        data.NoteOnset(modIndex)=modNoteStart;
        data.NoteDuration(modIndex)=modNoteEnd-modNoteStart;
        data.notes(modIndex,1:2)=[modNoteStart,data.NoteDuration(modIndex)];
        
        data.notes(modIndex,5)= str2num(note{4});
        timeNoteVector=[data.NoteOnset,data.NoteOnset+data.NoteDuration,data.NoteDuration];
        timePitchNewNote = getPassages(data.pitchTime,data.pitch,timeNoteVector(modIndex,:),0);
        data.NoteDetail = setfield(data.NoteDetail,['passage',num2str(modIndex)],timePitchNewNote.passage1);

        %-----START of calculating the modify para-----------        
        %modify the para in the para array
        old_pitch=notename(freqToMidi(data.notes(modIndex,3)));
        new_pitch=median(timePitchNewNote.passage1(:,2));%mean->median
        new_pitch_index=notename(freqToMidi(new_pitch));
        if strcmp(note{3},new_pitch_index{1})
            data.avgPitch(modIndex)=new_pitch;
            data.notes(modIndex,3)=new_pitch;
            data.notes(modIndex,4)=fret_estimation(NoteNameToMIDInotes(new_pitch_index(1)));
        else%update the para
            if strcmp(note{3},old_pitch{1})%if you don't change the pitch, overlap it with new pitch.
                data.avgPitch(modIndex)=new_pitch;
                data.notes(modIndex,3)=new_pitch;
                data.notes(modIndex,4)=fret_estimation(NoteNameToMIDInotes(new_pitch_index(1)));
            else%note different from both new and old note.
                data.avgPitch(modIndex)=MidiToFreq(NoteNameToMIDInotes(note(3)));%Approx average pitch from input.
                data.notes(modIndex,3)=data.avgPitch(modIndex);
                data.notes(modIndex,4)=fret_estimation(NoteNameToMIDInotes(note(3)));
            end
        end
        %-----END of calculating the new para-----------
        %delete the old vibrato(locally)
        if isfield(data,'patchNoteArea')
            delete(data.patchNoteArea);
        end
        data.patchNoteArea=plotNote(data.NoteOnset,data.NoteDuration,data.avgPitch,data.axeOnsetOffsetStrength);
        hold on;
        plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,0);
        hold off;
%         
         % modify the note into the note array
%         data.vibratos(modIndex,[1,2]) = [modVibratoStart,modVibratoEnd];
%         data.vibratos(:,3) = data.vibratos(:,2)-data.vibratos(:,1); %duration
        %plot the modified note
%         modPatchVibratoArea = plotNewFeatureArea(data.vibratos(modIndex,:),data.axePitchTabVibrato);
%         %modify the patch in patch list
%         data.patchVibratoArea(modIndex) = modPatchVibratoArea;
        
        %higlight the selected note
        plotHighlightFeatureArea(data.patchNoteArea,modIndex,1);
    
        %plot the note num in the listbox
        plotFeatureNum(data.NoteOnset,data.noteListBox);
        
        %show the highlighted num of notes in note listbox
        data.noteListBox.Value = modIndex;
        
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
        end
        plotPitchFeature(data.NoteDetail,data.numNoteSelected,data.noteXaxisPara,data.axePitchTabNoteIndi);
end


