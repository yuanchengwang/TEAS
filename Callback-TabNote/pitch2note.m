function pitch2note(hObject,eventData)
%PITCH2NOTE Note segmentation using pitch discretization using 3 HMM
%method(Baseline=pitch only,tony=pitch+boundaries,hierarchic structure=pitch+boundaries+trend)
global data;
if isfield(data,'pitch')
    h = waitbar(0,'Pitch2Note converting...');
     method=data.pitch2noteMethodChange.Value;
    if method==1%HMM baseline
        if ~isfield(data,'onset')
            [data.NoteOnset,data.NoteDuration,data.avgPitch]=hmm_baseline(data.pitch,data.pitchTime,h);
        else
             if ~isfield(data,'offset')
                [data.NoteOnset,data.NoteDuration,data.avgPitch]=hmm_baseline(data.pitch,data.pitchTime,h,data.onset);
             else
                [data.NoteOnset,data.NoteDuration,data.avgPitch]=hmm_baseline(data.pitch,data.pitchTime,h,data.onset,data.offset);
             end
         end
    elseif method==2%Tony pitch2note +boundaries refining
         if ~isfield(data,'onset') %|| data.CB.Auto_Edge.Value==0% Edge auto-adjustment must be active
            [data.NoteOnset,data.NoteDuration,data.avgPitch]=hmm_note(data.pitch,data.pitchTime,h);%,data.onset,data.offset);
         else
             if ~isfield(data,'offset')
                [data.NoteOnset,data.NoteDuration,data.avgPitch]=hmm_note(data.pitch,data.pitchTime,h,data.onset);
             else
                [data.NoteOnset,data.NoteDuration,data.avgPitch]=hmm_note(data.pitch,data.pitchTime,h,data.onset,data.offset);
             end
         end
%    else%Hierarchic HMM Reference, more states for pitch trends(future)
        %Luwei Yang, Akira Maezawa, Jordan B. L. Smith, Elaine Chew. PROBABILISTIC TRANSCRIPTION OF SUNG MELODY USING A PITCH DYNAMIC MODEL
%         if isfield(data,'onset')
%            [data.NoteOnset,data.NoteDuration,data.avgPitch]=hmm_structure(data.pitch,data.pitchTime,h);%,data.onset,data.offset);
%         else
%             msgbox('No boundaries to define the note, press onset/offset detection button or import edges.');
%             return
%         end
    end
    data.fret=fret_estimation; 
    data.notes=[data.NoteOnset,data.NoteDuration,data.avgPitch,data.fret];
%     velocity_estimation([]);
%     
    %Plotting for tabs
    if isfield(data,'patchNoteArea')
        delete(data.patchNoteArea);
    end
    if isempty(data.NoteOnset)
        disp('No note detected.');
        close(h);
        return
    end
    %avgPitch=MidiToFreq(data.fret+data.str{data.track_index});
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
    if isfield(data,'onset')
        velocity_estimation([]);
        data.notes=[data.notes,data.velocity];
    end
    if isfield(data,'Cleaned_speech')
        [~,time2_min]=min(abs(data.EdgeTime-time(1)));
        [~,time2_max]=min(abs(data.EdgeTime-time(end)));
        time2=time2_min:time2_max;
        audio=data.Cleaned_speech(timerange);
        energy=data.energy(time2);
        xAxis = get(data.noteXaxisPara,'Value');
        if xAxis == 2%normalized time
            time=time-time(1);
            time2=time2-time2(1);
        end
        plotAudio(time,audio,data.axePitchTabNoteIndi,data.NoisefileNameSuffix,1);
        %figure(3);
%         hold on;
%         axes(data.axePitchTabNoteIndi);
%         plot(time2,energy/data.win_length);%
%         hold off;
    end
    plotPitchFeature(data.NoteDetail,data.numNoteSelected,data.noteXaxisPara,data.axePitchTabNoteIndi);
    plotHighlightFeatureArea(data.patchNoteArea,data.numNoteSelected,1);
    %Parameter display area
    note=notename(round(freqToMidi(data.avgPitch(data.numNoteSelected))));
    
    data.NoteXEdit.String=[num2str(data.NoteOnset(data.numNoteSelected)),'-',num2str(data.NoteOnset(data.numNoteSelected)+data.NoteDuration(data.numNoteSelected)),'+',note{1},'+',num2str(data.velocity(data.numNoteSelected))];
    close(h);
else
    msgbox('No pitch/boundary input.');
end
end
