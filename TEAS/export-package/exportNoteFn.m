function exportNoteFn(hObject,eventData)
%EXPORTNOTEFN export the notes with [onset,duration,pitch,fret]
%   Detailed explanation goes here
    global data;
    global protocol;
    if ~isfield(data,'avgPitch')
        msgbox('No note detected. Please compute the note using pitch2note or import notes');
        return
    end
    if isfield(data,'fileName')
        savedFileName = data.fileName;
    else
        savedFileName = data.NoisefileName;%rewrite the input denoised file
    end
    savedFileName = [savedFileName,'_note_str',num2str(data.track_index)];
    savedFileType = {'*.csv','CSV file (*.csv)';'*.txt','Text file (*.txt)';'*.mid','MIDI file (*.mid)';};
    
    if strcmp(data.tgroup.SelectedTab.Title,'Note Detection')
%         NoteOnset=data.NoteOnset;
%         NoteDuration=data.NoteDuration;
%         avgPitch=data.avgPitch;
%         fret=data.fret;
%         velocity=data.velocity;
         NoteOnset=data.notes(:,1);
        NoteDuration=data.notes(:,2);
        avgPitch=data.notes(:,3);
        fret=data.notes(:,4);
        velocity=data.notes(:,5);
        p=data.track_index;
    else
        currentname=data.subgroup.SelectedTab.Title;
        p=str2num(currentname(isstrprop(currentname,'digit'))); 
        notes=data.NoteTrack{p};
        NoteOnset=notes(:,1);
        NoteDuration=notes(:,2);
        avgPitch=notes(:,3);
        fret=notes(:,4);
        velocity=notes(:,5);
    end
    %let user specify the path using modal dialog box
    [savedFileName,savedPathName] = uiputfile(savedFileType,'Save File Name',savedFileName);
    data.fret=fret_estimation;%The fret can be changed with the track setting
    if isnumeric(savedFileName) == 0
        %if the user doesn't cancel, then save the data
        if ~isempty(strfind(savedFileName,'.csv'))
            %save the pitch curve as csv
            %csvwrite([savedPathName,savedFileName],[data.NoteOnset,data.NoteDuration,data.avgPitch,data.fret]);
            dlmwrite([savedPathName,savedFileName],[NoteOnset,NoteDuration,avgPitch,fret,velocity],'precision','%.4f');
        elseif ~isempty(strfind(savedFileName,'.txt'))
                %save the pitch curve as txt
                fid = fopen([savedPathName,savedFileName],'w');
                for j = 1:size(NoteOnset,1)
                    fprintf(fid,[num2str(NoteOnset(j)),'	',num2str(NoteDuration(j)),'	',num2str(avgPitch(j)),'	',num2str(fret(j)),'	',num2str(velocity(j)),'\r\n']);
                end
                fclose(fid);
         else%MIDI,onset (beats), duration (beats), channel,
%       pitch, velocity, onset (sec), duration (sec)            
            if strcmp(data.tgroup.SelectedTab.Title,'Note Detection')
                if isfield(data,'onset_env')
                    bps=tempo_estimation(data.onset_env,protocol.resolution*data.beats_per_second)/60;
                else
                    msgbox('Please run onset detection before estimating the tempo.');
                    return
                end
            else
                if isfield(data,'denoisedWaveTrack')
                    if length(data.denoisedWaveTrack)==data.track_nb+1
                        flag=0;
                        if isfield(data,'onset_env_track')
                            if length(data.onset_env_track)==data.track_nb+1
                                onset_env=data.onset_env_track{data.track_nb+1};
                                flag=1;
                            end
                        end
                        if ~isempty(data.denoisedWaveTrack{data.track_nb+1}) && flag==0
                            audio=data.denoisedWaveTrack{data.track_nb+1};
                            spec=spect_onset(audio);
                            onset_env=sum(abs(spec(6:end,:)),1);
                            data.onset_env_track{data.track_nb+1}=onset_env;
                            flag=1;
                        end
                    end
                    if flag
                        bps=tempo_estimation(onset_env,protocol.resolution*data.beats_per_second)/60;
                    else
                        msgbox('No polyphonic audio imported to estimate tempo.');
                        return
                    end
                else
                    msgbox('No polyphonic audio imported to estimate tempo.');
                    return
                end
            end
            ansOnset = questdlg(['Warning: Accept the estimated tempo=',num2str(bps),'? If not please set data.beat_per_second for an initial tempo.'],'Attention','Yes','No','No');
            switch ansOnset
            case 'Yes'
                
            case 'No'
                return
            end
            midi.notes=[];
            midi.notes=[NoteOnset*bps,NoteDuration*bps,ones(size(NoteDuration)),round(freqToMidi(avgPitch)),velocity,NoteOnset,NoteDuration];
            if ~isempty(protocol.string_force)%String forcing for each note.
                sf=notename(protocol.string_force{p});
                if ~strcmp(protocol.midimode,'default')
                    sf{1}=sf{1}+12;
                    midi.notes=[midi.notes;NoteOnset*bps,NoteDuration*bps,ones(size(NoteDuration)),sf{1}*ones(size(NoteDuration)),protocol.resolution*ones(size(NoteDuration)),NoteOnset,NoteDuration];
                end
                %String forcing+default velocity for all external note protocol.resolution.
            end
            isp_midiwrite(midi,[savedPathName,savedFileName]);
         end
    end
end

