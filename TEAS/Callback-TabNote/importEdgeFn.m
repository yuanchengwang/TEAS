function importEdgeFn(hObject,eventData)
%IMPORTNOTEFN import the note data
%   Detailed explanation goes here
    global data;
    %input pitch curve
    [fileNameSuffix,filePath] = uigetfile({'*.csv';'*.txt'},'Select File');
    if isnumeric(fileNameSuffix) == 0
        %if the user doesn't cancel, then read the note filepath
        fullPathName = strcat(filePath,fileNameSuffix);
        
        %pitchData is the matrix in the file
        noteData = importdata(fullPathName);
        assert(size(noteData,2)<=3,'Bad format for the note file or no note in imported file.');
        if size(noteData,2)==1%offset
            ansOnset = questdlg('Warning: A single column found, Import onset points?','Attention','Yes','No','No');
            switch ansOnset
            case 'Yes'
                %assert(mod(length(data.onset),2)==0,'Onset number must be even.')
                data.onset = round(noteData(:,1)'/(data.hop_length/data.fs));
                if ~isfield(data,'offset')
                    data.offset=[];
                end
            case 'No'
                data.offset = round(noteData(:,1)'/(data.hop_length/data.fs));
                if ~isfield(data,'onset')
                    data.onset=[];
                end
            end
        else%onset(pluck+natural transient) 2 or 3
            if data.double_peak || size(noteData,2)==3
                data.onset=zeros(1,2*size(noteData,1));
                data.onset(1:2:end)=round(noteData(:,1)'/(data.hop_length/data.fs));
                data.onset(2:2:end)=round(noteData(:,2)'/(data.hop_length/data.fs));
                if ~isfield(data,'offset')
                    data.offset=[];
                end
                if size(noteData,2)==3%onset+offset
                    data.offset = round(noteData(:,3)'/(data.hop_length/data.fs));
                end
            else
               data.onset = round(noteData(:,1)'/(data.hop_length/data.fs));
               data.offset = round(noteData(:,2)'/(data.hop_length/data.fs));
            end
        end
        if isfield(data,'patchFeaturesPoint')
            delete(data.patchFeaturesPoint);
        end
        if isfield(data,'onset_env') && isfield(data,'offset_env')
            data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.EdgeTime(1:end-1),data.axeOnsetOffsetStrength);
        elseif isfield(data,'Cleaned_speech')
            model=get(data.OnsetOffsetMethodChange,'value');
            if ~isfield(data,'EdgeTime')
                [data.Cleaned_speech_spec,data.EdgeTime]=spect_onset(data.Cleaned_speech);
            end
            if isfield(data,'onset')
                [~,data.onset_env]=onset_detector(data.Cleaned_speech_spec,model); %data.EdgeTime
            else
                [data.onset,data.onset_env]=onset_detector(data.Cleaned_speech_spec,model);
            end
            if data.OnsetOffsetMethodChange.Value~=4
                data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.EdgeTime(1:end-1),data.axeOnsetOffsetStrength);
            else
                data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.onset_env,data.log_energy_time,data.axeOnsetOffsetStrength);
            end
        else
            data.patchFeaturesPoint=plotEdge(data.onset*data.hop_length/data.fs,data.offset*data.hop_length/data.fs,data.axeOnsetOffsetStrength);
        end
        %Remove the note alignment if existing, redo the pitch2note is better.
%         model=get(data.CB.auto_NoteEdge,'value');
%         model2=get(data.pitch2noteMethodChange,'value');        
%         if isfield(data,'NoteOnset') && model && model2==2
%             if ~isempty(data.onset)
%                 if size(data.onset,2)~=size(data.offset,2) && data.OnsetOffsetMethodChange.Value~=4
%                     uiwait(msgbox('Onset and offset numbers are not identical. The unaligned notes are kept.'));
%                     return
%                 else%redo the note detection if 
%                     [NoteOnset_temp,NoteDuration_temp]=auto_alignment(data.NoteOnset,data.NoteDuration,data.onset,data.offset,round(0.03*data.fs/data.hop_length));
%                     if sum(NoteDuration_temp<=0)>0
%                         uiwait(msgbox('Bad onset/offset or notes detected. Alignment disabled.'));
%                     else
%                         data.NoteOnset=NoteOnset_temp;
%                         data.NoteDuration=NoteDuration_temp;
%                     end  
%                 end
%            end
%           
%         if isfield(data,'patchNoteArea')
%             data=rmfield(data,'patchNoteArea');
%         end
%         data.patchNoteArea=plotNote(data.NoteOnset,data.NoteDuration,data.avgPitch,data.axeOnsetOffsetStrength);
%         hold on;
%         plotPitch(data.pitchTime,data.pitch,data.axeOnsetOffsetStrength,0,0);
%         hold off;
%         %plot the Note number indices in the listbox
%         plotFeatureNum(data.NoteOnset,data.noteListBox);
    end  
end
        
    

